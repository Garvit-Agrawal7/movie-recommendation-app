from flask import Flask
from flask_cors import CORS
from flask_restful import Api


def create_app():
    app = Flask(__name__)

    CORS(app, resources={r"/api/*": {"origins": "*"}})

    api = Api(app)

    from app.routes import question_routes, recommendations
    app.register_blueprint(question_routes.bp)
    app.register_blueprint(recommendations.bp)

    return app
