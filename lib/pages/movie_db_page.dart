import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MovieDbPage extends StatefulWidget {
  const MovieDbPage({super.key});

  @override
  State<MovieDbPage> createState() => _MovieDbPageState();
}

class _MovieDbPageState extends State<MovieDbPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _userId => _auth.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _syncBorrowedMaterials(); // Sincronizar pedidos con la base de datos principal
  }

  Future<void> _syncBorrowedMaterials() async {
    final borrowedCollection = _firestore
        .collection("users")
        .doc(_userId)
        .collection("user_borrowed");

    borrowedCollection.snapshots().listen((borrowedSnapshot) async {
      final materialIds = borrowedSnapshot.docs.map((doc) => doc.id).toList();

      for (String materialId in materialIds) {
        final materialDoc = await _firestore.collection("materials").doc(materialId).get();

        // Si el material ya no existe, eliminarlo de la subcolección
        if (!materialDoc.exists) {
          borrowedCollection.doc(materialId).delete();
        }
      }
    });
  }

  Future<void> _borrowMaterial(QueryDocumentSnapshot material) async {
    final materialId = material.id;
    final name = material['name'];
    final currentQuantity = material['cantidad'];

    if (currentQuantity <= 0) {
      _showMessage("No hay unidades disponibles de este material.");
      return;
    }

    // Actualizar la cantidad en la base de datos
    await _firestore.collection("materials").doc(materialId).update({
      'cantidad': currentQuantity - 1,
    });

    // Registrar el pedido en la subcolección del usuario (incrementar si ya existe)
    final borrowedDoc = _firestore
        .collection("users")
        .doc(_userId)
        .collection("user_borrowed")
        .doc(materialId);

    final borrowedSnapshot = await borrowedDoc.get();
    if (borrowedSnapshot.exists) {
      borrowedDoc.update({
        'quantity': FieldValue.increment(1),
      });
    } else {
      borrowedDoc.set({
        'name': name,
        'materialId': materialId,
        'quantity': 1,
        'borrowedAt': FieldValue.serverTimestamp(),
      });
    }

    _showMessage("Has pedido el material: $name");
  }

  Future<void> _returnMaterial(QueryDocumentSnapshot material) async {
    final materialId = material.id;
    final currentQuantity = material['cantidad'];

    // Verificar si el material está en los pedidos del usuario
    final borrowedDoc = _firestore
        .collection("users")
        .doc(_userId)
        .collection("user_borrowed")
        .doc(materialId);

    final borrowedSnapshot = await borrowedDoc.get();

    if (!borrowedSnapshot.exists) {
      _showMessage("No tienes este material en tu lista.");
      return;
    }

    final borrowedQuantity = borrowedSnapshot['quantity'];

    // Actualizar la cantidad en la base de datos
    await _firestore.collection("materials").doc(materialId).update({
      'cantidad': currentQuantity + 1,
    });

    // Actualizar o eliminar el material de la subcolección del usuario
    if (borrowedQuantity > 1) {
      borrowedDoc.update({
        'quantity': FieldValue.increment(-1),
      });
    } else {
      borrowedDoc.delete();
    }

    _showMessage("Has devuelto una unidad de: ${borrowedSnapshot['name']}");
  }

  void _showMessage(String msg) {
    final snackBar = SnackBar(content: Text(msg));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _buildMaterialCard(QueryDocumentSnapshot material) {
    String materialId = material.id;
    String name = material['name'];
    int cantidad = material['cantidad'];

    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Text("Cantidad disponible: $cantidad"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _borrowMaterial(material),
              tooltip: "Pedir material",
            ),
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () => _returnMaterial(material),
              tooltip: "Devolver material",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBorrowedList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection("users")
          .doc(_userId)
          .collection("user_borrowed")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text("No tienes materiales pedidos.");
        }

        var borrowedMaterials = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Materiales Pedidos:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: borrowedMaterials.length,
              itemBuilder: (context, index) {
                var borrowed = borrowedMaterials[index];
                return ListTile(
                  title: Text(borrowed['name']),
                  subtitle: Text("Cantidad pedida: ${borrowed['quantity']}"),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Materiales"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection("materials").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var materials = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: materials.length,
                    itemBuilder: (context, index) {
                      return _buildMaterialCard(materials[index]);
                    },
                  );
                },
              ),
            ),
            const Divider(),
            _buildBorrowedList(),
          ],
        ),
      ),
    );
  }
}
