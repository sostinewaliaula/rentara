import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddPaymentMethodScreen extends StatelessWidget {
  const AddPaymentMethodScreen({super.key});

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
            _AddNewMethodButton(onTap: () {}),
          ],
        ),
      ),
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
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF94A3B8)),
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
