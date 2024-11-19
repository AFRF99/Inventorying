import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_movies/models/tool.dart';

import '../repository/firebase_api.dart';

class NewItemPage extends StatefulWidget {
  const NewItemPage({super.key});

  @override
  State<NewItemPage> createState() => _NewItemPageState();
}

class _NewItemPageState extends State<NewItemPage> {
  final FirebaseApi _firebaseApi = FirebaseApi();

  final _name = TextEditingController();
  final _descripcion = TextEditingController();
  final _cantidad = TextEditingController();
  final _canales = TextEditingController();
  final _salidasVoltaje = TextEditingController();
  final _salidasCorriente = TextEditingController();

  bool _funcionOnda = false;
  bool _contadorPulsos = false;
  bool _pantallaTactil = false;

  File? _image;
  String? _imageBase64;

  Future<void> _saveItemButtonClicked() async {
    var tool = Tool(
      "",
      _name.text,
      _descripcion.text,
      int.parse(_cantidad.text),
      int.parse(_canales.text),
      int.parse(_salidasVoltaje.text),
      int.parse(_salidasCorriente.text),
      _funcionOnda,
      _contadorPulsos,
      _pantallaTactil,
      _imageBase64 ?? '',
    );

    var result = await _firebaseApi.createMaterial(tool);

    if (result == 'network-request-failed') {
      showMessage('Revise su conexión a internet');
    } else {
      showMessage('Ítem creado exitosamente');
      Navigator.pop(context);
    }
  }

  void showMessage(String msg) {
    SnackBar snackBar = SnackBar(
      content: Text(msg),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Función para seleccionar una imagen
  Future pickImage() async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage == null) return;

      final imageTemp = File(pickedImage.path);
      final bytes = await imageTemp.readAsBytes();
      setState(() {
        _image = imageTemp;
        _imageBase64 = base64Encode(bytes);
      });
    } catch (e) {
      print('Failed to pick image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Ítem'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 170,
                child: Stack(
                  children: [
                    _image != null
                        ? Image.file(_image!, width: 150, height: 150)
                        : const Image(
                      image: AssetImage('assets/images/logo.webp'),
                      width: 150,
                      height: 150,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        onPressed: pickImage,
                        icon: const Icon(Icons.camera_alt),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nombre del Ítem'),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: _descripcion,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: _cantidad,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cantidad'),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: _canales,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Canales'),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: _salidasVoltaje,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Salidas de Voltaje'),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: _salidasCorriente,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Salidas de Corriente'),
              ),
              const SizedBox(height: 16.0),
              SwitchListTile(
                title: const Text('Función Onda'),
                value: _funcionOnda,
                onChanged: (bool value) {
                  setState(() {
                    _funcionOnda = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Contador de Pulsos'),
                value: _contadorPulsos,
                onChanged: (bool value) {
                  setState(() {
                    _contadorPulsos = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Pantalla Táctil'),
                value: _pantallaTactil,
                onChanged: (bool value) {
                  setState(() {
                    _pantallaTactil = value;
                  });
                },
              ),
              ElevatedButton(
                onPressed: _saveItemButtonClicked,
                child: const Text('Guardar Ítem'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
