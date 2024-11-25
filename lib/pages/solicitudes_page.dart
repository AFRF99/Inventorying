import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SolicitudesPage extends StatelessWidget {
  const SolicitudesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial de Materiales"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collectionGroup('user_borrowed').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var borrowedMaterials = snapshot.data!.docs;

          if (borrowedMaterials.isEmpty) {
            return const Center(
              child: Text("No hay materiales prestados en este momento."),
            );
          }

          return ListView.builder(
            itemCount: borrowedMaterials.length,
            itemBuilder: (context, index) {
              var borrowed = borrowedMaterials[index];
              var materialName = borrowed['name'];
              var quantity = borrowed['quantity'];


              var userId = borrowed.reference.parent.parent!.id;

              return FutureBuilder<DocumentSnapshot>(
                future: firestore.collection("users").doc(userId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(
                      title: Text("Cargando usuario..."),
                      subtitle: Text("Espere un momento."),
                    );
                  }

                  var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  var userName = userData['name'] ?? 'Nombre no disponible';
                  var userEmail = userData['email'] ?? 'Correo no disponible';

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: ListTile(
                      title: Text("Material: $materialName"),
                      subtitle: Text(
                        "Cantidad: $quantity\nUsuario: $userName\nCorreo: $userEmail",
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}