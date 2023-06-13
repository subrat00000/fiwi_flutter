class Book {
  const Book(
      {required this.bookName,
      required this.bookCategory,
      required this.authorName,
      required this.publication,
      required this.bookLocation,
      required this.quantity,
      required this.isbn,
      required this.bookId});

  final String bookName;
  final String bookCategory;
  final String authorName;
  final String publication;
  final String bookLocation;
  final String quantity;
  final String bookId;
  final String isbn;
}