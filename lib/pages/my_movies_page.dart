import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_movies/pages/new_page.dart';
import 'package:my_movies/repository/firebase_api.dart';

class MyMoviesPage extends StatefulWidget {
  const MyMoviesPage({super.key});

  @override
  State<MyMoviesPage> createState() => _MyMoviesPageState();
}

class _MyMoviesPageState extends State<MyMoviesPage> {
  String _searchQuery = '';
  final FirebaseApi _firebaseApi = FirebaseApi();
  bool _isAdmin = false;
  bool _isLoading = true;

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
        _isAdmin = userData?.isActionFavorite ?? false;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addButtonClicked() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userData = await _firebaseApi.getUserData(user.uid);
      if (userData != null && userData.isActionFavorite) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => NewItemPage()));
      } else {
        _showMessage("Solo los administradores pueden agregar nuevos materiales.");
      }
    } else {
      _showMessage("Debes iniciar sesión para agregar materiales.");
    }
  }

  void _deleteMovie(QueryDocumentSnapshot movie) async {
    var result = await _firebaseApi.deleteMovie(movie);
    if (result == 'network-request-failed') {
      _showMessage("Revise su conexión a internet");
    } else {
      _showMessage("Material eliminado con éxito");
    }
  }

  void _showMessage(String msg) {
    SnackBar snackBar = SnackBar(content: Text(msg));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showAlertDialog(QueryDocumentSnapshot movie) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userData = await _firebaseApi.getUserData(user.uid);

      if (userData != null && userData.isActionFavorite) {
        TextEditingController passwordController = TextEditingController();

        AlertDialog alert = AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Ingrese su contraseña para confirmar la eliminación:"),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: "Contraseña"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cerrar el diálogo
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                bool passwordIsCorrect = await _verifyPassword(passwordController.text);
                if (passwordIsCorrect) {
                  _deleteMovie(movie);
                  Navigator.pop(context); // Cerrar el diálogo
                } else {
                  _showMessage("Contraseña incorrecta. No se puede eliminar el material.");
                  Navigator.pop(context); // Cerrar el diálogo
                }
              },
              child: const Text('Eliminar'),
            ),
          ],
        );

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );
      } else {
        _showMessage("Solo los administradores pueden eliminar este material.");
      }
    }
  }

  Future<bool> _verifyPassword(String password) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        return true;
      }
      return false;
    } catch (e) {
      print("Error al verificar la contraseña: $e");
      return false;
    }
  }

  void _showDetails(QueryDocumentSnapshot movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsPage(movie: movie),
      ),
    );
  }

  InkWell _buildCard(QueryDocumentSnapshot movie) {
    return InkWell(
      onTap: () {
        _showDetails(movie);
      },
      onLongPress: () {
        _showAlertDialog(movie);
      },
      child: Card(
        elevation: 4.0,
        child: Column(
          children: [
            ListTile(
              title: Text(movie['name']),
              subtitle: Text(movie['descripcion']),
            ),
            Container(
              height: 100.0,
              width: 100.0,
              child: _buildImage(movie['urlPicture']),
            ),
            const SizedBox(height: 16.0),
            Text("Cantidad: ${movie['cantidad']}"),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String urlPicture) {
    if (urlPicture.isNotEmpty) {
      try {
        final base64Data = urlPicture.contains(',') ? urlPicture.split(',').last : urlPicture;
        Uint8List decodedBytes = base64Decode(base64Data);
        return Image.memory(
          decodedBytes,
          fit: BoxFit.cover,
        );
      } catch (e) {
        print("Error al decodificar la imagen: $e");
        return _defaultImage();
      }
    } else {
      return _defaultImage();
    }
  }

  Widget _defaultImage() {
    return Image.asset('assets/images/logo.webp', fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materiales'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("materials").snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text("Cargando...");
            var filteredDocs = snapshot.data!.docs.where((doc) {
              var name = doc['name'].toString().toLowerCase();
              return name.contains(_searchQuery);
            }).toList();
            return ListView.builder(
              itemCount: filteredDocs.length,
              itemBuilder: (context, index) {
                QueryDocumentSnapshot movie = filteredDocs[index];
                return _buildCard(movie);
              },
            );
          },
        ),
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
        onPressed: _addButtonClicked,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}

class DetailsPage extends StatelessWidget {
  final QueryDocumentSnapshot movie;

  const DetailsPage({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: movie['urlPicture'].isNotEmpty
                  ? Image.memory(
                base64Decode(movie['urlPicture'].split(',').last),
                height: 200,
              )
                  : Image.asset('assets/images/logo.webp', height: 200),
            ),
            const SizedBox(height: 16.0),
            Text("Nombre: ${movie['name']}",
                style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Text("Descripción: ${movie['descripcion']}",
                style: const TextStyle(fontSize: 16.0)),
            const SizedBox(height: 8.0),
            Text("Cantidad: ${movie['cantidad']}",
                style: const TextStyle(fontSize: 16.0)),
            const SizedBox(height: 8.0),
            Text("Canales: ${movie['canales']}",
                style: const TextStyle(fontSize: 16.0)),
            const SizedBox(height: 8.0),
            Text("Voltaje máximo: ${movie['salidasVoltaje']}",
                style: const TextStyle(fontSize: 16.0)),
            const SizedBox(height: 8.0),
            Text("Corriente máxima: ${movie['salidasCorriente']}",
                style: const TextStyle(fontSize: 16.0)),
            const SizedBox(height: 8.0),
            Text("Función onda: ${movie['funcionOnda'] ? 'Sí' : 'No'}",
                style: const TextStyle(fontSize: 16.0)),
            const SizedBox(height: 8.0),
            Text("Contador de pulsos: ${movie['contadorPulsos'] ? 'Sí' : 'No'}",
                style: const TextStyle(fontSize: 16.0)),
            const SizedBox(height: 8.0),
            Text("Pantalla táctil: ${movie['pantallaTactil'] ? 'Sí' : 'No'}",
                style: const TextStyle(fontSize: 16.0)),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }
}


