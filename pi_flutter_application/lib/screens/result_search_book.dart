import 'package:flutter/material.dart';
import '../screens/book_detail_page.dart';

class ResultBooksScreen extends StatefulWidget {
  final books;
  final token;
  final decodedToken;
  const ResultBooksScreen(
      {@required this.books, this.token, this.decodedToken, super.key});

  @override
  State<ResultBooksScreen> createState() => _ResultBooksScreenState();
}

class _ResultBooksScreenState extends State<ResultBooksScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados'),
      ),
      body: widget.books.isEmpty
          ? const Center(child: Text('Nenhum livro encontrado.'))
          : ListView.builder(
              itemCount: widget.books.length,
              itemBuilder: (context, index) {
                final book = widget.books[index]['volumeInfo'];
                final title = book['title'] ?? 'Sem título';
                final authors = (book['authors'] as List?)?.join(', ') ??
                    'Autor desconhecido';
                final pageCount = book['pageCount']?.toString() ?? 'Indefinido';
                final publishedDate =
                    book['publishedDate'] ?? 'Data desconhecida';
                final thumbnail = book['imageLinks']?['thumbnail'];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDetailPage(
                            book: widget.books[index],
                            token: widget.token,
                            decodedToken: widget.decodedToken),
                      ),
                    );
                  },
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      leading: thumbnail != null
                          ? Image.network(thumbnail,
                              fit: BoxFit.cover, width: 50, height: 75)
                          : const Icon(Icons.book, size: 50),
                      title: Text(title,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        'Autor(es): $authors\nPáginas: $pageCount\nPublicado em: $publishedDate',
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
