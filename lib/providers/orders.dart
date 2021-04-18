import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shop/providers/cart.dart';
import 'package:shop/utils/constants.dart';

class Order {
  final String id;
  final double total;
  final List<CartItem> products;
  final DateTime date;

  Order({
    this.id,
    this.total,
    this.products,
    this.date,
  });
}

class Orders with ChangeNotifier {
  String _token;
  List<Order> _items = [];

  List<Order> get items {
    // Clona a lista
    return [..._items];
  }

  final String _baseUrl =
      // Se quisermos simular um erro no Firebase retiramos .json
      '${Constants.BASE_API_URL}/orders';

  // Construtor
  Orders([this._token, this._items = const []]);

  int get itemsCount {
    return _items.length;
  }

  Future<void> addOrder(Cart cart) async {
    final date = DateTime.now();
    final response = await http.post(
      "$_baseUrl.json?auth=$_token",
      body: json.encode({
        'total': cart.totalAmount,
        // Convert no formato ISO-8601 para armazenamento
        'date': date.toIso8601String(),
        // Produtos é uma List de itens e preisa ser convertido em um Map
        'products': cart.items.values
            .map((cartItem) => {
                  'id': cartItem.id,
                  'productId': cartItem.productId,
                  'title': cartItem.title,
                  'quantity': cartItem.quantity,
                  'price': cartItem.price,
                })
            .toList(),
      }),
    );

    /* Poderiamos calcular o total aqui
    void addOrder(List<CartItem> products, double total) {
      final combine = (acumulador, element) =>
          acumulador + (element.price * element.quantity);
      final total = products.fold(0.0, combine);
    */

    _items.insert(
      0,
      Order(
        // No body recebemos um MAP "Chave" : Valor, sendo que a chave é um
        // string 'name' e valor é outro MAP com o conteúdo
        id: json.decode(response.body)['name'],
        total: cart.totalAmount,
        date: date,
        products: cart.items.values.toList(),
      ),
    );
    notifyListeners();
  }

  Future<void> loadOrders() async {
    List<Order> loadedItems = [];
    // Se não usarmos await response NÃO recebe a resposta, mas sim um FUTURE, e
    // com isso NÃO teremos acesso ao .body
    final reponse = await http.get("$_baseUrl.json?auth=$_token");
    Map<String, dynamic> data = json.decode(reponse.body);
    //Limpa o MAP

    if (data != null) {
      data.forEach((orderID, orderData) {
        loadedItems.add(
          Order(
            id: orderID,
            total: orderData['total'],
            date: DateTime.parse(orderData['date']),
            // products é uma LIST de MAP's
            products: (orderData['products'] as List<dynamic>).map((item) {
              return CartItem(
                id: item['id'],
                productId: item['productID'],
                title: item['title'],
                quantity: item['quantity'],
                price: item['price'],
              );
            }).toList(),
          ),
        );
      });
      notifyListeners();
    }

    // Muda a ordem da lista
    _items = loadedItems.reversed.toList();

    // Como não existe um return, temos que inserir
    return Future.value(); // Retorna um valor vazio
  }
}
