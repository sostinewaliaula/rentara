import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String? phoneNumber;
  const OtpVerificationScreen({super.key, this.phoneNumber});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _countdownTimer;
  int _secondsRemaining = 59;
  bool _isResending = false;
  OverlayEntry? _toastOverlay;

  String get _maskedPhoneNumber {
    final phone = widget.phoneNumber;
    if (phone == null || phone.isEmpty) {
      return 'your phone';
    }
    if (phone.length <= 7) {
      return phone;
    }
    return '${phone.substring(0, 7)}XXX XXX';
  }

  @override
  void dispose() {
    _removeToast();
    _countdownTimer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _startCountdown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showOtpSentBanner(isResent: false);
      }
    });
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
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  Future<void> _handleResendCode() async {
    setState(() {
      _isResending = true;
    });

    await Future<void>.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isResending = false;
    });

    _showOtpSentBanner(isResent: true);
    _startCountdown();
  }

  void _showOtpSentBanner({required bool isResent}) {
    final overlay = Overlay.of(context, rootOverlay: true);
    if (overlay == null) return;

    final phoneText = widget.phoneNumber ?? 'your phone';
    final title = isResent ? 'Verification code resent' : 'Verification code sent';
    final message = isResent
        ? 'We have resent the OTP to $phoneText.'
        : 'We have sent the OTP to $phoneText.';

    _removeToast();

    final entry = OverlayEntry(
      builder: (context) => _OtpToastBanner(
        title: title,
        message: message,
        isResent: isResent,
        onDismissed: _removeToast,
      ),
    );

    overlay.insert(entry);
    _toastOverlay = entry;

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _toastOverlay == entry) {
        _removeToast();
      }
    });
  }

  void _removeToast() {
    _toastOverlay?.remove();
    _toastOverlay = null;
  }

  void _onChanged(String value, int index) {
    if (value.isEmpty) {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
      return;
    }

    // Ensure only the last digit typed remains in the field
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
  }

  @override
  Widget build(BuildContext context) {
    final phoneDisplay = widget.phoneNumber ?? '';

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
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        context.go('/forgot-password');
                      }
                    },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'OTP Confirmation',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0B2B40),
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
                            child: Icon(
                              Icons.inbox_outlined,
                              size: 42,
                              color: const Color(0xFF037A73),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Enter Verification Code',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0B2B40),
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.phoneNumber == null
                                ? 'Enter the 6-digit code that was sent to your phone.'
                                : 'A 6-digit code has been sent to $phoneDisplay.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF64748B),
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(_controllers.length, (index) {
                                return Padding(
                                  padding: EdgeInsets.only(right: index == _controllers.length - 1 ? 0 : 6),
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
                                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Color(0xFF037A73), width: 1.4),
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
                          ),
                          const SizedBox(height: 24),
                          if (_secondsRemaining > 0)
                            Text(
                              'Resend code in 00:${_secondsRemaining.toString().padLeft(2, '0')}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF64748B),
                                    fontWeight: FontWeight.w600,
                                  ),
                              textAlign: TextAlign.center,
                            )
                          else
                            TextButton(
                              onPressed: _isResending ? null : _handleResendCode,
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF008F85),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
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
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF008F85),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            child: const Text(
                              'Verify',
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

class _OtpToastBanner extends StatelessWidget {
  final String title;
  final String message;
  final bool isResent;
  final VoidCallback onDismissed;

  const _OtpToastBanner({
    required this.title,
    required this.message,
    required this.isResent,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeTop = MediaQuery.of(context).padding.top;

    return Positioned(
      top: safeTop + 16,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4F6F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isResent ? Icons.refresh_outlined : Icons.mark_email_read_outlined,
                  color: const Color(0xFF008F85),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0B2B40),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onDismissed,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF008F85),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
                child: const Text('DISMISS'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
