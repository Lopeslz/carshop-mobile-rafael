import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/car.dart';
import '../services/api_service.dart';
import 'map_screen.dart';

class EditCarScreen extends StatefulWidget {
  final Car car;

  const EditCarScreen({Key? key, required this.car}) : super(key: key);

  @override
  _EditCarScreenState createState() => _EditCarScreenState();
}

class _EditCarScreenState extends State<EditCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _yearController = TextEditingController();
  final _mileageController = TextEditingController();
  final _variantController = TextEditingController();

  File? _selectedImage;
  LatLng? _meetingPoint;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.car.title;
    _priceController.text = widget.car.price;
    _yearController.text = widget.car.year;
    _mileageController.text = widget.car.mileage;
    _variantController.text = widget.car.variant;
    _meetingPoint = LatLng(widget.car.meetingLat, widget.car.meetingLng);
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _updateCar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_meetingPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o local de encontro')),
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

    final files = <String, http.MultipartFile>{};
    if (_selectedImage != null) {
      files['image'] = await http.MultipartFile.fromPath('image', _selectedImage!.path);
    }

    final response = await ApiService.instance.putMultipart(
      '/cars/${widget.car.id}',
      fields,
      files: files,
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anúncio atualizado com sucesso')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Anúncio")),
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
                      : Image.network(
                    widget.car.imageUrl.startsWith('http')
                        ? widget.car.imageUrl
                        : 'http://10.0.2.2:8080/uploads/${widget.car.imageUrl}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(child: Text("Erro ao carregar imagem")),
                  ),
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
              ElevatedButton(
                onPressed: _updateCar,
                child: const Text("Salvar Alterações"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
