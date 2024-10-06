import 'dart:convert';
import 'package:http/http.dart' as http;

class UnsplashService {
  final String _clientId = 'FPnyoW2lFyZqk6QLiuYY92T6ExqEzocYVL3wokmQkJU';
  final String _baseUrl = 'https://api.unsplash.com'; // Base URL for Unsplash API

  // Endpoints
  String get fetchImagesEndpoint => '/photos'; // Endpoint for fetching images
  String get searchImagesEndpoint => '/search/photos'; // Endpoint for searching images

  /// Fetch random images from Unsplash API with pagination
  Future<List<String>> fetchImages({int page = 1, int perPage = 10}) async {
    final String url = '$_baseUrl$fetchImagesEndpoint?client_id=$_clientId&page=$page&per_page=$perPage';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<String> imageUrls = List<String>.from(
          data.map((image) => image['urls']['regular'])); // Extract regular image URLs
      return imageUrls;
    } else {
      throw Exception('Failed to load images');
    }
  }

  /// Search for images based on user query
  Future<List<String>> searchImages(String query, {int page = 1, int perPage = 10}) async {
    final String url =
        '$_baseUrl$searchImagesEndpoint?client_id=$_clientId&page=$page&query=$query&per_page=$perPage';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      List<String> imageUrls = List<String>.from(
          data['results'].map((image) => image['urls']['regular'])); // Extract image URLs from search results
      return imageUrls;
    } else {
      throw Exception('No images found');
    }
  }
}
