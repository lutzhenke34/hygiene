// lib/login_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _success = false;

  Future<void> _sendMagicLink() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _message = 'Bitte eine gültige E-Mail-Adresse eingeben';
        _success = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
      _success = false;
    });

    try {
      // Dynamisch: aktuelle URL (localhost + aktueller Port) als Redirect
      final currentUrl = Uri.base.toString(); // z.B. "http://localhost:60922/"

      await Supabase.instance.client.auth.signInWithOtp(
  email: email,
  // KEIN emailRedirectTo mehr – Supabase schickt einfachen Link per Mail
);

      setState(() {
        _success = true;
        _message = 'Magic-Link gesendet!\nSchau in deinen Posteingang (auch Spam/Promotions-Ordner)';
      });
    } on AuthException catch (e) {
      setState(() {
        _message = 'Auth-Fehler: ${e.message}';
        _success = false;
      });
    } catch (e) {
      setState(() {
        _message = 'Fehler beim Senden: $e';
        _success = false;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Hygiene App',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 48),

                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'E-Mail-Adresse',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.go,
                    onSubmitted: (_) => _sendMagicLink(),
                  ),

                  const SizedBox(height: 32),

                  if (_message != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Text(
                        _message!,
                        style: TextStyle(
                          color: _success ? Colors.green.shade700 : Colors.red.shade700,
                          fontWeight: _success ? FontWeight.w500 : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  ElevatedButton.icon(
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(_isLoading ? 'Wird gesendet...' : 'Magic-Link senden'),
                    onPressed: _isLoading ? null : _sendMagicLink,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  const SizedBox(height: 32),
                  Text(
                    'Du bekommst eine E-Mail mit einem Link zum Einloggen.\nKein Passwort nötig.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}