import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  CartItemWidget(this.cartItem);

  @override
  Widget build(BuildContext context) {
    // Dismissible cria uma forma de descartar o card com o arraste
    return Dismissible(
      key: ValueKey(cartItem.id),
      background: Container(
        color: Theme.of(context).errorColor,
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
      ),
      direction: DismissDirection.endToStart,
      //O que é feito antes do elemento ser demitido da tela
      confirmDismiss: (_) {
        /*
        Abaixo a demissão nunca ocorrerá, pois sempre será retornado falso
        return Future.value(false);
        */
        return showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('Tem certeza?'),
                  content: Text('Quer remover o item do carrinho?'),
                  actions: [
                    FlatButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(false);
                      },
                      child: Text('Não'),
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(true);
                      },
                      child: Text('Sim'),
                    )
                  ],
                ));
      },
      // O que é feito ao arrastar e a elemento é demitido da tela
      onDismissed: (_) {
        Provider.of<Cart>(context, listen: false)
            .removeItem(cartItem.productId);
      },
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: EdgeInsets.all(5),
                child: FittedBox(
                  child: Text('${cartItem.price}'),
                ),
              ),
            ),
            title: Text(cartItem.title),
            subtitle: Text('Total: R\$ ${cartItem.quantity * cartItem.price}'),
            trailing: Text('${cartItem.quantity}x'),
          ),
        ),
      ),
    );
  }
}
