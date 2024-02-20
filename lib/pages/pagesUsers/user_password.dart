import 'package:e_petshop/controller/usersContoller.dart';
import 'package:e_petshop/pages/pagesUsers/user_detail.dart';
import 'package:e_petshop/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserPassword extends StatefulWidget {
  final String userId;

  UserPassword({required this.userId});

  @override
  _UserPasswordState createState() => _UserPasswordState();
}

class _UserPasswordState extends State<UserPassword> {
  final UsersController _usersController = UsersController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colour.primary,
        toolbarHeight: 120,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        leading: IconButton(
          color: Colors.white,
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back),
        ),
        actions: [],
        title: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4.3, left: 70.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ganti Password',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'OpenSans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            buildPasswordField(
                passwordController, 'Password Baru', _obscurePassword),
            SizedBox(height: 20),
            buildPasswordField(
                confirmController, 'Ulangi Password', _obscureConfirmPassword),
            SizedBox(height: 20),
            Container(
              alignment: AlignmentDirectional.centerStart,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colour.primary,
                    ),
                    onPressed: () {
                      String newPassword = passwordController.text.trim();
                      String confirmNewPassword = confirmController.text.trim();
                      if (newPassword.isNotEmpty &&
                          confirmNewPassword.isNotEmpty) {
                        if (newPassword == confirmNewPassword) {
                          _usersController.updatePassword(
                              widget.userId, newPassword, confirmNewPassword);
                          Get.back();
                        } else {
                          Get.snackbar(
                            'Password Gagal',
                            'Ganti Pasword gagal silahkan coba lagi',
                          );
                        }
                      } else {
                        Get.snackbar(
                          'Password Gagal',
                          'Ganti Pasword gagal silahkan coba lagi',
                        );
                      }
                    },
                    child: Text(
                      "Submit",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPasswordField(
      TextEditingController controller, String label, bool obscure) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: '***',
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          fontFamily: 'Poppins',
        ),
        filled: true,
        fillColor: Colour.secondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              if (controller == passwordController) {
                _obscurePassword = !_obscurePassword;
              } else if (controller == confirmController) {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              }
            });
          },
        ),
      ),
    );
  }
}
