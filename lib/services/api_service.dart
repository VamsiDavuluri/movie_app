// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';

class ApiService {
  final String _apiKey = '06a327015e491dcd132657a13f1b1a8c';
  final String _baseUrl = 'https://api.themoviedb.org/3';

  Future<List<Movie>> getNowPlayingMovies() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/now_playing?api_key=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      final List<dynamic> results = decodedData['results'];
      return results.map((movieJson) => Movie.fromJson(movieJson)).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }
}
