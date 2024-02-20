import 'dart:typed_data';
import 'package:e_petshop/model.dart/TransaksiItem.dart';
import 'package:e_petshop/model.dart/transaksi.dart';
import 'package:e_petshop/pdf/pdf.dart';
import 'package:e_petshop/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controller/transaksiController.dart';

class TransaksiS extends StatefulWidget {
  final String transactionId;

  TransaksiS({required this.transactionId});

  @override
  State<TransaksiS> createState() => _TransaksiSState();
}

class _TransaksiSState extends State<TransaksiS> {
  final TransaksiController _transaksiController =
      Get.put(TransaksiController());

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

  Future<Uint8List> loadAndProcessImage() async {
    ByteData bytesAsset = await rootBundle.load("images/logo.png");
    Uint8List imageBytesFromAsset = bytesAsset.buffer
        .asUint8List(bytesAsset.offsetInBytes, bytesAsset.lengthInBytes);

    return imageBytesFromAsset;
  }

  Future<Uint8List> printImageUsingPrinter() async {
    Uint8List imageBytes = await loadAndProcessImage();
    return imageBytes;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 7,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Column(
              children: [
                _buildAppBar(),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTransactionDetails(currencyFormatter),
                      SizedBox(height: 20),
                      _buildButtons(currencyFormatter),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Card(
      elevation: 5, // Adjust the elevation as needed
      color: Colour.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Align(
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Transaksi Berhasil!!',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'OpenSans',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionDetails(NumberFormat currencyFormatter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Rincian Pembelian",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 15),
        FutureBuilder<Transaksi>(
          future: _fetchTransaksiData(int.parse(widget.transactionId)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return Center(child: Text('No data available'));
            }

            Transaksi transaksi = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow("No. Struk", "${transaksi.nomor_unik}"),
                _buildDetailRow("Nama Pembeli", "${transaksi.nama_pelanggan}"),
                _buildDetailRow(
                  "Total Harga",
                  currencyFormatter.format(transaksi.total_belanja),
                ),
                _buildDetailRow(
                  "Uang Bayar",
                  currencyFormatter.format(transaksi.uang_bayar),
                ),
                _buildDetailRow(
                  "Uang Kembali",
                  currencyFormatter.format(transaksi.uang_kembali),
                ),
                Text(
                  "Transaction Items:", // Additional text here
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Column(
                  children: transaksi.items
                      .map((item) => buildProductDetailRow(item))
                      .toList(),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(NumberFormat currencyFormatter) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          ),
          onPressed: () async {
            await _printReceipt(currencyFormatter);
          },
          child: Text(
            "Struk",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colour.primary,
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          ),
          onPressed: () {
            Get.offNamed('/transaksi');
          },
          child: Text(
            "Selesai",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _printReceipt(NumberFormat currencyFormatter) async {
    try {
      Transaksi transaksi =
          await _fetchTransaksiData(int.parse(widget.transactionId));
      EmsPdfService emspdfservice = EmsPdfService();

      String transactionDate =
          DateFormat('MMMM dd, yyyy').format(DateTime.now());

      String transactionItems = transaksi.items
          .map((item) =>
              '${item.nama_produk} = ${item.qty} x ${currencyFormatter.format(item.harga_produk)}')
          .join('\n');

      String qty = transaksi.items
          .map((item) => '${currencyFormatter.format(item.totalProduk)}')
          .join('\n');
      final data = await emspdfservice.generateEMSPDF(
        "${transaksi.nomor_unik}",
        transactionDate, // Assuming the transaction number is of String type
        "${transaksi.nama_pelanggan}",
        transactionItems, // Pass the prepared transaction items as a String
        qty, // Pass the prepared transaction items as a String
        currencyFormatter.format(transaksi.total_belanja),
        currencyFormatter.format(transaksi.uang_bayar),
        currencyFormatter.format(transaksi.uang_kembali),
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

  Widget buildProductDetailRow(TransactionItem item) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${item.nama_produk} x ${item.qty}',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey),
          ),
          Text(
            '${currencyFormatter.format(item.totalProduk)}',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
