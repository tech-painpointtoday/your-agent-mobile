import 'package:flutter/material.dart';
import 'package:youragent/features/calendar/pages/calendar_screen.dart';
import 'package:youragent/features/contact/pages/contact_screen.dart';
import 'package:youragent/features/home/pages/home_screen.dart';
import 'package:youragent/features/money/pages/money_screen.dart';
import 'package:youragent/features/property/pages/property_screen.dart';
import 'package:youragent/widgets/app_bottom_navigation_bar.dart';

/// Main navigation screen that contains PageView for all tabs
/// This ensures the bottom navigation bar is singleton and tabs have smooth transitions
class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: const [
          HomeScreen(),
          PropertyScreen(),
          MoneyScreen(),
          CalendarScreen(),
          ContactScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }
}
