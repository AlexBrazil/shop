import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/products.dart';
import 'product_grid_item.dart';

class ProductGrid extends StatelessWidget {
  final bool showFavoriteOnly;
  ProductGrid(this.showFavoriteOnly);

  @override
  Widget build(BuildContext context) {
    /* Buscamos os produtos por meio do Provider que possui um notificador
    PODERIA SER:
    final List<Product> loadedProducts = Provider.of<Products>(context).items;
    */
    final productsProvider = Provider.of<Products>(context);
    final products = showFavoriteOnly
        ? productsProvider.favoriteItems
        : productsProvider.items;

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: products.length,
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        // Usa um ChangeNotifierProvider já existente, pois a classe Product
        // tem um 'with ChangeNotifier'
        value: products[i],
        child: ProductGridItem(),
      ),
      // Sliver é uma área que tem scroll
      // Terremos uma quantidade fixa de elementos no CrossAxes (na linha)
      // No eixo da coluna, ou seja, no manAxes teremos ilimitados elementos
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        // Número fixo de elementos da linha
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
