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
      String nama_pelanggan,
      String nama_produk,
      double harga_produk,
      String jenis,
      String cirihas,
      double uang_bayar,
      double uang_kembali) async {
    try {
      await _firestore.collection('transactions').doc(id).update({
        'nama_pelanggan': nama_pelanggan,
        'nama_produk': nama_produk,
        'harga_produk': harga_produk,
        'jenis': jenis,
        'ciri_has': cirihas,
        'uang_bayar': uang_bayar,
        'uang_kembali': uang_kembali,
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
