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
class iconFav extends StatelessWidget {
  final Color warna;
  const iconFav({super.key, required this.warna});

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
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite,
              color: Colors.red,
              size: 50,
            ),
            Text(
              "ini adalah icon favorite",
              style: TextStyle(
                  fontSize: 14
              ),
            )
          ],
        )
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
              iconFav(warna: Colors.white),
               SizedBox(height: 20, width: 20,),
               iconFav(warna: Colors.white),
               SizedBox(height: 20, width: 20,),
             ],
           ),
           SizedBox(height: 20),
           Row(
             children: [
               iconFav(warna: Colors.white),
               SizedBox(height:20, width: 20,),
               iconFav(warna: Colors.white),
               SizedBox(height:20, width: 20,),
             ],
           )
         ],
       ),
    );
  }
}






