import 'package:flutter/material.dart';
import '../../db/database_helper.dart';
import '../../models/book.dart';
import 'book_edit_screen.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  late Future<List<Book>> _booksFuture;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _refreshBooks();
  }

  Future<void> _refreshBooks() async {
    setState(() {
      _booksFuture = _getBooks();
    });
  }

  Future<List<Book>> _getBooks() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('books');
    return List.generate(maps.length, (i) => Book.fromMap(maps[i]));
  }

  Future<void> _deleteBook(int id) async {
    final db = await _dbHelper.database;
    await db.delete('books', where: 'id = ?', whereArgs: [id]);
    _refreshBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Livres')),
      body: FutureBuilder<List<Book>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun livre trouvé'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final book = snapshot.data![index];
              return ListTile(
                title: Text(book.title),
                subtitle: Text('${book.author} - ${book.isbn}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteBook(book.id!),
                ),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookEditScreen(book: book),
                    ),
                  );
                  _refreshBooks();
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BookEditScreen()),
          );
          _refreshBooks();
        },
      ),
    );
  }
}
