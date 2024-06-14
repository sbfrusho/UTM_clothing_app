// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, use_build_context_synchronously, avoid_print, sized_box_for_whitespace, prefer_interpolation_to_compose_strings

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:shopping_app/My%20Cart/my_cart_view.dart';
import 'package:shopping_app/const/app-colors.dart';
import 'package:shopping_app/controller/cart-controller.dart';
import 'package:shopping_app/controller/payment-controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_app/screens/user/order-screen.dart';

import '../../controller/get-customer-device-token-controller.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late TextEditingController timeController;
  final payment = PaymentController();

  @override
  void initState() {
    super.initState();
    timeController = TextEditingController();
    fetchUserData(); // Fetch user data
    fetchAddressData(); // Fetch address data
  }

  final CartController cartController = Get.find<CartController>();
  User? user = FirebaseAuth.instance.currentUser;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  String selectedPaymentMethod = 'Card';

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            // Display user information
            ListTile(
              title: Text('Name'),
              subtitle: TextField(
                controller: nameController,
                readOnly: true,
              ),
            ),
            ListTile(
              title: Text('Email'),
              subtitle: TextField(
                controller: emailController,
              ),
            ),
            // Display address details
            ListTile(
              title: Text('Address'),
              subtitle: TextField(
                controller: addressController,
              ),
            ),
            SizedBox(height: 20),
            // Other checkout fields
                        Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                height: 55.0.h,
                child: TextFormField(
                  controller: timeController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Select delivery date',
                    labelText: 'Delivery Date',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (date != null) {
                          timeController.text = "${date.toLocal()}".split(' ')[0];
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
              child: DropdownButtonFormField<String>(
                value: selectedPaymentMethod,
                items: ['Card', 'Cash on Delivery'].map((String method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPaymentMethod = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    onPressed: () async {
                        String name = nameController.text.trim();
                        String address = addressController.text.trim();
                        String phone = phoneController.text.trim();
                        String time = timeController.text.trim();
                        String total = cartController.totalPrice.toString();
                        String paymentMethod = selectedPaymentMethod;

                        String? customerToken = await getCustomerDeviceToken();

                        print('Customer Token: $customerToken');
                        print('Name: $name');
                        print('phome : $phone');
                        print('Address: $address');
                        print('Time: $time');
                        print('Payment Method: $paymentMethod');
                        print("Total price: $total");

                        if (selectedPaymentMethod=='Cash on Delivery') {
                          await cartController.placeOrder(
                            cartController.cartItems,
                            cartController.totalPrice,
                            user!.uid,
                            name,
                            phone,
                            address,
                            paymentMethod,
                            time,
                          );

                          await sendEmail(
                            user!.email!,
                            'Order Confirmation',
                            'Your order has been placed successfully. Order will be delivered within 3 days by $time.\n  Total amount: $total RM',
                          );

                          setState(() {
                            isPaymentCompleted = true;
                          });
                          
                          Get.offAll(OrderScreen());
                        }
                        

                        if (await payment.makePayment(total) && selectedPaymentMethod=='Card') {
                          await cartController.placeOrder(
                            cartController.cartItems,
                            cartController.totalPrice,
                            user!.uid,
                            name,
                            phone,
                            address,
                            paymentMethod,
                            time,
                          );

                          await sendEmail(
                            user!.email!,
                            'Order Confirmation',
                            'Your order has been placed successfully. Order will be delivered by $time.\n  Total amount: $total RM',
                          );

                          setState(() {
                            isPaymentCompleted = true;
                          });
                          Get.offAll(OrderScreen());
                        }

                        
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
  }

  // Fetch user data
  void fetchUserData() {
    FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user!.email)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        final userData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        print('User data: $userData');
        setState(() {
          nameController.text = userData['name'] ?? '';
          phoneController.text = userData['phone'] ?? '';
          emailController.text = user!.email ?? '';
          // You can add more fields if available in the address collection
        });
      } else {
        print('No data found for this user');
      }
    }).catchError((error) {
      print('Error fetching address data: $error');
    });
  }

  void fetchAddressData() {
    FirebaseFirestore.instance
        .collection('addresses')
        .where('email', isEqualTo: user!.email)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        final userData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        print('User data: $userData');
        setState(() {
          addressController.text = userData['address'] ?? '';
          // You can add more fields if available in the address collection
        });
      } else {
        print('No data found for this user');
      }
    }).catchError((error) {
      print('Error fetching address data: $error');
    });
  }
  Future<void> sendEmail(String recipient, String subject, String body) async {
    String username = "ealumnimobileapp@gmail.com";
    String password = "NABIL112233";

    print('Sending email to $recipient');

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'UTM E-COMMERCE APP')
      ..recipients.add(recipient)
      ..subject = subject
      ..text = body;

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent. \n' + e.toString());
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
}
