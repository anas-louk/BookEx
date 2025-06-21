import 'package:flutter/material.dart';
import 'package:miniprojet/db/database_helper.dart';
import 'package:miniprojet/models/book.dart';
import 'package:miniprojet/models/member.dart';
import 'package:miniprojet/models/loan.dart';


class LoanEditScreen extends StatefulWidget {
  const LoanEditScreen({super.key});

  @override
  _LoanEditScreenState createState() => _LoanEditScreenState();
}

class _LoanEditScreenState extends State<LoanEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  Book? _selectedBook;
  Member? _selectedMember;
  List<Book> _availableBooks = [];
  List<Member> _members = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = await _dbHelper.database;
    
    // Charger les livres disponibles
    final List<Map<String, dynamic>> bookMaps = await db.query(
      'books',
      where: 'available = 1',
    );
    setState(() {
      _availableBooks = List.generate(
        bookMaps.length, 
        (i) => Book.fromMap(bookMaps[i])
      );
    });
    
    // Charger tous les membres
    final List<Map<String, dynamic>> memberMaps = await db.query('members');
    setState(() {
      _members = List.generate(
        memberMaps.length, 
        (i) => Member.fromMap(memberMaps[i])
      );
    });
  }

  Future<void> _saveLoan() async {
    if (_formKey.currentState!.validate() && 
        _selectedBook != null && 
        _selectedMember != null) {
      
      final loan = Loan(
        bookId: _selectedBook!.id!,
        memberId: _selectedMember!.id!,
        loanDate: DateTime.now(),
      );

      final db = await _dbHelper.database;
      await db.insert('loans', loan.toMap());
      
      // Mettre à jour la disponibilité du livre
      await db.update(
        'books',
        {'available': 0},
        where: 'id = ?',
        whereArgs: [_selectedBook!.id],
      );
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau prêt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<Book>(
                decoration: const InputDecoration(labelText: 'Livre'),
                value: _selectedBook,
                items: _availableBooks.map((book) {
                  return DropdownMenuItem<Book>(
                    value: book,
                    child: Text('${book.title} (${book.author})'),
                  );
                }).toList(),
                onChanged: (book) {
                  setState(() {
                    _selectedBook = book;
                  });
                },
                validator: (value) =>
                    value == null ? 'Veuillez sélectionner un livre' : null,
              ),
              DropdownButtonFormField<Member>(
                decoration: const InputDecoration(labelText: 'Membre'),
                value: _selectedMember,
                items: _members.map((member) {
                  return DropdownMenuItem<Member>(
                    value: member,
                    child: Text(member.name),
                  );
                }).toList(),
                onChanged: (member) {
                  setState(() {
                    _selectedMember = member;
                  });
                },
                validator: (value) =>
                    value == null ? 'Veuillez sélectionner un membre' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveLoan,
                child: const Text('Enregistrer le prêt'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}