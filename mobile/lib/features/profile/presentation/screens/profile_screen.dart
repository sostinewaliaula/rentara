import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rentara/core/widgets/main_bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _phoneController = TextEditingController(text: '+254 712 345 678');
  final _idController = TextEditingController(text: '12345678');
  final _emergencyNameController = TextEditingController(text: 'John Otieno');
  final _relationshipController = TextEditingController(text: 'Spouse');
  final _emergencyPhoneController = TextEditingController(text: '+254 798 765 432');
  bool _isEditingPersonal = false;
  bool _isEditingEmergency = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _idController.dispose();
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
          onPressed: () => context.go('/dashboard?bypass=1'),
        ),
        centerTitle: true,
        title: Text(
          'My Profile',
          style: theme.textTheme.titleLarge?.copyWith(
            color: const Color(0xFF0B2B40),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            _buildAvatar(context),
            const SizedBox(height: 18),
            Text(
              'Wanjiru Kamau',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0B2B40),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'wanjiru.k@gmail.com',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 28),
            _ProfileSection(
              title: 'Personal Details',
              subtitle: 'Your personal information',
              actionLabel: _isEditingPersonal ? 'Save' : 'Edit',
              actionIcon: _isEditingPersonal ? Icons.check_rounded : Icons.edit,
              onActionTap: () {
                if (_isEditingPersonal) {
                  // In a real app, persist changes here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Details updated (placeholder).'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
                setState(() => _isEditingPersonal = !_isEditingPersonal);
              },
              children: [
                _isEditingPersonal
                    ? _EditableField(
                        label: 'Phone Number',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                      )
                    : _InfoRow(label: 'Phone Number', value: _phoneController.text),
                _isEditingPersonal
                    ? _EditableField(
                        label: 'National ID',
                        controller: _idController,
                        keyboardType: TextInputType.number,
                      )
                    : _InfoRow(label: 'National ID', value: _idController.text),
              ],
            ),
            const SizedBox(height: 16),
            _ProfileSection(
              title: 'Emergency Contact',
              subtitle: 'In case of an emergency',
              actionLabel: _isEditingEmergency ? 'Save' : 'Edit',
              actionIcon: _isEditingEmergency ? Icons.check_rounded : Icons.edit,
              onActionTap: () {
                if (_isEditingEmergency) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Emergency contact updated (placeholder).'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
                setState(() => _isEditingEmergency = !_isEditingEmergency);
              },
              children: [
                _isEditingEmergency
                    ? _EditableField(
                        label: 'Name',
                        controller: _emergencyNameController,
                      )
                    : _InfoRow(label: 'Name', value: _emergencyNameController.text),
                _isEditingEmergency
                    ? _EditableField(
                        label: 'Relationship',
                        controller: _relationshipController,
                      )
                    : _InfoRow(label: 'Relationship', value: _relationshipController.text),
                _isEditingEmergency
                    ? _EditableField(
                        label: 'Phone Number',
                        controller: _emergencyPhoneController,
                        keyboardType: TextInputType.phone,
                      )
                    : _InfoRow(label: 'Phone Number', value: _emergencyPhoneController.text),
              ],
            ),
            const SizedBox(height: 16),
            _ProfileSection(
              title: 'Payment Methods',
              subtitle: 'Manage your payment options',
              actionLabel: 'Add',
              actionIcon: Icons.add,
              onActionTap: () => context.push('/profile/payment-methods?bypass=1'),
              compactSeparators: true,
              children: const [
                _PaymentRow(label: 'M-PESA', icon: Icons.account_balance_wallet_rounded),
                _DividerSpacer(),
                _PaymentRow(label: 'Visa ending in 4242', icon: Icons.credit_card_rounded),
              ],
            ),
            const SizedBox(height: 16),
            _PrimaryButton(
              label: 'Change Password',
              icon: Icons.vpn_key_rounded,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _DestructiveButton(
              label: 'Log Out',
              icon: Icons.logout_rounded,
              onTap: () => context.go('/login'),
            ),
            const SizedBox(height: 24),
            Text(
              'Your information is secure. View our Privacy Policy.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 3),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [const Color(0xFF008F85).withOpacity(0.2), Colors.white],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const CircleAvatar(
            radius: 44,
            backgroundImage: AssetImage('assets/images/sample_avatar.png'),
            backgroundColor: Color(0xFFE4F6F5),
          ),
        ),
        Positioned(
          right: 6,
          bottom: 6,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF008F85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white, width: 2),
            ),
            padding: const EdgeInsets.all(6),
            child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionLabel;
  final IconData? actionIcon;
  final VoidCallback onActionTap;
  final List<Widget> children;
  final bool compactSeparators;

  const _ProfileSection({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onActionTap,
    required this.children,
    this.actionIcon,
    this.compactSeparators = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0B2B40),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onActionTap,
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFE6FBF8),
                  foregroundColor: const Color(0xFF008F85),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
                icon: Icon(actionIcon ?? Icons.edit_rounded, size: 18),
                label: Text(actionLabel),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._injectSeparators(children),
        ],
      ),
    );
  }

  List<Widget> _injectSeparators(List<Widget> items) {
    final separated = <Widget>[];
    final gap = compactSeparators ? 8.0 : 14.0;
    for (var i = 0; i < items.length; i++) {
      separated.add(items[i]);
      if (i != items.length - 1) {
        if (gap > 0) separated.add(SizedBox(height: gap));
        separated.add(Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.06),
                Colors.transparent,
              ],
            ),
          ),
        ));
        if (gap > 0) separated.add(SizedBox(height: gap));
      }
    }
    return separated;
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
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
}

class _PaymentRow extends StatelessWidget {
  final String label;
  final IconData icon;

  const _PaymentRow({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE4F6F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF008F85)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0B2B40),
                    ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

class _DividerSpacer extends StatelessWidget {
  const _DividerSpacer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.06),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE6FBF8),
          foregroundColor: const Color(0xFF008F85),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _DestructiveButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _DestructiveButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.red.shade600),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFF1F2),
          foregroundColor: Colors.red.shade600,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _EditableField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _EditableField({
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
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
        ),
      ],
    );
  }
}




