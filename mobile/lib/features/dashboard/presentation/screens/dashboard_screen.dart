import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rentara/core/widgets/main_bottom_nav.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _tenancyExpanded = true;

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        context.go('/dashboard', extra: {'bypassAuth': true});
        break;
      case 1:
        context.go('/payments', extra: {'bypassAuth': true});
        break;
      case 2:
        context.go('/maintenance', extra: {'bypassAuth': true});
        break;
      case 3:
        context.go('/profile', extra: {'bypassAuth': true});
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildRentCard(context),
              const SizedBox(height: 20),
              _buildTenancyDetails(context),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Payment History'),
              const SizedBox(height: 12),
              _buildPaymentHistory(context),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Maintenance Requests'),
              const SizedBox(height: 12),
              _buildMaintenanceCards(context),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Quick Links'),
              const SizedBox(height: 12),
              _buildQuickLinks(context),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 0),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => context.push('/profile?bypass=1'),
          child: CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFFE4F6F5),
            child: Text(
              'A',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF0B2B40),
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, Akinyi',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0B2B40),
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Welcome back to Rentara',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF64748B),
                    ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => context.push('/settings?bypass=1'),
          icon: const Icon(Icons.settings_outlined, color: Color(0xFF0B2B40)),
        ),
      ],
    );
  }

  Widget _buildRentCard(BuildContext context) {
    return Container(
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
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rent Due: Ksh 25,000',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0B2B40),
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Due on 1st July 2024',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF008F85),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            onPressed: () => context.push('/payments'),
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildTenancyDetails(BuildContext context) {
    return Container(
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
                  'Tenancy Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0B2B40),
                      ),
                ),
              ),
              IconButton(
                icon: AnimatedRotation(
                  turns: _tenancyExpanded ? 0.0 : 0.5,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_up_rounded,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                onPressed: () => setState(() => _tenancyExpanded = !_tenancyExpanded),
              ),
            ],
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _tenancyExpanded
                ? Padding(
                    key: const ValueKey('expanded'),
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      children: [
                        _buildDetailRow('Property', 'Apt 4B, Kilimani Heights'),
                        const SizedBox(height: 12),
                        _buildDetailRow('Lease Start', '1st Jan 2024'),
                        const SizedBox(height: 12),
                        _buildDetailRow('Lease End', '31st Dec 2024'),
                        const SizedBox(height: 12),
                        _buildDetailRow('Monthly Rent', 'Ksh 25,000'),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0B2B40),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0B2B40),
          ),
    );
  }

  Widget _buildPaymentHistory(BuildContext context) {
    final payments = [
      {
        'title': 'June Rent Payment',
        'date': '1st June 2024 - Ksh 25,000',
        'status': 'Cleared',
      },
      {
        'title': 'May Rent Payment',
        'date': '1st May 2024 - Ksh 25,000',
        'status': 'Cleared',
      },
      {
        'title': 'April Rent Payment',
        'date': '1st April 2024 - Ksh 25,000',
        'status': 'Cleared',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < payments.length; i++)
            _buildPaymentTile(context, payments[i], isLast: i == payments.length - 1),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF008F85),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              onPressed: () => context.push('/payments?bypass=1'),
              child: const Text('View All History'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTile(
    BuildContext context,
    Map<String, String> payment, {
    required bool isLast,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE4F6F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF008F85)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment['title']!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0B2B40),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    payment['date']!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF94A3B8),
                        ),
                  ),
                ],
              ),
            ),
            Row(
              children: const [
                Icon(Icons.circle, color: Color(0xFF10B981), size: 10),
                SizedBox(width: 6),
                Text(
                  'Cleared',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 18),
          Container(
            height: 1.2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
        ],
      ],
    );
  }

  Widget _buildMaintenanceCards(BuildContext context) {
    final requests = [
      {
        'title': 'Leaking Kitchen Tap',
        'date': 'Submitted: 15th June 2024',
        'status': 'In Progress',
        'statusColor': const Color(0xFFF97316),
      },
      {
        'title': 'Low Water Pressure',
        'date': 'Submitted: 28th May 2024',
        'status': 'Completed',
        'statusColor': const Color(0xFF10B981),
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < requests.length; i++)
            _buildMaintenanceTile(
              context,
              requests[i],
              isLast: i == requests.length - 1,
            ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008F85),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(54),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () => context.push('/maintenance/create'),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('New Request'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMaintenanceTile(
    BuildContext context,
    Map<String, Object> request, {
    required bool isLast,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4F6F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.build_rounded, color: Color(0xFF008F85)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['title'] as String,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0B2B40),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request['date'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF94A3B8),
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (request['statusColor'] as Color).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  request['status'] as String,
                  style: TextStyle(
                    color: request['statusColor'] as Color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) ...[
          Container(
            height: 1.2,
            margin: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuickLinks(BuildContext context) {
    final links = [
      {'title': 'Contact Agent', 'icon': Icons.phone_in_talk_rounded},
      {'title': 'View Documents', 'icon': Icons.insert_drive_file_rounded},
      {'title': 'Community Notices', 'icon': Icons.campaign_rounded},
      {'title': 'Settings', 'icon': Icons.settings_rounded},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: links.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, index) {
        final link = links[index];
        return InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4F6F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(link['icon'] as IconData, color: const Color(0xFF008F85)),
                ),
                const Spacer(),
                Text(
                  link['title'] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0B2B40),
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}




