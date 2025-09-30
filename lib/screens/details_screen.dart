// lib/screens/details_screen.dart

import 'package:flutter/material.dart';
import 'dart:ui'; // Needed for the blur effect
import '../models/movie_model.dart';

class DetailsScreen extends StatelessWidget {
  final Movie movie;
  const DetailsScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      // The body is a Stack to layer our components
      body: Stack(
        fit: StackFit.expand,
        children: [
          // --- LAYER 1: THE FULL-SCREEN BLURRED BACKGROUND ---
          // This uses the backdrop image to provide ambient color.
          Image.network(
            movie.fullBackdropPath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // If backdrop fails, create a simple black background
              return Container(color: Colors.black);
            },
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
            child: Container(
              // A dark overlay ensures text is always readable.
              color: Colors.black.withOpacity(0.6),
            ),
          ),

          // --- LAYER 2: THE SCROLLABLE CONTENT ---
          // A SingleChildScrollView allows all the details to scroll smoothly.
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // A spacer to push content below the phone's status bar
                  SizedBox(height: MediaQuery.of(context).padding.top + 60),

                  // --- THE MOVIE POSTER ---
                  // This is now the main visual element, guaranteed to have the correct aspect ratio.
                  Card(
                    elevation: 12,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SizedBox(
                      width: screenSize.width * 0.5, // 50% of screen width
                      child: Image.network(
                        movie.fullPosterPath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- MOVIE TITLE ---
                  Text(
                    movie.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- OVERVIEW SECTION ---
                  const Text(
                    'Overview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    movie.overview.isEmpty
                        ? "No overview available."
                        : movie.overview,
                    textAlign: TextAlign.justify, // Justified text looks clean
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 16,
                      height: 1.5, // Increased line spacing
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- RATING SECTION ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${movie.voteAverage.toStringAsFixed(1)} / 10',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // Extra padding at the bottom for scroll space
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),

          // --- LAYER 3: THE FLOATING BACK BUTTON ---
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.5),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
