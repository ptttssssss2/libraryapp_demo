import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class BorrowRecord {
  final String bookId;
  final String bookTitle;
  final String author;
  final String imagePath;
  final DateTime borrowDate;
  final DateTime returnDate;
  final String status;
  final String uid;

  BorrowRecord({
    required this.bookId,
    required this.bookTitle,
    required this.author,
    required this.imagePath,
    required this.borrowDate,
    required this.returnDate,
    required this.status,
    required this.uid,
  });

  factory BorrowRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BorrowRecord(
      bookId: data['bookId'] as String? ?? doc.id,
      bookTitle: data['bookTitle'] as String? ?? 'No title',
      author: data['author'] as String? ?? 'Unknown',
      imagePath: data['imagePath'] as String? ?? '',
      borrowDate: (data['borrowDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      returnDate: (data['returnDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: (data['status'] as String?)?.toLowerCase() ?? 'borrowed',
      uid: data['uid'] as String? ?? '',
    );
  }

  bool get isReturned => status == 'returned';
  bool get isOverdue => !isReturned && returnDate.isBefore(DateTime.now());

  String get statusText {
    if (isReturned) return 'Returned';
    if (isOverdue) return 'Overdue';
    return 'Borrowed';
  }

  Color get statusColor {
    if (isReturned) return Colors.green;
    if (isOverdue) return Colors.red;
    return Colors.orange;
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<BorrowRecord> _borrowHistory = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadBorrowHistory();
  }

  Future<void> _loadBorrowHistory() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      debugPrint('Loading history for user: ${user.uid}');

      final querySnapshot = await FirebaseFirestore.instance
          .collection('borrowed_books')
          .where('uid', isEqualTo: user.uid)
          .orderBy('borrowDate', descending: true)
          .get();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _borrowHistory = querySnapshot.docs
            .map((doc) => BorrowRecord.fromFirestore(doc))
            .toList();
      });

      debugPrint('Loaded ${_borrowHistory.length} records');

    } catch (e) {
      debugPrint('Error loading history: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Widget _buildHistoryItem(BorrowRecord record) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: _buildBookCover(record),
        title: Text(record.bookTitle),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Author: ${record.author}'),
            const SizedBox(height: 4),
            Text('Borrowed: ${DateFormat('dd/MM/yyyy').format(record.borrowDate)}'),
            Text('Due: ${DateFormat('dd/MM/yyyy').format(record.returnDate)}'),
            const SizedBox(height: 4),
            Text(
              'Status: ${record.statusText}',
              style: TextStyle(
                color: record.statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Icon(
          record.isReturned ? Icons.check_circle : Icons.access_time,
          color: record.statusColor,
        ),
      ),
    );
  }

  Widget _buildBookCover(BorrowRecord record) {
    return SizedBox(
      width: 50,
      height: 70,
      child: record.imagePath.isNotEmpty
          ? Image.network(
              record.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
            )
          : _buildPlaceholderIcon(),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.book, size: 30, color: Colors.grey),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 50, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Failed to load history'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadBorrowHistory,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history, size: 50, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No borrowing history found'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadBorrowHistory,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Borrowing History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? _buildLoadingIndicator()
          : _hasError
              ? _buildErrorState()
              : _borrowHistory.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadBorrowHistory,
                      child: ListView.builder(
                        itemCount: _borrowHistory.length,
                        itemBuilder: (context, index) {
                          return _buildHistoryItem(_borrowHistory[index]);
                        },
                      ),
                    ),
    );
  }
}