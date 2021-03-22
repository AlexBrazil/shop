import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/utils/app_routes.dart';
import '../widgets/app_drawer.dart';
import '../widgets/product_item.dart';
import '../providers/products.dart';

class ProductsScreen extends StatelessWidget {
  Future<void> _refreshProducts(BuildContext context) {
    return Provider.of<Products>(context, listen: false).loadproducts();
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products = productsData.items;

    return Scaffold(
      appBar: AppBar(
        title: Text("Gerenciar Produtos"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(
                AppRoutes.PRODUCT_FORM,
              );
            },
          )
        ],
      ),
      drawer: AppDrawer(),
      //RefreshIndicator refaz o procesamento se o usuário arrastar o dedo na tela
      // de cima para baixo
      body: RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListView.builder(
            itemCount: productsData.itemsCount,
            itemBuilder: (ctx, i) => Column(
              children: [
                ProductItem(products[i]),
                Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
