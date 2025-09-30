// lib/widgets/movie_card.dart

import 'package:flutter/material.dart';
import '../models/movie_model.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final bool isFocused;

  const MovieCard({super.key, required this.movie, required this.isFocused});

  @override
  Widget build(BuildContext context) {
    // The widget now only contains the main Card for the poster.
    // The entire reflection Column has been removed.
    return Card(
      elevation: isFocused ? 12 : 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        movie.imagePath,
        fit: BoxFit.cover,
        height: 320,
        width: 220,
      ),
    );
  }
}
