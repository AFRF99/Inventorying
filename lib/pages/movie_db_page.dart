import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_movies/pages/login_page.dart';

class MovieDbPage extends StatefulWidget {
  const MovieDbPage({super.key});

  @override
  State<MovieDbPage> createState() => _MovieDbPageState();
}

class _MovieDbPageState extends State<MovieDbPage> {
  void _onCerrarSessionButtonClicked(){
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context)=> const LoginPage())

    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Profile"),
              ElevatedButton(onPressed: _onCerrarSessionButtonClicked,
                  child: const Text("Cerrar sesion"))
            ],
          )

      ),
    );
  }
}
