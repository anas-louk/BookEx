import 'package:flutter/material.dart';
import '../../db/database_helper.dart';
import '../../models/book.dart';

class BookEditScreen extends StatefulWidget {
  final Book? book;
  const BookEditScreen({this.book, super.key});

  @override
  State<BookEditScreen> createState() => _BookEditScreenState();
}

class _BookEditScreenState extends State<BookEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _author;
  late String _isbn;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _title = widget.book?.title ?? '';
    _author = widget.book?.author ?? '';
    _isbn = widget.book?.isbn ?? '';
  }

  Future<void> _saveBook() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final book = Book(
        id: widget.book?.id,
        title: _title,
        author: _author,
        isbn: _isbn,
        available: widget.book?.available ?? true,
      );

      final db = await _dbHelper.database;
      if (book.id == null) {
        await db.insert('books', book.toMap());
      } else {
        await db.update(
          'books',
          book.toMap(),
          where: 'id = ?',
          whereArgs: [book.id],
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book == null ? 'Nouveau Livre' : 'Modifier Livre'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Titre'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Veuillez entrer un titre' : null,
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                initialValue: _author,
                decoration: const InputDecoration(labelText: 'Auteur'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Veuillez entrer un auteur' : null,
                onSaved: (value) => _author = value!,
              ),
              TextFormField(
                initialValue: _isbn,
                decoration: const InputDecoration(labelText: 'ISBN'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Veuillez entrer un ISBN' : null,
                onSaved: (value) => _isbn = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveBook,
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
