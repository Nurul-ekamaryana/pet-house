// import 'package:bacabox/model/book.dart';
import 'package:e_petshop/model.dart/produk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ProdukController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxBool shouldUpdate = false.obs;

//Create Produk
  Future<bool> addProduk(Produk produk) async {
    try {
      await _firestore.collection('products').add(produk.toMap());
      print('Produk Behasil Dibuat');
      shouldUpdate.toggle();
      return true;
    } catch (e) {
      print('Error adding Produk: $e');
      return false;
    }
  }

//Delete Produk
  Future<bool> deleteProduk(String id) async {
    try {
      await _firestore.collection('products').doc(id).delete();
      print('Produk Berhasil Di Hapus');
      shouldUpdate.toggle();
      return true;
    } catch (e) {
      print('Error deleting produk: $e');
      return false;
    }
  }

  

//Update Peoduk
  Future<bool> updateProduk(String id, String newNamaProduk, double newHargaProduk, String updated_at) async {
    try {
      await _firestore.collection('products').doc(id).update({
        'nama_produk': newNamaProduk,
        // 'jenis': newJenis,
        // 'ciri_has': newCiriHas,
        'harga_produk': newHargaProduk,
        'updated_at': updated_at,
      });
      print('Produk Berhasil Di Ubah');
      return true;
    } catch (e) {
      print('Error updating produk: $e');
      return false;
    }
  }

  Future<int> countProduk() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('products').get();
      return querySnapshot.size;
    } catch (e) {
      print('Error counting books: $e');
      return 0;
    }
  }
}