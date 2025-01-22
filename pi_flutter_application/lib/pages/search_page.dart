// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../screens/result_search_book.dart';

class SearchPage extends StatefulWidget {
  final token;
  const SearchPage({@required this.token, super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _queryController = TextEditingController();
  final TextEditingController _minPageController = TextEditingController();
  final TextEditingController _maxPageController = TextEditingController();
  final TextEditingController _minYearController = TextEditingController();
  final TextEditingController _maxYearController = TextEditingController();

  final List<String> allGenres = [
    'Antiques & Collectibles',
    'Literary Collections',
    'Architecture',
    'Literary Criticism',
    'Art',
    'Mathematics',
    'Bibles',
    'Medical',
    'Biography & Autobiography',
    'Music',
    'Body, Mind & Spirit',
    'Nature',
    'Business & Economics',
    'Performing Arts',
    'Comics & Graphic Novels',
    'Pets',
    'Computers',
    'Philosophy',
    'Cooking',
    'Photography',
    'Crafts & Hobbies',
    'Poetry',
    'Design',
    'Political Science',
    'Drama',
    'Psychology',
    'Education',
    'Reference',
    'Family & Relationships',
    'Religion',
    'Fiction',
    'Science',
    'Games & Activities',
    'Self-Help',
    'Gardening',
    'Social Science',
    'Health & Fitness',
    'Sports & Recreation',
    'History',
    'Study Aids',
    'House & Home',
    'Technology & Engineering',
    'Humor',
    'Transportation',
    'Juvenile Fiction',
    'Travel',
    'Juvenile Nonfiction',
    'True Crime',
    'Language Arts & Disciplines',
    'Young Adult Fiction',
    'Language Study',
    'Young Adult Nonfiction',
    'Law'
  ];

  Map<String, bool> selectedGenres = {};

  @override
  void initState() {
    super.initState();
    for (var genre in allGenres) {
      selectedGenres[genre] = false;
    }
  }

  Future<void> searchBooks(BuildContext context) async {
    final String query = _queryController.text;
    final List<String> genres = selectedGenres.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    final String? minPages =
        _minPageController.text.isNotEmpty ? _minPageController.text : null;
    final String? maxPages =
        _maxPageController.text.isNotEmpty ? _maxPageController.text : null;
    final String? minYear =
        _minYearController.text.isNotEmpty ? _minYearController.text : null;
    final String? maxYear =
        _maxYearController.text.isNotEmpty ? _maxYearController.text : null;

    String searchQuery = query.isNotEmpty ? query : '';
    if (genres.isNotEmpty) {
      searchQuery += '+(${genres.map((g) => 'subject:"$g"').join('=OR=')})';
    }

    if (minPages != null || maxPages != null) {
      searchQuery += '+pageCount:';
      if (minPages != null) searchQuery += '$minPages..';
      if (maxPages != null) searchQuery += maxPages;
      print('searchQuery pages: $searchQuery');
    }

    if (minYear != null || maxYear != null) {
      searchQuery += '+publishedDate:';
      if (minYear != null) searchQuery += minYear;
      searchQuery += '..';
      if (maxYear != null) searchQuery += maxYear;
      print('searchQuery date: $searchQuery');
    }

    final url =
        Uri.parse('https://www.googleapis.com/books/v1/volumes').replace(
      queryParameters: {
        'q': searchQuery,
        'maxResults': '40',
        'key': 'AIzaSyA1EyhuRlsRfmYajM17mF3dGtvh0nZtRyk',
      },
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final books = data['items'] ?? [];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ResultBooksScreen(books: books, token: widget.token),
          ),
        );
      } else {
        throw Exception('Erro: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar livros: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Busca de Livros'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _queryController,
              decoration: const InputDecoration(
                labelText: 'Nome do Livro',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPageController,
                    decoration: const InputDecoration(
                      labelText: 'Páginas mínimas',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _maxPageController,
                    decoration: const InputDecoration(
                      labelText: 'Páginas máximas',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minYearController,
                    decoration: const InputDecoration(
                      labelText: 'Ano mínimo',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _maxYearController,
                    decoration: const InputDecoration(
                      labelText: 'Ano máximo',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Selecione os Gêneros:'),
            Expanded(
              child: ListView(
                children: allGenres.map((genre) {
                  return CheckboxListTile(
                    title: Text(genre),
                    value: selectedGenres[genre],
                    onChanged: (isSelected) {
                      setState(() {
                        selectedGenres[genre] = isSelected ?? false;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: () => searchBooks(context),
              child: const Text('Pesquisar'),
            ),
          ],
        ),
      ),
    );
  }
}
