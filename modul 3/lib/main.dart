import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alignment',
      home: Scaffold(
        appBar: AppBar(title: Text('Alignment')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('Malang', style: TextStyle(fontSize: 30)),
              Text('25\u00B0C', style: TextStyle(fontSize: 75)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      Text('Minggu'),
                      SizedBox(height:20),
                      Icon(Icons.sunny, color: Colors.black, size: 45),
                      Row(children: [SizedBox(height: 20)]),
                      Text('20\u00B0C'),
                    ],
                  ),
                  Column(
                    children: [
                      Text('Senin'),
                      SizedBox(height:20),
                      Icon(Icons.cloudy_snowing, color: Colors.black, size: 45),
                      Row(children: [SizedBox(height: 20)]),
                      Text('23\u00B0C'),
                    ],
                  ),
                  Column(
                    children: [
                      Text('Selasa'),
                      SizedBox(height:20),
                      Icon(Icons.cloud, color: Colors.black, size: 45),
                      Row(children: [SizedBox(height: 20)]),
                      Text('22\u00B0C'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


