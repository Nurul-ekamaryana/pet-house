import 'dart:io';
import 'dart:typed_data';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class EmsPdfService {
  Future<Uint8List> generateEMSPDF(
    String noTransaksi,
    String tanggal,
    String namaPelanggan,
    String namaProduk,
    String hargaProduk,
    String qty,
    String total,
    String uangBayar,
    String uangKembali,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(
                alignment: pw.Alignment.topCenter,
                child: pw.Center(
                  child: pw.Text(
                    "PET HOUSE",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 26,
                    ),
                  ),
                ),
              ),
              pw.Container(
                alignment: pw.Alignment.topCenter,
                child: pw.Center(
                  child: pw.Text(
                    "Jl. Sukamelang Perum.BAP",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                margin: pw.EdgeInsets.symmetric(vertical: 10),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      noTransaksi,
                      style: pw.TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    pw.Text(
                      tanggal,
                      style: pw.TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Divider(thickness: 2),
              pw.SizedBox(
                height: 20,
              ),
              pw.Container(
                margin: pw.EdgeInsets.symmetric(vertical: 5),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Nama Pelanggan : ",
                      style: pw.TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    pw.Text(
                      namaPelanggan,
                      style: pw.TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Container(
                margin: pw.EdgeInsets.symmetric(vertical: 5),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Nama Barang : ",
                      style: pw.TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    pw.Text(
                      namaProduk,
                      style: pw.TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Container(
                margin: pw.EdgeInsets.symmetric(vertical: 5),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Harga Barang : ",
                      style: pw.TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    pw.Text(
                      hargaProduk,
                      style: pw.TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Container(
                margin: pw.EdgeInsets.symmetric(vertical: 5),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Jumlah : ",
                      style: pw.TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    pw.Text(
                      qty,
                      style: pw.TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(
                height: 20,
              ),
              pw.Divider(thickness: 2),
              pw.Container(
                margin: pw.EdgeInsets.symmetric(vertical: 20),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Total : ",
                      style: pw.TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    pw.Text(
                      total,
                      style: pw.TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Container(
                margin: pw.EdgeInsets.symmetric(vertical: 5),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Uang Bayar : ",
                      style: pw.TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    pw.Text(
                      uangBayar,
                      style: pw.TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Divider(thickness: 2),
              pw.Container(
                margin: pw.EdgeInsets.symmetric(vertical: 20),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Uang Kembali: $uangKembali",
                      style: pw.TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Container(
                margin: pw.EdgeInsets.symmetric(vertical: 10),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      "-Terima Kasih Sudah Berbelanja-",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> savePdfFile(String fileName, Uint8List byteList) async {
    final output = await getTemporaryDirectory();
    var filePath = "${output.path}/$fileName.pdf";
    final file = File(filePath);
    await file.writeAsBytes(byteList);
    await OpenFile.open(filePath);
  }
}
