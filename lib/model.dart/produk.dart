import 'dart:math';

class Produk {
  final String nama_produk;
  final String jenis;
  final String ciri_has;
  final String created_at;
  final String updated_at;
  final double harga_produk;

  Produk({
    required this.nama_produk,
    required this.jenis,
    required this.ciri_has,
    required this.harga_produk,
    required this.created_at,
    required this.updated_at,
  });

  Map<String, dynamic> toMap() {
    return {
      'nama_produk': nama_produk,
      'jenis': jenis,
      'ciri_has': ciri_has,
      'harga_produk': harga_produk,
      'created_at': created_at,
      'updated_at': updated_at,
    };
  }
}
