import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shop/providers/cart.dart';

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
  List<Order> _items = [];

  List<Order> get items {
    // Clona a lista
    return [..._items];
  }

  final String _baseUrl =
      // Se quisermos simular um erro no Firebase retiramos .json
      'https://flutter-cod3r-10ba2-default-rtdb.firebaseio.com/orders';

  int get itemsCount {
    return _items.length;
  }

  Future<void> addOrder(Cart cart) async {
    final date = DateTime.now();
    final response = await http.post(
      "$_baseUrl.json",
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
}
