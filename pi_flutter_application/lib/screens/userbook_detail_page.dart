import 'package:flutter/material.dart';

class UserbookDetailPage extends StatefulWidget {
  final Map<String, dynamic> book;
  final String token;

  const UserbookDetailPage({Key? key, required this.book, required this.token})
      : super(key: key);

  @override
  State<UserbookDetailPage> createState() => _UserbookDetailPageState();
}

class _UserbookDetailPageState extends State<UserbookDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book['title'] ?? 'Detalhes do Livro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.book['thumbnail'] != null)
              Center(
                child: Image.network(
                  widget.book['thumbnail'],
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              widget.book['title'] ?? 'Sem Título',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Estado: ${widget.book['state'] ?? 'Desconhecido'}'),
          ],
        ),
      ),
    );
  }
}
