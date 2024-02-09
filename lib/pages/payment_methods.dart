import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:users_app/pages/add_payment.dart';

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
    _getPaymentMethodsFromFirebase();
  }

  Future<void> _getPaymentMethodsFromFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;

      DatabaseReference databaseReference =
          FirebaseDatabase.instance.ref().child('users').child(userId);

      DatabaseEvent event = await databaseReference.once();
      DataSnapshot dataSnapshot = event.snapshot;

      if (dataSnapshot.value != null) {
        setState(() {
          if (dataSnapshot.value is Map) {
            Map<dynamic, dynamic> userData =
                dataSnapshot.value as Map<dynamic, dynamic>;

            if (userData['paymentmethods'] != null) {
              _paymentMethods =
                  userData['paymentmethods'] as List<dynamic>;
            }
          }
        });
      }
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
                  // Aquí puedes personalizar la visualización de cada método de pago
                  return ListTile(
                    title: Text('Número de Tarjeta: ${_paymentMethods[index]['cardNumber']}'),
                    subtitle: Text('Fecha de Caducidad: ${_paymentMethods[index]['expiryDate']}'),
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
              },
              child: Text('Añadir Nuevo Método de Pago'),
            ),
          ],
        ),
      ),
    );
  }
}
