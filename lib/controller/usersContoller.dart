import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_petshop/model.dart/users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum UserRole { Admin, Kasir, Owner }

class UsersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> firebaseUser = Rx<User?>(null);

  RxString userName = RxString('');
  RxString userId = RxString('');

  Rx<UserRole> userRole = UserRole.Admin.obs;

  get role => null;

  UserRole getCurrentUserRole() {
    return userRole.value;
  }

  Future<void> login(String username, String password) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> userData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        String role = userData['role'];

        Users user = Users.fromJson(
            querySnapshot.docs.first.data() as Map<String, dynamic>);
        userName.value = user.nama;

        switch (role.toLowerCase()) {
          case 'admin':
            userRole.value = UserRole.Admin;
            break;
          case 'kasir':
            userRole.value = UserRole.Kasir;
            break;
          case 'owner':
            userRole.value = UserRole.Owner;
            break;
          default:
            userRole.value = UserRole.Admin;
            break;
        }
        Get.offNamed('/home');
        Get.snackbar(
          'Login Success',
          'Anda Adalah ${querySnapshot.docs.first['nama']}',
        );
      } else {
        Get.snackbar(
          'Login Error',
          'login gagal silahkan coba lagi',
        );
      }
    } catch (e) {
      Get.snackbar(
        'Login Error',
        e.toString(),
      );
    }
  }

  Future<void> signOut() async {
    Get.defaultDialog(
      title: "Logout Confirmation",
      middleText: "Yakin akan keluar dari halaman?",
      actions: [
        ElevatedButton(
          onPressed: () {
            Get.back(); // Close the dialog
          },
          child: Text("Tidak"),
        ),
        ElevatedButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Get.offNamed('/splash');
            Get.snackbar('Sign Out', 'You have been signed out');
          },
          child: Text("Ya"),
        ),
      ], // Add this closing bracket
    );
  }

  Future<void> register(String password, String role, String nama,
      String username, String created_at, String updated_at) async {
    try {
      Users newUser = Users(
        password: password,
        role: role,
        nama: nama,
        username: username,
        created_at: created_at,
        updated_at: updated_at,
      );

      await _firestore.collection('users').add(newUser.toJson());
    } catch (e) {
      Get.snackbar('Registration Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> updateUser(String userId, String role, String nama,
      String username, String updated_at) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': role,
        'nama': nama,
        'username': username,
        'updated_at': updated_at,
      });
      Get.snackbar('Success', 'User data updated successfully');
    } catch (e) {
      Get.snackbar('Update Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> updatePassword(
      String userId, String newPassword, String confirmPassword) async {
    try {
      if (newPassword == confirmPassword) {
        await _firestore.collection('users').doc(userId).update({
          'password': newPassword,
        });
        Get.snackbar('Success', 'Password updated successfully');
      } else {
        Get.snackbar(
            'Update Error', 'Password and Confirm Password do not match');
      }
    } catch (e) {
      Get.snackbar('Update Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<bool> deleteUser(String id) async {
    try {
      await _firestore.collection('users').doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting book: $e');
      return false;
    }
  }

  Future<int> countUsers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.size;
    } catch (e) {
      print('Error counting books: $e');
      return 0;
    }
  }
}
