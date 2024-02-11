import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_petshop/model.dart/TransaksiItem.dart';
import 'package:e_petshop/model.dart/transaksi.dart';
import 'package:get/get.dart';

class TransaksiController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Transaksi> transaksiList = <Transaksi>[].obs;
  RxBool shouldUpdate = false.obs;

  final CollectionReference transaksiCollection =
      FirebaseFirestore.instance.collection('transactions');

  Future<bool> addTransaksi(Transaksi transaksi) async {
    try {
      await transaksiCollection.add(transaksi.toMap());
      return true;
    } catch (e) {
      print('Error adding transaksi: $e');
      return false;
    }
  }

  Future<bool> addMultipleTransaksi(List<Transaksi> transaksiList) async {
    try {
      var batch = FirebaseFirestore.instance.batch();
      for (var transaksi in transaksiList) {
        batch.set(transaksiCollection.doc(), transaksi.toMap());
      }
      await batch.commit();
      return true;
    } catch (e) {
      print('Error adding multiple transaksi: $e');
      return false;
    }
  }

  Future<bool> deleteTransaksi(int nomorUnik) async {
    try {
      await _firestore
          .collection('transactions')
          .where('nomor_unik', isEqualTo: nomorUnik)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });

      shouldUpdate.toggle();
      return true;
    } catch (e) {
      print('Error deleting transaction: $e');
      return false;
    }
  }

  Future<bool> updateTransaksi(
    int nomorUnik,
    String nama_pelanggan,
    List<TransactionItem> items,
    double uang_bayar,
    double total_belanja,
    double uang_kembali,
    String updated_at,
  ) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('transactions')
          .where('nomor_unik', isEqualTo: nomorUnik)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String id = querySnapshot.docs.first.id;
        await _firestore.collection('transactions').doc(id).update({
          'nama_pelanggan': nama_pelanggan,
          'items': items.map((item) => item.toMap()).toList(),
          'uang_bayar': uang_bayar,
          'total_belanja': total_belanja,
          'uang_kembali': uang_kembali,
          'updated_at': updated_at,
        });

        shouldUpdate.toggle();
        return true;
      } else {
        throw Exception('Transaction not found for nomor_unik: $nomorUnik');
      }
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
      print('Error counting produk: $e');
      return 0;
    }
  }

  Future<Transaksi> getTransaksiByNomorUnik(int nomorUnik) async {
    try {
      QuerySnapshot querySnapshot = await transaksiCollection
          .where('nomor_unik', isEqualTo: nomorUnik)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Transaksi.fromMap(
            querySnapshot.docs.first.data() as Map<String, dynamic>);
      } else {
        throw Exception('Transaction not found for nomor_unik: $nomorUnik');
      }
    } catch (e) {
      print('Error getting transaction by nomor_unik: $e');
      rethrow;
    }
  }
}
