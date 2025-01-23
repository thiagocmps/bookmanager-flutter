import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../screens/book_detail_page.dart';

class Book {
  final String title;
  final String author;
  final String imageUrl;
  final double rating;
  final int pages;
  final String description;

  Book({
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.rating,
    required this.pages,
    this.description = 'Descrição não disponível',
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'];
    return Book(
      title: volumeInfo['title'] ?? 'Unknown Title',
      author: (volumeInfo['authors'] as List<dynamic>?)?.first ?? 'Unknown Author',
      imageUrl: volumeInfo['imageLinks']?['thumbnail'] ?? 'https://via.placeholder.com/150',
      rating: (volumeInfo['averageRating'] ?? 4.0).toDouble(),
      pages: volumeInfo['pageCount'] ?? 0,
      description: volumeInfo['description'] ?? 'Descrição não disponível',
    );
  }
}

class HomePage extends StatefulWidget {
  final token;
  final decodedToken;
  const HomePage({@required this.token, this.decodedToken, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Book> _searchResults = [];
  
  final genres = [
    'Fantasy',
    'Science Fiction',
    'Mystery',
    'Romance',
  ];

  Future<void> _searchBooks(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    setState(() {
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://www.googleapis.com/books/v1/volumes?q=$query&key=AIzaSyBBY8mAYc9WeCA5-j0Xfi5VUocfHXhjzlc'
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List<dynamic>? ?? [];
        setState(() {
          _searchResults = items.map((item) => Book.fromJson(item)).toList();
        });
      } else {
        throw Exception('Falha ao carregar dados: ${response.reasonPhrase}');
      }
    } catch (e) {
      setState(() {
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar dados: $e')),
        );
      }
    }
  }

  void _navigateToDetailPage(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailPage(
          book: book,
          token: widget.token,
          decodedToken: widget.decodedToken,
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(
        5, 
        (index) => Icon(
          index < rating.floor() ? Icons.star : Icons.star_border, 
          color: Colors.amber[400], 
          size: 16
        )
      )..add(
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            '${rating.toStringAsFixed(1)}/5',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        )
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
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              onChanged: (value) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (value == _searchController.text) {
                    _searchBooks(value);
                  }
                });
              },
            ),
          ),
          _searchResults.isNotEmpty
              ? Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.6,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _navigateToDetailPage(_searchResults[index]),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(_searchResults[index].imageUrl),
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
                                      _searchResults[index].title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _searchResults[index].description,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildRatingStars(_searchResults[index].rating),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: genres.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: GenreSection(
                          genre: genres[index],
                          genreNumber: index + 1,
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

class GenreSection extends StatefulWidget {
  final String genre;
  final int genreNumber;

  const GenreSection({
    super.key,
    required this.genre,
    required this.genreNumber,
  });

  @override
  State<GenreSection> createState() => _GenreSectionState();
}

class _GenreSectionState extends State<GenreSection> {
  late Future<List<Book>> _booksFuture;

  Future<List<Book>> _fetchBooksByGenre() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://www.googleapis.com/books/v1/volumes?q=subject:${widget.genre}&maxResults=40'
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List<dynamic>? ?? [];
        return items.map((item) => Book.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching books: $e');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _booksFuture = _fetchBooksByGenre();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.genre,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  // Implement genre page navigation if needed
                },
              ),
            ],
          ),
        ),
        SizedBox(
          height: 240,
          child: FutureBuilder<List<Book>>(
            future: _booksFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final books = snapshot.data ?? [];
              if (books.isEmpty) {
                return const Center(child: Text('No books found'));
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: books
                      .map(
                        (book) => Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: BookCard(book: book),
                        ),
                      )
                      .toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class BookCard extends StatelessWidget {
  final Book book;

  const BookCard({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                book.imageUrl,
                width: 100,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.book, size: 40),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${book.pages} pages',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildRatingStars(book.rating),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(
        5, 
        (index) => Icon(
          index < rating.floor() ? Icons.star : Icons.star_border, 
          color: Colors.amber[400], 
          size: 16
        )
      )..add(
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            '${rating.toStringAsFixed(1)}/5',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        )
      ),
    );
  }
}