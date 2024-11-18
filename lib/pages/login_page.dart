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

  final _email = TextEditingController();
  final _password = TextEditingController();
  final FirebaseApi _firebaseApi= FirebaseApi();

  User user = User.Empty();

  bool _isPasswordObscure = true;

  void _showMessage(String msg) {
    setState(() {
      SnackBar snackBar = SnackBar(content: Text(msg));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  void _saveSession() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isUserLogged", true);
  }

  Future <void> _onLoginButtonClicked() async{
    final result= await _firebaseApi.signInUser(_email.text, _password.text);

    if (result=='invalid.email'){
      _showMessage("El correo eletrónico está mal escrito");
    }else if(result=='network -request-failed') {
      _showMessage("Revise su conexión a internet");
    }else if (result=='invalid-credencial'){
      _showMessage("Correo electrónico o contraseña incorrecta");
    }else{
      _showMessage("Bienvenido");
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> const NavigationBarPage()));
    }
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
                  controller: _email,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Correo electrónico",
                      prefixIcon: Icon(Icons.mail)),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  controller: _password,
                  obscureText: _isPasswordObscure,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Digite su contraseña",
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                        icon: Icon(_isPasswordObscure
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _isPasswordObscure = !_isPasswordObscure;
                          });
                        }),
                  ),
                  keyboardType: TextInputType.visiblePassword,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                ElevatedButton(
                    onPressed: () {
                      _onLoginButtonClicked();
                    },
                    child: const Text("Iniciar Sesión"),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic
                    ),
                  ),
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context)=> const RegisterPage()));
                  },
                  child: const Text("Registrarse")
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
