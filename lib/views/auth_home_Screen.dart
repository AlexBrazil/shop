import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import 'auth_screen.dart';
import 'products_overview_screen.dart';

class AuthOrHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Como o provider Auth tem o listen como true, quando este atributo alterar
    // a tela é renderizada novamente
    Auth auth = Provider.of(context);
    print(auth.isAuth);
    return auth.isAuth ? ProductsOverviewScreen() : AuthScreen();
  }
}
