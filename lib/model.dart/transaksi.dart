class Transaksi {
  final int nomor_unik;
  final String nama_pelanggan;
  final String nama_produk;
  final double harga_produk;
  final double uang_bayar;
  final double uang_kembali;

  Transaksi({
    required this.nomor_unik,
    required this.nama_pelanggan,
    required this.nama_produk,
    required this.harga_produk,
    required this.uang_bayar,
    required this.uang_kembali,
    required String creatad_at,
    required String updated_at,
  });

  Map<String, dynamic> toMap() {
    return {
      'nomor_unik': nomor_unik,
      'nama_pelanggan': nama_pelanggan,
      'nama_produk': nama_produk,
      'harga_produk': harga_produk,
      'uang_bayar': uang_bayar,
      'uang_kembali': uang_kembali,
      'creatad_at': DateTime.now().toString(),
      'updated_at': DateTime.now().toString(),
    };
  }
}
