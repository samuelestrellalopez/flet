// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class ApiService {
//   static const String baseUrl = "https://webapi-fletmin2.onrender.com";

//   Future<String> registerUser(
//     String email,
//     String password,
//     String photo,
//     String number,
//     String name,
//     String surname,
//   ) async {
//     final Uri registerUrl = Uri.parse('$baseUrl/api/users');

//     try {
//       final response = await http.post(
//         registerUrl,
//         body: {
//           'email': email,
//           'password': password,
//           'photo': photo,
//           'number': number,
//           'name': name,
//           'surname': surname,
//         },
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         if (data.containsKey('userId')) {
//           return data['userId'];
//         } else {
//           throw Exception('Error: Respuesta de la API no contiene userId');
//         }
//       } else {
//         throw Exception('Error en la solicitud HTTP: ${response.statusCode}');
//       }
//     } on http.ClientException catch (e) {
//       throw Exception('Error de cliente: $e');
//     } on FormatException catch (e) {
//       throw Exception('Error de formato JSON: $e');
//     } catch (error) {
//       throw Exception('Error desconocido: $error');
//     }
//   }
// }
