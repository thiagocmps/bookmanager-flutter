import 'pages/premium_page.dart';
import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/search_page.dart';
import 'pages/bookshelf_page.dart';
import 'pages/account_page.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'screens/login_screen.dart';

class BottomNavigator extends StatefulWidget {
  final token;
  const BottomNavigator({@required this.token, super.key});

  @override
  _BottomNavigatorState createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  int _currentIndex = 0;

  late String role;
  late Map<String, dynamic> decodedToken;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    decodedToken = jwtDecodedToken;
    role = jwtDecodedToken['data']?['role'];
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(token: widget.token, decodedToken: decodedToken),
      SearchPage(token: widget.token, decodedToken: decodedToken),
      LibraryPage(token: widget.token, decodedToken: decodedToken),
      AccountPage(token: widget.token, decodedToken: decodedToken),
    ];
    bool isAdmin = role == 'admin' ? true : false;
    if (isAdmin == true) {
      pages.add(const AdminPage());
    }

    return Scaffold(
      body: pages[_currentIndex],
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
            label: 'Estante',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Conta',
          ),
          if (isAdmin)
            const NavigationDestination(
              icon: Icon(Icons.star),
              label: 'Admin',
            ),
        ],
      ),
    );
  }
}
