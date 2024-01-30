import 'package:e_petshop/controller/logController.dart';
import 'package:e_petshop/controller/produkController.dart';
import 'package:e_petshop/model.dart/produk.dart';
import 'package:e_petshop/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProdukCreate extends StatefulWidget {
  @override
  _ProdukCreateState createState() => _ProdukCreateState();
}

class _ProdukCreateState extends State<ProdukCreate> {
  final ProdukController _produkController = Get.put(ProdukController());
  final TextEditingController namaController = TextEditingController();
  final TextEditingController jenisController = TextEditingController();
  final TextEditingController cirihasController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();
  final LogController logController = LogController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colour.primary,
        toolbarHeight: 120,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        leading: IconButton(
          color: Colors.white,
          onPressed: () {
            Get.offNamed('/produk');
          },
          icon: Icon(Icons.arrow_back),
        ),
        actions: [],
        title: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4.3, left: 59.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Create Produk',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'OpenSans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
        color: Colour.b,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: namaController,
              decoration: InputDecoration(
                hintText: 'Ex. Kucing Orang',
                labelText: 'Hewan',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
                filled: true,
                fillColor: Colour.secondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: jenisController,
              decoration: InputDecoration(
                hintText: 'Ex. Persia',
                labelText: 'Jenis Hewan',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
                filled: true,
                fillColor: Colour.secondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: cirihasController,
              decoration: InputDecoration(
                hintText: 'Ex. Berwarna Hijau',
                labelText: 'Ciri Has',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
                filled: true,
                fillColor: Colour.secondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: hargaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Exm. Rp. 100.000',
                labelText: 'Harga',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
                filled: true,
                fillColor: Colour.secondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 12),
            Container(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  backgroundColor: Colour.primary,
                ),
                onPressed: () async {
                  String nama_produk = namaController.text.trim();
                  String ciri_has = cirihasController.text.trim();
                  String jenis = jenisController.text.trim();
                  double harga_produk =
                      double.tryParse(hargaController.text.trim()) ?? 0.0;

                  if (nama_produk.isNotEmpty &&
                      harga_produk > 0 &&
                      jenis.isNotEmpty &&
                      ciri_has.isNotEmpty) {
                    Produk newProduk = Produk(
                      nama_produk: nama_produk,
                      jenis: jenis,
                      ciri_has: ciri_has,
                      harga_produk: harga_produk,
                      created_at: DateTime.now().toString(),
                      updated_at: DateTime.now().toString(),
                    );
                    bool success = await _produkController.addProduk(newProduk);
                    if (success) {
                      print('Produk added successfully');
                      _produkController.shouldUpdate.value = true;
                      Get.offNamed('/produk');
                      _addLog('Menambah Produk');
                    } else {
                      print('Failed to add produk');
                    }
                  } else {
                    print('Please fill in all fields correctly');
                  }
                },
                child: Text(
                  'Submit',
                  style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

   Future<void> _addLog(String activity) async {
    try {
      await logController.addLog(activity);
      print('Log added successfully!');
    } catch (e) {
      print('Failed to add log: $e');
    }
  }
}
