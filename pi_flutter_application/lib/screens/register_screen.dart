import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "És administrador?",
                  style: TextStyle(fontSize: 16),
                ),
                Switch(
                    value: isSwitched,
                    onChanged: (value) {
                      setState(() {
                        isSwitched = value;
                      });
                    }),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                /* try {
                  final response = await http.post(
                    Uri.parse(''),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'email': email,
                      'password': password,
                      'nome': username,
                    }),
                  );
                if (response.statusCode == 201) {
                  Navigator.push(
                    context, 
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                }
                } catch (error) {
                  print('Error: $error');
                } */
              },
              child: Text('Criar conta'),
            ),
          ],
        ),
      ),
    );
  }
}
