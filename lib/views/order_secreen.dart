import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/order_widget.dart';
import '../providers/orders.dart';

class OrderScreen extends StatelessWidget {
  Future<void> _refreshOrders(BuildContext context) {
    return Provider.of<Orders>(context, listen: false).loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    /*
    Não estamos usando o Provider aqui pois estamos usando pontualmente
    um Consumer<Orders>

    final Orders orders = Provider.of(context);
    */
    return Scaffold(
        appBar: AppBar(
          title: Text('MEUS PEDIDOS'),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future: Provider.of<Orders>(context, listen: false).loadOrders(),
          builder: (ctx, snapshot) {
            // Enquanto future não receber o retorno, snapshot.connectionState
            // estará no estado de waiting
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.error != null) {
              return Center(
                child: Text('Ocorreu um erro!'),
              );
            } else {
              // RefreshIndicator atualiza a tela caso arrastada para baixo
              return RefreshIndicator(
                onRefresh: () => _refreshOrders(context),
                // Consumer é uma forma de Provider que atua de forma pontual
                child: Consumer<Orders>(
                  builder: (ctx, orders, child) {
                    return ListView.builder(
                      itemCount: orders.itemsCount,
                      itemBuilder: (ctx, i) => OrderWidget(orders.items[i]),
                    );
                  },
                ),
              );
            }
          },
        )
        /*isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () => _refreshOrders(context),
              child: ListView.builder(
                itemCount: orders.itemsCount,
                itemBuilder: (ctx, i) => OrderWidget(orders.items[i]),
              ),
            ),*/
        );
  }
}
