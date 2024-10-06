import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prictechnologyassigmenthemangifalak/Service.dart';
import 'search_history_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> images = [];
  bool isLoading = false; // Track if data is loading
  int currentPage = 1;
  final int perPage = 10; // Load 10 images per page
  String searchQuery = "nature"; // Default search query
  final UnsplashService _unsplashService = UnsplashService(); // Create an instance of the service

  @override
  void initState() {
    super.initState();
    fetchImages(); // Fetch initial images
  }

  /// Fetch images using the UnsplashService
  Future<void> fetchImages({String query = "nature"}) async {
    if (isLoading) return; // Avoid multiple API calls at the same time
    setState(() => isLoading = true); // Set loading to true

    try {
      List<String> newImages;
      if (query == "nature") {
        // Fetch random images if no query is specified
        newImages = await _unsplashService.fetchImages(page: currentPage, perPage: perPage);
      } else {
        // Fetch images based on user search query
        newImages = await _unsplashService.searchImages(query, page: currentPage, perPage: perPage);
      }

      setState(() {
        images.addAll(newImages); // Add new images to the list
        isLoading = false; // Stop loading indicator
      });
      // Save search query in Firestore if relevant
      if (query != "nature") saveSearchQuery(query);
    } catch (e) {
      setState(() => isLoading = false);
      if (images.isEmpty) {
        // Display "No images found" message if the list is empty
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('No Images Found'),
            content: Text('No images match your search query.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  /// Save search query to Firestore for search history
  void saveSearchQuery(String query) async {
    FirebaseFirestore.instance.collection('searchHistory').add({
      'query': query,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Clear current images and fetch based on a new search query
  void onSearch(String query) {
    setState(() {
      images.clear(); // Clear the current list
      searchQuery = query;
      currentPage = 1; // Reset to the first page for new search
    });
    fetchImages(query: query);
  }

  /// Load more images when user scrolls to the end of the carousel
  void loadMoreImages() {
    currentPage++; // Move to the next page
    fetchImages(query: searchQuery); // Load next batch of images
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Home Screen")),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchHistoryScreen(onSearch: onSearch)),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Search bar for images
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: onSearch, // Trigger search on submit
            ),
          ),
          Expanded(
            child: images.isEmpty && !isLoading
                ? Center(child: Text('No images found.')) // Show if no images found
                : Column(
              children: [
                Expanded(
                  child: CarouselSlider.builder(
                    itemCount: images.length,
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height * 0.6,
                      scrollDirection: Axis.vertical, // Vertical scrolling
                      enableInfiniteScroll: false,
                      onPageChanged: (index, reason) {
                        // Load more images when reaching last image
                        if (index == images.length - 1) {
                          loadMoreImages();
                        }
                      },
                    ),
                    itemBuilder: (context, index, realIndex) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0), // Add equal vertical spacing
                        child: Image.network(
                          images[index],
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
                if (isLoading)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(), // Show loading spinner
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
