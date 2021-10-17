import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PAE',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Benvinguts al projecte de PAE'),
        ),
        body: const Center(
          child: Text('App DETECCIÓ I RESOLUCIÓ DE PLAGUES'),
        ),
      ),
    );
  }
}
