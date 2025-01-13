import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'bottom_navigator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MainApp(token: prefs.getString('token')));
  print('Token: ${prefs.getString('token')}');
}

class MainApp extends StatelessWidget {
  final token;

  const MainApp({
    @required this.token,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        home: (token != null && JwtDecoder.isExpired(token) == false)
            ? BottomNavigator(token: token)
            : const LoginPage(),
      ),
    );
  }
}
