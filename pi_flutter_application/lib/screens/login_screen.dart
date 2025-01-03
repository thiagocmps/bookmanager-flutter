// ignore_for_file: avoid_print

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart'; // Adicionado

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
  }

  void loginUser() async {
    if (usernameLoginController.text.isNotEmpty &&
        passwordLoginController.text.isNotEmpty) {
      var reqBody = {
        "username": usernameLoginController.text,
        "password": passwordLoginController.text
      };

      try {
        var response = await http.post(
            Uri.parse("http://192.168.1.218:5000/users/login/"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(reqBody));

        if (response.statusCode == 200 || response.statusCode == 201) {
          var jsonResponse = jsonDecode(response.body);
          print("Response: $jsonResponse");
          if (jsonResponse != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BottomNavigator(token: jsonResponse),
                ));
            var myToken = jsonResponse['token'] as String;
            print("Token: $myToken");
            prefs.setString('token', myToken);
            if (prefs.containsKey('token')) {
              print("Token saved successfully!");
            } else {
              print("Failed to save token!");
            }
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
