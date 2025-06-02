import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/user_prefs.dart';
import 'home_screen.dart';
import 'dart:convert';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtl    = TextEditingController();
  final _emailCtl   = TextEditingController();
  final _passCtl    = TextEditingController();
  final _confirmCtl = TextEditingController();
  bool _loading     = false;

  Future<void> _register() async {
    if (_passCtl.text != _confirmCtl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não conferem')),
      );
      return;
    }

    setState(() => _loading = true);
    final resp = await ApiService.instance.post(
      '/auth/register',
      body: {
        'name': _nameCtl.text,
        'email': _emailCtl.text,
        'password': _passCtl.text,
      },
    );
    setState(() => _loading = false);

    if (resp.statusCode == 201) {
      final data = json.decode(resp.body);
      final userId = data['userId'];
      await saveUserId(userId);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(userId: userId.toString()),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cadastro falhou (${resp.statusCode})')),
      );
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameCtl,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _emailCtl,
              decoration: const InputDecoration(labelText: 'E-mail'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passCtl,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmCtl,
              decoration:
              const InputDecoration(labelText: 'Confirme a senha'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _register,
              child: const Text('Cadastrar'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Já tenho conta. Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}
