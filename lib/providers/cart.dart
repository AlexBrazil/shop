import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shop/providers/product.dart';

class CartItem {
  final String id;
  final String productId;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    @required this.id,
    @required this.productId,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  // Não pegamos do item porque ele teria que reconstruir o MAP
  // toda a vez para poder contar o número de elementos
  int get itemsCount {
    return _items.length;
  }

  double roundDouble(double value, int places) {
    double mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return roundDouble(total, 2);
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(product.id, (existingItem) {
        return CartItem(
          id: existingItem.id,
          productId: product.id,
          title: existingItem.title,
          quantity: existingItem.quantity + 1,
          price: existingItem.price,
        );
      });
    } else {
      _items.putIfAbsent(product.id, () {
        return CartItem(
          id: Random().nextDouble().toString(),
          productId: product.id,
          title: product.title,
          quantity: 1,
          price: product.price,
        );
      });
    }
    // Notificar os listener (quem está escutando)
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }

  void removeSingleItem(productId) {
    // Se não tiver a chave apenas retorna
    if (!_items.containsKey(productId)) {
      return;
    }

    // Existe apenas um produto no carrinho. O produto será removido do mapa
    if (_items[productId].quantity == 1) {
      // Cuidado para não usar o clone de _item, ou seja, item
      _items.remove(productId);
    } else {
      // existe 2 ou mais produtos, e a quantdade será decrementada
      _items.update(productId, (existingItem) {
        return CartItem(
          id: existingItem.id,
          productId: existingItem.productId,
          title: existingItem.title,
          quantity: existingItem.quantity - 1,
          price: existingItem.price,
        );
      });
    }
    notifyListeners();
  }
}
