import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class AddNewPaymentScreen extends StatefulWidget {
  const AddNewPaymentScreen({Key? key}) : super(key: key);

  @override
  State<AddNewPaymentScreen> createState() => _AddNewPaymentScreenState();
}

class _AddNewPaymentScreenState extends State<AddNewPaymentScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _cardNumberController = TextEditingController();
  TextEditingController _expiryMonthController = TextEditingController();
  TextEditingController _expiryYearController = TextEditingController();
  TextEditingController _cvcController = TextEditingController();

  String _tokenMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar Método de Pago"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _cardNumberController,
                decoration: InputDecoration(labelText: 'Número de Tarjeta'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el número de tarjeta';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryMonthController,
                      decoration: InputDecoration(labelText: 'Mes de Expiración'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa el mes de expiración';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: TextFormField(
                      controller: _expiryYearController,
                      decoration: InputDecoration(labelText: 'Año de Expiración'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa el año de expiración';
                        return null;
                        }
                      },
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _cvcController,
                decoration: InputDecoration(labelText: 'CVC'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el CVC';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _addPaymentMethod,
                child: Text('Agregar Método de Pago'),
              ),
              SizedBox(height: 20.0),
              Text(_tokenMessage),
            ],
          ),
        ),
      ),
    );
  }
  
  void _addPaymentMethod() async {
    if (_formKey.currentState!.validate()) {
      final cardNumber = _cardNumberController.text;
      final expiryMonth = _expiryMonthController.text;
      final expiryYear = _expiryYearController.text;
      final cvc = _cvcController.text;

      try {
        Stripe.publishableKey = 'pk_test_51Oc9WPHDirRzPkGPs7RVgxaLXz7ZEpmeULsvZQsk5xDhtFPST7ke5TDCH03H444ijUW5xFcIt5R6YUSLEctCxlzG00ASdfAHZx'; // Reemplaza con tu clave pública de Stripe

        final token = await Stripe.instance.createTokenForCVCUpdate(cvc);
        final userEmail = _getUserEmail();

        setState(() {
          _tokenMessage = 'Token: ${token ?? 'No se pudo generar el token'} creado correctamente.';
        });

        await _sendTokenToApi(token ?? '', userEmail);
      } catch (e) {
        setState(() {
          _tokenMessage = 'Error al crear el token: $e';
        });
      }
    }
  }

  String _getUserEmail() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.email ?? '';
    } else {
      throw Exception('User not logged in');
    }
  }

  Future<void> _sendTokenToApi(String token, String userEmail) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.70:4000/api/generate_token2'),
      body: jsonEncode({
        'token': token,
        'userEmail': userEmail,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Token enviado correctamente
    } else {
      throw Exception("Error al enviar el token al servidor.");
    }
  }
}
