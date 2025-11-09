import 'package:flutter/foundation.dart';

import '../models/movies.dart';
import '../services/api_service.dart';

class RecommendationProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Movie> _recommendations = [];
  bool _isLoading = false;
  String? _error;

  List<Movie> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRecommendations(
    Map<String, String> answers,
    int pageNo,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recommendations = await _apiService.generateRecommendations(
        answers,
        pageNo,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearRecommendations() {
    _recommendations.clear();
    notifyListeners();
  }
}
