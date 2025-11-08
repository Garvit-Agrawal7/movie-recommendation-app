import requests as req


class DatabaseManager:
    def __init__(self):
        self.base_url = 'https://api.themoviedb.org/3'
        self.image_base_url = 'https://image.tmdb.org/t/p/w500'
        self.api_key = '4bd5ebdd64137a63a4353545771c387d'
        self.access_token = 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0YmQ1ZWJkZDY0MTM3YTYzYTQzNTM1NDU3NzFjMzg3ZCIsIm5iZiI6MTc2MDk1OTI3Mi4wOTc5OTk4LCJzdWIiOiI2OGY2MWIyOGZkNzY2MTQ5ODE2OTE1MTUiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.oeFHIN624Qzt4oVWZ6hRiPmP2oHW4Fbbybr7QF27RnQ'
        self.headers = {"Authorization": "Bearer " + self.access_token}
        self.session = req.Session()

    def fetch(self, endpoint, params=None):
        """Internal helper function for GET requests"""
        if params is None:
            params = {}
        params["api_key"] = self.api_key
        response = self.session.get(f"{self.base_url}/{endpoint}", params=params, headers=self.headers)
        response.raise_for_status()
        return response.json()

    def get_genres(self):
        """Fetch all movie genres from TMDb"""
        data = self.fetch("genre/movie/list")
        genres = {genre["id"]: genre["name"] for genre in data.get("genres", [])}
        return genres

    def get_popular_movies(self, page):
        """Retrieve a list of popular movies"""
        data = self.fetch("movie/popular", {"page": page})
        genres = self.get_genres()

        movies = []
        for movie in data.get("results", []):
            movies.append({
                "id": movie["id"],
                "title": movie["title"],
                "genres": ", ".join(genres.get(gid, "") for gid in movie.get("genre_ids", [])),
                "release_year": movie.get("release_date", "")[:4],
                "rating": movie.get("vote_average"),
                "description": movie.get("overview"),
                "poster_url": f"{self.image_base_url}{movie.get('poster_path')}" if movie.get("poster_path") else None,
                "popularity_score": movie.get("popularity"),
            })
        return movies

    def get_movies_by_genre(self, genre_id=None, page=1):
        """Retrieve movies from a specific genre"""
        data = self.fetch("discover/movie", {"with_genres": genre_id, "page": page})
        genres = self.get_genres()

        movies = []
        for movie in data.get("results", []):
            movies.append({
                "id": movie["id"],
                "title": movie["title"],
                "genres": ", ".join(genres.get(gid, "") for gid in movie.get("genre_ids", [])),
                "release_year": movie.get("release_date", "")[:4],
                "rating": movie.get("vote_average"),
                "description": movie.get("overview"),
                "poster_url": f"{self.image_base_url}{movie.get('poster_path')}" if movie.get("poster_path") else None,
                "popularity_score": movie.get("popularity"),
            })
        return movies
