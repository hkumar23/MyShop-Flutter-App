import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/app_drawer.dart';
import '../widgets/badge_.dart';
import '../widgets/product_grid.dart';
import '../providers/cart.dart';
import '../screens/cart_screen.dart';

enum FilterOptions {
  Favorite,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  static const routeName = "/productsoverview-screen";
  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool showFavoritesOnly = false;
  bool _isinit = true;
  bool isLoading = false;
  @override
  void initState() {
    //   setState(() {
    //     isLoading = true;
    //   });
    //   Provider.of<Products>(context, listen: false)
    //       .fetchAndSetProducts(); //we can use context here by keeping listen as false
    //   setState(() {
    //     isLoading = false;
    //   });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // if we don't want to keep listen false then use didChangeDependencies
    if (_isinit) {
      setState(() {
        isLoading = true;
      });
      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() {
          isLoading = false;
        });
      });
      _isinit = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MyShop"),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              // print(selectedValue);
              setState(() {
                if (selectedValue == FilterOptions.Favorite) {
                  showFavoritesOnly = true;
                } else {
                  showFavoritesOnly = false;
                }
              });
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: FilterOptions.Favorite,
                child: Text("Only Favorites"),
              ),
              const PopupMenuItem(
                value: FilterOptions.All,
                child: Text("Show All"),
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge_(
              value: cart.itemCount.toString(),
              child: ch as Widget,
            ),
            child: IconButton(
              // here ch = child,child passed in builder function by flutter, this is not rebuild
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routName);
              },
              icon: const Icon(
                Icons.shopping_cart,
              ),
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ProductGrid(showFavoritesOnly),
    );
  }
}
