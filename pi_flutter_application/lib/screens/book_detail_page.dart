import 'package:flutter/material.dart';

class BookDetailPage extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookDetailPage({super.key, required this.book});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

List<String> options = ['Ler Mais Tarde', 'Lendo', 'Lido'];

class _BookDetailPageState extends State<BookDetailPage> {
  @override
  Widget build(BuildContext context) {
    final volumeInfo = widget.book['volumeInfo'];
    return Scaffold(
      appBar: AppBar(
        title: Text(volumeInfo['title'] ?? 'Detalhes do Livro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (volumeInfo['imageLinks'] != null)
                Center(
                    child: Image.network(
                        volumeInfo['imageLinks']['thumbnail'] ?? '')),
              const SizedBox(height: 36),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text('${volumeInfo['title'] ?? 'N/A'}',
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
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 16),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Flexible(
                                          child: Text(
                                            'Adicionar ${volumeInfo['title']} à: ',
                                            style:
                                                const TextStyle(fontSize: 18),
                                          ),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          ListTile(
                                            title: const Text('Ler Mais Tarde'),
                                            leading: Radio(
                                              value: options[0],
                                              groupValue: currentOption,
                                              onChanged: (value) {
                                                setState(() {
                                                  currentOption =
                                                      value.toString();
                                                });
                                              },
                                            ),
                                          ),
                                          ListTile(
                                            title: const Text('Lendo'),
                                            leading: Radio(
                                              value: options[1],
                                              groupValue: currentOption,
                                              onChanged: (value) {
                                                setState(() {
                                                  currentOption =
                                                      value.toString();
                                                });
                                              },
                                            ),
                                          ),
                                          ListTile(
                                            title: const Text('Lido'),
                                            leading: Radio(
                                              value: options[2],
                                              groupValue: currentOption,
                                              onChanged: (value) {
                                                setState(() {
                                                  currentOption =
                                                      value.toString();
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            currentOption = options[0];
                                            /* salvar livro no banco de dados 
                                            books com o id do utilizador que 
                                            depois será usado para mostrar os 
                                            livros que o utilizador adicionou */
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Adicionar'),
                                      ),
                                    ],
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
