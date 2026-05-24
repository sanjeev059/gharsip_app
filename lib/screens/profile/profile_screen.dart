import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Profile',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
      ),
      body: user == null
          ? const _NotLoggedIn()
          : ListView(
              children: [
                _ProfileHeader(auth: auth),
                _MenuSection(title: 'My Account', items: [
                  _MenuItem(Icons.person_outline, 'Edit Profile', () => _showEditProfile(context, auth)),
                  _MenuItem(Icons.receipt_long_outlined, 'My Orders', () => Navigator.pushNamed(context, '/orders')),
                  _MenuItem(Icons.content_cut_outlined, 'Saree Bookings', () => Navigator.pushNamed(context, '/orders')),
                ]),
                _MenuSection(title: 'Support', items: [
                  _MenuItem(Icons.chat_outlined, 'WhatsApp Support', () => launchUrl(
                    Uri.parse('https://wa.me/${AppStrings.whatsappNumber}?text=Hi%2C+I+need+help+with+Gharsip'),
                    mode: LaunchMode.externalApplication,
                  )),
                  _MenuItem(Icons.help_outline, 'FAQ', () => launchUrl(
                    Uri.parse('https://gharsip.in/#faq'),
                    mode: LaunchMode.externalApplication,
                  )),
                  _MenuItem(Icons.policy_outlined, 'Privacy Policy', () => launchUrl(
                    Uri.parse('https://gharsip.in/privacy-policy'),
                    mode: LaunchMode.externalApplication,
                  )),
                  _MenuItem(Icons.description_outlined, 'Terms of Service', () => launchUrl(
                    Uri.parse('https://gharsip.in/terms'),
                    mode: LaunchMode.externalApplication,
                  )),
                ]),
                _MenuSection(title: 'App', items: [
                  _MenuItem(Icons.info_outline, 'App Version', () {},
                    trailing: const Text('1.0.0',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted, fontFamily: 'Poppins'))),
                ]),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmSignOut(context, auth),
                    icon: const Icon(Icons.logout, color: AppColors.error),
                    label: const Text('Sign Out',
                      style: TextStyle(color: AppColors.error, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
    );
  }

  void _confirmSignOut(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out?',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: const Text('You will be returned to the login screen.',
          style: TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins'))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Sign Out', style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _showEditProfile(BuildContext context, AuthProvider auth) {
    final nameCtrl = TextEditingController(text: auth.user?.name ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(16, 20, 16,
            MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: const TextStyle(fontFamily: 'Poppins'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await auth.updateProfile(name: nameCtrl.text.trim());
                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Save', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final AuthProvider auth;
  const _ProfileHeader({required this.auth});

  @override
  Widget build(BuildContext context) {
    final user = auth.user!;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primaryMuted,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : user.phone[0],
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800,
                  color: AppColors.primary, fontFamily: 'Poppins'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name.isNotEmpty ? user.name : 'Gharsip User',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary, fontFamily: 'Poppins')),
                const SizedBox(height: 2),
                Text(user.phone,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecond, fontFamily: 'Poppins')),
                if (user.isAdmin)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMuted,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Admin',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                          color: AppColors.primary, fontFamily: 'Poppins')),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                color: AppColors.textMuted, fontFamily: 'Poppins', letterSpacing: 0.5)),
        ),
        Container(
          color: Colors.white,
          child: Column(
            children: items.asMap().entries.map((e) {
              final item = e.value;
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryMuted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(item.icon, color: AppColors.primary, size: 20),
                    ),
                    title: Text(item.label,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary, fontFamily: 'Poppins')),
                    trailing: item.trailing ?? const Icon(Icons.chevron_right, color: AppColors.textMuted),
                    onTap: item.onTap,
                    dense: true,
                  ),
                  if (!isLast)
                    Divider(height: 1, indent: 68, color: AppColors.border),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  const _MenuItem(this.icon, this.label, this.onTap, {this.trailing});
}

class _NotLoggedIn extends StatelessWidget {
  const _NotLoggedIn();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_outline, size: 72, color: AppColors.textMuted),
          const SizedBox(height: 16),
          const Text('Not logged in',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary, fontFamily: 'Poppins')),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Login', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
