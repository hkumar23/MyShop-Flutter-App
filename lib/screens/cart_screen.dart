import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart';
import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routName = "/cart";

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Cart",
          ),
        ),
        body: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(15),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(fontSize: 20),
                    ),
                    const Spacer(),
                    Expanded(
                      child: Chip(
                        label: Text(
                          "\$${cart.totalAmount.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                    OrderButton(cart: cart),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (ctx, i) => CartItem(
                    cart.items.values.toList()[i].id,
                    cart.items.keys.toList()[i],
                    cart.items.values.toList()[i].title,
                    cart.items.values.toList()[i].price,
                    cart.items.values.toList()[i].quantity),
              ),
            ),
          ],
        ));
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    super.key,
    required this.cart,
  });

  final Cart cart;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const CircularProgressIndicator()
        : TextButton(
            onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
                ? null
                : () async {
                    setState(() {
                      _isLoading = true;
                    });
                    await Provider.of<Orders>(context, listen: false).addOrder(
                      widget.cart.items.values.toList(),
                      widget.cart.totalAmount,
                    );
                    setState(() {
                      _isLoading = false;
                    });
                    widget.cart.clear();
                  },
            child: const Text("ORDER NOW"),
          );
  }
}
