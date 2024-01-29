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
  final double uang_kembali;
  final String created_at;

  const TransaksiS({
    required this.nomor_unik,
    required this.nama_pelanggan,
    required this.harga_produk,
    required this.nama_produk,
    required this.uang_bayar,
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
    Future<Uint8List> resizeImage(
      Uint8List imageBytes, int newWidth, int newHeight) async {
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Gagal mendecode gambar.');
      }

      img.Image resizedImage =
          img.copyResize(image, width: newWidth, height: newHeight);

      Uint8List resizedImageBytes =
          Uint8List.fromList(img.encodePng(resizedImage));

      return resizedImageBytes;
    }

    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Colour.b,
        padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              "Transaksi Berhasil",
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: Column(
                children: [
                       Container(
            margin: EdgeInsets.only(top: 20),
            child: Column(
              children: [
                Container(
                  alignment: AlignmentDirectional.bottomStart,
                  child: Text(
                    "Rincian Pembelian",
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
                        "No. Struk",
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      Text(
                        "${widget.nomor_unik}",
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Nama Pembeli",
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      Text(
                        "${widget.nama_pelanggan}",
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Nama Barang",
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      Text(
                        "${widget.nama_produk}",
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Harga Satuan",
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      Text(
                        "${currencyFormatter.format(widget.harga_produk)}",
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                    ]),
                // Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text(
                //         "QTY",
                //         style: TextStyle(
                //             fontFamily: 'Poppins',
                //             fontSize: 13,
                //             fontWeight: FontWeight.bold,
                //             color: Colors.grey),
                //       ),
                //       Text(
                //         "${widget.qty}",
                //         style: TextStyle(
                //             fontFamily: 'Poppins',
                //             fontSize: 13,
                //             fontWeight: FontWeight.bold,
                //             color: Colors.grey),
                //       ),
                //     ]),
                // Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text(
                //         "Total Belanja",
                //         style: TextStyle(
                //             fontFamily: 'Poppins',
                //             fontSize: 13,
                //             fontWeight: FontWeight.bold,
                //             color: Colors.grey),
                //       ),
                //       Text(
                //         "${currencyFormatter.format(widget.totalBelanja)}",
                //         style: TextStyle(
                //             fontFamily: 'Poppins',
                //             fontSize: 13,
                //             fontWeight: FontWeight.bold,
                //             color: Colors.grey),
                //       ),
                //     ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Uang Bayar",
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      Text(
                        "${currencyFormatter.format(widget.uang_bayar)}",
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Uang Kembali",
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      Text(
                        "${currencyFormatter.format(widget.uang_kembali)}",
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                    ]),
              ],
            ),
          ),

                  Container(
                    margin: EdgeInsets.only(top: 20),
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          final data = await emspdfservice.generateEMSPDF(
                            "${widget.nomor_unik}",
                            "${widget.created_at}",
                            "${widget.nama_pelanggan}",
                            "${widget.nama_produk}",
                            "${currencyFormatter.format(widget.harga_produk)}",
                            "${currencyFormatter.format(widget.uang_bayar)}",
                            "${currencyFormatter.format(widget.uang_kembali)}",
                          );

                          await emspdfservice.savePdfFile(
                              "Invoice_Transactions", data);

                          Get.snackbar('Success', 'PDF saved successfully!');
                        } catch (e) {
                          print('Error: $e');
                          Get.snackbar('Error', 'Failed to save PDF');
                        }
                      },
                      child: const Text("Print"),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
