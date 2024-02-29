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
          FirebaseDatabase.instance.reference().child('PaymentMethods').child(userId);

      try {
      DataSnapshot dataSnapshot = await databaseReference.once().then((event) => event.snapshot);
        if (dataSnapshot.value != null) {
          setState(() {
            if (dataSnapshot.value is Map) {
              Map<dynamic, dynamic> paymentMethodsData =
                  dataSnapshot.value as Map<dynamic, dynamic>;

              _paymentMethods =
                  paymentMethodsData.values.toList(); // Convertir a lista
            }
          });
        }
      } catch (error) {
        print("Error al obtener los métodos de pago: $error");
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
                  final cardNumber = _paymentMethods[index]['cardNumber'] as String?;
                  final expiryDate = _paymentMethods[index]['expiryDate'] as String?;

                  return ListTile(
                    title: Text('Número de Tarjeta: ${cardNumber ?? 'N/A'}'),
                    subtitle: Text('Fecha de Caducidad: ${expiryDate ?? 'N/A'}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        confirmDeletePaymentMethod(index);
                      },
                    ),
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

  void confirmDeletePaymentMethod(int index) {
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
                deletePaymentMethod(index);
                Navigator.of(context).pop();
              },
              child: Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  void deletePaymentMethod(int index) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      DatabaseReference databaseReference =
          FirebaseDatabase.instance.reference().child('PaymentMethods').child(userId);

      try {
      DataSnapshot dataSnapshot = await databaseReference.once().then((event) => event.snapshot);
        if (dataSnapshot.value != null && dataSnapshot.value is Map) {
          Map<dynamic, dynamic> paymentMethodsData =
              dataSnapshot.value as Map<dynamic, dynamic>;

          // Obtener la clave del método de pago basado en el índice
          String? paymentKey = paymentMethodsData.keys.toList()[index];
          if (paymentKey != null) {
            // Eliminar el método de pago de la base de datos
            await databaseReference.child(paymentKey).remove();
            // Actualizar la lista de métodos de pago
            _getPaymentMethodsFromFirebase();
          }
        }
      } catch (error) {
        print("Error al eliminar el método de pago: $error");
      }
    }
  }
}
