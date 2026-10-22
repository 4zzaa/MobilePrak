import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp( const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo GridView.builder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Demo GridView.builder')
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;
  
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
    List dataGame =[];
    
  @override
  void initState(){
    super.initState();
  _ambilData();
  }

//   Method request data API
Future _ambilData() async {
  try{
    final response =await http.get(
      Uri.parse('https://www.freetogame.com/api/games'),
    );
    if(response.statusCode == 200){
      final data =jsonDecode(response.body);
      setState(() {
        dataGame = data.take(20).toList();
      });
    }else{
      throw Exception('Gagal load data dari FreeToGame API');
    }
  }
  catch(e){
    print('Error : $e');
  }
}
@override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
      backgroundColor: Colors.amber,
      title: Text(widget.title),
      ),
      body: ListView.builder(
          itemCount: dataGame.length,
          itemBuilder: (context, index){
            return _listItem(
              dataGame[index]['thumbnail'] ?? 'https://via.placeholder.com/150',
              dataGame[index]['title'] ?? 'tidak ada judul',
              dataGame[index]['genre'] ?? 'tidak ada genre',
              dataGame[index]['release_date'] ?? 'tidak ada tanggal'
            );
          }
      )
      );

}
}

Container _tombolBaca(){
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
    decoration: BoxDecoration(
      color: Colors.orange, borderRadius: BorderRadius.circular(15)),
    child: const Text(''
        'Baca Info',
      style: TextStyle(color: Colors.white),
    ),
  );
}
Container _listItem(String url, String judul, String genre, String rilis){
  return Container(
    padding: const EdgeInsets.all(15),
    margin: const EdgeInsets.only(bottom:10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15)
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.network(
            url,
            width: 70,
            height: 70,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
            child:Column (
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                  judul,
                  style: const TextStyle( fontSize: 18, fontWeight: FontWeight.bold),
                ) ,
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment:MainAxisAlignment.spaceBetween ,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(genre,
                        style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 2),
                        Text(rilis,
                         style: const TextStyle(color:Colors.grey))
                      ],
                  ),
                    _tombolBaca()
                  ],
                )
                ],
            )
        )
      ],
    ),
  );
}

ClipRRect tile( Color warnaKotak, String gambar, String judul){
  return ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Container(
      color: warnaKotak,
      child: GridTile(
        footer: SizedBox(
          height: 45,
          child: GridTileBar(
            backgroundColor: Colors.black38,
            title: Text(
              judul,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        child: Image.asset(gambar,scale: 4,),
      ),
    ),
  );
}

Container listTile (Color warna, Color warnaAvatar, String judul, String subjudul, String gambar){
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: ListTile(
      tileColor: warna,
      title: Text(
        judul,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold
        ),
      ),
      subtitle: Text(
        subjudul,
        style: const TextStyle(
          fontSize: 16
        ),
      ),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: warnaAvatar,
        child: Image.asset(
          gambar,
          width: 35,
          height: 35,
        ),
      ),
      trailing: Icon(
        Icons.star,
        color: Colors.orangeAccent.shade400,
      ),
    ),
  );
}