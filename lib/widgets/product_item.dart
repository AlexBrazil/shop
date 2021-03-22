import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/products.dart';
import '../providers/product.dart';
import '../utils/app_routes.dart';

class ProductItem extends StatelessWidget {
  final Product product;
  ProductItem(this.product);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(product.imageUrl),
      ),
      title: Text(product.title),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              color: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.PRODUCT_FORM,
                  arguments: product,
                );
                print("Passado em item produto ao editar: " +
                    product.description);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              color: Theme.of(context).errorColor,
              onPressed: () {
                return showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Tem certeza?'),
                    content: Text('Quer remover o produto?'),
                    actions: [
                      FlatButton(
                        onPressed: () {
                          // Pop retornará um valor futuro false quando a
                          // janela for fechada
                          Navigator.of(ctx).pop(false);
                        },
                        child: Text('Não'),
                      ),
                      FlatButton(
                        onPressed: () {
                          // Pop retornará um valor futuro true quando a
                          // janela for fechada
                          Navigator.of(ctx).pop(true);
                        },
                        child: Text('Sim'),
                      )
                    ],
                  ),
                  // Aguarda um retorno futuro quando a janela for fechada
                ).then((value) {
                  if (value == true) {
                    // listen é false porque o que tem que ser atualizado não é
                    // o widget product_item, pois ele será deletado
                    Provider.of<Products>(context, listen: false)
                        .deleteProduct(product.id);
                  }
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
