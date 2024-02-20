// import 'package:bacabox/theme/color.dart';
import 'package:e_petshop/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Screenpage extends StatelessWidget {
  const Screenpage({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Get.offNamed('/login');
    });
    return Scaffold(
      body: Container(
        color: Colour.primary,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage('images/4.png'),
                height: 150,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
