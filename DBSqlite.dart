import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(MyApp());
}

class TukangOjek {
  int id;
  String nama;
  String nomorPolisi;

  TukangOjek({required this.id, required this.nama, required this.nomorPolisi});

  Map<String, dynamic> toMap() {
    return {'id': id, 'nama': nama, 'nopol': nomorPolisi};
  }
}

class Transaksi {
  int id;
  int tukangOjekId;
  int harga;
  String timestamp;

  Transaksi({required this.id, required this.tukangOjekId, required this.harga, required this.timestamp});

  Map<String, dynamic> toMap() {
    return {'id': id, 'tukangojek_id': tukangOjekId, 'harga': harga, 'timestamp': timestamp};
  }
}

class DataProvider extends ChangeNotifier {
  late Database _database;

  DataProvider() {
    initDatabase();
  }

  Future<void> initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'opangatimin_database.db'),
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE tukangojek(
            id INTEGER PRIMARY KEY,
            nama TEXT,
            nopol TEXT
          )
        ''');
        db.execute('''
          CREATE TABLE transaksi(
            id INTEGER PRIMARY KEY,
            tukangojek_id INTEGER,
            harga INTEGER,
            timestamp TEXT
          )
        ''');
      },
      version: 1,
    );
    notifyListeners();
  }

  Future<void> tambahTukangOjek(TukangOjek tukangOjek) async {
    await _database.insert('tukangojek', tukangOjek.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    notifyListeners();
  }

  Future<void> tambahTransaksi(Transaksi transaksi) async {
    await _database.insert('transaksi', transaksi.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    notifyListeners();
  }

  Future<List<TukangOjek>> getTukangOjekList() async {
    final List<Map<String, dynamic>> maps = await _database.query('tukangojek');

    return List.generate(maps.length, (i) {
      return TukangOjek(
        id: maps[i]['id'],
        nama: maps[i]['nama'],
        nomorPolisi: maps[i]['nopol'],
      );
    });
  }

  Future<List<Transaksi>> getTransaksiList() async {
    final List<Map<String, dynamic>> maps = await _database.query('transaksi');

    return List.generate(maps.length, (i) {
      return Transaksi(
        id: maps[i]['id'],
        tukangOjekId: maps[i]['tukangojek_id'],
        harga: maps[i]['harga'],
        timestamp: maps[i]['timestamp'],
      );
    });
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DataProvider(),
      child: MaterialApp(
        title: 'OPANGATIMIN App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var dataProvider = context.watch<DataProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('OPANGATIMIN'),
      ),
      body: FutureBuilder(
        future: dataProvider.getTukangOjekList(),
        builder: (context, AsyncSnapshot<List<TukangOjek>> snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          List<TukangOjek> tukangOjekList = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: tukangOjekList.length,
                  itemBuilder: (context, index) {
                    TukangOjek tukangOjek = tukangOjekList[index];
                    // ... implementasikan bagian ini seperti sebelumnya
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TambahTukangOjekPage()),
                  );
                },
                child: Text('Tambah Tukang Ojek'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TambahTransaksiPage()),
                  );
                },
                child: Text('Tambah Transaksi'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class TambahTukangOjekPage extends StatelessWidget {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController nomorPolisiController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var dataProvider = context.read<DataProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Tukang Ojek'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: namaController,
              decoration: InputDecoration(labelText: 'Nama Tukang Ojek'),
            ),
            TextField(
              controller: nomorPolisiController,
              decoration: InputDecoration(labelText: 'Nomor Polisi'),
            ),
            ElevatedButton(
              onPressed: () async {
                await dataProvider.tambahTukangOjek(TukangOjek(
                  id: 0, // id akan di-generate oleh SQLite
                  nama: namaController.text,
                  nomorPolisi: nomorPolisiController.text,
                ));

                Navigator.pop(context);
              },
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

class TambahTransaksiPage extends StatelessWidget {
  final TextEditingController hargaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var dataProvider = context.read<DataProvider>();
    List<TukangOjek> tukangOjekList = [];

    return Scaffold(
        appBar: AppBar(
          title: Text('Tambah Transaksi'),
        ),
        body: FutureBuilder(
        future: dataProvider.getTukangOjekList(),
    builder
