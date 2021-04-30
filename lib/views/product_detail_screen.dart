import 'package:flutter/material.dart';
import '../providers/product.dart';

class ProductDetailScreen extends StatefulWidget {
  ProductDetailScreen();

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final Product product =
        ModalRoute.of(context).settings.arguments as Product;

    return Scaffold(
      /*appBar: AppBar(
        title: Text(product.title),
      ),
      */
      body: CustomScrollView(
        // slivers são áreas que podem ter scroll dentro delas
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            // Com true o app bar sempre vai aparecer
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                product.title,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: product.id,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0, 0.8),
                        end: Alignment(0, 0),
                        colors: [
                          Color.fromRGBO(0, 0, 0, 0.6),
                          Color.fromRGBO(0, 0, 0, 0.0),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                SizedBox(height: 10),
                Text(
                  'R\$ ${product.price}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  child: Text(
                    product.description,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 1000),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
