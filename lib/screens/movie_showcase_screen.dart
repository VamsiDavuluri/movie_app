// lib/screens/movie_showcase_screen.dart

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/movie_model.dart';
import '../services/api_service.dart';
import '../widgets/movie_card.dart';
import 'details_screen.dart';

class MovieShowcaseScreen extends StatefulWidget {
  const MovieShowcaseScreen({super.key});

  @override
  State<MovieShowcaseScreen> createState() => _MovieShowcaseScreenState();
}

class _MovieShowcaseScreenState extends State<MovieShowcaseScreen> {
  late Future<List<Movie>> _nowPlayingMovies;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _nowPlayingMovies = ApiService().getNowPlayingMovies();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<List<Movie>>(
        future: _nowPlayingMovies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          if (snapshot.hasData) {
            final movies = snapshot.data!;
            if (movies.isEmpty) {
              return const Center(
                child: Text(
                  'No movies found.',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }
            return LiveMovieCarousel3D(movies: movies);
          }
          return const Center(
            child: Text(
              'Something went wrong.',
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}

class LiveMovieCarousel3D extends StatefulWidget {
  final List<Movie> movies;
  const LiveMovieCarousel3D({super.key, required this.movies});

  @override
  State<LiveMovieCarousel3D> createState() => _LiveMovieCarousel3DState();
}

class _LiveMovieCarousel3DState extends State<LiveMovieCarousel3D> {
  static const int _initialPage = 5000;
  late final PageController _pageController;
  double _currentPage = _initialPage.toDouble();
  int _focusedIndex = _initialPage;
  Timer? _slideshowTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.6,
      initialPage: _initialPage,
    );
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSlideshow());
  }

  @override
  void dispose() {
    _slideshowTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startSlideshow() {
    _slideshowTimer?.cancel();
    _slideshowTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || !_pageController.hasClients) return;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopSlideshow() {
    _slideshowTimer?.cancel();
  }

  // A helper widget to build the blurred background to avoid code duplication
  Widget _buildBlurredBackground(String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(color: Colors.black.withOpacity(0.5)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPage.round() != _focusedIndex) {
      _focusedIndex = _currentPage.round();
      HapticFeedback.lightImpact();
    }

    // --- REAL-TIME BACKGROUND SYNC LOGIC ---
    // 1. Get the integer indices of the pages we are between.
    final int currentPageIndex = _currentPage.floor() % widget.movies.length;
    final int nextPageIndex = _currentPage.ceil() % widget.movies.length;

    // 2. Calculate the scroll progress (a value from 0.0 to 1.0).
    final double scrollProgress = _currentPage - _currentPage.floor();

    return Stack(
      alignment: Alignment.center,
      children: [
        // --- NEW, PERFECTLY SYNCHRONIZED BACKGROUND ---
        // A stack of two backgrounds that cross-fade based on scroll progress.
        Stack(
          fit: StackFit.expand,
          children: [
            // The "current" page background, fading out.
            Opacity(
              opacity: 1 - scrollProgress,
              child: _buildBlurredBackground(
                widget.movies[currentPageIndex].fullBackdropPath,
              ),
            ),
            // The "next" page background, fading in.
            if (currentPageIndex != nextPageIndex) // Prevents flicker on snap
              Opacity(
                opacity: scrollProgress,
                child: _buildBlurredBackground(
                  widget.movies[nextPageIndex].fullBackdropPath,
                ),
              ),
          ],
        ),

        Listener(
          onPointerDown: (_) => _stopSlideshow(),
          onPointerUp: (_) => _startSlideshow(),
          child: SizedBox(
            height: 400,
            child: PageView.builder(
              clipBehavior: Clip.none,
              controller: _pageController,
              itemCount: 10000,
              itemBuilder: (context, index) {
                final movie = widget.movies[index % widget.movies.length];

                final double pageDifference = index - _currentPage;
                final Matrix4 matrix = Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(pageDifference * -0.8);
                final double scale = 1 - pageDifference.abs() * 0.15;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsScreen(movie: movie),
                      ),
                    );
                  },
                  child: Transform.scale(
                    scale: scale,
                    child: Transform(
                      transform: matrix,
                      alignment: Alignment.center,
                      child: MovieCard(
                        imageUrl: movie.fullPosterPath,
                        isFocused: index == _focusedIndex,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
