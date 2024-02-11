import 'package:e_petshop/controller/produkController.dart';
import 'package:e_petshop/pages/pagesProduk/produk_detail.dart';
import 'package:e_petshop/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProdukPage extends StatefulWidget {
  @override
  State<ProdukPage> createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  final ProdukController _produkController = Get.put(ProdukController());
  final currencyFormatter = NumberFormat.currency(locale: 'id', symbol: 'Rp ');
  final CollectionReference produkCollection =
      FirebaseFirestore.instance.collection('products');
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
            padding: const EdgeInsets.only(bottom: 4.3, left: 79.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Data Products',
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
                    queryProduk(value);
                  },
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: 'Cari Produk',
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
                 Text(
              'All Produk',
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
              stream: produkCollection.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final List<QueryDocumentSnapshot<Object?>> products =
                    snapshot.data!.docs;

                final filteredProducts = searchQuery.isEmpty
                    ? products
                    : products.where((produk) {
                        final nama =
                            produk['nama_produk'].toString().toLowerCase();
                        final harga =
                            produk['harga_produk'].toString().toLowerCase();
                        return nama.contains(searchQuery) || harga.contains(searchQuery);
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
                    var produkData =
                        filteredProducts[index].data() as Map<String, dynamic>;
                    String namaProduk = produkData['nama_produk'];
               
                    double hargaProduk =
                        produkData['harga_produk']?.toDouble() ?? 0.0;
                    String formattedProduk =
                        currencyFormatter.format(hargaProduk);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          Get.to(() => ProdukDetail(), arguments: {
                            'id': filteredProducts[index].id,
                            'nama_produk': namaProduk,
                            'harga_produk': hargaProduk,
                          });
                        },
                        
                        child: Card(
                          margin:
                              EdgeInsets.symmetric(horizontal: 22, vertical: 1),
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
                                      namaProduk,
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      formattedProduk,
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
                                      Get.to(() => ProdukDetail(), arguments: {
                                        'id': filteredProducts[index].id,
                                        'nama_produk': namaProduk,
                                      
                                        'harga_produk': hargaProduk,
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
          Get.offNamed('/produkcreate');
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
