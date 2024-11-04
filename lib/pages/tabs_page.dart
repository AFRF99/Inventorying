import 'package:flutter/material.dart';
import 'package:my_movies/pages/profile_page.dart';

import 'favorite_movies_page.dart';
import 'movie_db_page.dart';
import 'my_movies_page.dart';

class TabsPage extends StatefulWidget {
  const TabsPage({super.key});

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Mis Películas"),
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.list), text: "Mis Pelís"),
                  Tab(icon: Icon(Icons.api), text: "MovieDB"),
                  Tab(icon: Icon(Icons.favorite), text: "Favoritas"),
                  Tab(icon: Icon(Icons.person), text: "Mi Pérfil"),
                ],
              ),
            ),
            body: const TabBarView(children: [
              MyMoviesPage(),
              MovieDbPage(),
              FavoriteMoviesPage(),
              ProfilePage()
            ]),
          ))
    );
  }
}
