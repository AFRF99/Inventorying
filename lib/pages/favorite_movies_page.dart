import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_movies/repository/firebase_api.dart';

class FavoriteMoviesPage extends StatefulWidget {
  const FavoriteMoviesPage({super.key});

  @override
  State<FavoriteMoviesPage> createState() => _FavoriteMoviesPageState();
}

class _FavoriteMoviesPageState extends State<FavoriteMoviesPage> {
  final FirebaseApi _firebaseApi = FirebaseApi();
  bool _isAdmin = false;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userData = await _firebaseApi.getUserData(user.uid);
      setState(() {
        _isAdmin = userData != null && userData.isActionFavorite;
      });
    }
  }

  Future<void> _updateMaterial(
      QueryDocumentSnapshot material, Map<String, dynamic> updates) async {
    try {
      await FirebaseFirestore.instance
          .collection("materials")
          .doc(material.id)
          .update(updates);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Material actualizado con éxito.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al actualizar: $e")),
      );
    }
  }

  Future<void> pickImage(TextEditingController urlPictureController) async {
    try {
      final pickedImage =
      await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage == null) return;

      final imageFile = File(pickedImage.path);
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      setState(() {
        urlPictureController.text = "data:image/jpeg;base64,$base64Image";
      });
    } catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Widget _buildEditableForm(QueryDocumentSnapshot material) {
    final nameController = TextEditingController(text: material['name']);
    final descriptionController = TextEditingController(text: material['descripcion']);
    final quantityController = TextEditingController(text: material['cantidad'].toString());
    final canalesController = TextEditingController(text: material['canales'].toString());
    final salidasVoltajeController = TextEditingController(text: material['salidasVoltaje'].toString());
    final salidasCorrienteController = TextEditingController(text: material['salidasCorriente'].toString());
    bool funcionOnda = material['funcionOnda'];
    bool contadorPulsos = material['contadorPulsos'];
    bool pantallaTactil = material['pantallaTactil'];
    final urlPictureController = TextEditingController(text: material['urlPicture']);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Nombre"),
          ),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: "Descripción"),
          ),
          TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Cantidad"),
          ),
          TextField(
            controller: canalesController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Canales"),
          ),
          TextField(
            controller: salidasVoltajeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Voltaje máximo"),
          ),
          TextField(
            controller: salidasCorrienteController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Corriente máxima"),
          ),
          SwitchListTile(
            title: const Text("Función de onda"),
            value: funcionOnda,
            onChanged: (value) {
              funcionOnda = value;
            },
          ),
          SwitchListTile(
            title: const Text("Contador de pulsos"),
            value: contadorPulsos,
            onChanged: (value) {
              contadorPulsos = value;
            },
          ),
          SwitchListTile(
            title: const Text("Pantalla táctil"),
            value: pantallaTactil,
            onChanged: (value) {
              pantallaTactil = value;
            },
          ),
          const SizedBox(height: 16.0),
          urlPictureController.text.isNotEmpty
              ? Image.memory(
            base64Decode(urlPictureController.text.split(',').last),
            height: 200,
          )
              : Image.asset('assets/images/logo.webp', height: 200),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () => pickImage(urlPictureController),
            child: const Text("Seleccionar Imagen"),
          ),
          ElevatedButton(
            onPressed: () {
              final updates = {
                "name": nameController.text.trim(),
                "descripcion": descriptionController.text.trim(),
                "cantidad": int.tryParse(quantityController.text.trim()) ?? 0,
                "canales": int.tryParse(canalesController.text.trim()) ?? 0,
                "salidasVoltaje":
                int.tryParse(salidasVoltajeController.text.trim()) ?? 0,
                "salidasCorriente":
                int.tryParse(salidasCorrienteController.text.trim()) ?? 0,
                "funcionOnda": funcionOnda,
                "contadorPulsos": contadorPulsos,
                "pantallaTactil": pantallaTactil,
                "urlPicture": urlPictureController.text.trim(),
              };

              _updateMaterial(material, updates);
              Navigator.pop(context);
            },
            child: const Text("Guardar cambios"),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(QueryDocumentSnapshot material) {
    return Card(
      child: ListTile(
        title: Text(material['name']),
        subtitle: Text(material['descripcion']),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            if (_isAdmin) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Editar ${material['name']}"),
                  content: _buildEditableForm(material),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cerrar"),
                    ),
                  ],
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      "Solo los administradores pueden editar los materiales."),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Materiales"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("materials").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var filteredDocs = snapshot.data!.docs.where((doc) {
            var name = doc['name'].toString().toLowerCase();
            return name.contains(_searchQuery);
          }).toList();
          return ListView(
            children: filteredDocs.map((doc) {
              return _buildMaterialCard(doc);
            }).toList(),
          );
        },
      ),
    );
  }
}
