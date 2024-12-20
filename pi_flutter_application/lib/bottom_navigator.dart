import 'screens/pages/premium_page.dart';
import 'package:flutter/material.dart';
import 'screens/pages/home_page.dart';
import 'screens/pages/search_page.dart';
import 'screens/pages/library_page.dart';
import 'screens/pages/account_page.dart';

class BottomNavigator extends StatefulWidget {
  @override
  _BottomNavigatorState createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const SearchPage(),
    const LibraryPage(),
    const AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    bool isPremiumUser = true;
    if (isPremiumUser) {
      _pages.add(const AdminPage()); // Adiciona o menu para o usuário premium
    }
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          const NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Pesquisa',
          ),
          const NavigationDestination(
            icon: Icon(Icons.library_books),
            label: 'Biblioteca',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Conta',
          ),
          if (isPremiumUser)
            const NavigationDestination(
              icon: Icon(Icons.star),
              label: 'Admin',
            ),
        ],
      ),
    );
  }
}
