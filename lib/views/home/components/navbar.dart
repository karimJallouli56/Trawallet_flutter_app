import 'package:flutter/material.dart';

class Navbar extends StatefulWidget {
  final int activeScreenId;
  final Widget child;

  const Navbar({super.key, required this.activeScreenId, required this.child});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  void navigateTo(int index) {
    if (index == widget.activeScreenId) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/planner');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/community');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: widget.child,

      bottomNavigationBar: Container(
        height: 100,
        color: Colors.white,
        child: Container(
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 25),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 22),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navItem(icon: Icons.home_filled, index: 0),
              _navItem(icon: Icons.calendar_month_outlined, index: 1),
              _navItem(icon: Icons.people_alt_outlined, index: 2),
              _navItem(icon: Icons.person_outline, index: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({required IconData icon, required int index}) {
    final bool isActive = widget.activeScreenId == index;

    return GestureDetector(
      onTap: () => navigateTo(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: isActive ? 16 : 0,
        ),
        decoration: BoxDecoration(
          color: isActive ? Colors.teal : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 26,
              color: isActive ? Colors.white : Colors.grey.shade600,
            ),

            if (isActive) ...[
              SizedBox(width: 8),
              Text(
                _getLabel(index),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getLabel(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Travel Scheduler';
      case 2:
        return 'Community';
      case 3:
        return 'Account';
      default:
        return '';
    }
  }
}
