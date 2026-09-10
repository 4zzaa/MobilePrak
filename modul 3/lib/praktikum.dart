import 'package:flutter/material.dart';

void main() {
  runApp(praktikum());
}

class praktikum extends StatelessWidget {
  const praktikum({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alignment',
      home: Scaffold(
        appBar: AppBar(title: Text('Alignment')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('Suhu:', style: TextStyle(fontSize: 30)),
              Text('25\u00B0C', style: TextStyle(fontSize: 75)),
              Icon(Icons.sunny, color: Colors.amber, size: 45),
            ],
          ),
        ),
      ),
    );
  }
}

class KotakBiruJempol extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.blue,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.thumb_up, color: Colors.white, size: 40),
    );
  }
}

class KotakBiruJempolKecil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        color: Colors.blue,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.thumb_up, color: Colors.white, size: 40),
    );
  }
}
