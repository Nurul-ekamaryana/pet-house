import 'dart:convert';
import 'dart:typed_data';

import 'package:e_petshop/controller/usersContoller.dart';
import 'package:e_petshop/pdf/pdf.dart';
import 'package:e_petshop/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;

class TransaksiS extends StatefulWidget {
  final int nomor_unik;
  final String nama_pelanggan;
  final String nama_produk;
  final double harga_produk;
  final double uang_bayar;
  final int qty;
  final double total;
  final double uang_kembali;
  final String created_at;

  const TransaksiS({
    required this.nomor_unik,
    required this.nama_pelanggan,
    required this.harga_produk,
    required this.nama_produk,
    required this.uang_bayar,
    required this.qty,
    required this.total,
    required this.uang_kembali,
    required this.created_at, 
  });

  @override
  State<TransaksiS> createState() => _TransaksiSState();
}

class _TransaksiSState extends State<TransaksiS> {
  final UsersController _UsersController = Get.find<UsersController>();
  final EmsPdfService emspdfservice = EmsPdfService();
  List _orders = [];

  Future<void> readJson() async {
    final String response = await rootBundle.loadString("assets/orders.json");
    final data = await json.decode(response);
    setState(() {
      _orders = data['records'];
    });
  }

  @override
  void initState() {
    super.initState();
    readJson();
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
        _buildDetailRow("No. Struk", "${widget.nomor_unik}"),
        _buildDetailRow("Nama Pembeli", "${widget.nama_pelanggan}"),
        _buildDetailRow("Nama Barang", "${widget.nama_produk}"),
        _buildDetailRow(
          "Harga Satuan",
          currencyFormatter.format(widget.harga_produk),
        ),
        _buildDetailRow("Jumlah", "${widget.qty}"),
        _buildDetailRow(
          "Total Harga",
          currencyFormatter.format(widget.total),
        ),
        _buildDetailRow(
          "Uang Bayar",
          currencyFormatter.format(widget.uang_bayar),
        ),
        _buildDetailRow(
          "Uang Kembali",
          currencyFormatter.format(widget.uang_kembali),
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
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
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
            primary: Colors.black,
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          ),
          onPressed: () async {
            await _printReceipt(currencyFormatter);
          },
          child: Text(
            "Print",
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
            primary: Colour.primary,
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
      String formattedDate =
          DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.created_at));
      final data = await emspdfservice.generateEMSPDF(
        "${widget.nomor_unik}",
        formattedDate,
        "${widget.nama_pelanggan}",
        "${widget.nama_produk}",
        currencyFormatter.format(widget.harga_produk),
        "${widget.qty}",
        currencyFormatter.format(widget.total),
        currencyFormatter.format(widget.uang_bayar),
        currencyFormatter.format(widget.uang_kembali),
      );

      await emspdfservice.savePdfFile("Invoice_Transactions", data);

      Get.snackbar('Success', 'PDF saved successfully!',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      print('Error: $e');
      Get.snackbar('Error', 'Failed to save PDF',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
