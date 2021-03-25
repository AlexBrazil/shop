import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/providers/products.dart';
import '../providers/product.dart';
import '../utils/app_routes.dart';

class ProductItem extends StatelessWidget {
  final Product product;
  ProductItem(this.product);

  @override
  Widget build(BuildContext context) {
    /* Usamos o scaffold em uma variável para ter acesso em um método Async,
     pois métodos Async não tem acesso a árvore de componentes
    */
    final scaffold = Scaffold.of(context);
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
                  /* Aguarda um retorno futuro quando a janela for fechada
                  Tornamos o método THEN como ASYNC para poder usar Await
                  */
                ).then((value) async {
                  if (value == true) {
                    // listen é false porque o que tem que ser atualizado não é
                    // o widget product_item, pois ele será deletado
                    try {
                      await Provider.of<Products>(context, listen: false)
                          .deleteProduct(product.id);
                    } on HttpException catch (error) {
                      // Para acessar o Scaffold aqui estamos usando uma variável
                      // Veja acima
                      scaffold.showSnackBar(
                        SnackBar(content: Text(error.toString())),
                      );
                    }
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
