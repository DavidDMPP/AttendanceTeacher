import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';
import '../models/teacher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final databaseService = Provider.of<DatabaseService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: FutureBuilder<Teacher?>(
        future: databaseService.getTeacher(authProvider.user?.uid ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Tidak ada data'));
          }
          final teacher = snapshot.data!;
          _name = teacher.name;
          _email = teacher.email;

          return Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  TextFormField(
                    initialValue: _name,
                    decoration: const InputDecoration(labelText: 'Nama'),
                    validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                    onSaved: (value) => _name = value!,
                  ),
                  TextFormField(
                    initialValue: _email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) => value!.isEmpty ? 'Email tidak boleh kosong' : null,
                    onSaved: (value) => _email = value!,
                  ),
                  ElevatedButton(
                    child: const Text('Update Profil'),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        await databaseService.updateProfile(teacher.id, {
                          'name': _name,
                          'email': _email,
                        });
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(content: Text('Profil berhasil diperbarui')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}