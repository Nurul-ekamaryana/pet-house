import 'package:e_petshop/controller/logController.dart';
import 'package:e_petshop/controller/produkController.dart';
import 'package:e_petshop/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProdukDetail extends StatelessWidget {
  final ProdukController _produkController = Get.put(ProdukController());
  final LogController _LogController = Get.put(LogController());
  final TextEditingController namaController = TextEditingController();
  // final TextEditingController jenisController = TextEditingController();
  // final TextEditingController jkController = TextEditingController();
  // final TextEditingController cirihasController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args = Get.arguments;
    final String id = args?['id'] ?? '';
    final String nama_produk = args?['nama_produk'] ?? '';
    // final String jenis = args?['jenis'] ?? '';
    // final String ciri_has = args?['ciri_has'] ?? '';
    final double harga_produk = args?['harga_produk'] ?? 0.0;

    // Atur nilai ke controller
    namaController.text = nama_produk;
    // jenisController.text = jenis;
    // cirihasController.text = ciri_has;
    hargaController.text = harga_produk.toStringAsFixed(0);

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
            Get.offNamed('/produk');
          },
          icon: Icon(Icons.arrow_back),
        ),
        actions: [],
        title: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4.3, left: 65.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Detai Produk',
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
              TextField(
                controller: namaController,
                decoration: InputDecoration(
                  hintText: 'Contoh: Kucing Angora',
                  labelText: 'Nama Produk/Hewan',
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
              ),
              // SizedBox(height: 20),
              // TextField(
              //   controller: jenisController,
              //   decoration: InputDecoration(
              //     hintText: 'Contoh: Anggora',
              //     labelText: 'Jenis',
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
              //   controller: cirihasController,
              //   decoration: InputDecoration(
              //     hintText: 'Contoh: Warna Hijau',
              //     labelText: 'Ciri Has',
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
              SizedBox(height: 20),
              TextField(
                controller: hargaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Contoh: Rp. 100.000',
                  labelText: 'Harga',
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
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        String nama_produk = namaController.text.trim();

                        // String jenis = jenisController.text.trim();
                        // String cirihas = cirihasController.text.trim();
                        double harga_produk =
                            double.tryParse(hargaController.text.trim()) ?? 0.0;
                        String updated_at = DateTime.now().toString();
                        if (nama_produk.isNotEmpty && harga_produk > 0) {
                          await _produkController.updateProduk(
                            id,
                            namaController.text,
                            double.parse(hargaController.text),
                            updated_at,
                          );
                          _produkController.shouldUpdate.value = true;
                          Get.back();
                          _addLog("Updated Produk");
                          Get.snackbar(
                              'Success', 'produk updated successfully!');
                        } else {
                          Get.snackbar('Failed',
                              'Gagal memperbarui buku, silakan periksa kembali form.');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colour.primary),
                      child: Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
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
                        bool success = await _produkController.deleteProduk(id);
                        if (success) {
                          _produkController.shouldUpdate.value = true;
                          Get.back(); // Kembali ke halaman produk
                          _addLog("Menahapus produk");
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addLog(String message) async {
    try {
      await _LogController.addLog(
          message); // Menambahkan log saat tombol ditekan
      print('Log added successfully!');
    } catch (e) {
      print('Failed to add log: $e');
    }
  }
}
