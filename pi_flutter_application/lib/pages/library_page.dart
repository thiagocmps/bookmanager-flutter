import 'package:flutter/material.dart';

class LibraryPage extends StatefulWidget {
  final token;
  const LibraryPage({@required this.token, super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Library page"),
      ),
    );
  }
}
