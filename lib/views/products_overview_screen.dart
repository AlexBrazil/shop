import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/cart.dart';
import 'package:shop/providers/products.dart';
import '../widgets/product_grid.dart';
import '../widgets/badge.dart';
import '../widgets/app_drawer.dart';
import '../utils/app_routes.dart';

enum FilterOptions { Favorite, All }

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _showFavoriteOnly = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    /* Carregar produtos
    Por não estar dentro do contexto da árvre de renderização temos que usar
    listen para false, com isso Provider serve apenas para acessar de forma 
    estática

    Os métodos de Products, tal como loadProducts, estarão disponíveis apenas
    se resolvermos os genérics para <Products>
    */
    Provider.of<Products>(context, listen: false).loadproducts().then((value) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minha Joja'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favorite) {
                  _showFavoriteOnly = true;
                } else {
                  _showFavoriteOnly = false;
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Somente Favoritos'),
                value: FilterOptions.Favorite,
              ),
              PopupMenuItem(
                child: Text('Todos'),
                value: FilterOptions.All,
              ),
            ],
          ),
          /*
          // Este formato não usa o parâmetro child para otimizar e não renderizar
          // parte da tela que não muda
          Consumer<Cart>(
            builder: (ctx, cart, child) => Badge(
              value: cart.itemCount.toString(),
              child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {},
              ),
            ),
          )
          */
          // Este formato USA o parâmetro child para otimizar e não renderizar
          // parte da tela que não muda. Neste caso o contexto que não é usado
          Consumer<Cart>(
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.CART,
                );
              },
            ),
            builder: (_, cart, child) => Badge(
              value: cart.itemsCount.toString(),
              child: child,
            ),
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ProductGrid(_showFavoriteOnly),
      drawer: AppDrawer(),
    );
  }
}
