import 'package:e_petshop/controller/logController.dart';
import 'package:e_petshop/controller/usersContoller.dart';
import 'package:e_petshop/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final UsersController _usersController = Get.find<UsersController>();
  // final LogController _LogController = Get.find<LogController>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isObscure = true;

  void togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colour.b,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image(
              image: AssetImage(
                  'images/undraw_welcome_cats_thqn-removebg-preview.png'),
              height: 160,
            ),
            SizedBox(height: 20),
            Text(
              "PET-HOUSE",
              style: TextStyle(
                fontSize: 30,
                color: Colour.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Login here",
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(204, 118, 134, 224),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Username :",
              style: TextStyle(
                color: Colour.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(
                hintText: 'Ex: Nurul Eka',
                filled: true,
                fillColor: const Color.fromARGB(88, 170, 197, 180),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Password",
              style: TextStyle(
                color: Colour.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextFormField(
              controller: passwordController,
              obscureText: _isObscure,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () {
                    togglePasswordVisibility();
                  },
                  icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off),
                ),
                hintText: 'Ex: Ah%T&8#',
                filled: true,
                fillColor: const Color.fromARGB(88, 170, 197, 180),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight, // Align to the right
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colour.primary,
                  padding: EdgeInsets.symmetric(vertical: 18, horizontal: 60),
                ),
                onPressed: () {
                  String username = usernameController.text.trim();
                  String password = passwordController.text.trim();

                  if (username.isNotEmpty && password.isNotEmpty) {
                    _usersController.login(username, password);
                    // _addLog('Login');
                  } else {
                    Get.snackbar('Login Gagal', 'Silakan lengkapi form.');
                  }
                },
                child: Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> _addLog(String message) async {
  //   try {
  //     await _LogController.addLog(
  //         message); // Menambahkan log saat tombol ditekan
  //     print('Log added successfully!');
  //   } catch (e) {
  //     print('Failed to add log: $e');
  //   }
  // }
}
