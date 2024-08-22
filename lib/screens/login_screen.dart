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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 60),
                  Image.asset(
                    'assets/logo.png', // Pastikan Anda memiliki logo di folder assets
                    height: 120,
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Selamat Datang',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'NIP',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        _logger.info('NIP is empty');
                        return 'NIP tidak boleh kosong';
                      }
                      return null;
                    },
                    onSaved: (value) => _nip = value!,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Login', style: TextStyle(fontSize: 18)),
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
                        bool success =
                            await authProvider.signIn(_nip, _password);

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
        ),
      ),
    );
  }
}
