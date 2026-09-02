import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Row and Column',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Row and Column'),
        ),
        body: Center(
          child: grid(),
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
        color : Colors.blue,
        border : Border.all(color: Colors.black, width : 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.thumb_up,
        color: Colors.white,
        size: 40,
      ),
    );
  }
}
class Kotakwarna extends StatelessWidget {
  final Color warna;
  const Kotakwarna({super.key, required this.warna});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
          color: warna,
          border: Border.all(color: Colors.brown, width: 2),
          borderRadius: BorderRadius.circular(12)
      ),
    );
  }
}

class grid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
       child: Column(
         children: [
           Row(
             children: [
              Kotakwarna(warna: Colors.green),
               SizedBox(height: 20, width: 20,),
               Kotakwarna(warna: Colors.yellow),
               SizedBox(height: 20, width: 20,),
             ],
           ),
           SizedBox(height: 20),
           Row(
             children: [
               Kotakwarna(warna: Colors.blue),
               SizedBox(height:20, width: 20,),
               Kotakwarna(warna: Colors.red),
               SizedBox(height:20, width: 20,),
             ],
           )
         ],
       ),
    );
  }
}

