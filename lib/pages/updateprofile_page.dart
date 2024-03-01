import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:users_app/authentication/login_screen.dart';
import 'package:users_app/methods/common_methods.dart';
import 'package:users_app/widgets/loading_dialog.dart';
import 'package:users_app/pages/profile_page.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController nametextEditingController = TextEditingController();
  TextEditingController surnametextEditingController = TextEditingController();
  TextEditingController emailtextEditingController = TextEditingController();
  TextEditingController passwordtextEditingController = TextEditingController();
  TextEditingController numbertextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();
  XFile? imageFile;
  String? urlOfUploadedImage;

  // Método para cargar la imagen desde Firebase Storage
  Future<String?> _loadImage(String? imageUrl) async {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final ref = FirebaseStorage.instance.ref().child("users").child(imageUrl);
        final url = await ref.getDownloadURL();
        return url;
      } catch (e) {
        print("Error al cargar la imagen: $e");
        return null; // Puedes manejar este caso según sea necesario
      }
    }
    return null;
  }

  getUserInfoAndCheckBlockStatus() async {
    // Lógica para obtener datos del usuario y autocompletar campos
    DatabaseReference usersRef = FirebaseDatabase.instance
        .reference()
        .child("Users")
        .child(FirebaseAuth.instance.currentUser!.uid);

    await usersRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        setState(() {
          emailtextEditingController.text = (snap.snapshot.value as Map)["email"] ?? "";
          nametextEditingController.text = (snap.snapshot.value as Map)["name"] ?? "";
          surnametextEditingController.text = (snap.snapshot.value as Map)["surnames"] ?? "";
          numbertextEditingController.text = (snap.snapshot.value as Map)["number"] ?? "";
          urlOfUploadedImage = (snap.snapshot.value as Map)["photo"] ?? "";
        });
      } else {
        FirebaseAuth.instance.signOut();
        Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getUserInfoAndCheckBlockStatus();
  }

  chooseImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
      });
    }
  }

  updateProfile() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Guardando cambios..."),
    );

    try {
      // Verificar si se ha cargado una nueva imagen
      if (imageFile != null) {
        await uploadImageToStorage();
      }

      User? currentUser = FirebaseAuth.instance.currentUser;

      // Actualizar información del usuario en Firebase Authentication
      await currentUser!.updateEmail(emailtextEditingController.text.trim());

      // Actualizar información del usuario en la base de datos de Firebase
      DatabaseReference usersRef = FirebaseDatabase.instance
          .reference()
          .child("Users")
          .child(currentUser.uid);

      Map<String, dynamic> updatedUserData = {
        "name": nametextEditingController.text.trim(),
        "surnames": surnametextEditingController.text.trim(),
        "number": numbertextEditingController.text.trim(),
        "photo": urlOfUploadedImage ?? "", // Usa la nueva URL o la existente
      };

      await usersRef.update(updatedUserData);

      Navigator.pop(context); // Cerrar diálogo de carga
      cMethods.displaySnackBar("Cambios guardados exitosamente", context);

      // Redirigir a la página de perfil después de guardar los cambios
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfilePage()));
    } catch (error) {
      Navigator.pop(context); // Cerrar diálogo de carga
      if (error is FirebaseAuthException) {
        cMethods.displaySnackBar(error.message ?? 'Error desconocido', context);
      } else {
        cMethods.displaySnackBar('Error desconocido', context);
      }
    }
  }

  uploadImageToStorage() async {
    String imageIDName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceImage =
        FirebaseStorage.instance.ref().child("users").child(imageIDName);

    UploadTask uploadTask = referenceImage.putFile(File(imageFile!.path));
    TaskSnapshot snapshot = await uploadTask;
    urlOfUploadedImage = await snapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Perfil"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20), // Aumenté el espaciado a 20
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),

FutureBuilder<String?>(
  future: _loadImage(urlOfUploadedImage),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      return GestureDetector(
        onTap: () {
          chooseImageFromGallery();
        },
        child: CircleAvatar(
          radius: 86,
          backgroundImage: imageFile != null
              ? FileImage(File(imageFile!.path)) // Usar la nueva imagen si está seleccionada
              : (snapshot.data != null
                  ? NetworkImage(snapshot.data!) // Usar la imagen cargada desde Firebase si está disponible
                  : AssetImage("assets/images/avatar_placeholder.png") as ImageProvider<Object>), // Usar la imagen de marcador de posición por defecto
        ),
      );
    } else {
      // Si no se ha cargado la imagen nueva, muestra la imagen actual
      return GestureDetector(
        onTap: () {
          chooseImageFromGallery();
        },
        child: CircleAvatar(
          radius: 86,
          backgroundImage: urlOfUploadedImage != null
              ? NetworkImage(urlOfUploadedImage!) // Usar la imagen actual desde Firebase si está disponible
              : AssetImage("assets/images/avatar_placeholder.png") as ImageProvider<Object>, // Usar la imagen de marcador de posición por defecto
        ),
      );
    }
  },
),

              const SizedBox(
                height: 10,
              ),

              const Text(
                "Presiona para cambiar la imagen",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              // Campos de edición directa en la página
              const SizedBox(height: 20), // Espaciado de 20
              TextField(
                controller: nametextEditingController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 20), // Espaciado de 20
              TextField(
                controller: surnametextEditingController,
                decoration: const InputDecoration(labelText: 'Apellidos'),
              ),
              const SizedBox(height: 20), // Espaciado de 20
              TextField(
                controller: numbertextEditingController,
                decoration: const InputDecoration(labelText: 'Número de Teléfono'),
              ),

              // Botón para confirmar los cambios
              SizedBox(height: 20), // Espacio separado de arriba

              ElevatedButton(
                onPressed: () {
                  updateProfile();                      

                },                  
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 88, vertical: 13),
                ),
                child: const Text(

                  "Confirmar Cambios",
                  style: TextStyle(
                    color: Colors.white,                  


                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
