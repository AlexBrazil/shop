import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product.dart';

// ChangeNotifier - quando o evento de mudança acontece ele irá notificar
// todos os interessados. pode ser adicionar, excluir ou alterar algum produto
class Products with ChangeNotifier {
  List<Product> _items = [];

  /*
     1) Aqui usa o alias criado - http. O objetivo é diferenciar o nome e ficar mais legível
     2) products.json é usado no firebase, em uma API Rest comum usaria apenas products
    */
  final String _baseUrl =
      // Se quisermos simular um erro no Firebase retiramos .json
      'https://flutter-cod3r-10ba2-default-rtdb.firebaseio.com/products';

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
      "$_baseUrl.json", // Parâmetro posicional
      // Passamos um map para json.encode
      body: json.encode({
        // o ID não será passado
        'title': newProduct.title,
        'description': newProduct.description,
        'price': newProduct.price,
        'imageUrl': newProduct.imageUrl,
        'isFavorite': newProduct.isFavorite,
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
        "$_baseUrl/${product.id}.json",
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
        }),
      );
      _items[index] = product;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    final index = _items.indexWhere((itemProduto) => itemProduto.id == id);
    if (index >= 0) {
      _items.removeWhere((itemProduct) => itemProduct.id == id);
      notifyListeners();
    }
  }

  int get itemsCount {
    return _items.length;
  }

  Future<void> loadproducts() async {
    // Se não usarmos await response NÃO recebe a resposta, mas sim um FUTURE, e
    // com isso NÃO teremos acesso ao .body
    final reponse = await http.get("$_baseUrl.json");
    Map<String, dynamic> data = json.decode(reponse.body);
    //Limpa o MAP
    _items.clear();
    if (data != null) {
      data.forEach((productID, productData) {
        _items.add(Product(
            id: productID,
            title: productData['title'],
            description: productData['description'],
            price: productData['price'],
            imageUrl: productData['imageUrl'],
            isFavorite: productData['isFavorite']));
      });
      notifyListeners();
    }

    // Como não existe um return, temos que inserir
    return Future.value(); // Retorna um valor vazio
  }
}
