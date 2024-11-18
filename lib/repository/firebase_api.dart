import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/tool.dart';
import '../models/user.dart' as UserApp;
class UserData {
  final String name;
  final String email;
  final bool isActionFavorite;
  final bool isFantasyFavorite;// Role (admin or not)

  UserData({
    required this.name,
    required this.email,
    required this.isActionFavorite,
    required this.isFantasyFavorite,
  });

  // Method to convert Firestore document data to UserData object
  factory UserData.fromMap(Map<String, dynamic> data) {
    return UserData(
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      isActionFavorite: data['isActionFavorite'] ?? false,
      isFantasyFavorite: data['isFantasyFavorite'] ?? false,// Default to false if not found
    );
  }
}
class FirebaseApi {
  Future<String?> createUser(String emailAddress, String password) async {
    try {
      final credential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      return credential.user?.uid;
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException ${e.code}");
      return e.code;
    } on FirebaseException catch (e) {
      print("FirebaseException ${e.code}");
      return e.code;
    }
  }

  Future<String?> signInUser(String emailAddress, String password) async {
    try {
      final credential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      return credential.user?.uid;
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException ${e.code}");
      return e.code;
    } on FirebaseException catch (e) {
      print("FirebaseException ${e.code}");
      return e.code;
    }
  }


  Future<String> createUserInDB(UserApp.User user) async {
    try {
      var db = FirebaseFirestore.instance;
      final document = await db.collection('users').doc(user.uid).set(
          user.toJson());
      return user.uid;
    } on FirebaseException catch (e) {
      print("FirebaseException ${e.code}");
      return e.code;
    }
  }

  Future<String> createMaterial(Tool tool) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      var db = FirebaseFirestore.instance;

      // Crear un nuevo documento en la colección de materiales del usuario
      final document = await db.collection('users').doc(uid).collection(
          'materials').doc();
      tool.id = document.id;


      // Guardar el material en la colección del usuario
      await db.collection('users').doc(uid).collection('materials').doc(
          document.id).set(tool.toJson());

      // Guardar el material en la colección general de materiales
      await db.collection('materials').doc(document.id).set(tool.toJson());

      return document.id;
    } on FirebaseException catch (e) {
      print("FirebaseException ${e.code}");
      return e.code;
    }
  }


  Future<String> deleteMovie(QueryDocumentSnapshot tool) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) {
        print("Error: Usuario no autenticado");
        return "Usuario no autenticado";
      }

      // Verificar y eliminar de la colección del usuario
      var userDocRef = FirebaseFirestore.instance.collection('users').doc(uid).collection('materials').doc(tool.id);
      var userDocSnapshot = await userDocRef.get();
      if (userDocSnapshot.exists) {
        await userDocRef.delete();
        print("Documento eliminado de users/materials");
      } else {
        print("Documento no encontrado en users/materials");
      }

      // Verificar y eliminar de la colección general
      var globalDocRef = FirebaseFirestore.instance.collection('materials').doc(tool.id);
      var globalDocSnapshot = await globalDocRef.get();
      if (globalDocSnapshot.exists) {
        await globalDocRef.delete();
        print("Documento eliminado de materials");
      } else {
        print("Documento no encontrado en materials");
      }

      return "Eliminación exitosa";
    } on FirebaseException catch (e) {
      print("Error al eliminar documento: ${e.message}");
      print("Código de error: ${e.code}");
      return e.code;
    }
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Future<UserData?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        return UserData.fromMap(data);  // Asumiendo que tienes una clase UserData
      }
    } catch (e) {
      print("Error obteniendo los datos del usuario: $e");
    }
    return null;
  }

}