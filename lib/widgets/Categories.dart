import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shopping_app/controller/cart-controller.dart';
import 'package:shopping_app/screens/user/corporate-screen.dart';

import '../screens/user/cap-screen.dart';
import '../screens/user/mug-screen.dart';
import '../screens/user/t-shirt-screen.dart';

class Categories extends StatelessWidget {
  // const Categories({
  //   super.key,
  // });
  final CartController cartController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text("Explore Categories"),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * .2,
          width: MediaQuery.of(context).size.width * .8,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TshirtScreen()));
                    },
                    child: Column(
                      children: [
                        Image(
                          image:
                              const AssetImage("assets/Corporate/tshirt.jpg"),
                          height: 100.h,
                        ),
                        const Text("T - shirt"),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CorporateScreen()));
                    },
                    child: Column(
                      children: [
                        Image(
                          image: const AssetImage("assets/Corporate/shirt.jpg"),
                          height: 100.h,
                        ),
                        const Text("Corporate"),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MugScreen()));
                    },
                    child: Column(
                      children: [
                        Image(
                          image: const AssetImage("assets/Corporate/cup.jpg"),
                          height: 100.h,
                        ),
                        const Text("Mug"),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => CapScreen()));
                      Fluttertoast.showToast(msg: "CLicked");
                    },
                    child: Column(
                      children: [
                        Image(
                          image: const AssetImage("assets/Corporate/cap.jpg"),
                          height: 100.h,
                        ),
                        const Text("Cap"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
