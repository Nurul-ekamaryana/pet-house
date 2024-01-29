import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_petshop/controller/logController.dart';
import 'package:e_petshop/controller/transaksiController.dart';
import 'package:e_petshop/pages/pagesTransaksi/successtransaksi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../model.dart/transaksi.dart';
import '../../theme/color.dart';

class TransaksiCreate extends StatefulWidget {
  @override
  State<TransaksiCreate> createState() => _TransaksiCreateState();
}

class _TransaksiCreateState extends State<TransaksiCreate> {
  final currencyFormatter = NumberFormat.currency(locale: 'id', symbol: 'Rp');
  String? _selectedProduct;
  List<String> produkList = [];
  double _hargaProduk = 0.0;
  String _cirihas = '';
  String _jenis = '';

  double _uangKembali = 0.0;

  final TextEditingController _namaPembeliController = TextEditingController();
  final TextEditingController _uangBayarController = TextEditingController();
  final LogController logController = LogController();

  final TransaksiController _transaksiController =
      Get.put(TransaksiController());

  final TextEditingController _hargaProdukController = TextEditingController();
  final TextEditingController _cirihasController = TextEditingController();
  final TextEditingController _jenisController = TextEditingController();

  void fetchProductPrice(String? selectedProducts) async {
    try {
      if (selectedProducts != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('products')
            .where('nama_produk', isEqualTo: selectedProducts)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          double hargaProduk = querySnapshot.docs.first['harga_produk'];
          String cirihas = querySnapshot.docs.first['ciri_has'];
          String jenis = querySnapshot.docs.first['jenis'];

          setState(() {
            _hargaProduk = hargaProduk;
            _cirihas = cirihas;
            _jenis = jenis;

            // Update the controllers directly
            _hargaProdukController.text =
                "Rp. ${_hargaProduk.toStringAsFixed(2)}";
            _cirihasController.text = _cirihas;
            _jenisController.text = _jenis;
          });
        }
      } else {
        setState(() {
          _hargaProduk = 0.0;
          _hargaProdukController.text = '';
          _jenisController.text = '';
          _cirihasController.text = '';
        });
      }
    } catch (e) {
      print('Error fetching product details: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('products').get();

    setState(() {
      produkList = querySnapshot.docs
          .map((doc) => doc['nama_produk'])
          .toList()
          .cast<String>();
    });
  }

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
            Get.offNamed('/home');
          },
          icon: Icon(Icons.arrow_back),
        ),
        actions: [],
        title: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4.3, left: 64.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Create Data',
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
          child: Column(children: [
            TextField(
              controller: _namaPembeliController,
              decoration: InputDecoration(
                hintText: 'Exm.Nurul Eka',
                label: Text(
                  'Nama Pembeli',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Poppins'),
                ),
                filled: true,
                fillColor: Colour.secondary,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colour.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              width: double.infinity,
              padding: EdgeInsets.all(10),
              height: 50,
              child: DropdownButton<String>(
                hint: Text('Pilih Produk'),
                value: _selectedProduct,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedProduct = newValue;
                    fetchProductPrice(newValue);
                  });
                },
                items: produkList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: _hargaProdukController,
              enabled: false,
              decoration: InputDecoration(
                hintText: 'Exm. Rp. 100.000',
                label: Text(
                  'Harga Produk',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Poppins'),
                ),
                filled: true,
                fillColor: Colour.secondary,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: _cirihasController,
              enabled: false,
              decoration: InputDecoration(
                hintText: 'Exm. Rp.Warna Putih',
                label: Text(
                  'Ciri Hewan',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Poppins'),
                ),
                filled: true,
                fillColor: Colour.secondary,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: _jenisController,
              enabled: false,
              decoration: InputDecoration(
                hintText: 'Exm. Rp.Perisa',
                label: Text(
                  'Jenis',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Poppins'),
                ),
                filled: true,
                fillColor: Colour.secondary,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: _uangBayarController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  double uangBayar =
                      double.tryParse(value.replaceAll(RegExp('[^0-9]'), '')) ??
                          0;
                  _uangKembali = uangBayar - _hargaProduk;
                });
              },
              decoration: InputDecoration(
                hintText: 'Exm. Rp. 100.000',
                label: Text(
                  'Uang Bayar',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Poppins'),
                ),
                filled: true,
                fillColor: Colour.secondary,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Kembalian",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "${currencyFormatter.format(_uangKembali)}",
                    // Convert the result to a string and use currencyFormatter
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  backgroundColor: Colour.primary,
                ),
                onPressed: () async {
                  String namaPembeli = _namaPembeliController.text.trim();
                  double uangBayar = double.tryParse(_uangBayarController.text
                          .replaceAll(RegExp('[^0-9]'), '')) ??
                      0;
                  if (_selectedProduct != null &&
                      uangBayar >= _hargaProduk &&
                      namaPembeli.isNotEmpty) {
                    int _nomor_unik = Random().nextInt(1000000000);
                    String _created_at = DateTime.now().toString();
                    String _updated_at = DateTime.now().toString();

                    Transaksi newTransaksi = Transaksi(
                      nomor_unik: _nomor_unik,
                      nama_pelanggan: namaPembeli,
                      nama_produk: _selectedProduct!,
                      ciri_has: _cirihas!,
                      jenis: _jenis!,
                      harga_produk: _hargaProduk,
                      uang_bayar: uangBayar,
                      uang_kembali: _uangKembali,
                      creatad_at: _created_at,
                      updated_at: _updated_at,
                    );
                    _addLog('menambah transaksi');
                    Get.to(() => TransaksiS(
                          nomor_unik: _nomor_unik,
                          nama_pelanggan: namaPembeli,
                          nama_produk: _selectedProduct!,
                          harga_produk: _hargaProduk,
                          uang_bayar: uangBayar,
                          uang_kembali: _uangKembali,
                          created_at: _created_at,
                        ));
                    Get.snackbar('Success', 'Berhasil Transaksi');

                    bool success =
                        await _transaksiController.addTransaksi(newTransaksi);

                    if (success) {
                      _namaPembeliController.clear();
                      _uangBayarController.clear();
                      _hargaProdukController.clear();
                      setState(() {
                        _selectedProduct = null;
                      });
                    } else {
                      print('Failed to add transaction to the database');
                    }
                  } else {
                    Get.snackbar(
                        'Failed', 'Silakan periksa kembali transaksi.');
                  }
                },
                child: Text('Submit',
                    style:
                        TextStyle(color: Colors.white, fontFamily: 'Poppins')),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _addLog(String message) async {
    try {
      await logController
          .addLog(message); // Menambahkan log saat tombol ditekan
      print('Log added successfully!');
    } catch (e) {
      print('Failed to add log: $e');
    }
  }
}
