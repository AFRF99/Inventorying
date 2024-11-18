import 'package:flutter/material.dart';
import 'package:my_movies/pages/navigation_bar_page.dart';
import 'package:my_movies/repository/firebase_api.dart';
import '../models/user.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

enum Genre { male, female }

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseApi _firebaseApi = FirebaseApi();

  final _name = TextEditingController();
  final _apellido = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _repPassword = TextEditingController();
  final _city = TextEditingController();

  bool _isPasswordObscure = true;
  bool _isRepPasswordObscure = true;

  Genre? _genre = Genre.male;
  bool _isActionFavorite = false;
  bool _isAdventureFavorite = false;
  bool _isComicFavorite = false;
  bool _isFantasyFavorite = false;
  bool _isLoveFavorite = false;
  bool _isTerrorFavorite = false;

  String buttonMsg = "Fecha de Nacimiento";

  DateTime _data = DateTime.now();

  final List<String> _cities = ['Administrador', 'Usuario'];

  void _showMessage(String msg) {
    setState(() {
      SnackBar snackBar = SnackBar(content: Text(msg));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  void createUserInDB(User user) async {
    var result = await _firebaseApi.createUserInDB(user);
    if (result == 'network-request-failed') {
      _showMessage('Revise su conexión a internet');
    } else {
      _showMessage('Usuario creado con éxito');
      Navigator.pop(context);


    }
  }


  void _createUser(User user) async {
    var result = await _firebaseApi.createUser(user.email, user.password);

    if (result == 'invalid-email') {
      _showMessage('El correo está mal escrito');
    } else if (result == 'email-already-in-use') {
      _showMessage('ya existe una cuenta con ese correo electrónico');
    } else if (result == 'waek-password') {
      _showMessage('La contraseña debe tener minimo 6 digitos');
    } else {
      user.uid=result;
      createUserInDB(user);
    }
  }

  void _onRegisterButtonClicked() {
    if (_email.text.isEmpty || _password.text.isEmpty) {
      _showMessage("ERROR: Debe digitar correo electrónico y contraseña");
    } else if (_password.text != _repPassword.text) {
      _showMessage("ERROR: Las contraseñas deben de ser iguales");
    } else {
      String genre = _genre == Genre.male ? "Masculino" : "Femenino";


      var user2 = User(
        "",
        _name.text,
        _apellido.text,
        _email.text,
        _password.text,
        genre,
        _isActionFavorite,
        _isAdventureFavorite,
        _isComicFavorite,
        _isFantasyFavorite,
        _isLoveFavorite,
        _isTerrorFavorite,
        _data.toString(),
        _city.text,
      );
      var user = user2;
      _createUser(user);
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Image(
                  image: AssetImage('assets/images/logo.webp'),
                  width: 256,
                  height: 256,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Digite sus nombres",
                      prefixIcon: Icon(Icons.person)),
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  controller: _apellido,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Digite sus apellidos",
                      prefixIcon: Icon(Icons.person)),
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Digite su correo electrónico",
                        helperText: "*Campo obligatorio",
                        prefixIcon: Icon(Icons.email)),
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) =>
                    value!.isValidEmail() ? null : "Correo inválido"),
                const SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                    controller: _password,
                    obscureText: _isPasswordObscure,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "Digite su contraseña",
                      helperText: "*Campo obligatorio",
                      prefixIcon: const Icon(Icons.lock),
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
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => value!.isPasswordValid()
                        ? null
                        : "La contraseña debe tener mínimo 6 caracteres"),
                const SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  controller: _repPassword,
                  obscureText: _isRepPasswordObscure,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: "Repita la contraseña",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                        icon: Icon(_isRepPasswordObscure
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _isRepPasswordObscure = !_isRepPasswordObscure;
                          });
                        }),
                  ),
                  keyboardType: TextInputType.visiblePassword,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                // Aquí agregamos un Switch para seleccionar si el usuario es Administrador
                const SizedBox(
                  height: 16.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text("¿Es Administrador?"),
                    Switch(
                      value: _isActionFavorite,
                      onChanged: (bool value) {
                        setState(() {
                          _isActionFavorite = value; // Cambia el valor de _isActionFavorite
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16.0,
                ),
                ElevatedButton(
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      _onRegisterButtonClicked();
                    },
                    child: const Text("Registrar")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
extension on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}

extension on String {
  bool isPasswordValid() {
    return this.length > 5;
  }
}
