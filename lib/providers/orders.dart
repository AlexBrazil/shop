import 'dart:math';

import 'package:flutter/cupertino.dart';
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

  int get itemsCount {
    return _items.length;
  }

  void addOrder(Cart cart) {
    /* Poderiamos calcular o total aqui
    void addOrder(List<CartItem> products, double total) {
      final combine = (acumulador, element) =>
          acumulador + (element.price * element.quantity);
      final total = products.fold(0.0, combine);
    */

    _items.insert(
      0,
      Order(
        id: Random().nextDouble().toString(),
        total: cart.totalAmount,
        date: DateTime.now(),
        products: cart.items.values.toList(),
      ),
    );
    notifyListeners();
  }
}
