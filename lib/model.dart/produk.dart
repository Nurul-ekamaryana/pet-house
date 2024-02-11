import 'dart:math';

class Produk {
  final String id;
  final String nama_produk;
  final String created_at;
  final String updated_at;
  final double harga_produk;

  Produk({
    required this.id,
    required this.nama_produk,
    required this.harga_produk,
    required this.created_at,
    required this.updated_at,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_produk': nama_produk,
      'harga_produk': harga_produk,
      'created_at': created_at,
      'updated_at': updated_at,
    };
  }
}
