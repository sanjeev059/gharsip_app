import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _ctrls = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  int _timer = 60;
  Timer? _countdown;
  bool _loading = false;
  String? _error;
  late String _email;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _email = ModalRoute.of(context)!.settings.arguments as String;
      _nodes[0].requestFocus();
    });
  }

  void _startTimer() {
    _countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timer == 0) { t.cancel(); return; }
      setState(() => _timer--);
    });
  }

  String get _otp => _ctrls.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_otp.length != 6) {
      setState(() => _error = 'Enter all 6 digits');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final auth = context.read<AuthProvider>();
    final ok = await auth.verifyOtp(
      otp: _otp,
      onError: (msg) {
        if (mounted) setState(() { _error = msg; _loading = false; });
      },
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, auth.isAdmin ? '/admin' : '/home');
    }
  }

  Future<void> _resend() async {
    setState(() { _timer = 60; _error = null; });
    _startTimer();
    final auth = context.read<AuthProvider>();
    await auth.sendOtp(
      email: _email,
      onSent: () {},
      onError: (msg) { if (mounted) setState(() => _error = msg); },
    );
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    for (final n in _nodes) n.dispose();
    _countdown?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Verify OTP',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Check your email',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary, fontFamily: 'Poppins')),
            const SizedBox(height: 8),
            Text('We sent a 6-digit code to $_email',
              style: const TextStyle(fontSize: 14, color: AppColors.textSecond, fontFamily: 'Poppins')),
            const SizedBox(height: 36),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) => SizedBox(
                width: 48, height: 56,
                child: TextField(
                  controller: _ctrls[i],
                  focusNode: _nodes[i],
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: EdgeInsets.zero,
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  onChanged: (v) {
                    if (v.isNotEmpty && i < 5) {
                      _nodes[i + 1].requestFocus();
                    } else if (v.isEmpty && i > 0) {
                      _nodes[i - 1].requestFocus();
                    }
                    if (_otp.length == 6) {
                      Future.delayed(const Duration(milliseconds: 100), _verify);
                    }
                  },
                ),
              )),
            ),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!,
                style: const TextStyle(color: AppColors.error, fontSize: 13, fontFamily: 'Poppins')),
            ],

            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _verify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _loading
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Text('Verify & Continue',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
              ),
            ),

            const SizedBox(height: 20),
            Center(
              child: _timer > 0
                  ? Text('Resend OTP in $_timer seconds',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecond, fontFamily: 'Poppins'))
                  : TextButton(
                      onPressed: _resend,
                      child: const Text('Resend OTP',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
