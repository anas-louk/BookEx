import 'package:flutter/material.dart';
import '../../db/database_helper.dart';
import '../../models/member.dart';
import 'member_edit_screen.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  _MemberListScreenState createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  late Future<List<Member>> _membersFuture;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _refreshMembers();
  }

  Future<void> _refreshMembers() async {
    setState(() {
      _membersFuture = _getMembers();
    });
  }

  Future<List<Member>> _getMembers() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('members');
    return List.generate(maps.length, (i) => Member.fromMap(maps[i]));
  }

  Future<void> _deleteMember(int id) async {
    final db = await _dbHelper.database;
    await db.delete('members', where: 'id = ?', whereArgs: [id]);
    _refreshMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Membres')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MemberEditScreen()),
          );
          _refreshMembers();
        },
      ),
      body: FutureBuilder<List<Member>>(
        future: _membersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun membre trouvé'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final member = snapshot.data![index];
                return Card(
                  child: ListTile(
                    title: Text(member.name),
                    subtitle: Text('${member.email ?? ''} - ${member.phone ?? ''}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteMember(member.id!),
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MemberEditScreen(member: member),
                        ),
                      );
                      _refreshMembers();
                    },
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