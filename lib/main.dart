import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/cart.dart';
import './views/auth_home_Screen.dart';
//import 'views/products_overview_screen.dart';
import './utils/app_routes.dart';
import './views/product_detail_screen.dart';
import './views/products_screen.dart';
import './views/cart_secreen.dart';
import './views/order_secreen.dart';
import './views/product_form_screen.dart';
import './providers/products.dart';
import './providers/orders.dart';
import './providers/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider é um Observador
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          // Products() deve ter um mixin de ChangeNotifier
          // Criando o ChangeNotifierProvider
          create: (ctx) => new Products(),
        ),
        ChangeNotifierProvider(
          // Cart() deve ter um mixin de ChangeNotifier
          // Criando o ChangeNotifierProvider
          create: (ctx) => new Cart(),
        ),
        ChangeNotifierProvider(
          // Orders() deve ter um mixin de ChangeNotifier
          // Criando o ChangeNotifierProvider
          create: (ctx) => new Orders(),
        ),
        ChangeNotifierProvider(
          // Auth() deve ter um mixin de ChangeNotifier
          // Criando o ChangeNotifierProvider
          create: (ctx) => new Auth(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Minha Loja',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          accentColor: Colors.deepOrange,
          fontFamily: 'Lato',
        ),
        //home: ProductsOverviewScreen(), - estamos suando a tota abaixo
        routes: {
          AppRoutes.AUTH_HOME: (ctx) => AutOrhHomeScreen(),
          AppRoutes.ORDERS: (ctx) => OrderScreen(),
          AppRoutes.PRODUCTS: (ctx) => ProductsScreen(),
          AppRoutes.PRODUCT_DETAIL: (ctx) => ProductDetailScreen(),
          AppRoutes.CART: (ctx) => CartScreen(),
          AppRoutes.PRODUCT_FORM: (ctx) => ProductFormScreen(),
        },
      ),
    );
  }
}
