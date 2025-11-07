import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final _providerController = TextEditingController();
  final _detailsController = TextEditingController();

  @override
  void dispose() {
    _providerController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final paymentMethods = [
      {
        'provider': 'M-Pesa',
        'details': '+254 712 345 678',
        'isDefault': true,
      },
      {
        'provider': 'Equity Bank',
        'details': '**** **** 5678',
        'isDefault': false,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0B2B40)),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          'Payment Methods',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0B2B40),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Linked Methods',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF94A3B8),
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 12),
            ...paymentMethods.map((method) => _PaymentMethodCard(method: method)).toList(),
            const SizedBox(height: 20),
            _AddNewMethodButton(onTap: () => _showAddSheet(context)),
          ],
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add Payment Method',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B2B40),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Provider Name',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _BottomSheetField(controller: _providerController, hint: 'e.g. M-Pesa'),
              const SizedBox(height: 16),
              const Text(
                'Account Details',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _BottomSheetField(
                controller: _detailsController,
                hint: 'e.g. +254 712 345 678',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Payment method added (placeholder).'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008F85),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Save Payment Method'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final Map<String, Object> method;

  const _PaymentMethodCard({required this.method});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDefault = method['isDefault'] as bool;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4F6F5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: const Color(0xFF008F85),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method['provider'] as String,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0B2B40),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method['details'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_PaymentAction>(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF94A3B8)),
                color: Colors.white,
                onSelected: (action) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        action == _PaymentAction.edit
                            ? 'Edit flow coming soon.'
                            : 'Payment method removed (placeholder).',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _PaymentAction.edit,
                    padding: EdgeInsets.zero,
                    child: Icon(Icons.edit_rounded, color: const Color(0xFF008F85)),
                  ),
                  PopupMenuItem(
                    value: _PaymentAction.delete,
                    padding: EdgeInsets.zero,
                    child: Icon(Icons.delete_rounded, color: const Color(0xFFEF4444)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isDefault ? const Color(0xFF008F85) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isDefault ? 'Default' : 'Secondary',
                  style: TextStyle(
                    color: isDefault ? Colors.white : const Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: const Color(0xFF008F85),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
                child: Text(isDefault ? 'Change' : 'Set as Default'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddNewMethodButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddNewMethodButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFD6E4EC), style: BorderStyle.solid, width: 1),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_circle_outline, color: Color(0xFF008F85)),
            SizedBox(width: 8),
            Text(
              'Add New Payment Method',
              style: TextStyle(
                color: Color(0xFF008F85),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomSheetField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _BottomSheetField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF94A3B8),
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: const Color(0xFFF5F7F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      ),
      style: const TextStyle(
        color: Color(0xFF0B2B40),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

enum _PaymentAction { edit, delete }
