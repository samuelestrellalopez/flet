import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:users_app/authentication/login_screen.dart';
import 'package:users_app/methods/common_methods.dart';
import 'package:users_app/widgets/loading_dialog.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController nametextEditingController = TextEditingController();
  TextEditingController surnametextEditingController = TextEditingController();
  TextEditingController emailtextEditingController = TextEditingController();
  TextEditingController passwordtextEditingController = TextEditingController();
  TextEditingController confirmpasswordtextEditingController =
      TextEditingController();
  TextEditingController numbertextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();
  XFile? imageFile;

  checkIfNetworkIsAvailable() {
    cMethods.checkConnectivity(context);
    if (imageFile != null) {
      SignUpFormValidation();
    } else {
      cMethods.displaySnackBar("Por favor elige una foto de perfil", context);
    }
  }

  SignUpFormValidation() {
    if (!emailtextEditingController.text.trim().contains("@") &&
        !emailtextEditingController.text.trim().endsWith(".com")) {
      cMethods.displaySnackBar("Ingresa un correo electronico valido", context);
    } else if (passwordtextEditingController.text.trim().length < 8) {
      cMethods.displaySnackBar(
          "Tu contraseña debe de contener al menos 8 caracteres", context);
    } else if (confirmpasswordtextEditingController.text !=
        passwordtextEditingController.text) {
      cMethods.displaySnackBar(
          "Asegurate de que tu contraseña coincida con la contraseña proporcionada",
          context);
    } else if (numbertextEditingController.text.trim().length < 8) {
      cMethods.displaySnackBar("Ingresa un número de telefono válido", context);
    } else {
      uploadImageToStorage();
    }
  }

  chooseImageFromGalery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
      });
    }
  }

  uploadImageToStorage() async {
    String imageIDName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceImage =
        FirebaseStorage.instance.ref().child("Images").child(imageIDName);

    UploadTask uploadTask = referenceImage.putFile(File(imageFile!.path));
    TaskSnapshot snapshot = await uploadTask;
    String urlOfUploadedImage = await snapshot.ref.getDownloadURL();

    registerNewUser(urlOfUploadedImage);
  }

  registerNewUser(String urlOfUploadedImage) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Registrando tu cuenta..."),
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailtextEditingController.text.trim(),
            password: passwordtextEditingController.text.trim(),
          );

      // Registro exitoso
      if (userCredential != null && userCredential.user != null) {
        DatabaseReference usersRef = FirebaseDatabase.instance
            .ref()
            .child("Users")
            .child(userCredential.user!.uid);

        Map userDataMap = {
          "photo": urlOfUploadedImage,
          "email": emailtextEditingController.text.trim(),
          "number": numbertextEditingController.text.trim(),
          "id": userCredential.user!.uid,
          "name": nametextEditingController.text.trim(),
          "surname": surnametextEditingController.text.trim(),
          "blockStatus": "no",
        };

        await usersRef.set(userDataMap);

        Navigator.pop(context); // Cerrar diálogo de carga
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const LoginScreen()));
      }
    } catch (error) {
      Navigator.pop(context); // Cerrar diálogo de carga
      if (error is FirebaseAuthException) {
        cMethods.displaySnackBar(error.message ?? 'Error desconocido', context);
      } else {
        cMethods.displaySnackBar('Error desconocido', context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),

              imageFile == null
                  ? const CircleAvatar(
                      radius: 86,
                      backgroundImage:
                          AssetImage("assets/images/avatarman.png"),
                    )
                  : Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                        image: DecorationImage(
                          fit: BoxFit.fitHeight,
                          image: FileImage(
                            File(
                              imageFile!.path,
                            ),
                          ),
                        ),
                      ),
                    ),

              GestureDetector(
                onTap: () {
                  chooseImageFromGalery();
                },
                child: const Text(
                  "Selecciona una imagen",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Text(
                "Crea tu cuenta!",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const Text(
                "Llena los campos de abajo",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),

              //Text fields and Button
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    TextField(
                      controller: emailtextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Correo electrónico",
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        hintText: "usuario@correo.com",
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 255, 194, 103),
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    TextField(
                      controller: numbertextEditingController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Número de telefono",
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        hintText: "12345678",
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 255, 194, 103),
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    TextField(
                      controller: nametextEditingController,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        labelText: "Nombre/s",
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        hintText: "",
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 255, 194, 103),
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    TextField(
                      controller: surnametextEditingController,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        labelText: "Apellido/s",
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        hintText: "",
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 255, 194, 103),
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    TextField(
                      controller: passwordtextEditingController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Contraseña",
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    TextField(
                      controller: confirmpasswordtextEditingController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Repite tu contraseña",
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        checkIfNetworkIsAvailable();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 88, vertical: 13),
                      ),
                      child: const Text(
                        "Registrarse",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: '¿Ya tienes una cuenta? ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Inicia sesión',
                              style: TextStyle(
                                color: Colors.orangeAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
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
