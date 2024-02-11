import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_petshop/controller/usersContoller.dart';
import 'package:e_petshop/pages/pagesTransaksi/transaksi_create.dart';
import 'package:e_petshop/pages/pagesTransaksi/transaksi_detail.dart';
import 'package:e_petshop/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({Key? key});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  final UsersController _usersController = Get.find<UsersController>();
  final currencyFormatter = NumberFormat.currency(locale: 'id', symbol: 'Rp ');
  final CollectionReference transaksiCollection =
      FirebaseFirestore.instance.collection('transactions');
  var searchQuery = '';

  DateTime? selectedDate;

  List<DocumentSnapshot> transaksiList = [];
  List<DocumentSnapshot> filteredTransaksi = [];

  void queryProduk(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filterTransaksi();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        filterTransaksi();
      });
    }
  }

  void getTransaksi() {
    transaksiCollection.snapshots().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          transaksiList = snapshot.docs;
          filterTransaksi();
        });
      } else {
        setState(() {
          transaksiList = [];
          filteredTransaksi = [];
        });
      }
    }, onError: (error) {
      print('Error getting transaksi: $error');
    });
  }

  void filterTransaksi() {
    filteredTransaksi = transaksiList.where((transaksi) {
      final namaPelanggan =
          transaksi['nama_pelanggan'].toString().toLowerCase();
      final tanggalTransaksiString = transaksi['updated_at'] as String;
      final tanggalTransaksi = DateTime.parse(tanggalTransaksiString);

      final isTanggalSelected = selectedDate != null
          ? (tanggalTransaksi.day == selectedDate!.day &&
              tanggalTransaksi.month == selectedDate!.month &&
              tanggalTransaksi.year == selectedDate!.year)
          : true;

      return namaPelanggan.contains(searchQuery) && isTanggalSelected;
    }).toList();

    filterAndGenerateInvoices();
  }

  Future<void> filterAndGenerateInvoices() async {
    await generateAndSaveInvoice(filteredTransaksi
        .map((transaksi) => transaksi.data() as Map<String, dynamic>)
        .toList());
  }

  Future<String> generateAndSaveInvoice(
      List<Map<String, dynamic>> transaksiList) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Transaksi Pemjualan Toko Pet House",
                    style: pw.TextStyle(
                      fontSize: 15,
                      fontWeight: pw.FontWeight.bold,
                    )),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                    headerStyle: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 8),
                    cellStyle: pw.TextStyle(fontSize: 8),
                    border: pw.TableBorder.all(),
                    cellAlignment: pw.Alignment.centerLeft,
                    headerDecoration: pw.BoxDecoration(
                      color: PdfColors.grey300,
                      border: pw.TableBorder.all(),
                    ),
                    headerHeight: 30,
                    data: [
                      [
                        'No.Transaksi',
                        'Nama Pembeli',
                        'Nama Barang',
                        'Harga Barang',
                        'qty',
                        'Total Produk',
                        'Uang Bayar',
                        'Total Belanja',
                        'Uang Kembali',
                        'Tanggal',
                      ],
                      for (var transaksiData in transaksiList)
                        [
                          transaksiData['nomor_unik'],
                          transaksiData['nama_pelanggan'],
                          transaksiData['items']
                              .map((item) => item['nama_produk']),
                          transaksiData['items'].map(
                              (item) => _formatCurrency(item['harga_produk'])),
                          transaksiData['items'].map((item) => item['qty']),
                          transaksiData['items'].map(
                              (item) => _formatCurrency(item['totalProduk'])),
                          _formatCurrency(transaksiData['uang_bayar']),
                          _formatCurrency(transaksiData['total_belanja']),
                          _formatCurrency(transaksiData['uang_kembali']),
                          DateFormat('MMMM dd, yyyy').format(DateTime.parse(
                              transaksiData['updated_at'] as String)),
                        ],
                    ]),
                pw.Container(
                  margin: pw.EdgeInsets.symmetric(vertical: 10),
                  height: 0.5,
                  width: double.infinity,
                  color: PdfColors.grey,
                ),
                pw.Container(
                  alignment: pw.Alignment.bottomRight,
                  child: pw.Text(
                      "Total Pendapatan:${_formatCurrency(calculateTotalBelanja(transaksiList))} ",
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      )),
                )
              ],
            );
          },
        ),
      );

      final Uint8List pdfBytes = await pdf.save();

      final appDocumentsDirectory = await getTemporaryDirectory();
      final pdfPath = '${appDocumentsDirectory.path}/Laporan Transaksi.pdf';
      final pdfFile = File(pdfPath);
      await pdfFile.writeAsBytes(pdfBytes);
      return pdfPath;
    } catch (e) {
      print('Error generating invoice: $e');
      return '';
    }
  }

  String _formatCurrency(dynamic value) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    return currencyFormatter.format(value ?? 0.0);
  }

  // INCOME
  double calculateTotalBelanja(List<Map<String, dynamic>> transaksiList) {
    double total_belanja = 0;

    for (var transaksiData in transaksiList) {
      total_belanja += (transaksiData['total_belanja'] ?? 0.0);
    }

    return total_belanja;
  }

  @override
  Widget build(BuildContext context) {
    UserRole currentUserRole = _usersController.getCurrentUserRole();

    return Scaffold(
      backgroundColor: Colour.b,
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
            padding: const EdgeInsets.only(bottom: 4.3, left: 70.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Data Transaksi',
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
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Poppins',
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Search',
                labelStyle: TextStyle(
                  color: Colour.primary,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (query) => queryProduk(query),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: () {
                      _selectDate(context);
                    },
                    icon: Icon(Icons.date_range)),
                Text('Filter by tanggal',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            if (currentUserRole == UserRole.Owner) ...[
              Container(
                  alignment: AlignmentDirectional.bottomEnd,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colour.primary,
                      ),
                      onPressed: () async {
                        if (filteredTransaksi.isNotEmpty) {
                          String pdfPath = await generateAndSaveInvoice(
                              filteredTransaksi
                                  .map((transaksi) =>
                                      transaksi.data() as Map<String, dynamic>)
                                  .toList());
                          await OpenFile.open(pdfPath);
                        } else {
                          print("Tidak ada transaksi.");
                        }
                      },
                      child: Text(
                        "Generate Laporan",
                        style: TextStyle(color: Colors.white),
                      ))),
            ],
            SizedBox(height: 4),
            Text(
              'All Transaksi',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: transaksiCollection.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final List<DocumentSnapshot> transaksi = snapshot.data!.docs;

                  transaksiList = snapshot.data!.docs;

                  filterTransaksi();

                  if (filteredTransaksi.isEmpty) {
                    return Center(
                      child: Text(
                        'Transaksi tidak ditemukan',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: filteredTransaksi.length,
                    itemBuilder: (context, index) {
                      var transaksiData = filteredTransaksi[index].data()
                          as Map<String, dynamic>;
                      String namaPembeli = transaksiData['nama_pelanggan'];
                      String tanggal = transaksiData['updated_at'] as String;
                      String formattedDate = '';
                      if (tanggal != null) {
                        DateTime dateTime = DateTime.parse(tanggal);
                        formattedDate = DateFormat('MMMM dd, yyyy').format(dateTime);
                      }
                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 90, // Adjust height as needed
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color:
                                      Colour.primary, // Adjust color as needed
                                ),
                                padding: EdgeInsets.all(8),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 13.0),
                                  title: Text(
                                    namaPembeli,
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "$formattedDate",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color:
                                          const Color.fromARGB(255, 88, 88, 88),
                                    ),
                                  ),
                                  trailing: currentUserRole == UserRole.Admin
                                      ? CircleAvatar(
                                          child: Icon(
                                            Icons.edit,
                                            color: Colour.primary,
                                            size: 28.0,
                                          ),
                                        )
                                      : null,
                                  onTap: () {
                                    if (currentUserRole == UserRole.Admin) {
                                      int nomorUnik =
                                          transaksiData['nomor_unik'] as int ??
                                              0;
                                      Get.to(() => TransaksiDetail(
                                            nomorUnik: nomorUnik,
                                          ));
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: currentUserRole == UserRole.Kasir
          ? FloatingActionButton(
              backgroundColor: Colour.primary,
              onPressed: () async {
                await Get.to(() => TransaksiCreate());
                setState(() {});
              },
              child: Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
