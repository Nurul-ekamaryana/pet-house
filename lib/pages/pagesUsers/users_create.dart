import 'package:e_petshop/controller/logController.dart';
import 'package:e_petshop/controller/usersContoller.dart';
import 'package:e_petshop/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserCreate extends StatefulWidget {
  const UserCreate({super.key});

  @override
  State<UserCreate> createState() => _UserCreateState();
}

class _UserCreateState extends State<UserCreate> {
  final UsersController _userController = Get.put(UsersController());
  final TextEditingController namaController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  final LogController logController = LogController();
  String? _selectedRole;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  List<String> _roles = ['Admin', 'Kasir', 'Owner'];

  bool _isObscure = true;

  void togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    void _createUsername(String value) {
      String username = value.toLowerCase().replaceAll(' ', '');
      usernameController.text = username;
    }

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
              Get.offNamed('/users');
            },
            icon: Icon(Icons.arrow_back),
          ),
          actions: [],
          title: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4.3, left: 59.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Create users',
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
        body: SingleChildScrollView(
          child: Container(
            color: Colour.b,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // TextField(
                //   controller: namaController,
                //   // onChanged: (value) {
                //   //     _createUsername(value);
                //   //   },
                //   decoration: InputDecoration(
                //     hintText: 'Ex. Eka Maryana',
                //     labelText: 'Nama User',
                //     labelStyle: TextStyle(
                //       color: Colors.black,
                //       fontWeight: FontWeight.bold,
                //       fontSize: 16,
                //       fontFamily: 'Poppins',
                //     ),
                //     filled: true,
                //     fillColor: Colour.secondary,
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(10),
                //       borderSide: BorderSide.none,
                //     ),
                //   ),
                // ),
                buildField(namaController, 'Nama Users', _isObscure),
                SizedBox(height: 20),
                buildField(usernameController, 'Username', _isObscure),
                SizedBox(height: 20),
                buildPasswordField(
                    passwordController, 'Password', _obscurePassword),
                // SizedBox(height: 20),
                // TextField(
                //   controller: usernameController,
                //   // enabled: false,
                //   decoration: InputDecoration(
                //     hintText: 'Ex. Eka02',
                //     labelText: 'Username',
                //     labelStyle: TextStyle(
                //       color: Colors.black,
                //       fontWeight: FontWeight.bold,
                //       fontSize: 16,
                //       fontFamily: 'Poppins',
                //     ),
                //     filled: true,
                //     fillColor: Colour.secondary,
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(10),
                //       borderSide: BorderSide.none,
                //     ),
                //   ),
                // ),
                // SizedBox(height: 20),
                // TextField(
                //   controller: passwordController,
                //   obscureText: _isObscure,
                //   decoration: InputDecoration(
                //     suffixIcon: IconButton(
                //       icon: Icon(
                //           _isObscure ? Icons.visibility : Icons.visibility_off),
                //       onPressed: togglePasswordVisibility,
                //     ),
                //     hintText: '***',
                //     label: Text(
                //       'Password',
                //       style: TextStyle(
                //         color: Colors.black,
                //         fontWeight: FontWeight.bold,
                //         fontSize: 16,
                //         fontFamily: 'Poppins',
                //       ),
                //     ),
                //     filled: true,
                //     fillColor: Colour.secondary,
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(10),
                //       borderSide: BorderSide.none,
                //     ),
                //   ),
                // ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<String>(
                    hint: Text('Pilih Role'),
                    value: _selectedRole,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRole = newValue;
                      });
                    },
                    items: _roles.map((role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                  ),
                ),

                SizedBox(height: 20),
                Container(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        backgroundColor: Colour.primary,
                      ),
                      onPressed: () async {
                        String password = passwordController.text.trim();
                        String name = namaController.text.trim();
                        String username = usernameController.text.trim();
                        String created_at = DateTime.now().toString();
                        String updated_at = DateTime.now().toString();

                        if (username.isNotEmpty &&
                            password.isNotEmpty &&
                            name.isNotEmpty &&
                            _selectedRole != null) {
                          _userController.register(password, _selectedRole!,
                              name, username, created_at, updated_at);
                          Get.back();
                          Get.snackbar('Success', 'User created successfully!');
                          _addLog('Created new user');
                        } else {
                          Get.snackbar('Error', 'Please fill in all fields');
                        }
                      },
                      child: Text(
                        "Submit",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins'),
                      )),
                )
              ],
            ),
          ),
        ));
  }

  Future<void> _addLog(String activity) async {
    try {
      await logController.addLog(activity);
      print('Log added successfully!');
    } catch (e) {
      print('Failed to add log: $e');
    }
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

Widget buildField(
    TextEditingController controller, String label, bool obscure) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
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
    ),
  );
}
