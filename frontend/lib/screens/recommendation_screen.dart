import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/question_provider.dart';
import '../providers/recommendation_provider.dart';
import '../widgets/movie_widget.dart';
import './questions_screen.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  int pageNo = 1;

  @override
  void initState() {
    super.initState();
    final answers = Provider.of<QuestionProvider>(
      context,
      listen: false,
    ).answers;
    Provider.of<RecommendationProvider>(
      context,
      listen: false,
    ).fetchRecommendations(answers, pageNo);
  }

  void fetchNextPage() {
    setState(() => pageNo++);
    final answers = Provider.of<QuestionProvider>(
      context,
      listen: false,
    ).answers;
    Provider.of<RecommendationProvider>(
      context,
      listen: false,
    ).fetchRecommendations(answers, pageNo);
  }

  void fetchPreviousPage() {
    if (pageNo > 1) {
      setState(() => pageNo--);
      final answers = Provider.of<QuestionProvider>(
        context,
        listen: false,
      ).answers;
      Provider.of<RecommendationProvider>(
        context,
        listen: false,
      ).fetchRecommendations(answers, pageNo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Color(0xFFFAFAFA)),
        title: Text(
          'Your Recommendations',
          style: TextStyle(color: Color(0xFFFAFAFA)),
        ),
        backgroundColor: Color(0xFF323643),
      ),
      body: Consumer<RecommendationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF606470)),
                  SizedBox(height: 16),
                  Text('Finding perfect movies for you...'),
                ],
              ),
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
                ],
              ),
            );
          }

          if (provider.recommendations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.movie_filter, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No recommendations found'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Try Again'),
                  ),
                ],
              ),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (pageNo > 1)
                      GestureDetector(
                        onTap: fetchPreviousPage,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_back,
                              color: Color(0xFF606470),
                              size: 20,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Previous',
                              style: TextStyle(
                                color: Color(0xFF606470),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Spacer(),
                    GestureDetector(
                      onTap: fetchNextPage,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Next',
                            style: TextStyle(
                              color: Color(0xFF606470),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward,
                            color: Color(0xFF606470),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  itemCount: provider.recommendations.length,
                  itemBuilder: (context, index) {
                    return MovieCard(movie: provider.recommendations[index]);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Provider.of<QuestionProvider>(
                        context,
                        listen: false,
                      ).resetQuestions();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuestionsScreen(),
                        ),
                      );
                    },
                    icon: Icon(Icons.refresh),
                    label: Text('Find a new movie'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF323643),
                      foregroundColor: Color(0xFFFAFAFA),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
