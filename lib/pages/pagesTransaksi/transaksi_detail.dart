import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_petshop/controller/logController.dart';
import 'package:e_petshop/controller/transaksiController.dart';
import 'package:e_petshop/pdf/pdf.dart';
import 'package:e_petshop/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TransaksiDetail extends StatefulWidget {
  @override
  State<TransaksiDetail> createState() => _TransaksiDetailState();
}

class _TransaksiDetailState extends State<TransaksiDetail> {
  final currencyFormatter = NumberFormat.currency(locale: 'id', symbol: 'Rp');
  String? _selectedProduct;
  List<String> produkList = [];
  double _hargaProduk = 0.0;
  double _uangKembali = 0.0;
  double _total = 0.0;
  final LogController logController = LogController();
  final EmsPdfService emspdfservice = EmsPdfService();
  List _orders = [];
  DateTime _currentDate = DateTime.now();

  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString("assets/orders.json");
    final data = await json.decode(response);
    setState(() {
      _orders = data['records'];
    });
  }

  @override
  void initState() {
    super.initState();
    readJson();
    fetchProducts();
    final Map<String, dynamic>? args = Get.arguments;
    _selectedProduct = args?['nama_produk'] ?? null;
    if (_selectedProduct != null) {
      fetchprodukPrice(_selectedProduct);
    }
    _updateUangKembali(); // Call _updateUangKembali in initState
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

  Future<void> fetchprodukPrice(String? selectedProduk) async {
  if (selectedProduk != null) {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('nama_produk', isEqualTo: selectedProduk)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      double hargaProduk = querySnapshot.docs.first['harga_produk'];

      setState(() {
        _hargaProduk = hargaProduk;
        _hargaProdukController.text = currencyFormatter.format(hargaProduk);
      });
    }
  } else {
    setState(() {
     _hargaProduk = 0.0;
        _hargaProdukController.text = '';
        _uangKembali = 0.0;
    });
  }
}


  final TextEditingController _namaPembeliController = TextEditingController();
  final TextEditingController _uangBayarController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _hargaProdukController = TextEditingController();
  final TransaksiController _transaksiController =
      Get.put(TransaksiController());

  Future<void> updateTransaction() async {
    String id = Get.arguments['id'];
    String namaPembeli = _namaPembeliController.text.trim();
    double uangBayar = double.tryParse(
            _uangBayarController.text.replaceAll(RegExp('[^0-9]'), '')) ??
        0;
        int qty = int.tryParse(_qtyController.text.replaceAll(RegExp('[^0-9]'), '')) ?? 0;
    double uangKembali = _total - uangBayar;
    double total = _hargaProduk * qty;

    if (_selectedProduct != null &&
        uangBayar > _hargaProduk &&
        namaPembeli.isNotEmpty) {
      await _transaksiController.updateTransaksi(
          id,
          namaPembeli,
          _selectedProduct!,
          _hargaProduk,
          uangBayar,
          qty,
          total,
          uangKembali);

      _namaPembeliController.clear();
      _uangBayarController.clear();
      _hargaProdukController.clear();
      _qtyController.clear();
      setState(() {
        _selectedProduct = null;
        _uangKembali = uangKembali;
      });

      Get.back();
      Get.snackbar('Success', 'Transaction updated successfully!');
    } else {
      Get.snackbar('Failed', 'Failed to update transaction');
    }
  }

  // Method to update the change in the returned amount
  void _updateUangKembali() {
    double uangBayar = double.tryParse(
          _uangBayarController.text.replaceAll(RegExp('[^0-9]'), ''),
        ) ??
        0;
    double uangKembali = _total - uangBayar;

    setState(() {
      _uangKembali = uangKembali;
    });
  }

  void _updatetotal() {
  int qty = int.tryParse(_qtyController.text) ?? 0;
   double total = _hargaProduk * qty;
    setState(() {
      _total = total;
    });
  }
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args = Get.arguments;
    final String id = args?['id'] ?? '';
    final String namaPembeli = args?['nama_pelanggan'] ?? '';
    final double uangBayar = args?['uang_bayar'] ?? 0.0;
    final int qty = args?['qty'] ?? 0.0;
    final double total = args?['total'] ?? 0.0;
    final double uangKembali = args?['uang_kembali'] ?? 0.0;
    final double nounik = args?['nomor_unik'] ?? 0.0;

    _namaPembeliController.text = namaPembeli;
    _uangBayarController.text = uangBayar.toStringAsFixed(0);
    _qtyController.text = qty.toStringAsFixed(0);
    _uangKembali = _total - uangBayar;
    _total = qty * _hargaProduk;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
          color: Colour.secondary,
          onPressed: () {
            Get.offNamed('/home');
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
                  'Detail Transaksi',
                  style: TextStyle(
                    color: Colour.secondary,
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
              controller: _namaPembeliController,
              decoration: InputDecoration(
                hintText: 'Exm.Nurul Eka',
                label: Text(
                  'Nama Pembeli',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
                filled: true,
                fillColor: Colour.secondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
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
                    fetchprodukPrice(newValue);
                  });
                },
                items: produkList.map<DropdownMenuItem<String>>(
                  (String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  },
                ).toList(),
              ),
            ),
            SizedBox(height: 20),
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
                    fontFamily: 'Poppins',
                  ),
                ),
                filled: true,
                fillColor: Colour.secondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                // Panggil _updateUangKembali saat nilai berubah
                _updatetotal();
              },
              decoration: InputDecoration(
                hintText: 'Exm. Rp. 100.000',
                label: Text(
                  'QTY',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
                filled: true,
                fillColor: Colour.secondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _uangBayarController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                // Panggil _updateUangKembali saat nilai berubah
                _updateUangKembali();
              },
              decoration: InputDecoration(
                hintText: 'Exm. Rp. 100.000',
                label: Text(
                  'Uang Bayar',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
                filled: true,
                fillColor: Colour.secondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Belanja",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "${_total >= 0 ? '' : '-'}${currencyFormatter.format(_total.abs())}",
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
                    "${_uangKembali >= 0 ? '-' : ''}${currencyFormatter.format(_uangKembali.abs())}",
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      backgroundColor: Colour.primary,
                    ),
                    onPressed: () async {
                      updateTransaction();
                         _addLog('update transactions');
                    },
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      backgroundColor: Colors.amber,
                    ),
                   onPressed: () async {
                        try {
                              String formattedDate = DateFormat('dd-MM-yyyy').format(_currentDate);
                          final data = await emspdfservice.generateEMSPDF(
                            nounik.toString(),
                            formattedDate,
                            _namaPembeliController.text,
                            _selectedProduct.toString(),
                            _hargaProduk.toString(),
                            qty.toString(),
                            _total.toString(),
                            uangBayar.toString(),
                            uangKembali.toString()    
                            );

                          await emspdfservice.savePdfFile(
                              "Invoice_Transactions", data);
                          _addLog("Mencetak Struk");
                          Get.snackbar('Success', 'PDF saved successfully!');
                        } catch (e) {
                          print('Error: $e');
                          Get.snackbar('Error', 'Failed to save PDF');
                        }
                      },
                    child: Text(
                      'print',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  ElevatedButton(
                  onPressed: () async {
                    bool confirmDelete = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Konfirmasi"),
                          content: Text("Apakah Anda yakin ingin menghapus produk ini?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true); // User confirms deletion
                              },
                              child: Text("Ya"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false); // User cancels deletion
                              },
                              child: Text("Tidak"),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmDelete == true) {
                      bool success = await _transaksiController.deleteTransaksi(id);
                      if (success) {
                        _transaksiController.shouldUpdate.value = true;
                        Get.back(); // Kembali ke halaman produk
                        _addLog("menghapus transaksi");
                        Get.snackbar('Success', 'Berhasil delete');
                      } else {
                        Get.snackbar('Failed', 'Failed to delete transaction');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text(
                    "Hapus",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ],
              ),
            ),
          ],
        ),
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
