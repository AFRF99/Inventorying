import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_movies/pages/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  bool _isLoading = true;

  // Controladores para los campos del perfil
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _apellidoController = TextEditingController(); // Controlador para el apellido

  String _role = ''; // Variable para el rol del usuario
  IconData _roleIcon = Icons.person; // Icono para el rol del usuario

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    _currentUser = _auth.currentUser;

    if (_currentUser != null) {
      try {
        var userDoc = await _firestore.collection('users').doc(_currentUser!.uid).get();
        if (userDoc.exists) {
          var data = userDoc.data()!;
          _nameController.text = data['name'] ?? '';
          _apellidoController.text = data['apellido'] ?? ''; // Cargar apellido
          _emailController.text = _currentUser!.email ?? '';

          // Obtener isActionFavorite para determinar el rol
          bool isAdmin = data['isActionFavorite'] ?? false;
          _role = isAdmin ? 'Administrador' : 'Usuario'; // Definir rol
          _roleIcon = isAdmin ? Icons.build : Icons.person; // Seleccionar icono
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateUserData() async {
    if (_currentUser != null) {
      try {
        await _firestore.collection('users').doc(_currentUser!.uid).set({
          'name': _nameController.text.trim(),
          'apellido': _apellidoController.text.trim(), // Ahora también se actualiza el apellido
          // No actualizamos el rol, ya que este es solo lectura
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Perfil actualizado con éxito.")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al actualizar el perfil: $e")),
        );
      }
    }
  }

  void _onCerrarSessionButtonClicked() {
    _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono de acuerdo al rol
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade200,
                child: Icon(
                  _roleIcon,
                  size: 50,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nombre",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              // Campo para el apellido
              TextField(
                controller: _apellidoController,
                decoration: const InputDecoration(
                  labelText: "Apellido",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Correo electrónico",
                  border: OutlineInputBorder(),
                ),
                readOnly: true, // El correo no se puede editar.
              ),
              const SizedBox(height: 10),
              // Rol del usuario, solo lectura
              TextField(
                controller: TextEditingController(text: _role),
                decoration: const InputDecoration(
                  labelText: "Rol",
                  border: OutlineInputBorder(),
                ),
                readOnly: true, // El rol no se puede editar
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUserData,
                child: const Text("Guardar cambios"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _onCerrarSessionButtonClicked,
                child: const Text("Cerrar sesión"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
