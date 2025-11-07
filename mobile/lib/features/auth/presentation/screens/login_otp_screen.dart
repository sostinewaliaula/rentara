import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class LoginOtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String password;

  const LoginOtpScreen({super.key, required this.phoneNumber, required this.password});

  @override
  State<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _countdownTimer;
  int _secondsRemaining = 59;
  bool _isResending = false;
  bool _isVerifying = false;

  bool get _isOtpComplete =>
      _controllers.every((controller) => controller.text.trim().isNotEmpty);

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _secondsRemaining = 59;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 0) {
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _onChanged(String value, int index) {
    if (value.isEmpty) {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
      setState(() {});
      return;
    }

    if (value.length > 1) {
      final digit = value.substring(value.length - 1);
      _controllers[index]
        ..text = digit
        ..selection = const TextSelection.collapsed(offset: 1);
    }

    if (index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
    }

    setState(() {});
  }

  Future<void> _handleResend() async {
    setState(() => _isResending = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isResending = false);
    _startCountdown();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login code resent (placeholder).'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleVerify() async {
    if (!_isOtpComplete) return;

    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isVerifying = false);
    context.go('/dashboard', extra: {'bypassAuth': true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      color: Colors.white,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, size: 22, color: Color(0xFF0B2B40)),
                      onPressed: () => context.go('/login'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Login Verification',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0B2B40),
                          ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      color: Colors.white,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22, color: Color(0xFF0B2B40)),
                      onPressed: () => context.go('/login'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withOpacity(0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE4F6F5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.lock_open_rounded,
                              size: 42,
                              color: Color(0xFF037A73),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Enter Login Code',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0B2B40),
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We sent a 6-digit login code to ${widget.phoneNumber}. Enter it below to continue.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF64748B),
                                  height: 1.5,
                                ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_controllers.length, (index) {
                              return Padding(
                                padding:
                                    EdgeInsets.only(right: index == _controllers.length - 1 ? 0 : 6),
                                child: SizedBox(
                                  width: 40,
                                  child: TextField(
                                    controller: _controllers[index],
                                    focusNode: _focusNodes[index],
                                    textAlign: TextAlign.center,
                                    textAlignVertical: TextAlignVertical.center,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(1),
                                    ],
                                    decoration: InputDecoration(
                                      counterText: '',
                                      filled: true,
                                      fillColor: const Color(0xFFF5F7F9),
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(vertical: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide:
                                            const BorderSide(color: Color(0xFF037A73), width: 1.4),
                                      ),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0B2B40),
                                    ),
                                    onChanged: (value) => _onChanged(value, index),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 24),
                          if (_secondsRemaining > 0)
                            Text(
                              'Resend code in 00:${_secondsRemaining.toString().padLeft(2, '0')}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF64748B),
                                    fontWeight: FontWeight.w600,
                                  ),
                            )
                          else
                            TextButton(
                              onPressed: _isResending ? null : _handleResend,
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF008F85),
                                textStyle: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              child: _isResending
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Resend code'),
                            ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: !_isOtpComplete || _isVerifying ? null : _handleVerify,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF008F85),
                              disabledBackgroundColor: const Color(0xFFE2E8F0),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: _isVerifying
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text(
                                    'Verify & Continue',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
