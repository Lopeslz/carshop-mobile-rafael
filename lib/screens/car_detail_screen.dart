import 'package:flutter/material.dart';
import '../models/car.dart';
import 'schedule_screen.dart';
import 'chat_screen.dart';
import 'dart:convert';
import '../services/api_service.dart';

class CarDetailScreen extends StatelessWidget {
  final Car car;
  final String currentUserId;
  final String sellerId;

  const CarDetailScreen({
    super.key,
    required this.car,
    required this.currentUserId,
    required this.sellerId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalhes do Anúncio")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Imagem do carro com tratamento
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: NetworkImage(
                    car.imageUrl.startsWith('http')
                        ? car.imageUrl
                        : 'http://10.0.2.2:8080/uploads/${car.imageUrl}',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(car.title, style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold)),
            Text("Preço: ${car.price}",
                style: const TextStyle(fontSize: 20, color: Colors.green)),
            const SizedBox(height: 8),
            Text("Ano: ${car.year}"),
            Text("Quilometragem: ${car.mileage}"),
            Text("Variante: ${car.variant}"),
            const SizedBox(height: 24),


            ElevatedButton.icon(
              icon: const Icon(Icons.chat),
              label: const Text("Mandar Mensagem"),
              onPressed: () async {
                try {
                  final conversationId = await createOrGetConversation(
                    currentUserId,
                    sellerId,
                    car.id.toString(),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        conversationId: conversationId.toString(),
                        currentUserId: currentUserId,
                        userId: int.parse(currentUserId),
                        convId: conversationId,
                      ),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erro ao iniciar conversa')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<int> createOrGetConversation(String buyerId, String sellerId, String itemId) async {
    final body = {
      'buyerId': int.parse(buyerId),
      'sellerId': int.parse(sellerId),
      'itemId': int.parse(itemId),
    };

    final resp = await ApiService.instance.post('/conversations', body: body);

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final data = json.decode(resp.body);
      return data['id'];
    } else {
      throw Exception('Erro ao criar ou obter conversa (${resp.statusCode})');
    }
  }
}
