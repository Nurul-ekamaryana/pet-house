import 'package:e_petshop/model.dart/TransaksiItem.dart';

class Transaksi {
  final int nomor_unik;
  final String nama_pelanggan;
  final List<TransactionItem> items;
  final double total_belanja;
  final double uang_bayar;
  final double uang_kembali;

  Transaksi({
    required this.nomor_unik,
    required this.nama_pelanggan,
    required this.items,
    required this.total_belanja,
    required this.uang_bayar,
    required this.uang_kembali,
    required String creatad_at,
    required String updated_at,
  });

  get waktu_transaksi => null;

  Map<String, dynamic> toMap() {
    return {
      'nomor_unik': nomor_unik,
      'nama_pelanggan': nama_pelanggan,
      'items': items.map((item) => item.toMap()).toList(),
      'total_belanja': total_belanja,
      'uang_bayar': uang_bayar,
      'uang_kembali': uang_kembali,
      'creatad_at': DateTime.now().toString(),
      'updated_at': DateTime.now().toString(),
    };
  }

  factory Transaksi.fromMap(Map<String, dynamic> map) {
    return Transaksi(
      nomor_unik: map['nomor_unik'],
      nama_pelanggan: map['nama_pelanggan'],
      items: List<TransactionItem>.from(
          map['items']?.map((x) => TransactionItem.fromMap(x))),
      uang_bayar: map['uang_bayar'],
      total_belanja: map['total_belanja'],
      uang_kembali: map['uang_kembali'],
      creatad_at: map['creatad_at'],
      updated_at: map['updated_at'],
    );
  }
}
