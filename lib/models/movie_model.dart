// lib/models/movie_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'movie_model.g.dart';

@JsonSerializable()
class Movie {
  final int id;
  final String title;
  final String overview;

  @JsonKey(name: 'poster_path')
  // --- FIX 1: Allow posterPath to be null ---
  final String? posterPath;

  @JsonKey(name: 'backdrop_path')
  // --- FIX 2: Allow backdropPath to be null ---
  final String? backdropPath;

  @JsonKey(name: 'vote_average')
  final double voteAverage;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
  });

  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);
  Map<String, dynamic> toJson() => _$MovieToJson(this);

  // --- FIX 3: Handle null paths gracefully ---
  String get fullPosterPath {
    if (posterPath != null) {
      return 'https://image.tmdb.org/t/p/w500$posterPath';
    }
    // Return a placeholder image URL if the poster path is null
    return 'https://via.placeholder.com/500x750?text=No+Image';
  }

  String get fullBackdropPath {
    if (backdropPath != null) {
      return 'https://image.tmdb.org/t/p/w1280$backdropPath';
    }
    // Fallback to the poster if the backdrop is null
    return fullPosterPath;
  }
}
