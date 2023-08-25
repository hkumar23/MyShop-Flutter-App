import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../providers/product.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "/edit-product-screen";

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: null,
    title: "",
    description: "",
    price: 0.0,
    imageUrl: "",
  );
  var _initValues = {
    "title": "",
    "price": "",
    "description": "",
    "imageUrl": "",
  };
  var _isLoading = false;
  bool _isInit = true;
  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // print("didChangedep");
    if (_isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments as String;
      // String? productId;
      // if (ModalRoute.of(context) != null) {
      //   print("Not Null");
      //   productId = ModalRoute.of(context)!.settings.arguments as String;
      // } else {
      //   print("NULL");
      //   productId = null;
      // }
      if (productId != "null") {
        // final productId = ModalRoute.of(context)!.settings.arguments as String;
        // print("Not NULL");
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          "title": _editedProduct.title.toString(),
          "price": _editedProduct.price.toString(),
          "description": _editedProduct.description,
          // "imageUrl": _editedProduct.imageUrl,
          "imageUrl": "",
        };
        _imageUrlController.text = _editedProduct.imageUrl;
        // print(" yes ");
      } else {
        // print("NULL");
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (!_imageUrlController.text.startsWith("http") &&
          !_imageUrlController.text.startsWith("https")) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    // print("Save Form");
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      // print(_editedProduct.title);
      // print(_editedProduct.price);
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id as String, _editedProduct);
    } else {
      // print("add product");
      try {
        await Provider.of<Products>(context, listen: false)
            .addItem(_editedProduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                  title: const Text("An Error Occured"),
                  content: const Text("Something went wrong"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: const Text("Okay"),
                    )
                  ]);
            });
      }
      // finally {
      //   _isLoading = false;
      //   Navigator.of(context).pop();
      // }
    }
    setState(() {
      _isLoading = false;
    });
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Product"),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                  key: _form,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _initValues["title"],
                        decoration: const InputDecoration(
                          label: Text("Title"),
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.next,
                        onSaved: (value) {
                          // print(value);
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            title: value,
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl,
                            price: _editedProduct.price,
                            isFavorite: _editedProduct.isFavorite,
                          );
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please provide a value!";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _initValues["price"],
                        decoration: const InputDecoration(
                          label: Text("Price"),
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        onSaved: (value) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl,
                            price: double.parse(value!),
                            isFavorite: _editedProduct.isFavorite,
                          );
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please Enter a price!";
                          }
                          if (double.tryParse(value) == null) {
                            return "Please Enter a valid number!";
                          }
                          if (double.parse(value) <= 0) {
                            return "Please Enter a number greater than zero!";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _initValues["description"],
                        decoration: const InputDecoration(
                          labelText: "Description",
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.newline,
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        onSaved: (value) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            description: value!,
                            imageUrl: _editedProduct.imageUrl,
                            price: _editedProduct.price,
                            isFavorite: _editedProduct.isFavorite,
                          );
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please Enter a description!";
                          }
                          if (value.length < 10) {
                            return "Should be atleast 10 characters long!";
                          }
                          return null;
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.grey,
                              ),
                            ),
                            margin: const EdgeInsets.only(top: 8, right: 10),
                            child: _imageUrlController.text.isEmpty
                                ? const Text("Enter a URL")
                                : FittedBox(
                                    fit: BoxFit.contain,
                                    child:
                                        Image.network(_imageUrlController.text),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                label: Text("ImageUrl"),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageUrlController,
                              focusNode: _imageUrlFocusNode,
                              onFieldSubmitted: (_) {
                                // print(_editedProduct.title);
                                // print(_editedProduct.price);
                                _saveForm();
                              },
                              onSaved: (value) {
                                _editedProduct = Product(
                                  id: _editedProduct.id,
                                  title: _editedProduct.title,
                                  description: _editedProduct.description,
                                  imageUrl: value!,
                                  price: _editedProduct.price,
                                  isFavorite: _editedProduct.isFavorite,
                                );
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please Enter an Image URL!";
                                }
                                if (!value.startsWith("http") &&
                                    !value.startsWith("https")) {
                                  return "Please Enter a valid URL";
                                }
                                return null;
                              },
                              onEditingComplete: () {
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
    );
  }
}
