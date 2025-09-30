// lib/widgets/movie_card.dart

import 'package:flutter/material.dart';

class MovieCard extends StatelessWidget {
  final String imageUrl;
  final bool isFocused;

  const MovieCard({super.key, required this.imageUrl, required this.isFocused});

  @override
  Widget build(BuildContext context) {
    // The Column and the entire reflection section have been removed.
    // The widget is now just the main Card.
    return Card(
      elevation: isFocused ? 12 : 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        height: 320,
        width: 220,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.error, color: Colors.red));
        },
      ),
    );
  }
}
