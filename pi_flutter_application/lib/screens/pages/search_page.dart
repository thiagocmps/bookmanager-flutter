import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPage();
}

class _SearchPage extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Search',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 255, 255, 255)),
        useMaterial3: true,
      ),
      home: const SearchBarAPI(),
    );
  }
}

class SearchBarAPI extends StatefulWidget {
  const SearchBarAPI({super.key});

  @override
  State<SearchBarAPI> createState() => _SearchBarAPIState();
}

class _SearchBarAPIState extends State<SearchBarAPI> {
  final TextEditingController _searchController = TextEditingController();
  final List<dynamic> _searchResults = [];
  bool _isLoading = false;

  Future<void> _searchApi(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://www.googleapis.com/books/v1/volumes?q=$query&key=AIzaSyBBY8mAYc9WeCA5-j0Xfi5VUocfHXhjzlc'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _searchResults.clear();
          _searchResults.addAll(data['items'] ?? []);
          _isLoading = false;
        });
      } else {
        throw Exception('Falha ao carregar dados: ${response.reasonPhrase}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar dados: $e')),
        );
      }
    }
  }

  void _navigateToDetailPage(Map<String, dynamic> book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailPage(book: book),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Digite para pesquisar os livros...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                filled: true,
                fillColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              onChanged: (value) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (value == _searchController.text) {
                    _searchApi(value);
                  }
                });
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.6,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final repo = _searchResults[index];
                      final imageUrl =
                          repo['volumeInfo']['imageLinks']?['thumbnail'] ?? '';
                      return GestureDetector(
                        onTap: () => _navigateToDetailPage(
                            repo), // Navegar para a página de detalhes
                        child: Card(
                          elevation:
                              4, // Sombra para dar um efeito de profundidade
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                12), // Bordas arredondadas
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Container para a imagem ocupando a parte superior
                              Container(
                                height: 120, // Altura fixa para a imagem
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(
                                          12)), // Bordas arredondadas na parte superior
                                  image: DecorationImage(
                                    image: imageUrl.isNotEmpty
                                        ? NetworkImage(imageUrl)
                                        : const AssetImage(
                                                'assets/placeholder.png')
                                            as ImageProvider, // Placeholder se não houver imagem
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      repo['volumeInfo']['title'] ??
                                          'Título não disponível',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(
                                        height:
                                            4), // Espaçamento entre título e descrição
                                    Text(
                                      repo['volumeInfo']['description'] ??
                                          'Descrição não disponível',
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(
                                        height:
                                            8), // Espaçamento antes da avaliação
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            color: Colors.amber, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${repo['volumeInfo']['averageRating'] ?? 'N/A'}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
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
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class BookDetailPage extends StatelessWidget {
  final Map<String, dynamic> book;

  const BookDetailPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final volumeInfo = book['volumeInfo'];
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
                Image.network(volumeInfo['imageLinks']['thumbnail'] ?? ''),
              const SizedBox(height: 10),
              Text('Título: ${volumeInfo['title'] ?? 'N/A'}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Subtítulo: ${volumeInfo['subtitle'] ?? 'N/A'}',
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
              const SizedBox(height: 8),
              Text('Descrição: ${volumeInfo['description'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                  'Identificadores da Indústria: ${volumeInfo['industryIdentifiers']?.map((id) => '${id['type']}: ${id['identifier']}').join(', ') ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                  'Modos de Leitura: ${volumeInfo['readingModes'] != null ? 'Texto: ${volumeInfo['readingModes']['text']}, Imagem: ${volumeInfo['readingModes']['image']}' : 'N/A'}',
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
              Center(
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton(
                    onPressed: () {
                      // Ação do botão
                    },
                    child: const Text(
                      '+',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
