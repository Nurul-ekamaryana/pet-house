import 'package:e_petshop/controller/logController.dart';
import 'package:e_petshop/controller/produkController.dart';
import 'package:e_petshop/controller/transaksiController.dart';
import 'package:e_petshop/controller/usersContoller.dart';
import 'package:e_petshop/pages/Login/login.dart';
import 'package:e_petshop/pages/pageLog/log.dart';
import 'package:e_petshop/pages/pagesProduk/produk.dart';
import 'package:e_petshop/pages/pagesProduk/produk_create.dart';
import 'package:e_petshop/pages/pagesTransaksi/transaksi.dart';
import 'package:e_petshop/pages/pagesTransaksi/transaksi_detail.dart';
import 'package:e_petshop/pages/pagesUsers/users.dart';
import 'package:e_petshop/theme/color.dart';
import 'package:e_petshop/theme/screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(UsersController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => Screenpage()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/home', page: () => MyHomePage()),
        GetPage(name: '/produk', page: () => ProdukPage()),
        GetPage(name: '/transaksi', page: () => TransaksiPage()),
        GetPage(name: '/transaksid', page: () => TransaksiDetail()),
        GetPage(name: '/users', page: () => UsersPage()),
        GetPage(name: '/produkcreate', page: () => ProdukCreate()),
        GetPage(name: '/log', page: () => LogPage()),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  final UsersController _usersController = Get.find<UsersController>();
  final TransaksiController _transaksiController =
      Get.put(TransaksiController());
  final ProdukController _produkController = Get.put(ProdukController());

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final UsersController _usersController = Get.find<UsersController>();
  final TransaksiController _transaksiController =
      Get.put(TransaksiController());
  final ProdukController _produkController = Get.put(ProdukController());
  final LogController _logController = Get.put(LogController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 218, 218, 218),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 218, 218, 218),
          title: Row(
            children: [
              Text(
                'PET HOUSE',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: Colour.primary,
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  _usersController.signOut();
                },
              ),
            ],
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 160,
                  child: Image(
                    image: AssetImage(
                        'images/undraw_playing_fetch_cm19-removebg-preview.png'),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Dashboard',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20.0, color: Color.fromARGB(209, 23, 37, 63)
                ),
              ),
              SizedBox(height: 16),
              FutureBuilder<int>(
                future: _transaksiController.countTransaksi(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    int transaksiCount = snapshot.data ?? 0;
                    return buildProductTile(
                      title: "Transactions",
                      subtitle: transaksiCount.toString(),
                      icon: Icons.add_card_outlined,
                      iconColor: Colour.primary,
                      onTap: () {
                        Get.offNamed('/transaksi');
                      },
                    );
                  }
                },
              ),
              SizedBox(height: 16),
                 if (
                  _usersController.getCurrentUserRole() == UserRole.Admin)
              FutureBuilder<int>(
                future: _produkController.countProduk(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    int produkCount = snapshot.data ?? 0;
                    return buildProductTile(
                      title: "Products",
                      subtitle: produkCount.toString(),
                      icon: Icons.add_box_rounded,
                      iconColor: Colour.primary,
                      onTap: () {
                        Get.offNamed('/produk');
                      },
                    );
                  }
                },
              ),
              SizedBox(height: 16),
                 if (_usersController.getCurrentUserRole() == UserRole.Admin)
              FutureBuilder<int>(
                future: _usersController.countUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    int usersCount = snapshot.data ?? 0;
                    return buildProductTile(
                      title: "Users",
                      subtitle: usersCount.toString(),
                      icon: Icons.group_rounded,
                      iconColor: Colour.primary,
                      onTap: () {
                        Get.offNamed('/users');
                      },
                    );
                  }
                },
              ),
              SizedBox(height: 16),
              FutureBuilder<int>(
                future: _logController.countLog(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    int produkCount = snapshot.data ?? 0;
                    return buildProductTile(
                      title: "History",
                      subtitle: produkCount.toString(),
                      icon: Icons.history,
                      iconColor: Colour.primary,
                      onTap: () {
                        Get.offNamed('/log');
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProductTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required void Function() onTap,
  }) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9.0),
      ),
      color: Color.fromARGB(255, 255, 255, 255),
      child: ListTile(
        contentPadding: EdgeInsets.all(9),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: iconColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14.0,
            color: Color.fromARGB(178, 68, 97, 224),
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.2),
          child: Icon(
            icon,
            color: iconColor,
            size: 25.0,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
