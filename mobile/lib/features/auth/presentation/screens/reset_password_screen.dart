import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? phoneNumber;

  const ResetPasswordScreen({super.key, this.phoneNumber});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _meetsLength = false;
  bool _hasNumber = false;
  bool _hasSpecial = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updateStrengthIndicators);
    _confirmPasswordController.addListener(_triggerRebuild);
  }

  @override
  void dispose() {
    _passwordController
      ..removeListener(_updateStrengthIndicators)
      ..dispose();
    _confirmPasswordController
      ..removeListener(_triggerRebuild)
      ..dispose();
    super.dispose();
  }

  void _updateStrengthIndicators() {
    final value = _passwordController.text;
    setState(() {
      _meetsLength = value.length >= 8;
      _hasNumber = RegExp(r'[0-9]').hasMatch(value);
      _hasSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>\-_=+\[\]\\/]').hasMatch(value);
    });
  }

  void _triggerRebuild() => setState(() {});

  double get _strengthProgress {
    final achieved = [_meetsLength, _hasNumber, _hasSpecial].where((e) => e).length;
    return achieved / 3;
  }

  String get _strengthLabel {
    final achieved = [_meetsLength, _hasNumber, _hasSpecial].where((e) => e).length;
    if (achieved == 0) return 'Very Weak';
    if (achieved == 1) return 'Weak';
    if (achieved == 2) return 'Good';
    return 'Strong';
  }

  Color get _strengthColor {
    final progress = _strengthProgress;
    if (progress <= 0.33) return const Color(0xFFEF4444); // red
    if (progress <= 0.66) return const Color(0xFFF97316); // orange
    return const Color(0xFF10B981); // green
  }

  bool get _canSubmit {
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    final matches = password.isNotEmpty && password == confirm;
    return matches && _meetsLength && _hasNumber && _hasSpecial;
  }

  void _handleSubmit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    _showSuccessToast();
  }

  void _showSuccessToast() {
    final overlay = Overlay.of(context, rootOverlay: true);
    if (overlay == null) return;

    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (_) => _ResetSuccessToast(
        message: 'Your password has been updated successfully.',
        onDismissed: () => entry?.remove(),
      ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 3), () {
      entry?.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phone = widget.phoneNumber;

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
                      onPressed: () => context.go('/forgot-password/verify', extra: widget.phoneNumber),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Set New Password',
                      style: theme.textTheme.titleMedium?.copyWith(
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Set New Password',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0B2B40),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your new password must be different from previous passwords and at least 8 characters long.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF64748B),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildPasswordField(
                              label: 'New Password',
                              controller: _passwordController,
                              obscure: _obscurePassword,
                              onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            const SizedBox(height: 18),
                            _buildPasswordField(
                              label: 'Confirm New Password',
                              controller: _confirmPasswordController,
                              obscure: _obscureConfirmPassword,
                              onToggle: () =>
                                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Re-enter your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Text(
                                  'Password Strength: ',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF0B2B40),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _strengthLabel,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: _strengthColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: LinearProgressIndicator(
                                minHeight: 6,
                                value: _strengthProgress.clamp(0.05, 1.0),
                                backgroundColor: const Color(0xFFE2E8F0),
                                valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _buildCriteriaRow('Minimum 8 characters', _meetsLength),
                            const SizedBox(height: 10),
                            _buildCriteriaRow('Includes a number', _hasNumber),
                            const SizedBox(height: 10),
                            _buildCriteriaRow('Includes a special character', _hasSpecial),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: _canSubmit ? _handleSubmit : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF008F85),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                disabledBackgroundColor: const Color(0xFFE2E8F0),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: const Text('Set Password'),
                            ),
                          ],
                        ),
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

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF0B2B40),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator ?? _passwordValidator,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0B2B40),
            letterSpacing: 0.2,
          ),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: label == 'New Password' ? 'Enter new password' : 'Re-enter new password',
            hintStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8).withOpacity(0.9),
            ),
            filled: true,
            fillColor: const Color(0xFFF5F7F9),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF037A73), width: 1.6),
            ),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
              color: const Color(0xFF0B2B40),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  Widget _buildCriteriaRow(String label, bool met) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: met ? const Color(0xFF008F85) : const Color(0xFFCBD5E1),
              width: 2,
            ),
            color: met ? const Color(0xFF008F85).withOpacity(0.12) : Colors.transparent,
          ),
          child: met
              ? const Icon(
                  Icons.check,
                  size: 12,
                  color: Color(0xFF008F85),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF42505C),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResetSuccessToast extends StatelessWidget {
  final String message;
  final VoidCallback onDismissed;

  const _ResetSuccessToast({required this.message, required this.onDismissed});

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
                child: const Icon(
                  Icons.verified_outlined,
                  color: Color(0xFF008F85),
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
                      'Password Updated',
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
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

