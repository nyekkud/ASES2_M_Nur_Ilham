import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class TukangOjek {
  String nama;
  String nomorPolisi;

  TukangOjek({required this.nama, required this.nomorPolisi});
}

class Transaksi {
  TukangOjek tukangOjek;
  int harga;

  Transaksi({required this.tukangOjek, required this.harga});
}

class DataProvider extends ChangeNotifier {
  List<TukangOjek> tukangOjekList = [];
  List<Transaksi> transaksiList = [];

  void tambahTukangOjek(TukangOjek tukangOjek) {
    tukangOjekList.add(tukangOjek);
    notifyListeners();
  }

  void tambahTransaksi(Transaksi transaksi) {
    transaksiList.add(transaksi);
    notifyListeners();
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
          primarySwatch: Colors.purple,
        ),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var dataProvider = context.read<DataProvider>();
    List<TukangOjek> tukangOjekList = dataProvider.tukangOjekList;
    List<Transaksi> transaksiList = dataProvider.transaksiList;

    return Scaffold(
      appBar: AppBar(
        title: Text('OPANGATIMIN'),
      ),
      body: Column(
        children: [
          // Tampilkan list atau tabel nama, jumlah order, dan omzet tukang ojek
          Expanded(
            child: ListView.builder(
              itemCount: tukangOjekList.length,
              itemBuilder: (context, index) {
                TukangOjek tukangOjek = tukangOjekList[index];
                int jumlahOrder = transaksiList
                    .where((transaksi) => transaksi.tukangOjek == tukangOjek)
                    .length;
                int omzet = transaksiList
                    .where((transaksi) => transaksi.tukangOjek == tukangOjek)
                    .map((transaksi) => transaksi.harga)
                    .fold(0, (prev, amount) => prev + amount);

                return ListTile(
                  title: Text(tukangOjek.nama),
                  subtitle: Text('Jumlah Order: $jumlahOrder | Omzet: $omzet'),
                );
              },
            ),
          ),

          // Tombol untuk menambah tukang ojek
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TambahTukangOjekPage()),
              );
            },
            child: Text('Tambah Tukang Ojek'),
          ),

          // Tombol untuk menambah transaksi
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
      ),
    );
  }
}

class TambahTukangOjekPage extends StatelessWidget {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController nomorPolisiController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
              onPressed: () {
                var dataProvider = context.read<DataProvider>();
                dataProvider.tambahTukangOjek(TukangOjek(
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
    List<TukangOjek> tukangOjekList = dataProvider.tukangOjekList;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Transaksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown untuk memilih tukang ojek dari list yang ada pada HomePage
            DropdownButtonFormField(
              items: tukangOjekList
                  .map((tukangOjek) => DropdownMenuItem(
                value: tukangOjek,
                child: Text(tukangOjek.nama),
              ))
                  .toList(),
              onChanged: (value) {
                // Do something with the selected tukang ojek
              },
              decoration: InputDecoration(
                labelText: 'Tukang Ojek',
              ),
            ),
            TextField(
              controller: hargaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Harga'),
            ),

          ],
        ),
      ),
    );
  }
}
