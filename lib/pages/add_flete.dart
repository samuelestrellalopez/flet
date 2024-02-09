 import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:users_app/global/global_variables.dart';
import 'package:users_app/pages/home_page.dart';
import 'package:users_app/widgets/loading_dialog.dart';

class AddFlete extends StatefulWidget {
  @override
  _AddFleteState createState() => _AddFleteState();
}

DateTime? selectedDate;
TimeOfDay? selectedTime;
final TextEditingController dateController = TextEditingController();
final TextEditingController timeController = TextEditingController();
final TextEditingController descriptionController = TextEditingController();
final TextEditingController vehicleTypeController = TextEditingController();
final TextEditingController offerRateController = TextEditingController();
late String userId; // Aquí almacenarás el ID del usuario que solicita el flete
String? selectedVehicleType;
List<String> vehicleTypes = [
  'Pickup/Van',
  'Camión mediano',
  'Camión grande',
  'Camión pequeño'
];

class _AddFleteState extends State<AddFlete> {
  final TextEditingController startSearchtextEditingController =
      TextEditingController();
  final TextEditingController endSearchtextEditingController =
      TextEditingController();
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  Timer? _debounce;
  DetailsResult? startPosition;
  DetailsResult? endPosition;

  late FocusNode startFocusNode;
  late FocusNode endFocusNode;

  autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null &&
        result.predictions != null &&
        result.predictions!.isNotEmpty && // Verificar si la lista no está vacía
        mounted) {
      print(result.predictions!.first.description);
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

 Future<void> registerNewFlete() async {
    if (dateController.text.isEmpty ||
        timeController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        selectedVehicleType == null ||
        offerRateController.text.isEmpty ||
        startSearchtextEditingController.text.isEmpty ||
        endSearchtextEditingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos'),
        ),
      );
      return;
    } else{
       showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) =>
        LoadingDialog(messageText: "Registrando tu flete..."));
    }

    

  // Obtén el ID del usuario actual
  String userId = FirebaseAuth.instance.currentUser!.uid;

  // Obtén las direcciones de recogida y destino
  String? startAddress = startPosition?.formattedAddress;
  String? endAddress = endPosition?.formattedAddress;

  // Agrega los datos del flete a la base de datos de Firebase
  DatabaseReference fletesRef =
      FirebaseDatabase.instance.ref().child("Fletes").push();
  Map fleteDataMap = {
    "userId": userId, 
    "date": dateController.text,
    "time": timeController.text,
    "description": descriptionController.text,
    "vehicleType": selectedVehicleType ?? "", // Usar el tipo de vehículo seleccionado
    "offerRate": offerRateController.text,
    "startAddress": startAddress ?? "", // Agregar dirección de recogida
    "endAddress": endAddress ?? "", // Agregar dirección de destino
    // Agrega otros campos si es necesario
  };
  await fletesRef.set(fleteDataMap);

  dateController.clear();
  timeController.clear();
  descriptionController.clear();
  vehicleTypeController.clear();
  offerRateController.clear();
  startSearchtextEditingController.clear();
  endSearchtextEditingController.clear();

  // Limpia las variables de fecha y hora seleccionadas
  setState(() {
    selectedDate = null;
    selectedTime = null;
  });
  Navigator.pop(context);

  // Puedes mostrar un mensaje o realizar alguna acción después de registrar el flete
  // Por ejemplo, navegar a otra pantalla
  Navigator.push(context, MaterialPageRoute(builder: (c) => const HomePage()));
}

  Future<void> _selectDate(BuildContext context) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(DateTime.now().year + 1),
  );
  if (pickedDate != null) {
    setState(() {
      selectedDate = pickedDate;
      dateController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
    });
  }
}

Future<void> _selectTime(BuildContext context) async {
  final TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );
  if (pickedTime != null) {
    setState(() {
      selectedTime = pickedTime;
      timeController.text = pickedTime.format(context);
    });
  }
}


  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace(googleMapKey);
    startFocusNode = FocusNode();
    endFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    startFocusNode.dispose();
    endFocusNode.dispose();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      leading: const BackButton(color: Colors.white),
      title: const Text("FleT"),
      titleTextStyle: const TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Colors.orangeAccent,
      ),
    ),
    body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
           Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(0.0),
        border: Border(
          bottom: BorderSide(color: const Color.fromARGB(255, 130, 122, 110), width: startFocusNode.hasFocus ? 2.0 : 0.0),
        ),
      ),
      child: TextField(
      controller: startSearchtextEditingController,
             autofocus: false,
             showCursor: true,
             focusNode: startFocusNode,
        style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w300),        
        decoration: InputDecoration(
          hintText: "Dirección de recogida",
          filled: true,
          fillColor: Colors.transparent,
          suffixIcon: startSearchtextEditingController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      startSearchtextEditingController.clear();
                    });
                  },
                  icon: const Icon(Icons.clear_outlined, color: Colors.white),
                )
              : null,
        ),
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 1000), () {
                    if (value.isNotEmpty) {
                      autoCompleteSearch(value);
                    } else {
                      setState(() {
                        predictions = [];
                        endPosition = null;
                      });
                    }
                  });
                },
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            

   Container(
    decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(0.0),
        border: Border(
          bottom: BorderSide(color: const Color.fromARGB(255, 130, 122, 110), width: startFocusNode.hasFocus ? 2.0 : 0.0),
        ),
      ),
    child:TextField(
    controller: endSearchtextEditingController,
                  autofocus: false,
                  focusNode: endFocusNode,                  
                  showCursor: true,
                  enabled: startSearchtextEditingController.text.isNotEmpty && startPosition != null,
                              style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w300),        
        decoration: InputDecoration(
    hintText: "Dirección de destino",
    filled: true,
    fillColor: Colors.transparent,
    suffixIcon: endSearchtextEditingController.text.isNotEmpty
        ? IconButton(
            onPressed: () {
              setState(() {
                predictions = [];
                endSearchtextEditingController.clear();
              });
            },
            icon: const Icon(Icons.clear_outlined, color: Colors.white),
          )
        : null,
  ),
  onChanged: (value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      if (value.isNotEmpty) {
        autoCompleteSearch(value);
      } else {
        setState(() {
          predictions = [];
          endPosition = null;
        });
      }
    });
  },
),),

