import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/products.dart';

class ProductFormScreen extends StatefulWidget {
  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _priceFocusNode = FocusNode();
  final _descrptionFocusNode = FocusNode();
  final _imageURLFocusNode = FocusNode();
  final _imageURLController = TextEditingController();
  // Para acessar os dados do FORM
  final _form = GlobalKey<FormState>();
  // Mapa para adicionar os valores do formulário
  final _formData = Map<String, Object>();
  // Serve para controlar a ampulheta que indica que um produto está sendo cadastrado
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _priceFocusNode.dispose();
    _descrptionFocusNode.dispose();
    // Antes de limpar o foco, como ele tem um listener, o ideal é limpar ele
    // primeiro
    _imageURLFocusNode.removeListener(_updateImage);
    _imageURLFocusNode.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Para escutar quando o campo de URL perde ou recebe o foco
    // Este método exige uma função como parâmetro
    _imageURLFocusNode.addListener(_updateImage);
  }

// Chamado quando uma dependência desse objeto State é alterada
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Preenche o mapa com os dados do formulário somente se estiver vazio
    if (_formData.isEmpty) {
      // Recebendo o argumento, neste caso o produto vindo de product_item
      final product = ModalRoute.of(context).settings.arguments as Product;

      // Somente se for edição e receber o produto, se for adição não entra
      if (product != null) {
        // Inseridno os dados do produto recebido por argumento no mapa
        _formData['id'] = product.id;
        _formData['title'] = product.title;
        _formData['description'] = product.description;
        _formData['price'] = product.price;
        _formData['imageUrl'] = product.imageUrl;

        // Alterando o controller do campo de URL do formulário
        _imageURLController.text = _formData['imageUrl'];
      } else {
        _formData['price'] = "";
      }
    }
  }

  void _updateImage() {
    if (isValidImageUrl(_imageURLController.text)) {
      setState(() {});
    }
  }

  bool isValidImageUrl(String url) {
    bool startWithHttp = url.toLowerCase().startsWith('http://');
    bool startWithHttps = url.toLowerCase().startsWith('https://');
    bool endsWithPng = url.toLowerCase().endsWith('.png');
    bool endsWithJpg = url.toLowerCase().endsWith('.jpg');
    bool endsWithJpeg = url.toLowerCase().endsWith('.jpeg');

    print((startWithHttp || startWithHttps) &&
        (endsWithPng || endsWithJpg || endsWithJpeg));

    return (startWithHttp || startWithHttps) &&
        (endsWithPng || endsWithJpg || endsWithJpeg);
  }

  Future<void> _saveForm() async {
    /*
    Se qualquer um dos campos do FORM no método validator retornar algo
    diferente de NULL, o método _form.currentState.validate() retorna false
    */
    bool isValid = _form.currentState.validate();

    /*
     Se um dos métodos de validação retornar falso a partir daqui sai 
     da função _saveForm()
    */
    if (!isValid) {
      return;
    }

    // O método currentState.save() chama o método onSave() em cada campo
    _form.currentState.save();
    final product = Product(
      id: _formData['id'],
      title: _formData['title'],
      description: _formData['description'],
      price: _formData['price'],
      imageUrl: _formData['imageUrl'],
    );
    // Antes de começar a salvar o produto mostra a ampulheta
    setState(() {
      _isLoading = true;
    });

    /*
    Precisamos colocar listen como false pois o Provider não está em uma
    árvore de componentes, o que irá tentará escutar o que não é possível.
    Outra coisa, só conseguiremos usar Provider neste caso por ter acesso
    ao context por estar dentro de um State
    */
    final products = Provider.of<Products>(context, listen: false);

    try {
      // Se no mapa já tem o id é porque devemos fazer uma alteração, caso
      // contrário é porque precisamos fazer uma inclusão
      if (_formData['id'] == null) {
        // Await retorna e contina apenas quando o produto é adicionado
        await products.addProduct(product);
        // Para sair da tela
      } else {
        await products.updateProduct(product);
      }
      Navigator.of(context).pop();
      // Retorno de erro/exceção
    } catch (error) {
      // showDialog tem que ser do tipo Null porque o CatchError retorna
      // Null se ocorrer um erro
      await showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Ocorreu um erro'),
          //content: Text(error.toString()),
          content: Text('Ocorreu um erro no cadastro do produto.'),
          actions: [
            FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fechar'),
            )
          ],
        ),
      );

      // O bloco FINALLY é usado independente de ocorrer uma exceção
    } finally {
      // showDialog retorna um FUTURE e AWAIT dá o retorno apenas quando
      // a mensagem é fechada com .pop()
      setState(() {
        // Esconde a ampulheta
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulário produtos'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _saveForm();
            },
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                /*
          autovalidate: true,
          Se verdadeiro, os campos do formulário validarão e atualizarão seu texto 
          de erro imediatamente após cada alteração. Caso contrário, você deve 
          chamar [FormState.validate] para validar.
          */
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue:
                          _formData['title'], // Usado no caso de edição
                      decoration: InputDecoration(labelText: 'Título'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      // os Saved() de cada campo é acionado sempre que o método
                      // _form.currentState.save() é acionado
                      onSaved: (value) => _formData['title'] = value,
                      //
                      validator: (textoDigitado) {
                        bool isEmpty = textoDigitado.trim().isEmpty;
                        bool isValid = textoDigitado.trim().length < 3;

                        if (isEmpty || isValid) {
                          return 'Informe um título vádido com pelo menos 3 caracteres';
                        }
                        return null; // Null informa que não tem erro
                      },
                    ),
                    TextFormField(
                      // Usado no caso de edição
                      initialValue: _formData['price'].toString(),
                      focusNode: _priceFocusNode,
                      decoration: InputDecoration(labelText: 'Preço'),
                      textInputAction: TextInputAction.next,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descrptionFocusNode);
                      },
                      onSaved: (value) =>
                          _formData['price'] = double.parse(value),
                      validator: (precoDigitado) {
                        bool isEmpty = precoDigitado.trim().isEmpty;
                        // Se a conversão do string em number retornar null é invalido
                        var newPrice = double.tryParse(precoDigitado);
                        bool isValid = newPrice == null || newPrice <= 0;
                        if (isEmpty || isValid) {
                          return 'Informe um preço válido';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      // Usado no caso de edição
                      initialValue: _formData['description'],
                      decoration: InputDecoration(labelText: 'Descrição'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      //textInputAction: TextInputAction.next,
                      focusNode: _descrptionFocusNode,
                      onSaved: (value) => _formData['description'] = value,
                      validator: (descricaoDigitada) {
                        bool isEmpty = descricaoDigitada.trim().isEmpty;
                        bool isValid = descricaoDigitada.trim().length < 10;

                        if (isEmpty || isValid) {
                          return 'Informe uma descrição vádida com pelo menos 10 caracteres';
                        }
                        return null; // Null informa que não tem erro
                      },
                    ),
                    /*
              Por padrão TextFormField e TextInputAction.done submetem todos os
              campos, porém como vamos querer uma prévia da imagem antes de
              submeter, vamos ter que usar um TextEditingController
              */
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Row não possui uma largura conhecida (finita), por isso
                        // teremos que envolver o TextFormField com um widget que forneça
                        // uma largura conhecida
                        Expanded(
                          child: TextFormField(
                            /*
                      initialValue: _formData['imageUrl'],
                      Aqui não inicializamos o valor direto, mas sim alteramos 
                      o valor de _imageURLController                    
                      */
                            focusNode: _imageURLFocusNode,
                            decoration:
                                InputDecoration(labelText: 'URL da imagem'),
                            keyboardType: TextInputType.url,
                            // Done porque é neste campo que o FORM será submetido
                            textInputAction: TextInputAction.done,
                            // Usamos Controller aqui para ter acesso ao valor da URL
                            controller: _imageURLController,
                            // onFieldSubmitted - ao submeter os campos
                            // Submeter é possível por tertextInputAction: TextInputAction.done
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            onSaved: (value) => _formData['imageUrl'] = value,
                            validator: (valorDaUrl) {
                              bool isEmpty = valorDaUrl.trim().isEmpty;
                              bool isInvalid = !isValidImageUrl(valorDaUrl);
                              if (isEmpty || isInvalid) {
                                return 'Informa uma URL válida';
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            top: 8,
                            left: 10,
                          ),
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: _imageURLController.text.isEmpty
                              ? Text('Informe a URL')
                              : Image.network(_imageURLController.text),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
