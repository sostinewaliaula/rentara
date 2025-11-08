import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rentara/core/widgets/main_bottom_nav.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  int _selectedMethod = 0;
  bool _showUpcoming = true;

  final List<Map<String, Object>> _paymentMethods = [
    {
      'label': 'M-Pesa',
      'subtitle': 'Use Paybill 123456, Account No. APT4B',
      'icon': Icons.phone_iphone_rounded,
    },
    {
      'label': 'Airtel Money',
      'subtitle': 'Service coming soon',
      'icon': Icons.account_balance_wallet_rounded,
    },
    {
      'label': 'Bank Transfer',
      'subtitle': 'Account No. 1234567890',
      'icon': Icons.account_balance_rounded,
    },
  ];

  final List<Map<String, Object>> _transactions = [
    {
      'amount': 'KES 35,000',
      'date': 'June 1, 2024',
      'status': 'Paid',
      'statusColor': const Color(0xFF10B981),
    },
    {
      'amount': 'KES 35,000',
      'date': 'May 2, 2024',
      'status': 'Processing',
      'statusColor': const Color(0xFFF59E0B),
    },
    {
      'amount': 'KES 35,000',
      'date': 'April 1, 2024',
      'status': 'Failed',
      'statusColor': const Color(0xFFF87171),
    },
    {
      'amount': 'KES 35,000',
      'date': 'March 1, 2024',
      'status': 'Paid',
      'statusColor': const Color(0xFF10B981),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Payments',
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
            _buildRentSummaryCard(context),
            const SizedBox(height: 20),
            _buildChooseMethodSection(context),
            const SizedBox(height: 20),
            _buildUpcomingSection(context),
            const SizedBox(height: 12),
            _buildTransactionsSection(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 1),
    );
  }

  Widget _buildRentSummaryCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rent Due for Apartment 4B, Westlands View',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'KES 35,000',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0B2B40),
                      ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Due on 1st July 2024',
                  style: TextStyle(
                    color: Color(0xFFF87171),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF008F85),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
            onPressed: () {},
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildChooseMethodSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          Text(
            'Choose Payment Method',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0B2B40),
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(_paymentMethods.length, (index) {
              final method = _paymentMethods[index];
              final isSelected = _selectedMethod == index;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index != _paymentMethods.length - 1 ? 12 : 0),
                  child: ChoiceChip(
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedMethod = index),
                    label: Text(method['label'] as String),
                    backgroundColor: const Color(0xFFF5F7F9),
                    selectedColor: const Color(0xFFE6FBF8),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF008F85) : const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF008F85) : Colors.transparent,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          _buildMethodDetail(context, _paymentMethods[_selectedMethod]),
        ],
      ),
    );
  }

  Widget _buildMethodDetail(BuildContext context, Map<String, Object> method) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6FBF8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(method['icon'] as IconData, color: const Color(0xFF008F85)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              method['subtitle'] as String,
              style: const TextStyle(
                color: Color(0xFF0B2B40),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
            children: [
              Expanded(
                child: Text(
                  'Upcoming Payments',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0B2B40),
                      ),
                ),
              ),
              IconButton(
                icon: AnimatedRotation(
                  turns: _showUpcoming ? 0 : 0.5,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_up_rounded, color: Color(0xFF94A3B8)),
                ),
                onPressed: () => setState(() => _showUpcoming = !_showUpcoming),
              ),
            ],
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _showUpcoming
                ? Column(
                    children: const [
                      SizedBox(height: 10),
                      _UpcomingPaymentRow(
                        title: 'KES 35,000 due July 1, 2024',
                        subtitle: 'Automated reminder set 3 days before due date.',
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
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
          Text(
            'Transaction History',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0B2B40),
            ),
          ),
          const SizedBox(height: 16),
          ..._transactions
              .map((transaction) => _TransactionTile(data: transaction))
              .toList(),
        ],
      ),
    );
  }
}

class _UpcomingPaymentRow extends StatelessWidget {
  final String title;
  final String subtitle;

  const _UpcomingPaymentRow({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6FBF8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0B2B40),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Map<String, Object> data;

  const _TransactionTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['amount'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B2B40),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data['date'] as String,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: (data['statusColor'] as Color).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              data['status'] as String,
              style: TextStyle(
                color: data['statusColor'] as Color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}




