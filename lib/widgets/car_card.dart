import 'package:flutter/material.dart';
import '../models/car.dart';

// ✅ URL base do backend local (ajuste para produção)
const String kBaseImageUrl = 'http://10.0.2.2:8080/uploads/';

class CarListScreen extends StatelessWidget {
  final List<Car> cars;

  const CarListScreen({super.key, required this.cars});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: cars.length,
        itemBuilder: (context, index) {
          return CarCard(car: cars[index], onTap: () {});
        },
      ),
    );
  }
}

class CarCard extends StatelessWidget {
  final Car car;
  final VoidCallback onTap;

  const CarCard({super.key, required this.car, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // ✅ Verifica se imageUrl é externa ou local
    final imageUrl = car.imageUrl.startsWith('http')
        ? car.imageUrl
        : '$kBaseImageUrl${car.imageUrl}';

    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Container(
          height: 130,
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // ✅ Imagem do carro
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  car.imageUrl.startsWith('http')
                      ? car.imageUrl
                      : '$kBaseImageUrl${car.imageUrl}', // kBaseImageUrl = http://10.0.2.2:8080/uploads/
                  width: 140,
                  height: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported, size: 50),
                ),
              ),
              const SizedBox(width: 12),

              // ✅ Informações do carro
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      car.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      'Ano: ${car.year} | ${car.variant}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      'Quilometragem: ${car.mileage}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      car.price,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
