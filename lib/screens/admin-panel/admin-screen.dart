//ignore_for_file: prefer_const_constructors, file_names, prefer_const_constructors_in_immutables , unused_field
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth-ui/welcome-screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async{
              // Add logout functionality here
              await auth.signOut();

              Navigator.push(context, MaterialPageRoute(builder: (context) =>  WelcomeScreen()));
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome to the Admin Panel'),
      ),
    );
  }
}