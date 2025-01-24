import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../screens/userbook_detail_page.dart';

class LibraryPage extends StatefulWidget {
  final String token;
  final Map<String, dynamic> decodedToken;
  const LibraryPage({Key? key, required this.token, required this.decodedToken})
      : super(key: key);

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late Future<Map<String, List<Map<String, dynamic>>>> booksByState;

  @override
  void initState() {
    super.initState();
    booksByState = fetchBooksByState();
  }

  Future<Map<String, List<Map<String, dynamic>>>> fetchBooksByState() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.217:5000/books/userbooks'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> books = jsonDecode(response.body);
      final Map<String, List<Map<String, dynamic>>> groupedBooks = {
        'Ler Mais Tarde': [],
        'Lendo': [],
        'Lido': []
      };

      for (var book in books) {
        groupedBooks[book['state']]?.add(book);
      }

      return groupedBooks;
    } else {
      throw Exception('Failed to load books');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Estante'),
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: booksByState,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final booksByState = snapshot.data!;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: booksByState.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: entry.value.length,
                          itemBuilder: (context, index) {
                            final book = entry.value[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserbookDetailPage(
                                      book: book,
                                      token: widget.token,
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  children: [
                                    if (book['thumbnail'] != null)
                                      Image.network(
                                        book['thumbnail'],
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        book['title'] ?? 'Sem Título',
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            );
          } else {
            return const Center(child: Text('Nenhum dado disponível'));
          }
        },
      ),
    );
  }
}
