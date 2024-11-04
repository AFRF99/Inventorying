import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_page.dart';
import 'navigation_bar_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Future<void> _closeSplash() async {
    Future.delayed(const Duration(seconds: 2), () async {
      /*SharedPreferences prefs = await SharedPreferences.getInstance();
      var isUserLogged = prefs.getBool("isUserLogged");
      if (isUserLogged ?? false) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const NavigationBarPage()));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginPage()));
      }
      */

      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const LoginPage()));
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const NavigationBarPage()));
        }
      });
    });
  }

  @override
  void initState() {
    _closeSplash();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Image(
          image: AssetImage('assets/images/logo.webp'),
        ),
      ),
    );
  }
}