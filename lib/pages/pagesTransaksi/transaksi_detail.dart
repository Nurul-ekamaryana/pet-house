import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_petshop/controller/logController.dart';
import 'package:e_petshop/controller/transaksiController.dart';
import 'package:e_petshop/model.dart/TransaksiItem.dart';
import 'package:e_petshop/model.dart/transaksi.dart';
import 'package:e_petshop/pdf/pdf.dart';
import 'package:e_petshop/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TransaksiDetail extends StatefulWidget {
  final int nomorUnik;

  TransaksiDetail({required this.nomorUnik});

  @override
  State<TransaksiDetail> createState() => _TransaksiDetailState();
}

class _TransaksiDetailState extends State<TransaksiDetail> {
  final currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
  String? _selectedProduct;
  int _qty = 0;
  List<String> produkList = [];
  double _hargaProduk = 0.0;
  double _totalBelanja = 0.0;

  final TextEditingController _namaPembeliController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _uangBayarController = TextEditingController();
  final TextEditingController _hargaProdukController = TextEditingController();
  final TextEditingController _totalBelanjaController = TextEditingController();
  final LogController _logController = LogController();
  final TransaksiController _transaksiController =
      Get.find<TransaksiController>();

  List<TransactionItem> selectedProducts = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchData();
  }

  void fetchData() async {
    try {
      Transaksi transaksi =
          await _transaksiController.getTransaksiByNomorUnik(widget.nomorUnik);

      setState(() {
        _namaPembeliController.text = transaksi.nama_pelanggan;
        _uangBayarController.text = transaksi.uang_bayar.toStringAsFixed(0);
        _totalBelanjaController.text =
            currencyFormatter.format(transaksi.total_belanja);
        selectedProducts = transaksi.items;
      });
    } catch (e) {
      print('Error fetching data for update: $e');
    }
  }

  Future<void> fetchProducts() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('products').get();

    setState(() {
      produkList = querySnapshot.docs
          .map((doc) => doc['nama_produk'] as String)
          .toList();
    });
  }

  Future<void> fetchProdukHarga(String? selectedProduk) async {
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
      });
    }
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
                      fetchProdukHarga(newValue);
                      _selectedProductChanged(_selectedProduct, _qty);
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
                onChanged: (String newValue) {
                  setState(() {
                    _qty = int.tryParse(newValue) ?? 0;
                    _selectedProductChanged(_selectedProduct, _qty);
                  });
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
                                          "${product.nama_produk} - ${product.qty} - ${currencyFormatter.format(product.harga_produk)}",
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        Text(
                                          "${currencyFormatter.format(product.totalProduk)}",
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
                                        calculateTotalBelanja();
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
              SizedBox(height: 20),
              TextField(
                // readOnly: true,
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
                      "${_totalBelanjaController.text}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      backgroundColor: Colour.primary,
                    ),
                    onPressed: () async {
                      String namaPelanggan = _namaPembeliController.text.trim();
                      double uangBayar = double.tryParse(_uangBayarController
                              .text
                              .replaceAll(RegExp('[^0-9]'), '')) ??
                          0;
                      double totalBelanja = _totalBelanja;
                      String updatedat = DateTime.now().toString();
                      double uangKembali = uangBayar - totalBelanja;

                      if (selectedProducts.isNotEmpty &&
                          uangBayar > 0 &&
                          namaPelanggan.isNotEmpty &&
                          uangBayar >= _totalBelanja) {
                        List<TransactionItem> items =
                            selectedProducts.map((product) {
                          return TransactionItem(
                            id_produk: product.id_produk,
                            nama_produk: product.nama_produk,
                            harga_produk: product.harga_produk,
                            qty: product.qty,
                            totalProduk: product.totalProduk,
                          );
                        }).toList();

                        await _transaksiController.updateTransaksi(
                          widget.nomorUnik,
                          namaPelanggan,
                          items,
                          uangBayar,
                          totalBelanja,
                          uangKembali,
                          updatedat,
                        );

                        _addLog("Transaksi updated");
                        Get.back();
                        Get.snackbar(
                            'Success', 'Transaction updated successfully!');
                      } else {
                        Get.snackbar('Failed', 'Failed to update transaction');
                      }
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
                      backgroundColor: Color.fromARGB(255, 65, 138, 31),
                    ),
                    onPressed: () async {
                      await _printReceipt(currencyFormatter);
                    },
                    child: Text(
                      'Struk',
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
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      bool success = await _transaksiController
                          .deleteTransaksi(widget.nomorUnik);
                      if (success) {
                        Get.back();
                        Get.snackbar(
                            'Success', 'Transaction deleted successfully!');
                        _addLog("Menhapus Transaksi");
                      } else {
                        Get.snackbar('Failed', 'Failed to delete transaction');
                      }
                    },
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _printReceipt(NumberFormat currencyFormatter) async {
    try {
      Transaksi transaksi = await _fetchTransaksiData(widget.nomorUnik);
      EmsPdfService emspdfservice = EmsPdfService();
      double uang_bayar = double.tryParse(_uangBayarController.text.replaceAll(RegExp('[^0-9]'), '')) ?? 0;
      // Buat list of strings untuk menyimpan data transaksi yang akan ditampilkan di PDF
      List<String> transactionItems = selectedProducts
          .map((item) =>
              '${item.nama_produk} = ${item.qty} x ${currencyFormatter.format(item.harga_produk)}')
          .toList();

      // Buat list of strings untuk menyimpan jumlah dari setiap produk
      List<String> totalProduk = selectedProducts
          .map((item) => '${currencyFormatter.format(item.totalProduk)}')
          .toList();
          
      double uangKembali = uang_bayar - _totalBelanja;
      // Generate PDF dengan data yang sudah disiapkan
      final data = await emspdfservice.generateEMSPDF(
        "${transaksi.nomor_unik}",
        DateTime.now().toString(),
        _namaPembeliController.text,
        transactionItems.join('\n'),
        totalProduk.join('\n'),
        currencyFormatter.format(_totalBelanja),
        currencyFormatter.format(uang_bayar),
        currencyFormatter.format(uangKembali),
      );
      // Save the PDF file
      await emspdfservice.savePdfFile("Struk", data);
      Get.snackbar('Success', 'Struk Behasil!!',
          snackPosition: SnackPosition.TOP);
    } catch (e) {
      print('Error: $e');
      Get.snackbar('Error', 'Failed to save Struk',
          snackPosition: SnackPosition.TOP);
    }
  }

  Future<Transaksi> _fetchTransaksiData(int nomorUnik) async {
    try {
      Transaksi transaksi =
          await _transaksiController.getTransaksiByNomorUnik(nomorUnik);
      return transaksi;
    } catch (e) {
      print('Error fetching transaction data: $e');
      rethrow;
    }
  }

  void calculateTotalBelanja() {
    double totalBelanja =
        selectedProducts.fold(0.0, (sum, product) => sum + product.totalProduk);
    setState(() {
      _totalBelanja = totalBelanja;
      _totalBelanjaController.text = currencyFormatter.format(totalBelanja);
    });
  }

  void addSelectedProductToContainer(int qty) {
    if (_selectedProduct != null && qty > 0) {
      double totalBelanja = _hargaProduk * qty;

      TransactionItem newProduct = TransactionItem(
        id_produk: _selectedProduct!,
        nama_produk: _selectedProduct!,
        harga_produk: _hargaProduk,
        qty: qty,
        totalProduk: totalBelanja,
      );

      setState(() {
        selectedProducts.add(newProduct);
        calculateTotalBelanja();
        _clearFormFields();
      });
    }
  }

  void _clearFormFields() {
    setState(() {
      _selectedProduct = null;
      _qtyController.clear();
      _hargaProdukController.clear();
      _qty = 0;
    });
  }

  void _selectedProductChanged(String? selectedProduct, int qty) {
    setState(() {
      _selectedProduct = selectedProduct;
      fetchProdukHarga(selectedProduct);
      addSelectedProductToContainer(qty);
    });
  }

  void _addLog(String activity) {
    try {
      _logController.addLog(activity);
      print('Log added successfully!');
    } catch (e) {
      print('Failed to add log: $e');
    }
  }
}
