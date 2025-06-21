import 'package:flutter/material.dart';
import '../../db/database_helper.dart';
import '../../models/loan.dart';
import 'loan_edit_screen.dart';

class LoanListScreen extends StatefulWidget {
  const LoanListScreen({super.key});

  @override
  _LoanListScreenState createState() => _LoanListScreenState();
}

class _LoanListScreenState extends State<LoanListScreen> {
  late Future<List<Loan>> _loansFuture;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _showActiveOnly = true;

  @override
  void initState() {
    super.initState();
    _refreshLoans();
  }

  Future<void> _refreshLoans() async {
    setState(() {
      _loansFuture = _getLoans();
    });
  }

  Future<List<Loan>> _getLoans() async {
    final db = await _dbHelper.database;
    String where = _showActiveOnly ? 'loans.return_date IS NULL' : '1=1';
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT loans.*, books.title as book_title, members.name as member_name 
      FROM loans
      INNER JOIN books ON loans.book_id = books.id
      INNER JOIN members ON loans.member_id = members.id
      WHERE $where
      ORDER BY loans.loan_date DESC
    ''');
    return List.generate(maps.length, (i) => Loan.fromMap(maps[i]));
  }

  Future<void> _returnLoan(int loanId, int bookId) async {
    final db = await _dbHelper.database;
    await db.update(
      'loans',
      {'return_date': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [loanId],
    );
    await db.update(
      'books',
      {'available': 1},
      where: 'id = ?',
      whereArgs: [bookId],
    );
    _refreshLoans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoanEditScreen()),
          );
          _refreshLoans();
        },
      ),
      appBar: AppBar(
        title: const Text('Prêts'),
        actions: [
          Switch(
            value: _showActiveOnly,
            onChanged: (value) {
              setState(() {
                _showActiveOnly = value;
                _refreshLoans();
              });
            },
            activeColor: Colors.white,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Center(
              child: Text(
                _showActiveOnly ? 'Actifs' : 'Tous',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Loan>>(
        future: _loansFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(_showActiveOnly
                  ? 'Aucun prêt actif'
                  : 'Aucun prêt trouvé'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final loan = snapshot.data![index];
                return Card(
                  child: ListTile(
                    title: Text(loan.bookTitle ?? 'Livre inconnu'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Emprunteur: ${loan.memberName ?? 'Inconnu'}'),
                        Text('Date: ${loan.loanDate.toLocal()}'),
                        if (loan.returnDate != null)
                          Text('Retour: ${loan.returnDate!.toLocal()}'),
                      ],
                    ),
                    trailing: loan.returnDate == null
                        ? IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () => _returnLoan(loan.id!, loan.bookId),
                          )
                        : null,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}