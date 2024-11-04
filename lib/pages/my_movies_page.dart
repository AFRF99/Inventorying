import 'package:flutter/material.dart';

class MyMoviesPage extends StatefulWidget {
  const MyMoviesPage({super.key});

  @override
  State<MyMoviesPage> createState() => _MyMoviesPageState();
}

class _MyMoviesPageState extends State<MyMoviesPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Ingresar"),
      ),
    );
  }
}
