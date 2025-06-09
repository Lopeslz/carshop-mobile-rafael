import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/car.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../widgets/car_card.dart';
import 'car_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});


  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _titleController = TextEditingController();
  final _yearController = TextEditingController();
  final _variantController = TextEditingController();

  List<Car> _results = [];
  bool _loading = false;

  Future<void> _searchCars() async {
    setState(() => _loading = true);

    // ✅ Declarar e montar os parâmetros primeiro
    final params = <String, String>{};

    if (_titleController.text.trim().isNotEmpty) {
      params['title'] = _titleController.text.trim();
    }
    if (_yearController.text.trim().isNotEmpty) {
      params['year'] = _yearController.text.trim(); // pode ser string, o backend converte
    }
    if (_variantController.text.trim().isNotEmpty) {
      params['variant'] = _variantController.text.trim();
    }

    // ✅ Só depois usar no get()
    final resp = await ApiService.instance.get(
      '/cars',
      params: params,
    );

    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as List;
      setState(() {
        _results = data.map((e) => Car.fromJson(e)).toList();
      });
    }

    setState(() => _loading = false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesquisar Carros')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Nome do Carro'),
            ),
            TextField(
              controller: _yearController,
              decoration: const InputDecoration(labelText: 'Ano'),
            ),
            TextField(
              controller: _variantController,
              decoration: const InputDecoration(labelText: 'Variante'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _searchCars,
              child: const Text('Buscar'),
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final car = _results[index];
                return CarCard(
                  car: car,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CarDetailScreen(
                          car: car,
                          currentUserId: car.sellerId.toString(), // ou use o userId logado se você tiver
                          sellerId: car.sellerId.toString(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
