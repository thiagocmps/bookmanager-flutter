import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookDetailPage extends StatefulWidget {
  final book;
  final token;
  final decodedToken;
  const BookDetailPage(
      {super.key,
      required this.book,
      required this.token,
      required this.decodedToken});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  List<String> options = ['Ler Mais Tarde', 'Lendo', 'Lido'];

  @override
  Widget build(BuildContext context) {
    final volumeInfo = widget.book['volumeInfo'];
    final userInfo = widget.decodedToken['data'];
    /* debugPrint('bookId: ' + widget.book['id']);
    debugPrint('state: ' + options[0]); */

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book['volumeInfo']['title'] ?? 'Detalhes do Livro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.book['volumeInfo']['imageLinks'] != null)
                Center(
                    child: Image.network(widget.book['volumeInfo']['imageLinks']
                            ['thumbnail'] ??
                        '')),
              const SizedBox(height: 36),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                        '${widget.book['volumeInfo']['title'] ?? 'N/A'}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  ButtonTheme(
                    minWidth: 40,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            String currentOption = options[0];
                            return StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return SizedBox(
                                  height: 400,
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Adicionar ${widget.book['volumeInfo']['title']} à: ',
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        const SizedBox(height: 16),
                                        Column(
                                          children: options.map((option) {
                                            return ListTile(
                                              title: Text(option),
                                              leading: Radio<String>(
                                                value: option,
                                                groupValue: currentOption,
                                                onChanged: (value) {
                                                  setState(() {
                                                    currentOption =
                                                        value!.toString();
                                                    print(currentOption);
                                                  });
                                                },
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                        const SizedBox(height: 16),
                                        Center(
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              try {
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder:
                                                      (BuildContext context) {
                                                    return const Center(
                                                        child:
                                                            CircularProgressIndicator());
                                                  },
                                                );
                                                final response =
                                                    await http.post(
                                                  Uri.parse(
                                                      'https://bookmanager-api-express-js.onrender.com/books/createbook'),
                                                  headers: <String, String>{
                                                    'Content-Type':
                                                        'application/json; charset=UTF-8',
                                                    'Authorization':
                                                        'Bearer ${widget.token}',
                                                  },
                                                  body: jsonEncode(<String,
                                                      dynamic>{
                                                    "id": widget.book['id'],
                                                    "title":
                                                        volumeInfo['title'],
                                                    "subtitle":
                                                        volumeInfo['subtitle'],
                                                    "authors":
                                                        volumeInfo['authors'],
                                                    "publisher":
                                                        volumeInfo['publisher'],
                                                    "description": volumeInfo[
                                                        'description'],
                                                    "publishedDate": volumeInfo[
                                                        'publishedDate'],
                                                    "pageCount":
                                                        volumeInfo['pageCount'],
                                                    "categories": volumeInfo[
                                                        'categories'],
                                                    "averageRating": volumeInfo[
                                                        'averageRating'],
                                                    "thumbnail":
                                                        volumeInfo['imageLinks']
                                                            ['thumbnail'],
                                                    'userId': userInfo['id'],
                                                    "bookId": widget.book['id'],
                                                    "state": currentOption,
                                                    'review': {
                                                      "description": null,
                                                      "rating": null,
                                                    }
                                                  }),
                                                );

                                                Navigator.pop(context);

                                                if (response.statusCode ==
                                                    201) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Livro adicionado com sucesso!')),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Erro ao adicionar livro: ${response.body} (Código: ${response.statusCode})'),
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                Navigator.pop(context);

                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content:
                                                          Text('Erro: $e')),
                                                );
                                              }
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Adicionar'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      child: const Icon(Icons.library_add),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('${volumeInfo['subtitle'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              Text('Avaliação: ${volumeInfo['averageRating'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Autores: ${volumeInfo['authors']?.join(', ') ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Editora: ${volumeInfo['publisher'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                  'Data de Publicação: ${volumeInfo['publishedDate'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              Text('Descrição: ${volumeInfo['description'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Contagem de Páginas: ${volumeInfo['pageCount'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Tipo de Impressão: ${volumeInfo['printType'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                  'Categorias: ${volumeInfo['categories']?.join(', ') ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
