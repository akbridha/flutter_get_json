import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class Fruit {
  final String id;
  final String nama;
  final String harga;

  Fruit({required this.id, required this.nama, required this.harga});

  factory Fruit.fromJson(Map<String, dynamic> json) {
    return Fruit(
      id: json['id'],
      nama: json['nama'],
      harga: json['harga'],
    );
  }
}

List<Fruit> parseFruits(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Fruit>((json) => Fruit.fromJson(json)).toList();
}

Future<List<Fruit>> fetchFruits() async {
  final response = await http
      .get(Uri.parse('https://rentalzeus.000webhostapp.com/getJSON.php'));
  if (response.statusCode == 200) {
    return parseFruits(response.body);
  } else {
    throw Exception('Gagal mengambil data buah');
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Fruit>> futureFruits;

  @override
  void initState() {
    super.initState();
    futureFruits = fetchFruits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Daftar Buah'),
        ),
        body: Center(
            child: Column(children: [
          ElevatedButton(
            onPressed: () {
              // Panggil fungsi untuk mengambil data dari API di sini
            },
            child: Text("Ambil Data"),
          ),
          _buildFruitList(),
        ])));
  }

  _buildFruitList() {
    return FutureBuilder<List<Fruit>>(
      future: futureFruits,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Expanded(
              child: ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(snapshot.data![index].nama),
                  subtitle: Text('Harga: ${snapshot.data![index].harga}'),
                ),
              );
            },
          ));
        }
      },
    );
  }
}
