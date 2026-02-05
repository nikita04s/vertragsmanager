import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vertragsmanager/src/features/contracts/presentation/contracts_screen.dart';
import 'package:vertragsmanager/src/features/dashboard/presentation/dashboard_screen.dart';
import 'package:vertragsmanager/src/features/settings/presentation/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ContractsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // CupertinoTabScaffold ist DAS Widget für echte iOS Navigation
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: const Color(0xCCF2F2F7), // Leicht transparent
        activeColor: const Color(0xFF007AFF), // Apple Blau
        inactiveColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_pie),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.doc_text),
            label: 'Verträge',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Einstellungen',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            return _screens[index];
          },
        );
      },
    );
  }
}