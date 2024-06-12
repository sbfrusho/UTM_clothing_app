import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shopping_app/models/address-model.dart'; // Import the Address model

class AddAddressScreen extends StatefulWidget {
  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final _addressController = TextEditingController(); // New address field controller
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        Address address = Address(
          street: _streetController.text,
          city: _cityController.text,
          state: _stateController.text,
          postalCode: _postalCodeController.text,
          country: _countryController.text,
          address: _addressController.text,
          email: user.email! // Add the address field to the model
        );

        FirebaseFirestore firestore = FirebaseFirestore.instance;
        try {
          await firestore
              .collection('addresses') // Plural form for consistency
              .add(address.toMap());

          // Show a success message and navigate back
          Get.snackbar('Success', 'Address added successfully!',
              snackPosition: SnackPosition.BOTTOM);
          Navigator.pop(context);
        } catch (e) {
          print('Error uploading address: $e');
          // Show an error message to the user
          Get.snackbar('Error', 'Failed to add address. Please try again later.',
              snackPosition: SnackPosition.BOTTOM);
        }
      }
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Add Address')), // Center-aligned title
        backgroundColor: Colors.red, // Example color, replace with AppColor().colorRed if defined
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              
              SizedBox(height: 16),
              TextFormField(
                controller: _streetController,
                decoration: InputDecoration(labelText: 'Street'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the street';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: 'City'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the city';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _stateController,
                decoration: InputDecoration(labelText: 'State'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the state';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _postalCodeController,
                decoration: InputDecoration(labelText: 'Postal Code'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the postal code';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _countryController,
                decoration: InputDecoration(labelText: 'Country'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the country';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'), // New address field
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Example color, replace with AppColor().colorRed if defined
                ),
                child: Text('Save Address'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
