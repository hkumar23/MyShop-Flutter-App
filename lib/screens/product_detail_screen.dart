import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = "/product-detail";

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments;
    final loadedProduct = Provider.of<Products>(
      context,
      listen:
          false, // it means that this widget will build once not again and again when there is some changes in Products provider
    ).findById(productId as String);
    return Scaffold(
      appBar: AppBar(
        title: Text(loadedProduct.title as String),
      ),
      body: Column(
        children: [
          Container(
            height: 300,
            width: double.infinity,
            child: Image.network(
              loadedProduct.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "\$${loadedProduct.price}",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            width: double.infinity,
            child: Text(
              loadedProduct.description,
              softWrap: true,
            ),
            alignment: Alignment.center,
          ),
        ],
      ),
    );
  }
}
