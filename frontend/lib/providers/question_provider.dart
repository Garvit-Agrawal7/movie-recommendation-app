import 'package:flutter/foundation.dart';

import '../models/questions.dart';
import '../services/api_service.dart';

class QuestionProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Question> _questions = [];
  Map<String, String> _answers = {};
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  String? _error;

  List<Question> get questions => _questions;
  Map<String, String> get answers => _answers;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Question? get currentQuestion => _currentQuestionIndex < _questions.length
      ? _questions[_currentQuestionIndex]
      : null;

  bool get hasNextQuestion => _currentQuestionIndex < _questions.length - 1;
  bool get isLastQuestion => _currentQuestionIndex == _questions.length - 1;

  Future<void> loadQuestions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _questions = await _apiService.fetchQuestions();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void answerQuestion(String answer) {
    if (currentQuestion != null) {
      _answers[currentQuestion!.id.toString()] = answer;
      notifyListeners();
    }
  }

  void nextQuestion() {
    if (hasNextQuestion) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  void resetQuestions() {
    _currentQuestionIndex = 0;
    _answers.clear();
    notifyListeners();
  }
}
