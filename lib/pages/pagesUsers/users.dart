import 'package:e_petshop/controller/usersContoller.dart';
import 'package:e_petshop/pages/pagesUsers/user_detail.dart';
import 'package:e_petshop/pages/pagesUsers/users_create.dart';
import 'package:e_petshop/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersPage extends StatefulWidget {
  @override
  State<UsersPage> createState() => _UserPageState();
}

class _UserPageState extends State<UsersPage> {
  final UsersController _usersController = Get.put(UsersController());
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  var searchQuery = '';

  void queryUsers(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
 backgroundColor: Colour.b,
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
            Get.offNamed('/home');
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
                  'Data Users',
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (value) {
                    queryUsers(value);
                  },
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: 'Cari Users',
                    labelStyle: TextStyle(
                      color: Colour.primary,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                  Text(
              'All Users',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: usersCollection.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final List<QueryDocumentSnapshot<Object?>> users =
                    snapshot.data!.docs;

                final filteredProducts = searchQuery.isEmpty
                    ? users
                    : users.where((users) {
                        final title =
                            users['nama'].toString().toLowerCase();
                        return title.contains(searchQuery);
                      }).toList();
                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Text(
                      'Produk tidak ditemukan',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    var usersData =
                        filteredProducts[index].data() as Map<String, dynamic>;
                    String namaUsers = usersData['nama'];
                    String namaUsername = usersData['username'];
                    String roleUsers = usersData['role'];

                    return GestureDetector(
                      onTap: () {
                        Get.to(() => UserDetail(), arguments: {
                          'id': filteredProducts[index].id,
                          'nama': namaUsers,
                          'username': namaUsername,
                          'role': roleUsers,
                        });
                      },child: Card(
                          margin:
                              EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                     height: 90, // Adjust height as needed
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colour.primary, // Adjust color as needed
                                    ),
                                    padding: EdgeInsets.all(8),
                                  ),
                                  
                                  SizedBox(width: 10),
                                Expanded(
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 13.0),
                                    title: Text(
                                      namaUsers,
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      roleUsers,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: const Color.fromARGB(
                                            255, 88, 88, 88),
                                      ),
                                    ),
                                    trailing: CircleAvatar(
                                      child: Icon(
                                        Icons.edit,
                                        color: Colour.primary,
                                        size: 28.0,
                                      ),
                                    ),
                                    onTap: () {
                                      Get.to(() => UserDetail(), arguments: {
                                   'id': filteredProducts[index].id,
                              'nama': namaUsers,
                              'username': namaUsername,
                              'role': roleUsers,
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      // child: Card(
                      //   elevation: 9.0,
                      //   color: Colors.white,
                      //   shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(16.0),
                      //   ),
                      //   child: ListTile(
                      //     contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), 
                      //     // Adjust the padding here
                      //     title: Text(
                      //       namaUsers,
                      //       style: TextStyle(
                      //         fontSize: 18.0,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //     subtitle: Text(
                      //       roleUsers,
                      //       style: TextStyle(
                      //         fontSize: 14.0,
                      //         color: Color.fromARGB(255, 82, 82, 82),
                      //       ),
                      //     ),
                      //     trailing: CircleAvatar(
                      //       child: Icon(
                      //         Icons.edit,
                      //         color: Colour.primary,
                      //         size: 28.0,
                      //       ),
                      //     ),
                      //     onTap: () {
                      //       Get.to(() => UserDetail(), arguments: {
                      //         'id': filteredProducts[index].id,
                      //         'nama': namaUsers,
                      //         'username': namaUsername,
                      //         'role': roleUsers,
                      //       });
                      //     },
                      //   ),

                      // ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colour.primary,
        onPressed: () {
          Get.to(() => UserCreate());
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
