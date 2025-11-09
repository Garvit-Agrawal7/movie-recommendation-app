import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/movies.dart';
import '../models/questions.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.4:5000';

  Future<List<Question>> fetchQuestions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/questions'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final questionsJson = data['data'] as List;
        return questionsJson.map((q) => Question.fromJson(q)).toList();
      } else {
        throw Exception('Failed to load questions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching questions: $e');
    }
  }

  Future<List<Movie>> generateRecommendations(
    Map<String, String> answers,
    int pageNo,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/recommendations/recommend'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'answers': answers, 'page_no': pageNo}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final moviesJson = data['data'] as List;
        return moviesJson.map((m) => Movie.fromJson(m)).toList();
      } else {
        throw Exception(
          'Failed to generate recommendations: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error generating recommendations: $e');
    }
  }
}
