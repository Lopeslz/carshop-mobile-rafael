import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../models/car.dart';
import '../services/api_service.dart';
import '../utils/user_prefs.dart';
import 'car_detail_screen.dart';
import 'edit_car_screen.dart';
import 'login_screen.dart';

class AccountScreen extends StatefulWidget {
  final String userId;
  const AccountScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _nameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  DateTime? _birthDate;
  LatLng? _userLocation;
  File? _profileImage;
  String? _profileImageFromServer;
  List<Car> _myAds = [];
  bool _hasJustUploadedImage = false;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
    });
    _loadMyAds();
  }

  Future<void> _loadUserProfile() async {
    final resp = await ApiService.instance.get('/user/${widget.userId}/profile', params: {});
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      setState(() {
        _nameCtrl.text = data['name'] ?? '';
        _cityCtrl.text = data['city'] ?? '';
        if (data['birth_date'] != null && data['birth_date'] != "") {
          _birthDate = DateTime.tryParse(data['birth_date']);
        }
        if (data['latitude'] != null && data['longitude'] != null) {
          _userLocation = LatLng(data['latitude'], data['longitude']);
        }
        // 👇 aqui, salva só o nome da imagem!
        _profileImageFromServer = data['profile_image_url'];
      });
    }
  }

  Future<void> _loadMyAds() async {
    final resp = await ApiService.instance.get('/cars/user/${widget.userId}', params: {});
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as List;
      setState(() {
        _myAds = data.map((e) => Car.fromJson(e)).toList();
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _profileImage = File(file.path);
      });
    }
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _saveProfile() async {
    final fields = {
      'name': _nameCtrl.text,
      'city': _cityCtrl.text,
      'birth_date': _birthDate?.toIso8601String() ?? '',
      'latitude': _userLocation?.latitude.toString() ?? '',
      'longitude': _userLocation?.longitude.toString() ?? '',
    };

    final files = <String, http.MultipartFile>{};
    if (_profileImage != null) {
      files['profile_image'] = await http.MultipartFile.fromPath('profile_image', _profileImage!.path);
    }

    final resp = await ApiService.instance.putMultipart(
      '/user/${widget.userId}/profile',
      fields,
      files: files,
    );

    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      setState(() {
        _profileImageFromServer = data['profile_image_url'];
      });

      // FORÇA reload do profile
      await _loadUserProfile();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar perfil')),
      );
    }
  }

  Future<void> _logout() async {
    await clearUserId();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  Future<void> _deleteAd(int adId) async {
    final resp = await ApiService.instance.delete('/cars/$adId');
    if (resp.statusCode == 204) {
      await _loadMyAds();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anúncio deletado com sucesso')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _profileImageFromServer != null
        ? 'http://10.0.2.2:8080/uploads/$_profileImageFromServer?v=${DateTime.now().millisecondsSinceEpoch}'
        : null;

    print('Image URL sendo usada: $imageUrl');

    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickProfileImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : (imageUrl != null ? NetworkImage(imageUrl) : null) as ImageProvider?,
                child: (_profileImage == null && imageUrl == null)
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nome')),
            TextFormField(controller: _cityCtrl, decoration: const InputDecoration(labelText: 'Cidade')),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _birthDate == null
                        ? 'Selecione sua data de nascimento'
                        : 'Nascimento: ${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                  ),
                ),
                TextButton(onPressed: _selectBirthDate, child: const Text('Alterar')),
              ],
            ),
            if (_userLocation != null)
              Text('Local: ${_userLocation!.latitude}, ${_userLocation!.longitude}'),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _saveProfile, child: const Text('Salvar Perfil')),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Sair'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: _logout,
            ),
            const Divider(height: 30),
            const Text('Meus Anúncios', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _myAds.length,
              itemBuilder: (context, index) {
                final car = _myAds[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Image.network(
                      car.imageUrl.startsWith('http')
                          ? car.imageUrl
                          : 'http://10.0.2.2:8080/uploads/${car.imageUrl}',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported),
                    ),
                    title: Text(car.title),
                    subtitle: Text('R\$ ${car.price}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => EditCarScreen(car: car)),
                            ).then((_) => _loadMyAds());
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteAd(car.id),
                        ),
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CarDetailScreen(
                          car: car,
                          currentUserId: widget.userId,
                          sellerId: car.sellerId.toString(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
