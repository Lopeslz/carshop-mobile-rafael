import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/car_card.dart';
import 'car_detail_screen.dart';
import 'car_form_screen.dart';
import 'conversation_list_screen.dart';
import 'login_screen.dart';
import 'schedule_screen.dart';
import '../models/car.dart';
import 'search_screen.dart';
import 'account_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  const HomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeContent(userId: widget.userId),
      const SearchScreen(),
      ConversationListScreen(userId: int.parse(widget.userId)),
      CarFormScreen(userId: widget.userId),
      AccountScreen(userId: widget.userId),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CarFormScreen(userId: widget.userId)),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CarShop - E-Commerce'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              if (prefs.containsKey('userId')) {
                final userId = prefs.getInt('userId')!;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AccountScreen(userId: userId.toString())),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black54),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.black54),
            label: 'Pesquisa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat, color: Colors.black54),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_a_photo, color: Colors.black54),
            label: 'Anunciar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.black54),
            label: 'Conta',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final String userId;
  const HomeContent({super.key, required this.userId});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<Car> _cars = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCarsFromApi();
  }

  Future<void> _loadCarsFromApi() async {
    final resp = await ApiService.instance.get('/cars', params: {});
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as List;
      setState(() {
        _cars = data.map((e) => Car.fromJson(e)).toList();
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar carros (${resp.statusCode})')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: const DecorationImage(
                image: AssetImage('assets/images/home_banner.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Seu carro dos sonhos está aqui.',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _cars.length,
            itemBuilder: (context, index) {
              final car = _cars[index];
              return CarCard(
                car: car,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CarDetailScreen(
                      car: car,
                      currentUserId: widget.userId,
                      sellerId: car.sellerId,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
