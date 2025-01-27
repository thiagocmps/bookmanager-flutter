// ignore_for_file: avoid_print

import 'package:shared_preferences/shared_preferences.dart';
import '../bottom_navigator.dart';
import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameLoginController = TextEditingController();
  TextEditingController passwordLoginController = TextEditingController();
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    print("Shared Preferences initialized!: $prefs");
  }

  void loginUser() async {
    if (usernameLoginController.text.isNotEmpty &&
        passwordLoginController.text.isNotEmpty) {
      /* var reqBody = {
        "username": usernameLoginController.text,
        "password": passwordLoginController.text
      }; */

      try {
        var response = await http.post(
            Uri.parse(
                "https://bookmanager-api-express-js.onrender.com/users/login"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "username": usernameLoginController.text,
              "password": passwordLoginController.text
            }));

        if (response.statusCode == 200 || response.statusCode == 201) {
          var jsonResponse = jsonDecode(response.body);
          print("Response: $jsonResponse");
          if (jsonResponse != null) {
            var myToken = jsonResponse as String;

            print("Token: $myToken");
            prefs.setString('token', myToken);
            if (prefs.containsKey('token')) {
              print("Token saved successfully!");
            } else {
              print("Failed to save token!");
            }

            Navigator.of(context).pop();
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BottomNavigator(token: jsonResponse),
                ));
          } else {
            print("Something went wrong!");
          }
        } else {
          print("Failed to login: ${response.reasonPhrase}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to login: ${response.reasonPhrase}')),
          );
        }
      } catch (error) {
        if (error is FormatException) {
          print("FormatException: ${error.message}");
        } else {
          print("An error occurred: $error");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: usernameLoginController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              controller: passwordLoginController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                loginUser();
              },
              child: const Text('Login'),
            ),
            OutlinedButton(
              onPressed: () {
                // Handle login action
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ));
              },
              child: const Text('Não tens conta?'),
            ),
          ],
        ),
      ),
    );
  }
}

clearToken(token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('token');
  print("Token removed!" + token);
}
