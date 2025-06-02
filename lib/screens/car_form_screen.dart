import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'map_screen.dart';

class CarFormScreen extends StatefulWidget {
  final String userId;
  const CarFormScreen({super.key, required this.userId});

  @override
  _CarFormScreenState createState() => _CarFormScreenState();
}

class _CarFormScreenState extends State<CarFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _yearController = TextEditingController();
  final _mileageController = TextEditingController();
  final _variantController = TextEditingController();

  File? _selectedImage;
  LatLng? _meetingPoint;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _saveCar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null || _meetingPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagem e local são obrigatórios')),
      );
      return;
    }

    final fields = {
      'title': _titleController.text,
      'price': _priceController.text,
      'year': _yearController.text,
      'mileage': _mileageController.text,
      'variant': _variantController.text,
      'meetingLat': _meetingPoint!.latitude.toString(),
      'meetingLng': _meetingPoint!.longitude.toString(),
    };

    final files = {
      'image': await http.MultipartFile.fromPath('image', _selectedImage!.path),
    };

    final response = await ApiService.instance.postMultipart(
      '/cars?sellerId=${widget.userId}',
      fields,
      files: files,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anúncio criado com sucesso')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Criar Anúncio")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _pickImage(ImageSource.gallery),
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : const Center(child: Text("Toque para escolher imagem")),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(icon: const Icon(Icons.camera_alt), onPressed: () => _pickImage(ImageSource.camera)),
                  IconButton(icon: const Icon(Icons.photo_library), onPressed: () => _pickImage(ImageSource.gallery)),
                ],
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Título"),
                validator: (v) => v!.isEmpty ? "Digite o título" : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Preço"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Digite o preço" : null,
              ),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: "Ano"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Digite o ano" : null,
              ),
              TextFormField(
                controller: _mileageController,
                decoration: const InputDecoration(labelText: "Quilometragem"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Digite a quilometragem" : null,
              ),
              TextFormField(
                controller: _variantController,
                decoration: const InputDecoration(labelText: "Variante"),
                validator: (v) => v!.isEmpty ? "Digite a variante" : null,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  final loc = await Navigator.push<LatLng>(
                    context,
                    MaterialPageRoute(builder: (_) => const MapScreen()),
                  );
                  if (loc != null) {
                    setState(() => _meetingPoint = loc);
                  }
                },
                child: const Text("Selecionar Local de Encontro"),
              ),
              if (_meetingPoint != null)
                Text("Local: ${_meetingPoint!.latitude}, ${_meetingPoint!.longitude}"),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _saveCar, child: const Text("Salvar Anúncio")),
            ],
          ),
        ),
      ),
    );
  }
}
