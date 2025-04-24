class Book {
  final String id; // เปลี่ยนเป็น final ตามเดิม
  final String title;
  final String author;
  final String imagePath;
  final String? rating;
  final int? firstPublishYear;
  final String? loggedDate;
  final bool isRecommended; // เปลี่ยนกลับเป็น final

  Book({
    required this.id, // กำหนดให้ต้องระบุ id เสมอ
    required this.title,
    required this.author,
    required this.imagePath,
    this.rating,
    this.firstPublishYear,
    this.loggedDate,
    this.isRecommended = false,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final work = json['work'] ?? {};
    final title = work['title'] ?? 'No Title';
    final author = (json['author_names'] as List?)?.isNotEmpty == true
        ? json['author_names'][0]
        : work['author_names']?.join(', ') ?? 'Unknown Author';

    final coverId = work['cover_id']?.toString();
    final imagePath = coverId != null
        ? 'https://covers.openlibrary.org/b/id/$coverId-M.jpg'
        : 'https://via.placeholder.com/150';

    // ใช้ coverId เป็น ID ถ้ามี ไม่เช่นนั้นใช้ title + author แทน
    final id = coverId ?? '${title}_${author}'.hashCode.toString();

    return Book(
      id: id,
      title: title,
      author: author,
      imagePath: imagePath,
      firstPublishYear: work['first_publish_year'],
      loggedDate: json['logged_date'],
      isRecommended: json['is_recommended'] ?? false,
    );
  }
}