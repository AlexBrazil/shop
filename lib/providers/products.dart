import 'dart:convert';

import 'package:flutter/material.dart';
/*
O método .Put de http atualiza tudo
o método .Patch de http atualiza parcial
*/
import 'package:http/http.dart' as http;
import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/utils/constants.dart';
import 'product.dart';

// ChangeNotifier - quando o evento de mudança acontece ele irá notificar
// todos os interessados. pode ser adicionar, excluir ou alterar algum produto
class Products with ChangeNotifier {
  List<Product> _items = [];
  String _token;
  String _userId;

  // * Este token deverá ser passado na construção do objeto e vem de outro provider
  //   e por isso será usado, bem como passamos a lista atual de produtos para que não
  //   se perca a lista após cada update.
  // * Os parâmetros serão opcionais para que no provider possamos ter mais liberdade
  //   na hora de usar update e create, onde no create usamos o construtor sem parãmetros
  //   e no update com parâmetros

  Products([this._token, this._userId, this._items = const []]);

  /*
     1) Aqui usa o alias criado - http. O objetivo é diferenciar o nome e ficar mais legível
     2) products.json é usado no firebase, em uma API Rest comum usaria apenas products
    */
  final String _baseUrlProducts =
      // Se quisermos simular um erro no Firebase retiramos .json
      '${Constants.BASE_API_URL}/products';
  final String _baseUrlUserFavorites =
      // Se quisermos simular um erro no Firebase retiramos .json
      '${Constants.BASE_API_URL}/userFavorites';

  /* Getters retorna uma cópia da lista de produtos, pois se passarmos uma
   referência de _item, qualquer um terá a possibilidade de alterar a
   lista de produtos sem passar pela classe produtos
  List<Product> get items => [..._items];
  */

  List<Product> get items => [..._items];
  List<Product> get favoriteItems {
    return _items.where((prod) => prod.isFavorite).toList();
  }

  /* Aqui acontece um evento e preciso notificar os interessados
  Primeiro irá executar a inclusão por POST/HTTP, depois irá executar
  _items.add e só depoiis retornará o um Void para quem o chamou, onde usaremos
  .thhen() para aguardar todo este processo acontecer
  */
  Future<void> addProduct(Product newProduct) async {
    // O método (requisição POST) post é assincrono e tem como resposta um Future
    // Nesta caso Then será chamado quando a requisição for entregue e receberá
    // a resposta do protocolo HTTP (htto é baseado em requisição e resposta)

    // Vai esperar a resposta chegar para continuar
    final response = await http.post(
      "$_baseUrlProducts.json?auth=$_token", // Parâmetro posicional
      // Passamos um map para json.encode
      body: json.encode({
        // o ID não será passado
        'title': newProduct.title,
        'description': newProduct.description,
        'price': newProduct.price,
        'imageUrl': newProduct.imageUrl,
      }),
    );
    // em response terei o json com a estrutura de dados cadastrada, inclusive
    // o ID do incluído pelo FIREBASE
    // Decode - converte o Json em Mapa novamente
    _items.add(
      Product(
          //id: Random().nextDouble().toString(),
          // O Map retorna o name, que é a chave primária para o registro
          id: json.decode(response.body)['name'],
          title: newProduct.title,
          description: newProduct.description,
          price: newProduct.price,
          imageUrl: newProduct.imageUrl),
    );
    //Aqui notifico os interessados
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    if (product == null || product.id == null) {
      return;
    }

    /* Percisamos achar o indice do produto para ser alterado
    Se o ID do produto passado for achado dentro de _items é retornado
    o índide (int), caso contrário retorna -1
    */
    final index =
        _items.indexWhere((itemProduto) => itemProduto.id == product.id);

    if (index >= 0) {
      await http.patch(
        "$_baseUrlProducts/${product.id}.json?auth=$_token",
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'isFavorite': product.isFavorite,
        }),
      );
      _items[index] = product;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final index = _items.indexWhere((itemProduto) => itemProduto.id == id);
    if (index >= 0) {
      final product = _items[index];
      final response = await http
          .delete("$_baseUrlProducts/${product.id}.json?auth=$_token");

      _items.remove(product);
      notifyListeners();

      // a faixa dos 400 é erro do lado do frontend e na faixa dos 500 é no backend
      // Já a faixa dos 200 é status bem sucedido
      if (response.statusCode >= 400) {
        // Caso o http retorno um erro o produto é reincerido
        _items.insert(index, product);
        notifyListeners();
        /* Vamos lançar uma exceção
        Conseguiremos lançar esta exceção porque criamos uma classe HttpException
        que implementa Exception

        Esta Exceção precisa ser tratada em algum ponto do código

        */
        throw HttpException('Ocorreu um erro na exclusão do produto');
      }
    }
  }

  int get itemsCount {
    return _items.length;
  }

  Future<void> loadproducts() async {
    // Se não usarmos await response NÃO recebe a resposta, mas sim um FUTURE, e
    // com isso NÃO teremos acesso ao .body
    final reponse = await http.get("$_baseUrlProducts.json?auth=$_token");
    Map<String, dynamic> data = json.decode(reponse.body);

    // Aqui pegamos a favoritação de produtos por usuário
    final favReponse = await http.get(
        "${Constants.BASE_API_URL}/userFavorites/$_userId.json?auth=$_token");
    final favMap = json.decode(favReponse.body);
    print("FAV MAP: $favMap");

    //Limpa o MAP
    _items.clear();
    if (data != null) {
      data.forEach((productID, productData) {
        /* Recuperando a favoritação do produto
        SE NO FIREBASE SE APAGAR A COLEÇÃO OU ALGUM CAMPO DA COLEÇÃO:
        Se o map for nulo é falso, caso o map não for nulo é pq existe um Id para o
        produto e recuperamos o valor de favorito para aquele produto, mas pode ser 
        tenham apagado o produto, por isso temos "?? false", ou seja, é um valor
        padrão.
        */
        final isFavorite = favMap == null ? false : favMap[productID] ?? false;
        _items.add(Product(
          id: productID,
          title: productData['title'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['imageUrl'],
          isFavorite: isFavorite,
        ));
      });
      notifyListeners();
    }

    // Como não existe um return, temos que inserir
    return Future.value(); // Retorna um valor vazio
  }

  Future<void> changeToggleFavorite(
      {Product product, String token, String userId}) async {
    if (product == null || product.id == null) {
      return Future.value();
    }
    /* Percisamos achar o indice do produto para ser alterado o isFavorite
    Se o ID do produto passado for achado dentro de _items é retornado
    o índide (int), caso contrário retorna -1
    */
    final index =
        _items.indexWhere((itemProduto) => itemProduto.id == product.id);

    if (index >= 0) {
      product.isFavorite = !product.isFavorite;
      _items[index].isFavorite = product.isFavorite;
      notifyListeners();

      final response = await http.put(
        "$_baseUrlUserFavorites/$userId/${product.id}.json?auth=$token",
        // Aqui não usa um campo, algo tipo 'isFavorite' : isFavorite para
        // registrar no FIREBASE, registra boleano direto no ID do produto
        body: json.encode(
          product.isFavorite,
        ),
      );

      if (response.statusCode >= 400) {
        // Caso o http retorno um erro o isFavorite é restaurado para o valor anterior
        product.isFavorite = !product.isFavorite;
        _items[index].isFavorite = product.isFavorite;
        notifyListeners();
        // Lançada uma exceção
        throw HttpException(
            'Ocorreu um erro na opção de favoritar ou desfavoritar');
      }
    }
  }
}
