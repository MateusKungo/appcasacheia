import 'package:casacheiapp/page/SplahScreen.dart';
import 'package:casacheiapp/page/LoginPage.dart';
import 'package:casacheiapp/page/CreateAccountPage.dart';

import 'package:casacheiapp/page/HomePage.dart';
import 'package:casacheiapp/page/BasketsPage.dart';
import 'package:casacheiapp/page/PromotionsPage.dart';
import 'package:casacheiapp/page/ProductsPage.dart';
import 'package:casacheiapp/theme/theme.dart';


import 'package:flutter/material.dart';
 void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/create-account': (context) => const CreateAccountPage(),
        '/home': (context) => const HomePage(),
        '/baskets': (context) => const BasketsPage(),
        '/promotions': (context) => const PromotionsPage(),
        '/products': (context) => const ProductsPage(),
        // A navegação para o carrinho é feita via MaterialPageRoute para passar argumentos,
        // mas podemos manter a rota registrada se necessário.
      } ,
    );
  }
}