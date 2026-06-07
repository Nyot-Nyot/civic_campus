import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:civic_campus/data/providers/auth_provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  static const routeName = '/verify-email';

  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _codeControllers = List.generate(6, (_) => TextEditingController());
  final _codeFocusNodes = List.generate(6, (_) => FocusNode());
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendInitialCode());
  }

  Future<void> _sendInitialCode() async {
    setState(() => _isResending = true);
    final auth = context.read<AuthProvider>();
    final error = await auth.resendVerificationEmail(widget.email);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
    setState(() => _isResending = false);
  }

  @override
  void dispose() {
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _codeFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _codeControllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    setState(() {
      if (value.isEmpty) return;
      if (value.length > 1) {
        _codeControllers[index].text = value.substring(value.length - 1);
      }
      if (index < 5) {
        _codeFocusNodes[index + 1].requestFocus();
      }
    });
  }

  Future<void> _verify() async {
    if (_code.length != 6) return;

    setState(() => _isVerifying = true);
    final auth = context.read<AuthProvider>();
    final error = await auth.verifyEmail(widget.email, _code);

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      setState(() => _isVerifying = false);
      return;
    }

    await auth.loadProfile();
    if (!mounted) return;

    final role = auth.profile?['role'] as String?;
    String route;
    switch (role) {
      case 'Super Admin':
        route = '/super-admin-home';
        break;
      case 'Facility Admin':
        route = '/admin-home';
        break;
      case 'Maintenance Staff':
        route = '/staff-home';
        break;
      default:
        route = '/student-home';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email berhasil diverifikasi!')),
    );
    Navigator.of(context).pushReplacementNamed(route);
  }

  Future<void> _resend() async {
    setState(() => _isResending = true);
    final auth = context.read<AuthProvider>();
    final error = await auth.resendVerificationEmail(widget.email);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode verifikasi dikirim ulang.')),
      );
    }
    setState(() => _isResending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.chevron_left_rounded, size: 32),
                tooltip: 'Kembali',
              ),
              const SizedBox(height: 18),
              const Text(
                'Verifikasi Email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Masukkan kode 6 digit yang sudah dikirim ke email kamu.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.email_outlined,
                                size: 18, color: Color(0xFF6B7280)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.email,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1D4ED8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Form(
                        child: Column(
                          children: [
                            Row(
                              children: List.generate(6, (i) {
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: i > 0 ? 6 : 0,
                                      right: i < 5 ? 6 : 0,
                                    ),
                                    child: SizedBox(
                                      height: 52,
                                      child: TextField(
                                    controller: _codeControllers[i],
                                    focusNode: _codeFocusNodes[i],
                                    enabled: !_isVerifying,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(1),
                                    ],
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      counterText: '',
                                      contentPadding:
                                          const EdgeInsets.symmetric(vertical: 14),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Color(0xFFE5E7EB)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Color(0xFFE5E7EB)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Color(0xFF1D4ED8), width: 2),
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF9FAFB),
                                    ),
                                    onChanged: (v) => _onDigitChanged(i, v),
                                  ),
                                ),
                              ),
                              );
                            }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: (_isVerifying || _code.length != 6)
                            ? null
                            : _verify,
                        child: _isVerifying
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Verifikasi'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: _isResending ? null : _resend,
                  child: Text(
                    _isResending ? 'Mengirim...' : 'Kirim ulang kode',
                    style: const TextStyle(color: Color(0xFF6B7280)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Sudah verifikasi? Masuk'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
