import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_petshop/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TransaksiL extends StatefulWidget {
  final String nama_pelanggan;
  final String nama_produk;
  final double harga_produk;
  final double uang_bayar;
  final double uang_kembali;
  final DateTime? selectedDate;

  const TransaksiL(
      {
      required this.nama_pelanggan,
      required this.nama_produk,
      required this.harga_produk,
      required this.uang_bayar,
      required this.uang_kembali,
      required this.selectedDate,
      });

  @override
  State<TransaksiL> createState() => _TransaksiSState();
}

class _TransaksiSState extends State<TransaksiL> {
  final CollectionReference transaksiCollection =
      FirebaseFirestore.instance.collection('transactions');
  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ');

    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Colour.b,
        padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              "Laporan Transaksi",
              style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Laporan Transaksi Pada Pet-house",
              style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  Container(
                    alignment: AlignmentDirectional.bottomStart,
                    child: Text(
                      "Rincian Transaksi",
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tanggal",
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      Text(
                        "${widget.selectedDate}",
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Penghasilan",
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      Text(
                        "${widget.harga_produk}",
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                    ],
                  ),
                 FutureBuilder<int>(
              future: getTransactionCountByDate(widget.selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  int transaksiCount = snapshot.data ?? 0;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Transaksi Count (${DateFormat.yMd().format(widget.selectedDate!)})",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      // Text(
                      //   "$transaksiCount",
                      //   style: TextStyle(
                      //     fontFamily: 'Poppins',
                      //     fontSize: 13,
                      //     fontWeight: FontWeight.bold,
                      //     color: Colors.grey,
                      //   ),
                      // ),
                    ],
                  );
                }
              },
            ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colour.primary),
                onPressed: () {
                       Get.offNamed('/transaksi');
                },
                child: Text(
                  "Selesai",
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
Future<int> getTransactionCountByDate(DateTime? selectedDate) async {
  try {
    QuerySnapshot querySnapshot = await transaksiCollection
        .where('transactions', isEqualTo: selectedDate)
        .get();
    return querySnapshot.size;
  } catch (error) {
    print('Error fetching transaction count: $error');
    return 0; // Return a default value or handle the error accordingly
  }
}

}
