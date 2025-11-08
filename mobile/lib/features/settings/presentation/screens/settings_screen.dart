import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rentara/core/widgets/main_bottom_nav.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;

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
          onPressed: () => context.go('/dashboard?bypass=1'),
        ),
        centerTitle: true,
        title: Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0B2B40),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileHeader(theme: theme),
            const SizedBox(height: 24),
            _SectionTitle(title: 'Account', theme: theme),
            const SizedBox(height: 12),
            _CardSection(
              children: [
                _SettingsTile(
                  icon: Icons.edit_outlined,
                  title: 'Edit Profile',
                  onTap: () => context.push('/profile?bypass=1'),
                ),
                const _TileDivider(),
                _SettingsTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Change Password',
                  onTap: () => context.push('/settings/change-password?bypass=1'),
                ),
                const _TileDivider(),
                _SettingsTile(
                  icon: Icons.credit_card_outlined,
                  title: 'Manage Payment Methods',
                  onTap: () => context.push('/profile/payment-methods?bypass=1'),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _SectionTitle(title: 'Notifications', theme: theme),
            const SizedBox(height: 12),
            _CardSection(
              children: [
                _SettingsTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Push Notifications',
                  trailing: Switch.adaptive(
                    value: _pushNotifications,
                    activeColor: const Color(0xFF008F85),
                    onChanged: (value) {
                      setState(() => _pushNotifications = value);
                    },
                  ),
                ),
                const _TileDivider(),
                _SettingsTile(
                  icon: Icons.mail_outline_rounded,
                  title: 'Email Notifications',
                  trailing: Switch.adaptive(
                    value: _emailNotifications,
                    activeColor: const Color(0xFF008F85),
                    onChanged: (value) {
                      setState(() => _emailNotifications = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _SectionTitle(title: 'General', theme: theme),
            const SizedBox(height: 12),
            _CardSection(
              children: [
                _SettingsTile(
                  icon: Icons.language_rounded,
                  title: 'Language',
                  trailingText: 'English',
                  onTap: () {},
                ),
                const _TileDivider(),
                _SettingsTile(
                  icon: Icons.brightness_6_outlined,
                  title: 'Appearance',
                  trailingText: 'Light',
                  onTap: () {},
                ),
                const _TileDivider(),
                _SettingsTile(
                  icon: Icons.shield_outlined,
                  title: 'Privacy & Security',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 28),
            _SectionTitle(title: 'Support & Legal', theme: theme),
            const SizedBox(height: 12),
            _CardSection(
              children: [
                _SettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help Center',
                  onTap: () {},
                ),
                const _TileDivider(),
                _SettingsTile(
                  icon: Icons.headset_mic_outlined,
                  title: 'Contact Support',
                  onTap: () {},
                ),
                const _TileDivider(),
                _SettingsTile(
                  icon: Icons.article_outlined,
                  title: 'Terms of Service',
                  onTap: () {},
                ),
                const _TileDivider(),
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFFECEC),
                  foregroundColor: const Color(0xFFE11D48),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  'Log Out',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 3),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFE6FBF8),
            child: Text(
              'IK',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0B2B40),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Imani Kamau',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0B2B40),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'imani.k@example.com',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.theme});

  final String title;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: const Color(0xFF0B2B40),
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 68,
      color: Color(0xFFE2E8F0),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
    this.trailingText,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFE6FBF8),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: const Color(0xFF008F85),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0B2B40),
                ),
              ),
            ),
            if (trailing != null)
              trailing!
            else if (trailingText != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    trailingText!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
                ],
              )
            else
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}
