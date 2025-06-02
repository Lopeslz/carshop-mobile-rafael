import 'dart:convert';

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/conversation_view.dart';
import 'chat_screen.dart';

class ConversationListScreen extends StatefulWidget {
  final int userId;
  const ConversationListScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  List<ConversationView> _conversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final resp = await ApiService.instance.get('/conversations/user/${widget.userId}', params: {});
    if (resp.statusCode == 200) {
      final List data = List.from(json.decode(resp.body));
      setState(() {
        _conversations = data.map((e) => ConversationView.fromJson(e)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conversas')),
      body: _conversations.isEmpty
          ? const Center(child: Text('Nenhuma conversa encontrada'))
          : ListView.builder(
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conv = _conversations[index];

          // Monta a URL da imagem corretamente, mesmo com nomes longos e únicos
          final imageUrl = conv.carImageUrl.startsWith('http')
              ? conv.carImageUrl
              : 'http://10.0.2.2:8080/uploads/${conv.carImageUrl}';

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    userId: widget.userId,
                    convId: conv.conversationId,
                    conversationId: '',
                    currentUserId: '',
                  ),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported),
                  ),
                ),
                title: Text(conv.carTitle),
                subtitle: Text('Vendedor: ${conv.sellerName}\nR\$ ${conv.carPrice}'),
                trailing: Text(
                  '${conv.lastMessageAt.day}/${conv.lastMessageAt.month} ${conv.lastMessageAt.hour}:${conv.lastMessageAt.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
