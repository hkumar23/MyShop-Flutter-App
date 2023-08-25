import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String? id;
  final String? title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });
  void setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(
      String id, String authToken, String userId) async {
    final url = Uri.parse(
        "https://myshop-app-11dd1-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken");
    bool oldStatus = isFavorite;
    setFavValue(!isFavorite);
    try {
      final response = await http.put(url,
          body: json.encode(
            isFavorite,
          ));
      if (response.statusCode >= 400) {
        setFavValue(oldStatus);
      }
    } catch (error) {
      setFavValue(oldStatus);
    }
  }
}
