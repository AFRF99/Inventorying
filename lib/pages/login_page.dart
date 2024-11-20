import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_movies/models/user.dart';
import 'package:my_movies/pages/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repository/firebase_api.dart';
import 'navigation_bar_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseApi _firebaseApi = FirebaseApi();

  bool _isPasswordObscure = true;
  bool _isLoading = false; // Estado de carga para bloquear el botón

  void _showMessage(String msg) {
    final snackBar = SnackBar(content: Text(msg));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  bool _isValidEmail(String email) {
    // Expresión regular para validar el formato del correo electrónico
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _onLoginButtonClicked() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validar campos vacíos
    if (email.isEmpty || password.isEmpty) {
      _showMessage("Por favor, complete todos los campos.");
      return;
    }

    // Validar formato del correo
    if (!_isValidEmail(email)) {
      _showMessage("Por favor, ingrese un correo electrónico válido.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _firebaseApi.signInUser(email, password);

      if (result == 'invalid-email') {
        _showMessage("El correo electrónico está mal escrito.");
      } else if (result == 'network-request-failed') {
        _showMessage("Revise su conexión a internet.");
      } else if (result == 'user-not-found' || result == 'wrong-password') {
        _showMessage("Correo electrónico o contraseña incorrecta.");
      } else if (result == 'too-many-requests') {
        _showMessage("Demasiados intentos fallidos. Por favor, inténtelo más tarde.");
      } else {
        _showMessage("Bienvenido");
        _saveSession();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NavigationBarPage()),
        );
      }
    } catch (e) {
      _showMessage("Error inesperado: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isUserLogged", true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Image(
                  image: AssetImage('assets/images/logo.webp'),
                  width: 250,
                  height: 250,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Correo electrónico",
                    prefixIcon: Icon(Icons.mail),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isPasswordObscure,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: "Digite su contraseña",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordObscure
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _isPasswordObscure = !_isPasswordObscure;
                        });
                      },
                    ),
                  ),
                  keyboardType: TextInputType.visiblePassword,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _onLoginButtonClicked,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text("Iniciar Sesión"),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text("Registrarse"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
