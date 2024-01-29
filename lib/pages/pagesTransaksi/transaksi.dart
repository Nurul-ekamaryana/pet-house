import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_petshop/controller/usersContoller.dart';
import 'package:e_petshop/pages/pagesTransaksi/transaksiL.dart';
import 'package:e_petshop/pages/pagesTransaksi/transaksi_create.dart';
import 'package:e_petshop/pages/pagesTransaksi/transaksi_detail.dart';
import 'package:e_petshop/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
  final CollectionReference transaksiCollection = FirebaseFirestore.instance.collection('transactions');
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
      final namaProduk = transaksi['nama_produk'].toString().toLowerCase();
      final tanggalTransaksiString = transaksi['creatad_at'] as String;
      final tanggalTransaksi = DateTime.parse(tanggalTransaksiString);

      final isTanggalSelected = selectedDate != null
          ? (tanggalTransaksi.day == selectedDate!.day &&
              tanggalTransaksi.month == selectedDate!.month &&
              tanggalTransaksi.year == selectedDate!.year)
          : true;

      return namaProduk.contains(searchQuery) && isTanggalSelected;
    }).toList();
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
            padding: const EdgeInsets.only(bottom: 4.3, left: 59.0),
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
                if (currentUserRole == UserRole.Owner)
                  IconButton(
                    onPressed: () async {
                      await _selectDate(context);
                      if (filteredTransaksi.isNotEmpty) {
                        final selectedTransaction = filteredTransaksi.first;
                        final transaksiData = selectedTransaction.data() as Map<String, dynamic>;
                        Get.to(() => TransaksiL(
                          nama_pelanggan: transaksiData['nama_pelanggan'],
                          nama_produk: transaksiData['nama_produk'],
                          harga_produk: transaksiData['harga_produk']?.toDouble() ?? 0.0,
                          uang_bayar: transaksiData['uang_bayar']?.toDouble() ?? 0.0,
                          uang_kembali: transaksiData['uang_kembali']?.toDouble() ?? 0.0,
                          selectedDate: selectedDate,
                        ));
                      } else {
                        // Handle the case when filteredTransaksi is empty
                      }
                    },
                    icon: Icon(Icons.date_range),
                  ),
                if (currentUserRole == UserRole.Owner)
                  Text(
                    'By tanggal',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
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
                      var transaksiData = filteredTransaksi[index].data() as Map<String, dynamic>;
                      String namaPembeli = transaksiData['nama_pelanggan'];
                      String namaProduk = transaksiData['nama_produk'];
                      // String nomorunik = transaksiData['nomor_unik'];
                      String tanggal = transaksiData['updated_at'];

                      double hargaProduk = transaksiData['harga_produk']?.toDouble() ?? 0.0;
                      String formattedPrice = currencyFormatter.format(hargaProduk);
                      double nomorunik = transaksiData['nomor_unik']?.toDouble() ?? 0.0;
                      String formattednouniq = currencyFormatter.format(hargaProduk);
                      double uangBayar = transaksiData['uang_bayar']?.toDouble() ?? 0.0;
                      String formattedUangBayar = currencyFormatter.format(uangBayar);
                      double uangKembali = transaksiData['uang_kembali']?.toDouble() ?? 0.0;
                      String formattedUangKembali = currencyFormatter.format(uangKembali);

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
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
                                  color: Colour.primary, // Adjust color as needed
                                ),
                                padding: EdgeInsets.all(8),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 13.0),
                                  title: Text(
                                    namaPembeli,
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                     '$namaProduk = $formattedPrice',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: const Color.fromARGB(255, 88, 88, 88),
                                    ),
                                  ),
                                  trailing: CircleAvatar(
                                    child: Icon(
                                      Icons.edit,
                                      color: Colour.primary,
                                      size: 28.0,
                                    ),
                                  ),
                                  onTap: () {
                                    Get.to(() => TransaksiDetail(), arguments: {
                                      'id': filteredTransaksi[index].id,
                                      'nama_pelanggan': namaPembeli,
                                      'nomor_unik': nomorunik,
                                      'nama_produk': namaProduk,
                                      'uang_bayar': uangBayar,
                                      'uang_kembali': uangKembali,
                                      'updated_at': tanggal,
                                    });
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
