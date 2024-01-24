import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../theme/color.dart';

class PdfGenerator {
  static Future<Uint8List> generatePdf() async {
    final pdf = pw.Document();

    // Add a page to the PDF
    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return _buildPdfContent(context);
      },
    ));

    // Save the PDF as bytes
    return pdf.save();
  }

  static pw.Widget _buildPdfContent(pw.Context context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id', symbol: 'Rp ');

    var widget;
    return pw.Container(
      width: double.infinity,
      color: PdfColor.fromHex(Colour.b as String),
      padding: pw.EdgeInsets.fromLTRB(20, 120, 20, 0),
      child: pw.Column(
        children: [
          pw.SizedBox(height: 20),
          pw.Text(
            "Transaksi Berhasil",
            style: pw.TextStyle(
              // fontFamily: 'OpenSans',
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            "TERIMA KASIH TELAH BERBELANJA",
            style: pw.TextStyle(
              // fontFamily: 'OpenSans',
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Container(
            margin: pw.EdgeInsets.only(top: 20),
            child: pw.Column(
              children: [
                pw.Container(
                  alignment: pw.AlignmentDirectional.bottomStart,
                  child: pw.Text(
                    "Rincian Pembelian",
                    style: pw.TextStyle(
                      // fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                _buildRow("Nama Pembeli", "${widget.nama_pelanggan}"),
                _buildRow("Nama Produk", "${widget.nama_produk}"),
                _buildRow("Harga Produk", "${currencyFormatter.format(widget.harga_produk)}"),
              ],
            ),
          ),
          // pw.Container(
          //   margin: pw.EdgeInsets.only(top: 20),
          //   width: double.infinity,
          //   height: 50,
          //   child: pw.ElevatedButton(
          //     style: pw.ElevatedButton.styleFrom(backgroundColor: PdfColor.fromHex(Colour.primary)),
          //     onPressed: () {},
          //     child: pw.Text(
          //       "Selesai",
          //       style: pw.TextStyle(
          //         fontFamily: 'Poppins',
          //         fontSize: 16,
          //         fontWeight: pw.FontWeight.bold,
          //         color: PdfColor.fromHex('#FFFFFF'),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  static pw.Widget _buildRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            // fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#808080'),
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            // fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#808080'),
          ),
        ),
      ],
    );
  }
}
