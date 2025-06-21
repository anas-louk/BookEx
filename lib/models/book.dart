class Book {
  int? id;
  String title;
  String author;
  String isbn;
  bool available;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.available,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'available': available ? 1 : 0,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      isbn: map['isbn'],
      available: map['available'] == 1,
    );
  }
}