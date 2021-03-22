import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/order_widget.dart';
import '../providers/orders.dart';

class OrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Orders orders = Provider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('MEUS PEDIDOS'),
      ),
      drawer: AppDrawer(),
      body: ListView.builder(
        itemCount: orders.itemsCount,
        itemBuilder: (ctx, i) => OrderWidget(orders.items[i]),
      ),
    );
  }
}
