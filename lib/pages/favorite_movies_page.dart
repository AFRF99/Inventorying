import 'package:flutter/material.dart';

class FavoriteMoviesPage extends StatefulWidget {
  const FavoriteMoviesPage({super.key});

  @override
  State<FavoriteMoviesPage> createState() => _FavoriteMoviesPageState();
}

class _FavoriteMoviesPageState extends State<FavoriteMoviesPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Buscar"),
      ),
    );
  }
}
