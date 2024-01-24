import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_petshop/controller/usersContoller.dart';
import 'package:e_petshop/pages/pagesTransaksi/transaksiL.dart';
import 'package:e_petshop/pages/pagesTransaksi/transaksi_create.dart';
import 'package:e_petshop/pages/pagesTransaksi/transaksi_detail.dart';
import 'package:e_petshop/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({Key? key});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  final UsersController _UsersController = Get.find<UsersController>();
  final currencyFormatter = NumberFormat.currency(locale: 'id', symbol: 'Rp ');
  final CollectionReference transaksiCollection =
      FirebaseFirestore.instance.collection('transactions');
  var searchQuery = '';

  void queryProduk(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filterTransaksi();
    });
  }

  DateTime? selectedDate;

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

  List<DocumentSnapshot> transaksiList = [];
  List<DocumentSnapshot> filteredTransaksi = [];

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
    UserRole currentUserRole = _UsersController.getCurrentUserRole();
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
                        final selectedTransaction = filteredTransaksi
                            .first; // Assuming you want the first transaction in the list
                        final transaksiData =
                            selectedTransaction.data() as Map<String, dynamic>;
                        Get.to(() => TransaksiL(
                              nama_pelanggan: transaksiData['nama_pelanggan'],
                              nama_produk: transaksiData[
                                  'nama_produk'], // Replace with actual data
                              harga_produk:
                                  transaksiData['harga_produk']?.toDouble() ??
                                      0.0, // Replace with actual data
                              uang_bayar:
                                  transaksiData['uang_bayar']?.toDouble() ??
                                      0.0, // Replace with actual data
                              uang_kembali:
                                  transaksiData['uang_kembali']?.toDouble() ??
                                      0.0, // Replace with actual data
                              selectedDate: selectedDate,
                            ));
                      } else {
                        // Handle the case when filteredTransaksi is empty
                      }
                    },
                    icon: Icon(Icons.date_range),
                  ),
                if (currentUserRole == UserRole.Owner)
                  Text('By tanggal',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)
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
                      var transaksiData = filteredTransaksi[index].data()
                          as Map<String, dynamic>;
                      String namaPembeli = transaksiData['nama_pelanggan'];
                      String namaProduk = transaksiData['nama_produk'];

                      double hargaProduk =
                          transaksiData['harga_produk']?.toDouble() ?? 0.0;
                      String formattedPrice =
                          currencyFormatter.format(hargaProduk);
                      double uangBayar =
                          transaksiData['uang_bayar']?.toDouble() ?? 0.0;
                      String formattedUangBayar =
                          currencyFormatter.format(uangBayar);
                      double uangKembali =
                          transaksiData['uang_kembali']?.toDouble() ?? 0.0;
                      String formattedUangKembali =
                          currencyFormatter.format(uangKembali);

                      return GestureDetector(
  child: Container(
    margin: EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
    ),
    padding: const EdgeInsets.all(20),
    height: 94,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                namaPembeli,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$namaProduk",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Text(
                  //   formattedPrice,
                  //   style: TextStyle(
                  //     fontSize: 13,
                  //     color: Colors.grey,
                  //     fontFamily: "Poppins",
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
       if (currentUserRole == UserRole.Admin)
  GestureDetector(
    onTap: () {
      Get.to(() => TransaksiDetail(), arguments: {
        'id': filteredTransaksi[index].id,
        'nama_pelanggan': namaPembeli,
        'nama_produk': namaProduk,
        'uang_bayar': uangBayar,
        'uang_kembali': uangKembali,
      });
    },
    child: Icon(
      Icons.edit, // Replace with the desired icon
      color: Colors.blue, // Adjust the color as needed
      size: 24.0, // Adjust the size as needed
    ),
  ),

      ],
    ),
  ),
  onTap: () {
    if (currentUserRole == UserRole.Admin) {
      Get.to(() => TransaksiDetail(), arguments: {
        'id': filteredTransaksi[index].id,
        'nama_pelanggan': namaPembeli,
        'nama_produk': namaProduk,
        'uang_bayar': uangBayar,
        'uang_kembali': uangKembali,
      });
    }
  },
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
