import 'package:flutter/material.dart';
import '../models/car.dart';

class ScheduleScreen extends StatefulWidget {
  final Car car;

  const ScheduleScreen({super.key, required this.car});

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String? selectedLocation;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String contactType = 'email';
  final TextEditingController contactController = TextEditingController();

  final List<String> locations = [
    'Combinar com o(a) vendedor(a).',
    'Onde o Carro está Guardado.',
    'Marcar no seu endereço.'
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendamento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Carro Selecionado: ${widget.car.title}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Preço: ${widget.car.price}', style: const TextStyle(fontSize: 16, color: Colors.green)),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Local de retirada'),
              items: locations.map((location) {
                return DropdownMenuItem<String>(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedLocation = value;
                });
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text(selectedDate == null
                        ? 'Selecionar Data'
                        : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectTime(context),
                    child: Text(selectedTime == null
                        ? 'Selecionar Horário'
                        : '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Forma de Contato'),
              items: const [
                DropdownMenuItem(value: 'email', child: Text('E-mail')),
                DropdownMenuItem(value: 'phone', child: Text('Telefone')),
              ],
              onChanged: (value) {
                setState(() {
                  contactType = value!;
                  contactController.clear();
                });
              },
              value: contactType,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contactController,
              decoration: InputDecoration(
                labelText: contactType == 'email' ? 'E-mail' : 'Telefone',
                hintText: contactType == 'email' ? 'exemplo@email.com' : '(00) 00000-0000',
              ),
              keyboardType: contactType == 'email' ? TextInputType.emailAddress : TextInputType.phone,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implementar lógica para confirmar agendamento
              },
              child: const Text('Confirmar Agendamento'),
            ),
          ],
        ),
      ),
    );
  }
}