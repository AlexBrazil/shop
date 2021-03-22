import 'package:flutter/material.dart';
import '../utils/app_routes.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text('Bem Vindo Usuário'),
            // retira o ícone do dwawer
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Loja'),
            onTap: () {
              // Não coloca em uma pilha de telas, a tela atual é
              // substituída
              Navigator.of(context).pushReplacementNamed(AppRoutes.HOME);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Pedidos'),
            onTap: () {
              // Não coloca em uma pilha de telas, a tela atual é
              // substituída
              Navigator.of(context).pushReplacementNamed(AppRoutes.ORDERS);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Gerenciar Produtos'),
            onTap: () {
              // Não coloca em uma pilha de telas, a tela atual é
              // substituída
              Navigator.of(context).pushReplacementNamed(AppRoutes.PRODUCTS);
            },
          )
        ],
      ),
    );
  }
}
