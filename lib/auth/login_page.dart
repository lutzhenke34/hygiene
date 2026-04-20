import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hygiene_app/providers/auth_provider.dart';
import '../dashboard/admin_dashboard_page.dart';
import '../dashboard/pages/employee_home_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePin = true;

  // Demo-Accounts – ändere diese bei Bedarf
  final String _adminPhone = '49123456789';
  final String _mitarbeiterPhone = '49612345678';

  Future<void> _normalLogin() async {
    final phone = _phoneController.text.trim();
    final pin = _pinController.text.trim();

    if (phone.isEmpty || pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte Telefonnummer und PIN eingeben')),
      );
      return;
    }
    await _performLogin(phone, pin);
  }

  Future<void> _demoAdminLogin() async {
    await _performLogin(_adminPhone, '1234', roleName: 'Admin');
  }

  Future<void> _demoMitarbeiterLogin() async {
    await _performLogin(_mitarbeiterPhone, '1234', roleName: 'Mitarbeiter');
  }

  Future<void> _performLogin(String phone, String pin, {String? roleName}) async {
    setState(() => _isLoading = true);

    try {
      final user = await ref.read(authProvider.notifier).login(phone: phone, pin: pin);

      if (!mounted) return;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${roleName ?? "Login"} fehlgeschlagen')),
        );
        return;
      }

      // last_login aktualisieren
      try {
        await Supabase.instance.client
            .from('mitarbeiter')
            .update({'last_login': DateTime.now().toIso8601String()})
            .eq('phone', phone);
      } catch (e) {
        debugPrint('last_login update fehlgeschlagen: $e');
      }

      final role = (user.role as String?)?.toLowerCase() ?? '';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => (role == 'admin' || role == 'manager')
              ? const AdminDashboardPage()
              : const EmployeeHomePage(),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 25, offset: const Offset(0, 8))],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: const [
                        Icon(Icons.shield_outlined, size: 80, color: Color(0xFF15803D)),
                        Positioned(
                          bottom: 16,
                          right: 14,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.check_circle, size: 34, color: Color(0xFF4ADE80)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  const Text('Le Pot', style: TextStyle(fontSize: 44, fontWeight: FontWeight.w700, letterSpacing: -1.5, color: Color(0xFF1C2526))),
                  const Text('Hygiene & Aufgaben', style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w500, color: Color(0xFF4B5563))),

                  const SizedBox(height: 52),

                  // Login Card
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 35, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Willkommen zurück', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF1C2526)), textAlign: TextAlign.center),
                        const SizedBox(height: 6),
                        const Text('Melden Sie sich mit Telefonnummer und PIN an', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)), textAlign: TextAlign.center),

                        const SizedBox(height: 32),

                        _buildInputField(controller: _phoneController, hint: 'Telefonnummer', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: _pinController,
                          hint: 'PIN (4-stellig)',
                          icon: Icons.lock_outline,
                          obscure: _obscurePin,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePin ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF6B7280)),
                            onPressed: () => setState(() => _obscurePin = !_obscurePin),
                          ),
                        ),

                        const SizedBox(height: 36),

                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _normalLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1C2526),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.8)
                                : const Text('Einloggen', style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Demo Buttons
                  if (kDebugMode) ...[
                    const Text('Demo-Logins (nur Entwicklung)', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _demoAdminLogin,
                          icon: const Icon(Icons.admin_panel_settings),
                          label: const Text('Admin'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _demoMitarbeiterLogin,
                          icon: const Icon(Icons.person),
                          label: const Text('Mitarbeiter'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),
                  const Text('Nur für autorisierte Mitarbeiter', style: TextStyle(fontSize: 12.8, color: Color(0xFF9CA3AF))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    int? maxLength,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        counterText: '',
        hintText: hint,
        prefixIcon: Icon(icon, size: 22, color: const Color(0xFF6B7280)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF15803D), width: 1.8)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    );
  }
}