import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_petshop/controller/logController.dart';
import 'package:e_petshop/controller/transaksiController.dart';
import 'package:e_petshop/pages/pagesTransaksi/adop.dart';
import 'package:e_petshop/theme/color.dart';
import 'package:flutter/material.dart';
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
  String _cirihas = '';
  String _jenis = '';
  double _uangKembali = 0.0;
  final LogController logController = LogController();

  final TextEditingController _namaPembeliController = TextEditingController();
  final TextEditingController _uangBayarController = TextEditingController();
  final TextEditingController _hargaProdukController = TextEditingController();
  final TextEditingController _jenisController = TextEditingController();
  final TextEditingController _cirihasController = TextEditingController();
  final TransaksiController _transaksiController =
      Get.put(TransaksiController());

  Future<void> updateTransaction() async {
    String id = Get.arguments['id'];
    String namaPembeli = _namaPembeliController.text.trim();
    double uangBayar = double.tryParse(
            _uangBayarController.text.replaceAll(RegExp('[^0-9]'), '')) ??
        0;
    double uangKembali = _hargaProduk - uangBayar;

    if (_selectedProduct != null &&
        uangBayar > _hargaProduk &&
        namaPembeli.isNotEmpty) {
      await _transaksiController.updateTransaksi(
          id,
          namaPembeli,
          _selectedProduct!,
          _hargaProduk,
          _jenis,
          _cirihas,
          uangBayar,
          uangKembali);

      _namaPembeliController.clear();
      _uangBayarController.clear();
      _hargaProdukController.clear();
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

  // Metode untuk mengupdate uang kembali
  void _updateUangKembali() {
    double uangBayar = double.tryParse(
          _uangBayarController.text.replaceAll(RegExp('[^0-9]'), ''),
        ) ??
        0;
    double uangKembali = _hargaProduk - uangBayar;

    setState(() {
      _uangKembali = uangKembali;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
    final Map<String, dynamic>? args = Get.arguments;
    _selectedProduct = args?['nama_produk'] ?? null;
    if (_selectedProduct != null) {
      fetchBookPrice(_selectedProduct);
    }

    // Panggil _updateUangKembali di initState
    _updateUangKembali();
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

  Future<void> fetchBookPrice(String? selectedBook) async {
    if (selectedBook != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('nama_produk', isEqualTo: selectedBook)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        double hargaProduk = querySnapshot.docs.first['harga_produk'];
        String jenis = querySnapshot.docs.first['jenis'];
        String cirihas = querySnapshot.docs.first['ciri_has'];

        setState(() {
          _hargaProduk = hargaProduk;
          _cirihas = cirihas;
          _jenis = jenis;
          _jenisController.text = _jenis;
          _cirihasController.text = _cirihas;
          _hargaProdukController.text = currencyFormatter.format(hargaProduk);
        });
      }
    } else {
      setState(() {
        _hargaProduk = 0.0;
        _hargaProdukController.text = '';
        _uangKembali = 0.0;
        _jenisController.text = '';
        _cirihasController.text = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args = Get.arguments;
    final String id = args?['id'] ?? '';
    final String namaPembeli = args?['nama_pelanggan'] ?? '';
    final double uangBayar = args?['uang_bayar'] ?? 0.0;

    _namaPembeliController.text = namaPembeli;
    _uangBayarController.text = uangBayar.toStringAsFixed(0);
    _uangKembali = _hargaProduk - uangBayar;

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
                    fetchBookPrice(newValue);
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
              controller: _jenisController,
              enabled: false,
              decoration: InputDecoration(
                hintText: 'Exm. Rp. 100.000',
                label: Text(
                  'Jenis',
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
              controller: _cirihasController,
              enabled: false,
              decoration: InputDecoration(
                hintText: 'Exm. Rp. 100.000',
                label: Text(
                  'ciri Has',
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

                  // ElevatedButton(
                  //   style: ElevatedButton.styleFrom(
                  //     padding:
                  //         EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  //     backgroundColor: Color.fromARGB(255, 143, 141, 27),
                  //   ),
                  //   onPressed: () async {
                  //     Get.to(() => Adop(
                  //           nama_pelanggan: namaPembeli,
                  //           nama_produk: _selectedProduct!,
                  //           harga_produk: _hargaProduk,
                  //           uang_bayar: uangBayar,
                  //           uang_kembali: _uangKembali,
                  //         ));
                  //   },
                  //   child: Text(
                  //     'Laporan Adop',
                  //     style: TextStyle(
                  //       color: Colors.white,
                  //       fontFamily: 'Poppins',
                  //     ),
                  //   ),
                  // ),
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
