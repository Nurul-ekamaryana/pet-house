import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_petshop/model.dart/transaksi.dart';
import 'package:get/get.dart';

class TransaksiController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Transaksi> transaksiList = <Transaksi>[].obs;
  RxBool shouldUpdate = false.obs;

  Future<bool> addTransaksi(Transaksi transaksi) async {
    try {
      await _firestore.collection('transactions').add(transaksi.toMap());
      shouldUpdate.toggle();
      return true;
    } catch (e) {
      print('Error adding transaction: $e');
      return false;
    }
  }

  Future<bool> deleteTransaksi(String id) async {
    try {
      await _firestore.collection('transactions').doc(id).delete();
      shouldUpdate.toggle();
      return true;
    } catch (e) {
      print('Error deleting transaction: $e');
      return false;
    }
  }

  Future<bool> updateTransaksi(
    String id,
    String namaPembeli,
    String selectedProduct,
    double hargaProduk,
    double uangBayar,
    int qty,
    double total,
    double uangKembali,) async {
    try {
      await _firestore.collection('transactions').doc(id).update({
        'nama_pelanggan': namaPembeli,
        'nama_produk': selectedProduct,
        'harga_produk': hargaProduk,
        'qty': qty,
        'total': total,
        'uang_bayar': uangBayar,
        'uang_kembali': uangKembali,
        'updated_at': DateTime.now().toString(),
      });
      shouldUpdate.toggle();
      return true;
    } catch (e) {
      print('Error updating transaction: $e');
      return false;
    }
  }

  void clearTransaksiList() {
    transaksiList.clear();
  }

  Future<int> countTransaksi() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('transactions').get();
      return querySnapshot.size;
    } catch (e) {
      print('Error counting books: $e');
      return 0;
    }
  }
}
