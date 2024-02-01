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
        child: Container(
          width: double.infinity,
          color: Colour.b,
          padding: EdgeInsets.fromLTRB(20, 120, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Transaksi Berhasil",
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              _buildTransactionDetails(currencyFormatter),
              SizedBox(height: 20),
              _buildButtons(currencyFormatter),
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        _buildDetailRow("No. Struk", "${widget.nomor_unik}"),
        _buildDetailRow("Nama Pembeli", "${widget.nama_pelanggan}"),
        _buildDetailRow("Nama Barang", "${widget.nama_produk}"),
        _buildDetailRow(
            "Harga Satuan", currencyFormatter.format(widget.harga_produk)),
        _buildDetailRow("jumlah", "${widget.qty}"),
        _buildDetailRow(
            "Total Harga", currencyFormatter.format(widget.total)),
        _buildDetailRow("Uang Bayar", currencyFormatter.format(widget.uang_bayar)),
        _buildDetailRow(
            "Uang Kembali", currencyFormatter.format(widget.uang_kembali)),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(NumberFormat currencyFormatter) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
          ),
          onPressed: () async {
            await _printReceipt(currencyFormatter);
          },
          child: Text(
            "Print",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colour.primary,
          ),
          onPressed: () {
            Get.offNamed('/transaksi');
          },
          child: Text(
            "Selesai",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
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

      Get.snackbar('Success', 'PDF saved successfully!');
    } catch (e) {
      print('Error: $e');
      Get.snackbar('Error', 'Failed to save PDF');
    }
  }
}
