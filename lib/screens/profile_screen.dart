import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
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

  Future<void> _logout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
    if (mounted) {
      // Menggunakan pushAndRemoveUntil untuk menghapus semua rute sebelumnya
      Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    }
  }

  Future<void> _updateProfile(String teacherId) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final databaseService = Provider.of<DatabaseService>(context, listen: false);
      await databaseService.updateProfile(teacherId, {
        'name': _name,
        'email': _email,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final databaseService = Provider.of<DatabaseService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: FutureBuilder<Teacher?>(
        future: authProvider.user?.uid != null
            ? databaseService.getTeacher(authProvider.user!.uid)
            : Future.value(null),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Data tidak tersedia. Silakan login kembali.'));
          }
          final teacher = snapshot.data!;
          _name = teacher.name;
          _email = teacher.email;

          return SingleChildScrollView(
            child: Form(
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
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _updateProfile(teacher.id),
                      child: const Text('Update Profil'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}