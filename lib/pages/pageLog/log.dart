import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_petshop/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final CollectionReference logsCollection =
      FirebaseFirestore.instance.collection('logs');
  var refreshFlag = false;
  var searchQuery = '';

  void queryProduk(String query) {
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
              padding: const EdgeInsets.only(bottom: 4.3, left: 95.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'History',
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
          child: Column(children: [
            TextField(
              onChanged: (value) {
                queryProduk(value);
              },
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Poppins',
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Search users',
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
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: logsCollection.snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final List<DocumentSnapshot> logs = snapshot.data!.docs;

                  final filteredlogs = searchQuery.isEmpty
                      ? logs
                      : logs.where((logs) {
                          final name =
                              logs['username'].toString().toLowerCase();

                          return name.contains(searchQuery);
                        }).toList();
                  if (filteredlogs.isEmpty) {
                    return Center(
                      child: Text(
                        'Log tidak ditemukan',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredlogs.length,
                    itemBuilder: (context, index) {
                      var logsData =
                          filteredlogs[index].data() as Map<String, dynamic>;
                      String name = logsData['username'];
                      String activity = logsData['activity'];
                      String tanggal = logsData['created_at'];

                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 3, vertical: 4),
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
                                  color:
                                      Colour.primary, // Adjust color as needed
                                ),
                                padding: EdgeInsets.all(8),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                    vertical: 13.0,
                                  ),
                                  title: Text(
                                    '$name -> $activity',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    tanggal,
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color:
                                          const Color.fromARGB(255, 88, 88, 88),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ]),
        ));
  }
}
