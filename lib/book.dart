enum ReadingStatus {
  wantToRead('Want to Read'),
  reading('Currently Reading'),
  read('Read');

  const ReadingStatus(this.label);
  final String label;
}

/// A book. Search results only use the first few fields; the rest hold the
/// user's personal data once the book is saved to the library.
class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    this.coverUrl,
    this.year,
    this.publisher,
    this.description,
    this.genres = const [],
    this.status = ReadingStatus.wantToRead,
    this.favorite = false,
    this.rating = 0,
    this.review = '',
    this.progress = 0,
    this.addedAt,
    this.isSample = false,
  });

  final String id;
  final String title;
  final String author;
  final String? coverUrl;
  final int? year;
  final String? publisher;
  final String? description;
  final List<String> genres;

  // Personal data
  final ReadingStatus status;
  final bool favorite;
  final int rating; // 0 = not rated
  final String review;
  final int progress; // 0-100
  final DateTime? addedAt;
  final bool isSample;

  Book copyWith({
    String? description,
    ReadingStatus? status,
    bool? favorite,
    int? rating,
    String? review,
    int? progress,
    DateTime? addedAt,
    bool? isSample,
  }) => Book(
    id: id,
    title: title,
    author: author,
    coverUrl: coverUrl,
    year: year,
    publisher: publisher,
    description: description ?? this.description,
    genres: genres,
    status: status ?? this.status,
    favorite: favorite ?? this.favorite,
    rating: rating ?? this.rating,
    review: review ?? this.review,
    progress: progress ?? this.progress,
    addedAt: addedAt ?? this.addedAt,
    isSample: isSample ?? this.isSample,
  );

  /// Used to spot the same book even if it has a different id.
  String get matchKey => '${_norm(title)}|${_norm(author)}';
  static String _norm(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'author': author,
    'coverUrl': coverUrl,
    'year': year,
    'publisher': publisher,
    'description': description,
    'status': status.name,
    'favorite': favorite,
    'rating': rating,
    'review': review,
    'progress': progress,
    'addedAt': addedAt?.toIso8601String(),
    'isSample': isSample,
  };

  /// Returns null if the stored data is unusable.
  static Book? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'], title = raw['title'];
    if (id is! String || title is! String) return null;
    return Book(
      id: id,
      title: title,
      author: raw['author'] is String ? raw['author'] : 'Unknown author',
      coverUrl: raw['coverUrl'] is String ? raw['coverUrl'] : null,
      year: raw['year'] is int ? raw['year'] : null,
      publisher: raw['publisher'] is String ? raw['publisher'] : null,
      description: raw['description'] is String ? raw['description'] : null,
      status: ReadingStatus.values.firstWhere(
        (s) => s.name == raw['status'],
        orElse: () => ReadingStatus.wantToRead,
      ),
      favorite: raw['favorite'] == true,
      rating: raw['rating'] is int ? (raw['rating'] as int).clamp(0, 5) : 0,
      review: raw['review'] is String ? raw['review'] : '',
      progress: raw['progress'] is int
          ? (raw['progress'] as int).clamp(0, 100)
          : 0,
      addedAt: DateTime.tryParse('${raw['addedAt']}'),
      isSample: raw['isSample'] == true,
    );
  }
}

String _isbn(String isbn) =>
    'https://covers.openlibrary.org/b/isbn/$isbn-M.jpg?default=false';

/// Built-in sample books: used offline and for "Recommended" suggestions.
final List<Book> sampleBooks = [
  Book(
    id: 'sample:hobbit',
    title: 'The Hobbit',
    author: 'J.R.R. Tolkien',
    year: 1937,
    coverUrl: _isbn('9780547928227'),
    genres: const ['fantasy', 'fiction'],
  ),
  Book(
    id: 'sample:dune',
    title: 'Dune',
    author: 'Frank Herbert',
    year: 1965,
    coverUrl: _isbn('9780441172719'),
    genres: const ['science fiction', 'fiction'],
  ),
  Book(
    id: 'sample:mockingbird',
    title: 'To Kill a Mockingbird',
    author: 'Harper Lee',
    year: 1960,
    coverUrl: _isbn('9780061120084'),
    genres: const ['fiction'],
  ),
  Book(
    id: 'sample:pride',
    title: 'Pride and Prejudice',
    author: 'Jane Austen',
    year: 1813,
    coverUrl: _isbn('9780141439518'),
    genres: const ['romance', 'fiction'],
  ),
  Book(
    id: 'sample:orient',
    title: 'Murder on the Orient Express',
    author: 'Agatha Christie',
    year: 1934,
    coverUrl: _isbn('9780062693662'),
    genres: const ['mystery', 'fiction'],
  ),
  Book(
    id: 'sample:1984',
    title: '1984',
    author: 'George Orwell',
    year: 1949,
    coverUrl: _isbn('9780451524935'),
    genres: const ['science fiction', 'fiction'],
  ),
  Book(
    id: 'sample:hailmary',
    title: 'Project Hail Mary',
    author: 'Andy Weir',
    year: 2021,
    coverUrl: _isbn('9780593135204'),
    genres: const ['science fiction'],
  ),
  Book(
    id: 'sample:gatsby',
    title: 'The Great Gatsby',
    author: 'F. Scott Fitzgerald',
    year: 1925,
    coverUrl: _isbn('9780743273565'),
    genres: const ['fiction', 'romance'],
  ),
  Book(
    id: 'sample:name',
    title: 'The Name of the Wind',
    author: 'Patrick Rothfuss',
    year: 2007,
    coverUrl: _isbn('9780756404741'),
    genres: const ['fantasy'],
  ),
  Book(
    id: 'sample:girl',
    title: 'The Girl with the Dragon Tattoo',
    author: 'Stieg Larsson',
    year: 2005,
    coverUrl: _isbn('9780307454546'),
    genres: const ['mystery'],
  ),
];

const sampleQuotes = [
  ('A reader lives a thousand lives before he dies.', 'George R.R. Martin'),
  ('So many books, so little time.', 'Frank Zappa'),
  ('Books are a uniquely portable magic.', 'Stephen King'),
  ('There is no friend as loyal as a book.', 'Ernest Hemingway'),
];
