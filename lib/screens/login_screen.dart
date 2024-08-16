import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:logging/logging.dart';

final _logger = Logger('LoginScreen');

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _nip = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'NIP'),
                validator: (value) {
                  if (value!.isEmpty) {
                    _logger.info('NIP is empty');
                    return 'NIP tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) => _nip = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    _logger.info('Password is empty');
                    return 'Password tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) => _password = value!,
              ),
              ElevatedButton(
                child: const Text('Login'),
                onPressed: () async {
                  _logger.info('Login button pressed');
                  if (_formKey.currentState!.validate()) {
                    _logger.info('Form is valid, saving...');
                    _formKey.currentState!.save();
                    final authProvider =
                        Provider.of<AuthProvider>(context, listen: false);
                    final navigator = Navigator.of(context);
                    final scaffoldMessenger = ScaffoldMessenger.of(context);

                    _logger.info('Attempting to sign in with NIP: $_nip');
                    bool success = await authProvider.signIn(_nip, _password);

                    if (success) {
                      _logger.info('Login successful, navigating to home');
                      navigator.pushReplacementNamed('/home');
                    } else {
                      _logger.warning('Login failed');
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                            content: Text('Login gagal. Coba lagi.')),
                      );
                    }
                  } else {
                    _logger.info('Form is invalid');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
