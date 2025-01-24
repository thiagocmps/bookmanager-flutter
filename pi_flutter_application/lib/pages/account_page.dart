import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import 'package:confirm_dialog/confirm_dialog.dart';

class AccountPage extends StatefulWidget {
  final token;
  final decodedToken;
  const AccountPage(
      {@required this.token, required this.decodedToken, super.key});

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
              onPressed: () async {
                if (await confirm(
                  context,
                  title: const Text('Sair da conta'),
                  content: const Text('Tens certeza que queres sair da conta?'),
                  textOK: const Text('Sim'),
                  textCancel: const Text('Não'),
                )) {
                  clearToken(widget.token);
                  /* print('Token "vazio": ${widget.token}'); */
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                  return print('pressedOK');
                } else {
                  return print('pressedCancel');
                }
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
