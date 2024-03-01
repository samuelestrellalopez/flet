import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:users_app/pages/add_payment.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({Key? key}) : super(key: key);

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  late List<dynamic> _paymentMethods = [];

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      String userEmail = _getUserEmail();
      String apiUrl = 'https://webapi-fletmin2.onrender.com/api/payment-methods/$userEmail';
      final response = await http.get(Uri.parse(apiUrl));
      
      if (response.statusCode == 200) {
        setState(() {
          _paymentMethods = json.decode(response.body);
        });
      } else {
        throw Exception('Error al cargar los métodos de pago: ${response.statusCode}');
      }
    } catch (error) {
      print('Error al obtener los métodos de pago: $error');
      throw Exception('Error al cargar los métodos de pago');
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

  IconData _getIcon(String brand) {
    if (brand == 'visa') {
      return FontAwesomeIcons.ccVisa;
    } else if (brand == 'mastercard') {
      return FontAwesomeIcons.ccMastercard;
    } else {
      return Icons.credit_card;
    }
  }

  Future<void> _deletePaymentMethod(String paymentMethodId) async {
    try {
      String apiUrl = 'https://webapi-fletmin2.onrender.com/api/payment-methods/$paymentMethodId';
      final response = await http.delete(Uri.parse(apiUrl));
      
      if (response.statusCode == 200) {
        // Reload payment methods after successful deletion
        _loadPaymentMethods();
        // Show snackbar indicating payment method deleted
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Método de pago eliminado'),
        ));
        // Automatically navigate back to PaymentMethodsPage after deletion
        Navigator.pop(context);
      } else {
        throw Exception('Error al eliminar el método de pago: ${response.statusCode}');
      }
    } catch (error) {
      print('Error al eliminar el método de pago: $error');
      throw Exception('Error al eliminar el método de pago');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Métodos de Pago'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tus Métodos de Pago:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _paymentMethods.length,
                itemBuilder: (context, index) {
                  final card = _paymentMethods[index];
                  final brand = card['brand'];
                  final last4 = card['last4'];
                  final expMonth = card['expMonth'];
                  final expYear = card['expYear'];
                  final id = card['id'];

                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentDetailsPage(
                            cardName: brand == 'visa' ? 'Visa' : 'MasterCard',
                            cardNumber: '**** **** **** $last4',
                            expiryDate: '$expMonth/$expYear',
                            paymentMethodId: id,
                            onDeletePaymentMethod: _deletePaymentMethod, // Pasar la función de eliminación
                            cardBrand: brand, // Pasar la marca de la tarjeta
                          ),
                        ),
                      );
                    },
                    leading: Icon(_getIcon(brand)),
                    title: Text('**** $last4'),
                    subtitle: Text('Marca: ${brand.toUpperCase()}'),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddNewPaymentScreen()),
                );
                Icon(
      Icons.add,
      color: Colors.green,
      size: 30.0,
    );
              },
              child: Text('Añadir Nuevo Método de Pago'),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentDetailsPage extends StatelessWidget {
  final String cardName;
  final String cardNumber;
  final String expiryDate;
  final String paymentMethodId;
  final Function(String) onDeletePaymentMethod; // Función de eliminación
  final String cardBrand; // Marca de la tarjeta

  const PaymentDetailsPage({
    required this.cardName,
    required this.cardNumber,
    required this.expiryDate,
    required this.paymentMethodId,
    required this.onDeletePaymentMethod, // Añadir argumento de la función de eliminación
    required this.cardBrand, // Añadir la marca de la tarjeta
  });

  IconData _getIcon(String brand) {
    if (brand == 'visa') {
      return FontAwesomeIcons.ccVisa;
    } else if (brand == 'mastercard') {
      return FontAwesomeIcons.ccMastercard;
    } else {
      return Icons.credit_card;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Método de Pago'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alinear elementos al principio y al final
              children: [
                Text(
                  cardName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Icon(_getIcon(cardBrand), size: 40), // Mostrar el icono de la tarjeta
              ],
            ),
            SizedBox(height: 20),
            Text(
              cardNumber,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Fecha de Vencimiento',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              expiryDate,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start, // Alinear a la izquierda
              children: [
                IconButton(
                  icon: Icon(Icons.cancel_rounded, color: Colors.red), // Cambiar el icono y el color
                  onPressed: () {
                    _confirmDeletePaymentMethod(context);
                  },
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    _confirmDeletePaymentMethod(context);
                  },
                  child: Text(
                    'Eliminar método de pago', // Cambiar el texto
                    style: TextStyle(color: Colors.red), // Cambiar el color
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletePaymentMethod(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar Eliminación"),
          content: Text("¿Deseas confirmar la eliminación de este método de pago?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDeletePaymentMethod(paymentMethodId); // Llamar a la función de eliminación
              },
              child: Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }
}
