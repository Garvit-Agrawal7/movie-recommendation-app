class Movie {
  final int id;
  final String title;
  final String genres;
  final int releaseYear;
  final double rating;
  final String description;
  final String? posterUrl;
  final String? popularityScore;

  Movie({
    required this.id,
    required this.title,
    required this.genres,
    required this.releaseYear,
    required this.rating,
    required this.description,
    this.posterUrl,
    this.popularityScore,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'],
      genres: json['genres'],
      releaseYear: json['release_year'] is int
          ? json['release_year']
          : int.tryParse(json['release_year'].toString()) ?? 0,
      rating: json['rating'] is double
          ? json['rating']
          : double.tryParse(json['rating'].toString()) ?? 0.0,
      description: json['description'] ?? '',
      posterUrl: json['poster_url'],
    );
  }
}
