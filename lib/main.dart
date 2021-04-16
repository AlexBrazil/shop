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
        // Existe uma hierarquia entre os Providers e por isso caso este seja usado abaixo
        // deverá vir antes
        ChangeNotifierProvider(
          // Auth() deve ter um mixin de ChangeNotifier
          // Criando o ChangeNotifierProvider
          create: (ctx) => new Auth(),
        ),
        // Usamos ChangeNotifierProxyProvider para acessar dados de um provider
        // dentro de outro provider
        ChangeNotifierProxyProvider<Auth, Products>(
          // Aqui usaremos o token que está em Auth e a lista de produtos
          // que já está cadastrada (produtos na versão anterior antes de atualizar
          // a lista de produtos)
          // ----------------------------------------------------------------------
          // Este provider não só usa somente o método create, mas também o Update, pois a cada
          // chamada do backend temos que passar o token atualizado, sem perder a lista de produtos
          // já cadastrada
          create: (_) => new Products(null, []),
          update: (ctx, auth, previousProducts) => new Products(
            auth.token,
            previousProducts.items,
          ),
        ),
        ChangeNotifierProvider(
          // Cart() deve ter um mixin de ChangeNotifier
          // Criando o ChangeNotifierProvider
          create: (ctx) => new Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          // Aqui usaremos o token que está em Auth e a lista de produtos
          // que já está cadastrada (produtos na versão anterior antes de atualizar
          // a lista de produtos)
          // ----------------------------------------------------------------------
          // Este provider não só usa somente o método create, mas também o Update, pois a cada
          // chamada do backend temos que passar o token atualizado, sem perder a lista de produtos
          // já cadastrada
          create: (_) => new Orders(null, []),
          update: (ctx, auth, previousOrders) => new Orders(
            auth.token,
            previousOrders.items,
          ),
        ),
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
          AppRoutes.AUTH_HOME: (ctx) => AuthOrHomeScreen(),
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
