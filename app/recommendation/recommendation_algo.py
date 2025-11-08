import requests
from app.database.data_manager import DatabaseManager


class RecommendationAlgorithm:
    """
    Recommendation engine that uses TMDb API to fetch movies
    based on user answers to questions about their preferences.
    """

    def __init__(self):
        self.db_manager = DatabaseManager()
        self.genre_mapping = self._load_genre_mapping()

    def _load_genre_mapping(self):
        return self.db_manager.get_genres()

    def recommend_movies(self, user_preferences, page_no):
        """
        Generate movie recommendations based on user preferences.

        Args:
            user_preferences: Dictionary containing:
                - genres: List of genre strings (e.g., ["Action", "Adventure"])
                - year_range: Tuple of (min_year, max_year)
                - duration: Tuple of (min_duration, max_duration)
                - min_rating: Minimum vote average (0-10)
            page_no: Page number

        Returns:
            List of movie dictionaries matching user preferences
        """
        try:
            preferred_genres = user_preferences.get('genres', [])
            year_range = user_preferences.get('age_range', (1900, 2025))
            duration = user_preferences.get('duration', (0, 300))
            min_rating = user_preferences.get('min_rating', 6.0)

            # Convert genre names to IDs
            genre_ids = self._convert_genres_to_ids(preferred_genres)

            recommendations = self._discover_movies(
                genre_ids=genre_ids,
                year_range=year_range,
                duration=duration,
                min_rating=min_rating,
                page_no=page_no
            )

            return recommendations

        except Exception as e:
            raise Exception(f"Error in recommendation engine: {str(e)}")

    def _convert_genres_to_ids(self, genre_names):
        """
        Args:
            genre_names: List of genre names (e.g., ["Action", "Sci-Fi"])
        Returns:
            List of genre IDs
        """
        genre_ids = []
        reverse_mapping = {v: k for k, v in self.genre_mapping.items()}

        for genre_name in genre_names:
            if genre_name in reverse_mapping:
                genre_ids.append(reverse_mapping[genre_name])

        return genre_ids

    def _discover_movies(self, genre_ids, year_range, duration, min_rating, page_no):
        """
        Args:
            genre_ids: List of genre IDs to filter by
            year_range: Tuple of (min_year, max_year)
            duration: Tuple of (min_duration, max_duration)
            min_rating: Minimum vote average threshold
            page_no: Page number
        Returns:
            List of movie dictionaries
        """
        # Convert genre IDs to comma-separated string for API
        genre_param = ",".join(str(gid) for gid in genre_ids) if genre_ids else None

        # Build query parameters for TMDb discover endpoint
        params = {
            'vote_average.gte': min_rating,
            'primary_release_date.gte': f"{year_range[0]}-01-01",
            'primary_release_date.lte': f"{year_range[1]}-12-31",
            'page': page_no,
            'include_adult': True,
            'with_runtime.gte': duration[0],
            'with_runtime.lte': duration[1],
            'sort_by': 'popularity.desc'
        }

        if genre_param:
            params['with_genres'] = genre_param

        try:
            response = requests.get(
                f"{self.db_manager.base_url}/discover/movie",
                params={**params, 'api_key': self.db_manager.api_key}
            )
            response.raise_for_status()
            data = response.json()
        except requests.exceptions.RequestException as e:
            raise Exception(f"TMDb API error: {str(e)}")

        # Process and format movie results
        movies = self._format_movies(data.get('results', []))

        return movies

    def _format_movies(self, raw_movies):
        """
        Format raw TMDb movie data into the expected format

        Args:
            raw_movies: Raw movie data from TMDb API

        Returns:
            Formatted movie list
        """
        formatted_movies = []
        image_base_url = "https://image.tmdb.org/t/p/w500"

        for movie in raw_movies:
            # Skip movies with no title or poster
            if not movie.get('title') or not movie.get('poster_path'):
                continue

            # Convert genre IDs to genre names
            genre_ids = movie.get('genre_ids', [])
            genres = ", ".join(
                self.genre_mapping.get(gid, "Unknown")
                for gid in genre_ids
            )

            # Extract release year from release date
            release_date = movie.get('release_date', '')
            release_year = release_date[:4] if release_date else 'N/A'

            formatted_movie = {
                'id': movie['id'],
                'title': movie['title'],
                'genres': genres,
                'release_year': release_year,
                'rating': movie.get('vote_average', 0),
                'description': movie.get('overview', ''),
                'poster_url': f"{image_base_url}{movie['poster_path']}",
                'popularity_score': movie.get('popularity', 0),
            }

            formatted_movies.append(formatted_movie)

        return formatted_movies
