from flask import Blueprint, jsonify, request

from app.recommendation.questions import Questions

bp = Blueprint('questions', __name__, url_prefix='/questions')
question_service = Questions()


@bp.route('/', methods=['GET'])
def get_questions():
    """Return all questions"""
    questions = question_service.get_all_questions()
    return jsonify({
        'status': 'success',
        'data': questions
    }), 200


@bp.route('/<int:question_id>', methods=['GET'])
def get_question(question_id):
    """Return specific question by ID"""
    question = question_service.get_question(question_id)
    if question:
        return jsonify({
            'status': 'success',
            'data': question
        }), 200
    return jsonify({
        'status': 'error',
        'message': 'Question not found'
    }), 404
