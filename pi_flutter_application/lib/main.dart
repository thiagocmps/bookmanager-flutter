import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'bottom_navigator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  if (token != null) {
    /* String token = futureToken.substring(1, futureToken.length - 1); */
    runApp(MainApp(token: token));
    print('Token: $token');
  } else {
    runApp(const MainApp(token: null));
    print('Token não encontrado');
  }
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
