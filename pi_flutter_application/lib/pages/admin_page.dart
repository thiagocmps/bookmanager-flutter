import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminPage extends StatefulWidget {
  final String token;

  const AdminPage({Key? key, required this.token}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  Map<String, List<Map<String, dynamic>>> groupedBooks = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchBooksAndComments();
  }

  Future<void> fetchBooksAndComments() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse("http://192.168.1.217:5000/books/alluserbooks"),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        List<dynamic> books = jsonDecode(response.body);

        // Agrupa os livros por `bookId`.
        Map<String, List<Map<String, dynamic>>> grouped = {};
        for (var book in books) {
          String bookId = book['bookId'];
          if (!grouped.containsKey(bookId)) {
            grouped[bookId] = [];
          }
          grouped[bookId]!.add(book);
        }

        setState(() {
          groupedBooks = grouped;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao buscar livros: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Erro ao buscar livros: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao buscar livros.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      final response = await http.patch(
        Uri.parse(
            "http://192.168.1.217:5000/books/updateuserbookreview/$commentId"),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "review": {
            "description": null,
            "rating": null,
          }
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comentário removido com sucesso!')),
        );
        fetchBooksAndComments(); // Recarrega os dados
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Erro ao remover comentário: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Erro ao remover comentário: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao remover comentário.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comentários por Livro'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : groupedBooks.isEmpty
              ? const Center(
                  child: Text('Nenhum comentário encontrado.'),
                )
              : ListView.builder(
                  itemCount: groupedBooks.keys.length,
                  itemBuilder: (context, index) {
                    String bookId = groupedBooks.keys.elementAt(index);
                    List<Map<String, dynamic>> bookComments =
                        groupedBooks[bookId]!;

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bookComments.first['title'] ?? 'Sem Título',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (bookComments.first['thumbnail'] != null)
                              Image.network(
                                bookComments.first['thumbnail'],
                                height: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.broken_image,
                                    size: 100,
                                    color: Colors.grey,
                                  );
                                },
                              ),
                            const SizedBox(height: 10),
                            const Text(
                              'Comentários:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...bookComments.map((comment) {
                              final review = comment['review'];
                              return review['description'] != null ||
                                      review['rating'] != null
                                  ? ListTile(
                                      title: Text(review['description'] ??
                                          'Sem comentário'),
                                      subtitle: review['rating'] != null
                                          ? Text(
                                              'Avaliação: ${review['rating']} estrelas')
                                          : null,
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () =>
                                            deleteComment(comment['_id']),
                                      ),
                                    )
                                  : const SizedBox.shrink();
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
