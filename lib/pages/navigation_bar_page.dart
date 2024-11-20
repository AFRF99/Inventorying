import 'package:flutter/material.dart';
import 'package:my_movies/pages/favorite_movies_page.dart';
import 'package:my_movies/pages/movie_db_page.dart';
import 'package:my_movies/pages/my_movies_page.dart';
import 'package:my_movies/pages/profile_page.dart';

class NavigationBarPage extends StatefulWidget {
  const NavigationBarPage({super.key});

  @override
  State<NavigationBarPage> createState() => _NavigationBarPageState();
}

class _NavigationBarPageState extends State<NavigationBarPage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    MyMoviesPage(),
    MovieDbPage(),
    FavoriteMoviesPage(),
    ProfilePage(),
    //SolicitudesPage()
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
        title: const Center(
            child: Text("Inventorying", textAlign: TextAlign.center,
        style: TextStyle(color: Colors.green),)
      )),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.list), label: "Inventario"),
            /*BottomNavigationBarItem(
                icon: Icon(Icons.delete_forever_sharp), label: "Retirar"),*/
            BottomNavigationBarItem(
                icon: Icon(Icons.manage_search), label: "Solicitar"),
            BottomNavigationBarItem(
                icon: Icon(Icons.edit_note_rounded), label: "Editar"),
             BottomNavigationBarItem(
                 icon: Icon(Icons.person), label: "Perfil"),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped),
    );
  }
}
