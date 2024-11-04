import 'package:flutter/material.dart';
import 'package:my_movies/pages/profile_page.dart';

import 'favorite_movies_page.dart';
import 'movie_db_page.dart';
import 'my_movies_page.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({super.key});

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {

  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    MyMoviesPage(),
    MovieDbPage(),
    FavoriteMoviesPage(),
    ProfilePage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Películas'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex)
      ),
      drawer: Drawer(
        child:  ListView(
          children:  [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text("Mis Peliculas Header")
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text("Mis Películas"),
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.api),
              title: const Text("MovieDB"),
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text("Favoritas"),
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Mi Pérfil"),
              onTap: () {
                _onItemTapped(3);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
