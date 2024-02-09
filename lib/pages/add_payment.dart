import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:users_app/widgets/loading_dialog.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';

class AddNewPaymentScreen extends StatefulWidget {
  const AddNewPaymentScreen({Key? key}) : super(key: key);

  @override
  State<AddNewPaymentScreen> createState() => _AddNewPaymentScreenState();
}

class _AddNewPaymentScreenState extends State<AddNewPaymentScreen> {
  String cardNumber = "";
  String expiryDate = "";
  String cardHolderName = "";
  String cvvCode = "";

  final DatabaseReference usersReference =
      FirebaseDatabase.instance.reference().child('users');

  final Uuid uuid = Uuid();

  Future<void> addPaymentMethod() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;

      if (!validateCardNumber(cardNumber) ||
          !validateExpiryDate(expiryDate) ||
          !validateCardHolderName(cardHolderName)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Por favor, ingrese información de pago válida."),
          ),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            LoadingDialog(messageText: "Añadiendo método de pago..."),
      );

      String paymentMethodId = uuid.v4();

      Map<String, dynamic> paymentMethod = {
        'id': paymentMethodId,
        'cardNumber': cardNumber.replaceAll(' ', ''),
        'expiryDate': expiryDate,
        'cardHolderName': cardHolderName,
        'cvvCode': cvvCode,
      };

      // Actualizar el mapa 'paymentmethods' en el documento del usuario
      await usersReference.child(userId).update({
        'paymentmethod': paymentMethod,
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Método de pago añadido con éxito."),
        ),
      );

      print('Payment method added with ID: $paymentMethodId to user ID: $userId');
    } else {
      print('No user is currently logged in.');
    }
  }

  bool validateCardNumber(String cardNumber) {
    return RegExp(r'^[0-9]{16}$').hasMatch(cardNumber);
  }

  bool validateExpiryDate(String expiryDate) {
    return RegExp(r'^[0-9]{2}[0-9]{2}$').hasMatch(expiryDate);
  }

  bool validateCardHolderName(String cardHolderName) {
    return !RegExp(r'[0-9]').hasMatch(cardHolderName);
  }

  String formatCardNumber(String input) {
    input = input.replaceAll(' ', '');
    if (input.length > 4) {
      input = input.substring(0, 4) + ' ' + input.substring(4);
    }
    if (input.length > 9) {
      input = input.substring(0, 9) + ' ' + input.substring(9);
    }
    if (input.length > 14) {
      input = input.substring(0, 14) + ' ' + input.substring(14);
    }
    return input;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Añadir método de pago"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Número de tarjeta',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    cardNumber = formatCardNumber(value);
                  });
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Fecha de caducidad',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    expiryDate = value;
                  });
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nombre del titular',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    cardHolderName = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'CVV',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    cvvCode = value;
                  });
                },
                onFieldSubmitted: (value) {
                  setState(() {
                    // Handle focus change here if needed
                  });
                },
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  addPaymentMethod();
                },
                child: Text('Añadir método de pago'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
