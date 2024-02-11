import 'package:e_petshop/controller/logController.dart';
import 'package:e_petshop/controller/usersContoller.dart';
import 'package:e_petshop/pages/pagesUsers/user_password.dart';
import 'package:e_petshop/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserDetail extends StatefulWidget {
  const UserDetail({super.key});

  @override
  State<UserDetail> createState() => _UserDetailState();
}

class _UserDetailState extends State<UserDetail> {
  final UsersController _UsersController = Get.put(UsersController());
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final LogController logController = LogController();

  String? _selectedRole;

  List<String> _roles = ['Admin', 'Kasir', 'Owner'];

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic>? args = Get.arguments;
    _selectedRole = args?['role'] ?? null;
    if (_selectedRole != null) {
      (_selectedRole);
    }
  }

  bool _isObscure = true;

  void togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args = Get.arguments;
    final String id = args?['id'] ?? '';
    final String name = args?['nama'] ?? '';
    final String username = args?['username'] ?? '';

    nameController.text = name;
    usernameController.text = username;

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
              padding: const EdgeInsets.only(bottom: 4.3, left: 85.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Detail Users',
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
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Exm. Renaldi Nurmazid',
                  label: Text(
                    'Nama Lengkap',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  filled: true,
                  fillColor: Colour.secondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  hintText: 'Exm. Renaldi Nurmazid',
                  label: Text(
                    'Username',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  filled: true,
                  fillColor: Colour.secondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
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
                alignment: AlignmentDirectional.centerStart,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colour.primary,
                        ),
                        onPressed: () {
                          String name = nameController.text.trim();
                          String username = usernameController.text.trim();
                          String updated_at = DateTime.now().toString();

                          if (username.isNotEmpty &&
                              name.isNotEmpty &&
                              _selectedRole != null) {
                            String userId = id;
                            _UsersController.updateUser(userId, _selectedRole!,
                                name, username, updated_at);
                            Get.back();
                            _addLog('Updated user');
                          } else {
                            Get.snackbar('Error', 'Please fill all fields');
                          }
                        },
                        child: Text(
                          "Submit",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins'),
                        )),
                    ElevatedButton(
                      onPressed: () async {
                        bool confirmDelete = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Konfirmasi"),
                              content: Text(
                                  "Apakah Anda yakin ingin menghapus produk ini?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(true); // User confirms deletion
                                  },
                                  child: Text("Ya"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(false); // User cancels deletion
                                  },
                                  child: Text("Tidak"),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmDelete == true) {
                          bool success = await _UsersController.deleteUser(id);
                          if (success) {
                            Get.back(); // Kembali ke halaman produk
                            Get.snackbar('Success', 'Berhasil delete');
                          } else {
                            Get.snackbar(
                                'Failed', 'Failed to delete transaction');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text(
                        "Hapus",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 201, 253, 13),
                        ),
                        onPressed: () async {
                          String userId =
                              id; // Assuming id is the correct user ID
                          Get.to(() => UserPassword(userId: userId));
                        },
                        child: Text(
                          "Password",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins'),
                        )),
                  ],
                ),
              )
            ],
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
}
