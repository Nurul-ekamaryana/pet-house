import 'package:e_petshop/controller/usersContoller.dart';
import 'package:e_petshop/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserPassword extends StatelessWidget {
  final UsersController _usersController = UsersController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  final String userId; // Add userId property

  UserPassword({required this.userId}); // Constructor to receive userId

  @override
  Widget build(BuildContext context) {
         

    // Removed the arguments retrieval since userId is passed in the constructor
    // final Map<String, dynamic>? args = Get.arguments;
    // final String userId = args?['userId'] ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colour.b,
        title: Text(
          'Ganti Password',
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                hintText: 'Enter new password',
                label: Text(
                  'New Password',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: confirmController,
              decoration: InputDecoration(
                hintText: 'Confirm new password',
                label: Text(
                  'Confirm Password',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
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
                              userId, newPassword, confirmNewPassword);
                        } else {
                          print('Passwords do not match');
                        }
                      } else {
                        print('Please fill in all fields correctly');
                      }

                      Get.back();
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
}
