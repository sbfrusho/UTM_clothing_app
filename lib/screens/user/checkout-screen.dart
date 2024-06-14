// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, use_build_context_synchronously, avoid_print, sized_box_for_whitespace, prefer_interpolation_to_compose_strings

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:shopping_app/My%20Cart/my_cart_view.dart';
import 'package:shopping_app/const/app-colors.dart';
import 'package:shopping_app/controller/address-controller.dart';
import 'package:shopping_app/controller/cart-controller.dart';
import 'package:shopping_app/controller/payment-controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_app/screens/user/all-category.dart';
import 'package:shopping_app/screens/user/delivery-adress.dart';
import 'package:shopping_app/screens/user/home-screen.dart';
import 'package:shopping_app/screens/user/order-confirmation-screen.dart';
import 'package:shopping_app/screens/user/order-screen.dart';
import 'package:shopping_app/screens/user/shipping-address.dart';
import 'package:shopping_app/screens/user/wish-list.dart';

import '../../controller/get-customer-device-token-controller.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late TextEditingController timeController;
  final payment = PaymentController();
  AddressController ads = Get.put(AddressController());


  @override
void initState() {
  super.initState();
  timeController = TextEditingController();
  fetchUserData(); // Fetch user data
  fetchAddressData(); // Fetch address data

  // Add a listener to addressController
  addressController.addListener(() {
    setState(() {});
  });
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
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              fetchAddressData();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.push(context,MaterialPageRoute(builder: (context)=>AddAddressScreen())),
              child: Card(
                
                margin: EdgeInsets.all(20.0),
                child: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery Info',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Divider(),
                      ListTile(
                        title: Text('Name'),
                        subtitle: Text(nameController.text),
                      ),
                      ListTile(
                        title: Text('Email'),
                        subtitle: Text(emailController.text),
                      ),
                      ListTile(
                        title: Text('Address'),
                        subtitle: Text(addressController.text),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
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
                          timeController.text =
                              "${date.toLocal()}".split(' ')[0];
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
                items: [
                  DropdownMenuItem<String>(
                    value: 'Card',
                    child: Row(
                      children: [
                        Icon(Icons.credit_card),
                        SizedBox(width: 10),
                        Text('Card'),
                      ],
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Cash on Delivery',
                    child: Row(
                      children: [
                        Icon(Icons.money),
                        SizedBox(width: 10),
                        Text('Cash on Delivery'),
                      ],
                    ),
                  ),
                ],
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

                  if (selectedPaymentMethod == 'Cash on Delivery') {
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

                    // Get.offAll(OrderConfirmationScreen());

                    await sendEmail(
                      user!.email!,
                      'Order Confirmation',
                      'Your order has been placed successfully. Order will be delivered within 3 days by $time.\n  Total amount: $total RM',
                    );

                    setState(() {
                      isPaymentCompleted = true;
                    });
                  }

                  if (await payment.makePayment(total) &&
                      selectedPaymentMethod == 'Card') {
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

                    // Get.offAll(OrderConfirmationScreen());

                    await sendEmail(
                      user!.email!,
                      'Order Confirmation',
                      'Your order has been placed successfully. Order will be delivered by $time.\n  Total amount: $total RM',
                    );

                    setState(() {
                      isPaymentCompleted = true;
                    });
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (context) => OrderConfirmationScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor().colorRed,
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 15.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: Text(
                  'Confirm Order',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
              break;
            case 1:
              // Handle the Wishlist item tap
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => WishlistScreen()));
              break;
            case 2:
              // Handle the Categories item tap
              Get.offAll(AllCategoriesScreen());
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
              break;
            case 4:
              // Handle the Profile item tap
              break;
          }
        },
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
      final addressData =
          querySnapshot.docs.first.data() as Map<String, dynamic>;
      print('Address data: $addressData');
      setState(() {
        addressController.text = addressData['address'] ?? '';
        // You can add more fields if available in the address collection
      });
    } else {
      print('No data found for this address');
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
