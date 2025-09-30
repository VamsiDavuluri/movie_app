// lib/screens/movie_showcase_screen.dart

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/movie_data.dart';
import '../widgets/movie_card.dart';

class MovieShowcaseScreen extends StatefulWidget {
  const MovieShowcaseScreen({super.key});

  @override
  State<MovieShowcaseScreen> createState() => _MovieShowcaseScreenState();
}

class _MovieShowcaseScreenState extends State<MovieShowcaseScreen> {
  final PageController _pageController = PageController(
    viewportFraction: 0.55,
    initialPage: 5000,
  );

  double _currentPage = 5000.0;
  int _focusedIndex = 5000;
  Timer? _slideshowTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSlideshow();
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    _stopSlideshow();
    _pageController.dispose();
    super.dispose();
  }

  void _startSlideshow() {
    if (_slideshowTimer != null && _slideshowTimer!.isActive) return;
    _slideshowTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || !_pageController.hasClients) {
        timer.cancel();
        return;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopSlideshow() {
    _slideshowTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPage.round() != _focusedIndex) {
      _focusedIndex = _currentPage.round();
      HapticFeedback.lightImpact();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey<int>(_focusedIndex),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    movieData[_focusedIndex % movieData.length].imagePath,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
            ),
          ),
          Listener(
            onPointerDown: (_) => _stopSlideshow(),
            child: SizedBox(
              // --- THE ONLY CHANGE IN THIS FILE ---
              // Changed height from 500 back to 400 to re-center the posters.
              height: 400,
              child: PageView.builder(
                controller: _pageController,
                itemCount: 10000,
                itemBuilder: (context, index) {
                  final movie = movieData[index % movieData.length];

                  Matrix4 matrix = Matrix4.identity();
                  double pageDifference = index - _currentPage;

                  matrix.setEntry(3, 2, 0.001);
                  const double rotationAngle = 0.8;
                  matrix.rotateY(pageDifference * -rotationAngle);
                  double scale = 1 - pageDifference.abs() * 0.15;
                  matrix.scale(scale, scale, 1.0);

                  return Transform(
                    transform: matrix,
                    alignment: Alignment.center,
                    child: MovieCard(
                      movie: movie,
                      isFocused: index == _focusedIndex,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
