import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Fletes'),
      ),
      body: ListView.builder(
        itemCount: 10, // Ejemplo de 10 elementos en el historial
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              leading: Icon(Icons.local_shipping, color: Colors.orange),
              title: Text('Flete ${index + 1}', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4.0),
                  Text('Descripción del flete ${index + 1}'),
                  SizedBox(height: 4.0),
                  Text('Fecha: ${_generateRandomDate()}'),
                ],
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Color.fromARGB(255, 48, 48, 48)),
              onTap: () {
              },
            ),
          );
        },
      ),
    );
  }

  String _generateRandomDate() {
    // Método temporal para generar una fecha aleatoria
    final DateTime now = DateTime.now();
    final random = Random();
    final randomDay = random.nextInt(30) + 1;
    final randomHour = random.nextInt(24);
    final randomMinute = random.nextInt(60);
    final randomSecond = random.nextInt(60);
    return '${now.year}-${_formatNumber(now.month)}-${_formatNumber(randomDay)} $randomHour:${_formatNumber(randomMinute)}:${_formatNumber(randomSecond)}';
  }

  String _formatNumber(int number) {
    return number.toString().padLeft(2, '0');
  }
}
