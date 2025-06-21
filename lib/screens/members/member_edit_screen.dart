import 'package:flutter/material.dart';
import '../../models/member.dart';
import '../../db/database_helper.dart';

class MemberEditScreen extends StatefulWidget {
  final Member? member;

  const MemberEditScreen({this.member, super.key});

  @override
  _MemberEditScreenState createState() => _MemberEditScreenState();
}

class _MemberEditScreenState extends State<MemberEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String? _email;
  late String? _phone;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _name = widget.member?.name ?? '';
    _email = widget.member?.email;
    _phone = widget.member?.phone;
  }

  Future<void> _saveMember() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final member = Member(
        id: widget.member?.id,
        name: _name,
        email: _email,
        phone: _phone,
      );

      final db = await _dbHelper.database;
      if (member.id == null) {
        await db.insert('members', member.toMap());
      } else {
        await db.update(
          'members',
          member.toMap(),
          where: 'id = ?',
          whereArgs: [member.id],
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.member == null ? 'Ajouter un membre' : 'Modifier le membre'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez entrer un nom' : null,
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) => _email = value,
              ),
              TextFormField( 
                initialValue: _phone,
                decoration: const InputDecoration(labelText: 'Téléphone'),
                keyboardType: TextInputType.phone,
                onSaved: (value) => _phone = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMember,
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}