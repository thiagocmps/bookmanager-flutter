import 'package:flutter/material.dart';
import '../screens/login_screen.dart';

class AccountPage extends StatefulWidget {
  final token;
  const AccountPage({@required this.token, super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Account Page'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                widget.token == null;

                print('Token "vazio": ${widget.token}');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
