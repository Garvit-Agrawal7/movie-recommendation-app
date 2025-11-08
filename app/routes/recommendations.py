from flask import Blueprint, jsonify, request
from app.recommendation.recommendation_algo import RecommendationAlgorithm
from app.recommendation.questions import Questions
from app.database.data_manager import DatabaseManager

bp = Blueprint('recommendations', __name__, url_prefix='/recommendations')

db_manager = DatabaseManager()
recommendation_algo = RecommendationAlgorithm()
questions_service = Questions()


@bp.route('/recommend', methods=['POST'])
def recommend():
    try:
        data = request.get_json()
        user_answers = data.get('answers', {})

        preferences = transform_answers_to_preferences(user_answers)

        recommendations = recommendation_algo.recommend_movies(preferences)

        if not recommendations:
            recommendations = []

        return jsonify({
            'status': 'success',
            'count': len(recommendations),
            'data': recommendations
        }), 200

    except Exception as e:
        return jsonify({
            'status': 'error',
            'error': str(e)
        }), 500


def transform_answers_to_preferences(answers):
    """Transform answers to preferences"""
    preferences = {
        'genres': [],
        'duration': (),
        'age_range': (),
        'popularity': 6,
    }

    if '1' in answers:
        vibe = answers['1']
        question = questions_service.get_question(1)
        preferences['genres'] = question['genre_mapping'].get(vibe, [])

    if '2' in answers:
        age = answers['2']
        question = questions_service.get_question(2)
        preferences['age_range'] = question['year_mapping'].get(age, [])

    if '3' in answers:
        duration = answers['3']
        question = questions_service.get_question(3)
        preferences['duration'] = question['duration_mapping'].get(duration, [])

    return preferences
