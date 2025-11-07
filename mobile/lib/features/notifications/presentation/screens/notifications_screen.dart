import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<Map<String, Object>> _unreadNotifications = [
    {
      'title': 'Rent Due Soon',
      'body': 'Your rent for Maple Court, Apt 4B is due in 3 days.',
      'icon': Icons.receipt_long_rounded,
      'time': '2 hours ago',
      'accent': const Color(0xFFF87171),
      'actionLabel': 'View Request',
    },
    {
      'title': 'New Maintenance Request',
      'body': 'Ben Carter reported a leaky faucet at 255 Bay Street.',
      'icon': Icons.build_circle_rounded,
      'time': '2 hours ago',
      'accent': const Color(0xFFFACC15),
      'actionLabel': 'View Request',
    },
  ];

  final List<Map<String, Object>> _earlierNotifications = [
    {
      'title': 'Payment Confirmed',
      'body': 'Received KES 55,000 from Olivia Chen for January rent.',
      'icon': Icons.payments_rounded,
      'time': '1 day ago',
      'accent': const Color(0xFF34D399),
    },
    {
      'title': 'Lease Expiring',
      'body': 'The lease for 100 King Street West expires in 30 days.',
      'icon': Icons.hourglass_bottom_rounded,
      'time': '2 days ago',
      'accent': const Color(0xFFF59E0B),
    },
    {
      'title': 'New Announcement',
      'body': 'Scheduled water maintenance on Friday from 9 AM to 1 PM.',
      'icon': Icons.campaign_rounded,
      'time': '3 days ago',
      'accent': const Color(0xFF60A5FA),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          'Notifications',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0B2B40),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: const Color(0xFFE6FBF8),
                borderRadius: BorderRadius.circular(14),
              ),
              labelColor: const Color(0xFF008F85),
              unselectedLabelColor: const Color(0xFF94A3B8),
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Unread'),
                Tab(text: 'Important'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllTab(context),
          _buildAllTab(context),
          _buildAllTab(context),
        ],
      ),
    );
  }

  Widget _buildAllTab(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_unreadNotifications.isNotEmpty) ...[
            Text(
              'Unread',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF94A3B8),
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 12),
            ..._unreadNotifications
                .map((notification) => _NotificationCard(notification: notification))
                .toList(),
            const SizedBox(height: 24),
          ],
          Text(
            'Earlier',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF94A3B8),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 12),
          ..._earlierNotifications
              .map((notification) => _NotificationCard(notification: notification, isUnread: false))
              .toList(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final Map<String, Object> notification;
  final bool isUnread;

  const _NotificationCard({required this.notification, this.isUnread = true});

  @override
  Widget build(BuildContext context) {
    final accent = notification['accent'] as Color;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFE6FBF8) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          if (!isUnread)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 62,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(notification['icon'] as IconData, color: accent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification['title'] as String,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0B2B40),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification['body'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notification['time'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (notification['actionLabel'] != null)
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          foregroundColor: accent,
                          textStyle: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        child: Text(notification['actionLabel'] as String),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




