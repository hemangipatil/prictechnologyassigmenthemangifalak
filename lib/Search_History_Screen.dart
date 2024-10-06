import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchHistoryScreen extends StatelessWidget {
  final Function(String) onSearch;

  SearchHistoryScreen({required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search History"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('searchHistory')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            final history = snapshot.data!.docs;
            return ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final query = history[index]['query'];
                return ListTile(
                  title: Text(query),
                  onTap: () {
                    onSearch(query);
                    Navigator.pop(context);
                  },
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
