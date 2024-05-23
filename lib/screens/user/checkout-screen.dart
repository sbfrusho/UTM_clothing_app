// // ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_key_in_widget_constructors, sort_child_properties_last, unused_local_variable, use_build_context_synchronously, avoid_print
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:shopping_app/const/app-colors.dart';
// import 'package:shopping_app/controller/cart-controller.dart';
// import 'package:shopping_app/controller/get-customer-device-token-controller.dart';
// import 'package:shopping_app/controller/payment-controller.dart';

// class CheckoutScreen extends StatefulWidget {
//   @override
//   _CheckoutScreenState createState() => _CheckoutScreenState();
// }

// class _CheckoutScreenState extends State<CheckoutScreen> {
//   late TextEditingController timeController;
//   var paymentController = Get.put(PaymentController());

//   @override
//   void initState() {
//     super.initState();
//     timeController = TextEditingController();
//   }

//   final CartController cartController = Get.find<CartController>();

//   User? user = FirebaseAuth.instance.currentUser;

//   TextEditingController nameController = TextEditingController();
//   TextEditingController phoneController = TextEditingController();
//   TextEditingController addressController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: IconThemeData(color: Colors.white),
//         backgroundColor: AppColor().colorRed,
//         title: Text(
//           'Checkout',
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: cartController.cartItems.length,
//               itemBuilder: (context, index) {
//                 final item = cartController.cartItems[index];
//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: 8.0),
//                   child: ListTile(
//                       tileColor: Colors.grey[200],
//                       leading: Image.network(item.productImage),
//                       title: Text(item.productName),
//                       subtitle: Text(
//                         'price : \$${(item.price * item.quantity).toStringAsFixed(2)}',
//                       )),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Total: \$${cartController.totalPrice.toStringAsFixed(2)}',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     // Show bottom sheet
//                     showCustomBottomSheet(context);
//                   },
//                   child: const Text('Checkout'),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void showCustomBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           height: 500.h,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(20),
//               topRight: Radius.circular(20),
//             ),
//           ),
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Container(
//                     height: 55.0.h,
//                     child: TextFormField(
//                       textInputAction: TextInputAction.next,
//                       keyboardType: TextInputType.text,
//                       controller: nameController,
//                       decoration: InputDecoration(
//                         hintText: 'Enter your name',
//                         labelText: 'Name',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Container(
//                     height: 55.0.h,
//                     child: TextFormField(
//                       textInputAction: TextInputAction.next,
//                       keyboardType: TextInputType.phone,
//                       controller: phoneController,
//                       decoration: InputDecoration(
//                         hintText: 'Enter your phone',
//                         labelText: 'Phone',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Container(
//                     height: 55.0.h,
//                     child: TextFormField(
//                       keyboardType: TextInputType.streetAddress,
//                       textInputAction: TextInputAction.next,
//                       controller: addressController,
//                       decoration: InputDecoration(
//                         hintText: 'Enter your Address',
//                         labelText: 'Address',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Container(
//                     height: 55.0.h,
//                     child: TextFormField(
//                       controller: timeController,
//                       readOnly: true,
//                       decoration: InputDecoration(
//                         hintText: 'Enter delivery time',
//                         labelText: 'Delivery Time',
//                         suffixIcon: IconButton(
//                           icon: Icon(Icons.calendar_today),
//                           onPressed: () async {
//                             final time = await showTimePicker(
//                               context: context,
//                               initialTime: TimeOfDay.now(),
//                             );
//                             if (time != null) {
//                               timeController.text = time.format(context);
//                             }
//                           },
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       keyboardType: TextInputType.text,
//                       textInputAction: TextInputAction.next,
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: ElevatedButton(
//                     onPressed: () async {
//                       if (nameController.text != '' &&
//                           phoneController.text != '' &&
//                           addressController.text != '' &&
//                           timeController.text != '') {
//                         String name = nameController.text.trim();
//                         String phone = phoneController.text.trim();
//                         String address = addressController.text.trim();
//                         String time = timeController.text.trim();

//                         String? customerToken = await getCustomerDeviceToken();  
//                         print('Hello world');
//                         print('Customer Token: $customerToken');
//                         print('Name: $name');
//                         print('Phone: $phone');
//                         print('Address: $address');
//                         print('Time: $time');

//                         await cartController.placeOrder(
//                           cartController.cartItems,
//                           cartController.totalPrice,
//                           user!.uid,
//                           name,
//                           phone,
//                           address,
//                           'Cash on delivery',
//                           time,
//                         );
//                       } else {}

//                     },
//                     child: Text('COnfirm Order'),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shopping_app/const/app-colors.dart';
import 'package:shopping_app/controller/cart-controller.dart';
import 'package:shopping_app/controller/get-customer-device-token-controller.dart';
import 'package:shopping_app/controller/payment-controller.dart';
import 'package:shopping_app/controller/wishlist-controller.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late TextEditingController timeController;
  var paymentController = Get.put(PaymentController());
  WishlistController wishlistController = Get.put(WishlistController());

  @override
  void initState() {
    super.initState();
    timeController = TextEditingController();
  }

  final CartController cartController = Get.find<CartController>();

  User? user = FirebaseAuth.instance.currentUser;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  bool isPaymentCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColor().colorRed,
        title: Text(
          'Checkout',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartController.cartItems.length,
              itemBuilder: (context, index) {
                final item = cartController.cartItems[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    tileColor: Colors.grey[200],
                    leading: Image.network(item.productImage),
                    title: Text(item.productName),
                    subtitle: Text(
                      'price : \$${(double.parse(item.price)  * item.quantity).toStringAsFixed(2)}',
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: \$${cartController.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Show bottom sheet
                    showCustomBottomSheet(context);
                  },
                  child: const Text('Checkout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showCustomBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 500.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    height: 55.0.h,
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your name',
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    height: 55.0.h,
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.phone,
                      controller: phoneController,
                      decoration: InputDecoration(
                        hintText: 'Enter your phone',
                        labelText: 'Phone',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    height: 55.0.h,
                    child: TextFormField(
                      keyboardType: TextInputType.streetAddress,
                      textInputAction: TextInputAction.next,
                      controller: addressController,
                      decoration: InputDecoration(
                        hintText: 'Enter your Address',
                        labelText: 'Address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    height: 55.0.h,
                    child: TextFormField(
                      controller: timeController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Enter delivery time',
                        labelText: 'Delivery Time',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              timeController.text = time.format(context);
                            }
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    onPressed: () async {

                      // await paymentController.makePayment();

                      if (nameController.text != '' &&
                          phoneController.text != '' &&
                          addressController.text != '' &&
                          timeController.text != '') {
                        String name = nameController.text.trim();
                        String phone = phoneController.text.trim();
                        String address = addressController.text.trim();
                        String time = timeController.text.trim();

                        String? customerToken = await getCustomerDeviceToken();  
                        print('Hello world');
                        print('Customer Token: $customerToken');
                        print('Name: $name');
                        print('Phone: $phone');
                        print('Address: $address');
                        print('Time: $time');

                        await cartController.placeOrder(
                          cartController.cartItems,
                          cartController.totalPrice,
                          user!.uid,
                          name,
                          phone,
                          address,
                          'Cash on delivery',
                          time,
                        );

                        setState(() {
                          isPaymentCompleted = true;
                        });

                      } else {}

                    },
                    child: Text('Confirm Order'),
                  ),
                ),
                if (isPaymentCompleted)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Order placed successfully!',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
