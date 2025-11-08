class Questions:
    def __init__(self):
        self.questions = [
            {
                "id": 1,
                "text": "What kind of vibe do you want?",
                "type": "single_choice",
                "options": ["Adventurous/Thrilling", "Relaxed/Happy", "Thought-provoking/Serious", "Emotional", "Everything Works"],
                "genre_mapping": {
                    "Adventurous/Thrilling": ["Action", "Adventure", "Thriller"],
                    "Relaxed/Happy": ["Comedy", "Romance"],
                    "Thought-provoking/Serious": ["Drama", "Documentary", "Mystery"],
                    "Emotional": ["Romance", "Emotional"],
                    "Everything Works": []
                }
            },
            {
                "id": 2,
                "text": "Do you old do you want your movie to be?",
                "type": "single_choice",
                "options": ["Last 5 years", "Last 10 years", "Last 25 years", "Show me whatever"],
                "year_mapping": {
                    "Last 5 years": (2020, 2025),
                    "Last 10 years": (2015, 2025),
                    "Last 25 years": (2000, 2025),
                    "Show me whatever": (1900, 2025),
                }
            },
            {
                "id": 3,
                "text": "How long do you want the movie to be?",
                "type": "single_choice",
                "options": ["Short (<90 min)", "Medium (90-120 min)", "Long (>120 min)", "I don't care"],
                "duration_mapping": {
                    "Short (<90 min)": (0, 90),
                    "Medium (90-120 min)": (90, 120),
                    "Long (>120 min)": (120, 300),
                    "I don't care": (0, 300),
                }
            }
        ]

    def get_question(self, question_id):
        """Return question by ID"""
        return next((q for q in self.questions if q['id'] == question_id), None)

    def get_all_questions(self):
        """Return all questions"""
        return self.questions
