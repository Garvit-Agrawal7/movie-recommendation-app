import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/question_provider.dart';
import '../providers/recommendation_provider.dart';
import '../widgets/question_widget.dart';
import 'recommendation_screen.dart';

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({super.key});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuestionProvider>(context, listen: false).loadQuestions();
    });
  }

  void _handleAnswer(BuildContext context, String answer) {
    final questionProvider = Provider.of<QuestionProvider>(
      context,
      listen: false,
    );
    questionProvider.answerQuestion(answer);

    if (questionProvider.isLastQuestion) {
      _generateRecommendations(context);
    } else {
      questionProvider.nextQuestion();
    }
  }

  Future<void> _generateRecommendations(BuildContext context) async {
    final questionProvider = Provider.of<QuestionProvider>(
      context,
      listen: false,
    );
    final recommendationProvider = Provider.of<RecommendationProvider>(
      context,
      listen: false,
    );

    await recommendationProvider.fetchRecommendations(
      questionProvider.answers,
      1,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => RecommendationsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Find Your Movie',
          style: TextStyle(color: Color(0xFFFAFAFA)),
        ),
        backgroundColor: Color(0xFF323643),
        iconTheme: IconThemeData(color: Color(0xFFFAFAFA)),
      ),
      body: Consumer<QuestionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: Color(0xFF606470)),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error: ${provider.error}', textAlign: TextAlign.center),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadQuestions(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.currentQuestion == null) {
            return Center(child: Text('No questions available'));
          }

          return Column(
            children: [
              LinearProgressIndicator(
                value:
                    (provider.currentQuestionIndex) / provider.questions.length,
                backgroundColor: Color(0xFFFAFAFA),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF606470)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: QuestionCard(
                    question: provider.currentQuestion!,
                    onAnswerSelected: (answer) =>
                        _handleAnswer(context, answer),
                  ),
                ),
              ),
              if (provider.currentQuestionIndex > 0)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () => provider.previousQuestion(),
                    child: Text(
                      'Previous',
                      style: TextStyle(color: Color(0xFF323643)),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
