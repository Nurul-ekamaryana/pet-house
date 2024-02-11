import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_petshop/controller/logController.dart';
import 'package:e_petshop/controller/transaksiController.dart';
import 'package:e_petshop/model.dart/TransaksiItem.dart';
import 'package:e_petshop/model.dart/produk.dart';
import 'package:e_petshop/model.dart/transaksi.dart';
import 'package:e_petshop/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'successtransaksi.dart';

class TransaksiCreate extends StatefulWidget {
  @override
  State<TransaksiCreate> createState() => _TransaksiCreateState();
}

class _TransaksiCreateState extends State<TransaksiCreate> {
  final currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
  String? _selectedProduct;
  String? _selectedProductId;
  List<String> produkList = [];
  double _hargaProduk = 0.0;
  double _totalBelanja = 0.0;

  final TextEditingController _namaPembeliController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _uangBayarController = TextEditingController();
  final LogController logController = LogController();

  final TransaksiController _transaksiController =
      Get.put(TransaksiController());

  final TextEditingController _hargaProdukController = TextEditingController();

  List<Map<String, dynamic>> selectedProducts = [];

  void calculateTotalBelanja() {
    int qty = int.tryParse(_qtyController.text) ?? 0;

    if (_hargaProduk != null && _selectedProduct != null && qty > 0) {
      int existingProductIndex = selectedProducts
          .indexWhere((product) => product['products'] == _selectedProduct);

      if (existingProductIndex != -1) {
        setState(() {
          selectedProducts[existingProductIndex]['qty'] += qty;
          selectedProducts[existingProductIndex]['totalProduk'] +=
              _hargaProduk * qty;
          _totalBelanja = selectedProducts.fold(
              0.0, (sum, product) => sum + product['totalProduk']);
        });
      } else {
        double totalProduk = _hargaProduk * qty;

        Map<String, dynamic> selectedProductData = {
          'id': _selectedProductId,
          'products': _selectedProduct!,
          'harga_produk': _hargaProduk,
          'qty': qty,
          'totalProduk': totalProduk,
        };

        setState(() {
          selectedProducts.add(selectedProductData);
          _totalBelanja = selectedProducts.fold(
              0.0, (sum, product) => sum + product['totalProduk']);
        });
      }
      setState(() {
        _selectedProduct = null;
        _qtyController.clear();
      });
    } else {
      print('Harga produk tidak ditemukan atau qty tidak valid.');
    }
  }

  Future<void> _submitTransaksi() async {
    String namaPembeli = _namaPembeliController.text.trim();
    double uangBayar = double.tryParse(
            _uangBayarController.text.replaceAll(RegExp('[^0-9]'), '')) ??
        0;

           QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();

                  double hargaProduk = querySnapshot.docs.first['harga_produk'];



    if (selectedProducts.isNotEmpty &&
        uangBayar > 0 &&
        namaPembeli.isNotEmpty &&
        uangBayar >= _totalBelanja) {
      double totalBelanja = _totalBelanja;
      double uangKembali = uangBayar - totalBelanja;

      int _nomor_unik = Random().nextInt(1000000000);
      String _created_at = DateTime.now().toString();
      String _updated_at = DateTime.now().toString();

      List<TransactionItem> transactionItems = selectedProducts.map((product) {
        return TransactionItem(
          id_produk: product['id'],
          nama_produk: product['products'],
          harga_produk: product['harga_produk'],
          qty: product['qty'],
          totalProduk: product['totalProduk'],
        );
      }).toList();

      Transaksi newTransaksi = Transaksi(
        nomor_unik: _nomor_unik,
        nama_pelanggan: namaPembeli,
        items: transactionItems,
        uang_bayar: uangBayar,
        total_belanja: totalBelanja,
        uang_kembali: uangKembali,
        creatad_at: _created_at,
        updated_at: _updated_at,
      );

      bool success = await _transaksiController.addTransaksi(newTransaksi);

      if (success) {
        Get.snackbar('Success', 'Transaksi added successfully');

        String newtransactionId = _nomor_unik.toString();

        _namaPembeliController.clear();
        _uangBayarController.clear();
        _hargaProdukController.clear();
        _totalBelanja = 0;
        setState(() {
          _selectedProduct = null;
          selectedProducts.clear();
          Get.to(() => TransaksiS(transactionId: newtransactionId));
        });
      } else {
        Get.snackbar('Failed', 'Failed to add transaction to the database');
      }
    } else {
      Get.snackbar('Failed', 'Please check your transaction details.');
    }
  }

  void fetchProdukHarga(String? selectedProduk) async {
    if (selectedProduk != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('nama_produk', isEqualTo: selectedProduk)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        double hargaProduk = querySnapshot.docs.first['harga_produk'];
        String productId = querySnapshot.docs.first.id;

        setState(() {
          _selectedProductId = productId;
          _hargaProduk = hargaProduk;
          _hargaProdukController.text =
              "Rp. ${_hargaProduk.toStringAsFixed(2)}";
        });
      }
    } else {
      setState(() {
        _hargaProduk = 0.0;
        _hargaProdukController.text = '';
      });
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
          .map((doc) => Produk(
                id: doc['id'],
                nama_produk: doc['nama_produk'],
                harga_produk: doc['harga_produk'],
                created_at: doc['created_at'],
                updated_at: doc['updated_at'],
              ))
          .toList()
          .cast<Produk>()
          .map((product) => product.nama_produk)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
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
              padding: const EdgeInsets.only(bottom: 4.3, left: 84.0),
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
          child:
            Container(
                color: Colour.b,
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  TextField(
                      controller: _namaPembeliController,
                      decoration: InputDecoration(
                        hintText: 'Exm. Nurul Eka',
                        label: Text(
                          'Nama Pelanggan',
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
                      )),
                  SizedBox(
                    height: 20,
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
                          fetchProdukHarga(newValue);
                        });
                      },
                      items:
                          produkList.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(
                    height: 20,
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
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                      controller: _qtyController,
                      onChanged: (value) {
                        calculateTotalBelanja();
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Exm. 50',
                        label: Text(
                          'QTY',
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
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  selectedProducts.isNotEmpty
                      ? Container(
                          height: 100,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: selectedProducts.map((product) {
                                return Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${product['products']} - ${product['qty']} - ${currencyFormatter.format(product['harga_produk'])}",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                            Text(
                                              "${currencyFormatter.format(product['totalProduk'])}",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            selectedProducts.remove(product);
                                            _totalBelanja = selectedProducts.fold(
                                                0.0,
                                                (sum, product) =>
                                                    sum + product['totalProduk']);
                                          });
                                        },
                                        icon: Icon(Icons.close),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      : Container(),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                      controller: _uangBayarController,
                      keyboardType: TextInputType.number,
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
                      )),
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
                          "${currencyFormatter.format(_totalBelanja)}",
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
                    alignment: Alignment.centerRight,
                    margin: EdgeInsets.only(top: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        backgroundColor: Colour.primary,
                      ),
                      onPressed: () async {
                        await _submitTransaksi();
                      },
                      child: Text('Submit',
                          style: TextStyle(
                              color: Colors.white, fontFamily: 'Poppins')),
                    ),
                  ),
                ]
              )
            ),
           )
        );
  }

  void updateTotalBelanja() {
    double hargaProduk = _hargaProduk;
    int qty = int.tryParse(_qtyController.text) ?? 0;
    double totalBelanja = hargaProduk * qty;

    setState(() {
      _totalBelanja = totalBelanja;
    });
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
