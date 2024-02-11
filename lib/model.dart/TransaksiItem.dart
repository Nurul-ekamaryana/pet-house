class TransactionItem {
  final String id_produk;
  final String nama_produk;
  final double harga_produk;
  final int qty;
  final double totalProduk;

  TransactionItem({
    required this.id_produk,
    required this.nama_produk,
    required this.harga_produk,
    required this.qty,
    required this.totalProduk,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_produk': id_produk,
      'nama_produk': nama_produk,
      'harga_produk': harga_produk,
      'qty': qty,
      'totalProduk': totalProduk,
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id_produk: map['id_produk'],
      nama_produk: map['nama_produk'],
      harga_produk: map['harga_produk'],
      qty: map['qty'],
      totalProduk: map['totalProduk'],
    );
  }
}
