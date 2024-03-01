import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  bool _isExpired = false;
  bool _isCardValid = true;
  bool _isCardTyped = false;
  bool _isAddingPayment = false;

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
                decoration: InputDecoration(
                  labelText: 'Número de Tarjeta',
                  suffixIcon: _isCardTyped ? _getCardIcon() : null,
                ),
                keyboardType: TextInputType.number,
                maxLength: 16, // Limitar la longitud a 16 dígitos
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el número de tarjeta';
                  } else if (value.length != 16) {
                    return 'El número de tarjeta debe tener 16 dígitos';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _isCardTyped = true;
                  });
                  _detectCardType(value);
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryMonthController,
                      decoration: InputDecoration(
                        labelText: 'Mes de Expiración',
                        labelStyle: TextStyle(
                          color: _isExpired ? Colors.red : null,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa el mes de expiración';
                        } else {
                          final month = int.tryParse(value);
                          if (month == null || month < 1 || month > 12) {
                            return 'Mes inválido';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: TextFormField(
                      controller: _expiryYearController,
                      decoration: InputDecoration(
                        labelText: 'Año de Expiración',
                        labelStyle: TextStyle(
                          color: _isExpired ? Colors.red : null,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa el año de expiración';
                        } else {
                          final currentYear = DateTime.now().year % 100;
                          final year = int.tryParse(value);
                          if (year == null || year < currentYear) {
                            return 'Año inválido';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _cvcController,
                decoration: InputDecoration(labelText: 'CVC'),
                keyboardType: TextInputType.number,
                maxLength: 3, // Limitar la longitud a 3 dígitos
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el CVC';
                  } else if (value.length != 3) {
                    return 'El CVC debe tener 3 dígitos';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _isAddingPayment ? null : _addPaymentMethod,
                child: _isAddingPayment ? CircularProgressIndicator() : Text('Agregar Método de Pago'),
              ),
              SizedBox(height: 20.0),
              _tokenMessage.isNotEmpty
                  ? Row(
                      children: [
                        Icon(
                          _tokenMessage.startsWith('Error') ? Icons.close : Icons.check,
                          color: _tokenMessage.startsWith('Error') ? Colors.red : Colors.green,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _tokenMessage,
                            style: TextStyle(color: _tokenMessage.startsWith('Error') ? Colors.red : Colors.green),
                          ),
                        ),
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getCardIcon() {
    if (_cardNumberController.text.startsWith('4')) {
      return Icon(FontAwesomeIcons.ccVisa);
    } else if (_cardNumberController.text.startsWith('5')) {
      return Icon(FontAwesomeIcons.ccMastercard);
    } else {
      return Icon(Icons.credit_card); // Icono genérico de tarjeta
    }
  }

  void _detectCardType(String value) {
    setState(() {
      _isCardValid = true;
    });
  }

  void _addPaymentMethod() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isAddingPayment = true;
      });

      final cardNumber = _cardNumberController.text;
      final expiryMonth = _expiryMonthController.text;
      final expiryYear = _expiryYearController.text;
      final cvc = _cvcController.text;

      try {
        await Future.delayed(Duration(seconds: 2)); // Simulación de proceso de espera de 2 segundos

        final response1 = await http.post(
          Uri.parse('https://webapi-fletmin2.onrender.com/api/generate_tokent'),
          body: jsonEncode({
            'cardNumber': cardNumber,
            'cardExpiry': {'month': expiryMonth, 'year': expiryYear},
            'cardCvc': cvc,
          }),
          headers: {'Content-Type': 'application/json'},
        );

        if (response1.statusCode == 200) {
          final tokenResponse = jsonDecode(response1.body);
          final token = tokenResponse['token'];

          final userEmail = _getUserEmail();

          final response2 = await http.post(
            Uri.parse('https://webapi-fletmin2.onrender.com/api/generate_token2'),
            body: jsonEncode({
              'token': token,
              'userEmail': userEmail,
            }),
            headers: {'Content-Type': 'application/json'},
          );

          if (response2.statusCode == 200) {
            setState(() {
              _tokenMessage = 'Método de pago agregado correctamente.';
            });
          } else {
            setState(() {
              _tokenMessage = 'Error al enviar el token: ${response2.body}';
            });
          }
        } else {
          setState(() {
            _tokenMessage = 'Error al generar el token: ${response1.body}';
          });
        }
      } catch (e) {
        setState(() {
          _tokenMessage = 'Error: $e';
        });
      } finally {
        setState(() {
          _isAddingPayment = false;
        });
      }
    }
  }

  String _getUserEmail() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.email ?? '';
    } else {
      throw Exception('Usuario no ha iniciado sesión');
    }
  }
}
