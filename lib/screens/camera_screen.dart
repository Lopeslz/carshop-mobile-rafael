import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Lista global de câmeras disponíveis
List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Obtém a lista de câmeras disponíveis no dispositivo
  cameras = await availableCameras();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exemplo Câmera',
      home: CameraExample(),
    );
  }
}

class CameraExample extends StatefulWidget {
  @override
  State<CameraExample> createState() => _CameraExampleState();
}

class _CameraExampleState extends State<CameraExample> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    // Verifica se há câmeras disponíveis
    if (cameras.isNotEmpty) {
      // Inicializa o controller com a primeira câmera (geralmente a traseira)
      _cameraController = CameraController(
        cameras[0],
        ResolutionPreset.medium,
      );

      // Armazena a Future da inicialização para usar no FutureBuilder
      _initializeControllerFuture = _cameraController!.initialize();
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  /// Tira a foto e salva em um arquivo temporário
  Future<void> _takePicture() async {
    try {
      // Aguarda a inicialização do controller
      await _initializeControllerFuture;

      // Tira a foto e retorna um XFile (não aceita mais parâmetro de caminho)
      final XFile photo = await _cameraController!.takePicture();

      // Se quiser mover a foto para um diretório temporário específico:
      final tempDir = await getTemporaryDirectory();
      final newPath = path.join(
        tempDir.path,
        'foto_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      // Copia o arquivo original (photo.path) para o newPath
      final File originalFile = File(photo.path);
      await originalFile.copy(newPath);

      // Exibe uma mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foto salva em $newPath')),
      );
    } catch (e) {
      print('Erro ao tirar foto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao tirar foto')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null) {
      // Caso não haja câmeras disponíveis
      return Scaffold(
        appBar: AppBar(title: const Text('Câmera')),
        body: const Center(child: Text('Nenhuma câmera disponível')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Câmera')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Se a câmera foi inicializada, exibe o preview
            return CameraPreview(_cameraController!);
          } else {
            // Caso contrário, exibe um indicador de carregamento
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        child: const Icon(Icons.camera),
      ),
    );
  }
}