const SizedBox(
  height: 12,
),
ListView.builder(
  shrinkWrap: true,
  itemCount: predictions.length,
  itemBuilder: (context, index) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(
          Icons.pin_drop,
          color: Colors.orange,
        ),
      ),
      title: Text(predictions[index].description.toString()),
      onTap: () async {
        final placeId = predictions[index].placeId!;
        final details = await googlePlace.details.get(placeId);
        if (details != null &&
            details.result != null &&
            mounted) {
          if (startFocusNode.hasFocus) {
            setState(() {
              startPosition = details.result;
              startSearchtextEditingController.text =
                  details.result!.name!;
              predictions = [];
            });
          } else {
            setState(() {
              endPosition = details.result;
              endSearchtextEditingController.text =
                  details.result!.name!;
              predictions = [];
            });
          }
          if (startPosition != null && endPosition != null) {
            print("navigate");
          }
        }
      },
    );
  },
),



          
const SizedBox(height: 12),

GestureDetector(
  onTap: () => _selectDate(context),
  child: AbsorbPointer(
    child: TextFormField(
      controller: TextEditingController(
        text: selectedDate != null
            ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
            : "",
      ),
        autofocus: false,
        showCursor: false,
        style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w300),     enabled: startSearchtextEditingController.text.isNotEmpty &&
        startPosition != null,
                    decoration: InputDecoration(
                      hintText: "Fecha",
                      filled: true,
                      fillColor: Colors.transparent,
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.5),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.5),
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(4), right: Radius.circular(4)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.5),
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(4), right: Radius.circular(4)),
                      ),
      ),
    ),
  ),
),
const SizedBox(height: 12),
GestureDetector(
  onTap: () => _selectTime(context),
  child: AbsorbPointer(
    child: TextFormField(
      controller: TextEditingController(
        text: selectedTime != null
            ? "${selectedTime!.format(context)}"
            : "",
      ),
        autofocus: false,
        showCursor: false,

        style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w300),     enabled: startSearchtextEditingController.text.isNotEmpty &&
        startPosition != null,
                    decoration: InputDecoration(
                      hintText: "Hora",
                      filled: true,
                      fillColor: Colors.transparent,
                       border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.5),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.5),
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(4), right: Radius.circular(4)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.5),
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(4), right: Radius.circular(4)),
                      ),

      ),
    ),  
  ),
),

const SizedBox(height: 12),


Container(
  decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(0.0),
        border: Border(
          bottom: BorderSide(color: const Color.fromARGB(255, 130, 122, 110), width: startFocusNode.hasFocus ? 2.0 : 0.0),
        ),
      ),
  child: TextField(
    controller: descriptionController,              
        autofocus: false,
                  showCursor: true,
        style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w300),    decoration: const InputDecoration(
      hintText: "Descripción de flete",
      border: InputBorder.none,
      contentPadding: EdgeInsets.all(12),
    ),
    minLines: 1,
    maxLines: null,
  ),
),        
              const SizedBox(
                height: 12,
              ),
          
           DropdownButtonFormField<String>(
  value: selectedVehicleType,
  onChanged: (String? newValue) {
    setState(() {
      selectedVehicleType = newValue;
    });
  },
  decoration: InputDecoration(
    hintText: "Tipo de vehiculo",
    hintStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    filled: true,
    fillColor: Colors.transparent,
    
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 1.5),
      borderRadius: BorderRadius.circular(8.0),
    ),
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1.5),
        borderRadius: BorderRadius.horizontal(left: Radius.circular(4), right: Radius.circular(4)),
    ),
    focusedBorder: OutlineInputBorder(
     borderSide: BorderSide(color: Colors.grey, width: 1.5),
    borderRadius: BorderRadius.horizontal(left: Radius.circular(4), right: Radius.circular(4)),
    ),
  ),
  items: vehicleTypes.map((String type) {
    return DropdownMenuItem<String>(
      value: type,
      child: Text(type),
    );
  }).toList(),
),
const SizedBox(height: 12),

    TextField(            
    keyboardType: TextInputType.number,
  controller: offerRateController,
   autofocus: false,
                  showCursor: true,
        style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w300),    decoration: const InputDecoration(
    hintText: "Tarifa",
    filled: true,
    fillColor: Colors.transparent,
    border: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 1.5),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 1.5),
      borderRadius: BorderRadius.horizontal(left: Radius.circular(4), right: Radius.circular(4)),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 1.5),
      borderRadius: BorderRadius.horizontal(left: Radius.circular(4), right: Radius.circular(4)),
    ),
  ),
),
  const SizedBox(
                height: 20,
              ),
          
              ElevatedButton(
                onPressed: () {
                  registerNewFlete();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 88, vertical: 13),
                ),
                child: const Text(
                  "Solicitar flete",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),)
          
            ],
          ),
        ),
      ),
    );
  }
}