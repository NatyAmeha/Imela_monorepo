import 'package:flutter/material.dart';

class AccountPopup extends StatelessWidget {
  final String userName;
  final String phoneNumber;
  final VoidCallback onLogout;
  final Function(String) onLanguageChanged;
  final Offset triggerPosition;

  const AccountPopup({
    Key? key,
    required this.userName,
    required this.phoneNumber,
    required this.onLogout,
    required this.onLanguageChanged,
    required this.triggerPosition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate the available space below and to the right
    final screenSize = MediaQuery.of(context).size;
    final popupWidth = 320.0;
    final popupHeight = 300.0; // Approximate height, adjust as needed

    // Calculate position
    double left = triggerPosition.dx;
    double top = triggerPosition.dy + 50; // Add some offset from the trigger

    // Ensure the popup stays within screen bounds
    if (left + popupWidth > screenSize.width) {
      left = screenSize.width - popupWidth - 16; // 16 is padding from right edge
    }

    if (top + popupHeight > screenSize.height) {
      top = triggerPosition.dy - popupHeight - 8; // Show above if not enough space below
    }

    return Positioned(
      left: left,
      top: top,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: popupWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const Divider(height: 1),
              _buildActionsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _AccountAvatar(name: userName),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  phoneNumber,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionItem(
          icon: Icons.language,
          title: 'Language',
          onTap: () => _showLanguageSelector(),
        ),
        _ActionItem(
          icon: Icons.settings,
          title: 'Settings',
          onTap: () {},
        ),
        _ActionItem(
          icon: Icons.help_outline,
          title: 'Help & Support',
          onTap: () {},
        ),
        const Divider(height: 1),
        _ActionItem(
          icon: Icons.logout,
          title: 'Sign out',
          onTap: () {
            onLogout();
          },
          isDestructive: true,
        ),
      ],
    );
  }

  void _showLanguageSelector() {
    // Implement language selector logic
  }
}

class _AccountAvatar extends StatelessWidget {
  final String name;

  const _AccountAvatar({
    Key? key,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isDestructive ? Colors.red : Colors.grey.shade700),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: isDestructive ? Colors.red : Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountPopupFactory {
  static OverlayEntry showAccountPopup({
    required BuildContext context,
    required String userName,
    required String phoneNumber,
    required VoidCallback onLogout,
    required Function(String) onLanguageChanged,
    required Offset triggerPosition,
  }) {
    late final OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Backdrop
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => overlayEntry.remove(),
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
          ),
          // Popup
          AccountPopup(
            userName: userName,
            phoneNumber: phoneNumber,
            onLogout: () {
              overlayEntry.remove();
              onLogout();
            },
            onLanguageChanged: onLanguageChanged,
            triggerPosition: triggerPosition,
          ),
        ],
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    return overlayEntry;
  }
}
