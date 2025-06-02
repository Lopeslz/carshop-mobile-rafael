import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final int userId;
  final int convId;

  const ChatScreen({
    Key? key,
    required this.userId,
    required this.convId,
    required String conversationId,
    required String currentUserId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtl = TextEditingController();
  final _picker = ImagePicker();
  List<Map<String, dynamic>> _msgs = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final resp = await ApiService.instance.get(
      '/conversations/${widget.convId}/messages',
      params: {}, // mesmo que não use, necessário pois o método exige
    );
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as List;
      setState(() {
        _msgs = data.cast<Map<String, dynamic>>();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar mensagens')),
      );
    }
  }

  Future<void> _sendText() async {
    final text = _msgCtl.text.trim();
    if (text.isEmpty) return;

    final body = {
      'senderId': widget.userId,
      'type': 'text',
      'contentText': text,
    };

    final resp = await ApiService.instance.post(
      '/conversations/${widget.convId}/messages',
      body: body,
    );

    if (resp.statusCode == 200) {
      _msgCtl.clear();
      await _loadMessages();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao enviar mensagem')),
      );
    }
  }

  Future<void> _sendVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    if (await file.length() > 100 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vídeo ultrapassa 100 MB')),
      );
      return;
    }

    final files = {
      'video': await http.MultipartFile.fromPath('video', file.path),
    };

    final resp = await ApiService.instance.postMultipart(
      '/conversations/${widget.convId}/messages/video',
      {
        'senderId': widget.userId.toString(),
      },
      files: files,
    );

    if (resp.statusCode == 200) {
      await _loadMessages();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao enviar vídeo')),
      );
    }
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    final isMe = msg['senderId'] == widget.userId;

    if (msg['type'] == 'text') {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: isMe ? Colors.blue[100] : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(msg['contentText'] ?? ''),
        ),
      );
    }

    if (msg['type'] == 'video' && msg['contentBlob'] != null) {
      final List<int> bytes = List<int>.from(msg['contentBlob']);
      return FutureBuilder<VideoPlayerController>(
        future: _prepareVideo(bytes),
        builder: (ctx, snap) {
          if (!snap.hasData) return const CircularProgressIndicator();
          final ctrl = snap.data!;
          return Container(
            margin: const EdgeInsets.all(8),
            height: 200,
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: ctrl.value.aspectRatio,
                  child: VideoPlayer(ctrl),
                ),
                VideoProgressIndicator(ctrl, allowScrubbing: true),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(ctrl.value.isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: () {
                        setState(() {
                          ctrl.value.isPlaying ? ctrl.pause() : ctrl.play();
                        });
                      },
                    )
                  ],
                )
              ],
            ),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Future<VideoPlayerController> _prepareVideo(List<int> bytes) async {
    final dir = await Directory.systemTemp.createTemp();
    final file = File('${dir.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4');
    await file.writeAsBytes(bytes);
    final ctrl = VideoPlayerController.file(file);
    await ctrl.initialize();
    ctrl.setLooping(true);
    return ctrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: _msgs.map(_buildMessage).toList(),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: _sendVideo,
              ),
              Expanded(
                child: TextField(
                  controller: _msgCtl,
                  decoration: const InputDecoration(
                    hintText: 'Digite sua mensagem...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendText,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
