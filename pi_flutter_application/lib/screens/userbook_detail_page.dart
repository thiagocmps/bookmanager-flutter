// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../pages/bookshelf_page.dart';

class UserbookDetailPage extends StatefulWidget {
  final Map<String, dynamic> book;
  final String token;
  final decodedToken;
  const UserbookDetailPage(
      {Key? key,
      required this.book,
      required this.token,
      required this.decodedToken})
      : super(key: key);

  @override
  State<UserbookDetailPage> createState() => _UserbookDetailPageState();
}

class _UserbookDetailPageState extends State<UserbookDetailPage> {
  final TextEditingController _reviewController = TextEditingController();
  late double newRating;
  late String dropdownValue;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.book['state'];
  }

  Future<void> _updateBookState() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.patch(
        Uri.parse(
            "http://192.168.1.217:5000/books/updateuserbookstate/${widget.book['_id']}"),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer ${widget.token}'
        },
        body: jsonEncode(<String, dynamic>{"state": dropdownValue}),
      );
      print(widget.book['_id']);
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estado atualizado com sucesso!')),
        );
        /* Navigator.pop(context); */
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LibraryPage(
                token: widget.token, decodedToken: widget.decodedToken),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao atualizar estado: ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      print('Failed to update book state: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar estado do livro.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateBookReview() async {
    setState(() {
      isLoading = true;
    });
    try {
      print('newrating: ' + newRating.toString());
      print('newreview: ' + _reviewController.text);
      print('id: ' + widget.book['_id']);
      final response = await http.patch(
        Uri.parse(
            "http://192.168.1.217:5000/books/updateuserbookreview/${widget.book['_id']}"),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer ${widget.token}'
        },
        body: jsonEncode(<String, dynamic>{
          "review": {
            "rating": newRating,
            "description": _reviewController.text,
          }
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estado atualizado com sucesso!')),
        );
        /* Navigator.pop(context); */
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LibraryPage(
                token: widget.token, decodedToken: widget.decodedToken),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao atualizar estado: ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      print('Failed to update book review: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar comentário do livro.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book['title'] ?? 'Detalhes do Livro'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (widget.book['thumbnail'] != null)
            Center(
              child: Image.network(
                widget.book['thumbnail'],
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.broken_image,
                    size: 150,
                    color: Colors.grey,
                  );
                },
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
          const SizedBox(height: 20),
          const Text("Mudar estado do livro:"),
          const SizedBox(height: 8),
          if (widget.book['state'] != 'Lido') ...[
            DropdownButton<String>(
              value: dropdownValue,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: 'Lido',
                  child: Text('Lido'),
                ),
                DropdownMenuItem(
                  value: 'Lendo',
                  child: Text('Lendo'),
                ),
                DropdownMenuItem(
                  value: 'Ler Mais Tarde',
                  child: Text('Ler Mais Tarde'),
                ),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    dropdownValue = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _updateBookState,
                child: const Text('Salvar'),
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (widget.book['state'] == 'Lido') ...[
            const SizedBox(height: 16),
            if (widget.book['state'] != dropdownValue && !isLoading)
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            Row(
              children: [
                const Text("Avaliação: "),
                RatingBar(
                  initialRating: widget.book['rating']?.toDouble() ?? 0,
                  minRating: 0.5,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 30,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  ratingWidget: RatingWidget(
                    full: const Icon(Icons.star, color: Colors.amber),
                    half: const Icon(Icons.star_half, color: Colors.amber),
                    empty: const Icon(Icons.star_border, color: Colors.amber),
                  ),
                  onRatingUpdate: (rating) {
                    print(rating);
                    newRating = rating;
                    print('newrating: ' + newRating.toString());
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reviewController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Adicione seu comentário',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _updateBookReview,
                child: const Text('Salvar'),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}
