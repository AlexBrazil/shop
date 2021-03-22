import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/cart.dart';
import '../utils/app_routes.dart';

class ProductGridItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Usamos aqui o 'listen: false' e o Consumer() para o IconButton, pois o ícone
    //  de favoritos é a única parte da UI que sofre alteração (mudança de estado)
    final Product product = Provider.of<Product>(context, listen: false);
    // Usaremos aqui o 'listem false' por a UI não irá se alterar, apenas temos que
    // acionar algum método ao clicar no botão do carrinho
    final Cart cart = Provider.of<Cart>(context, listen: false);

    return ClipRRect(
      // Para definir uma borda arredondada
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              AppRoutes.PRODUCT_DETAIL,
              arguments: product,
            );
          },
          child: Image.network(
            product.imageUrl,
            // Forma de preenchimento da imagem
            fit: BoxFit.cover,
          ),
        ),
        // Parte inferior de cada tijolo
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            // O terceiro atributo 'naoUsoAqui' é usado somente se quisermos
            // referenciar widgets que não mudam seu estado dentro de Consumer
            builder: (ctx, product, naoUsoAqui) => IconButton(
              icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: () {
                product.toggleFavorite();
              },
              color: Theme.of(context).accentColor,
            ),
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              // Esconde a SnackBar anterior
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Produto adicionado com sucesso!',
                    //textAlign: TextAlign.center,
                  ),
                  duration: Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'DESFAZER',
                    onPressed: () {
                      cart.removeSingleItem(product.id);
                    },
                  ),
                ),
              );
              cart.addItem(product);
            },
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}
