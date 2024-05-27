// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart' as auth;
// import 'package:flutter/material.dart';
// import '../../models/user-model.dart';

// class UserScreen extends StatefulWidget {
//   @override
//   _UserScreenState createState() => _UserScreenState();
// }

// class _UserScreenState extends State<UserScreen> {
//   late Future<User> _futureUser;

//   @override
//   void initState() {
//     super.initState();
//     _futureUser = fetchUser();
//   }

//   Future<User> fetchUser() async {
//     final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
//     final auth.User? currentUser = _auth.currentUser;
// final userId = currentUser?.uid;
//     Text(userId!);
//     if (currentUser == null) {
//       throw Exception('No user is currently signed in');
//     }

    

//     try {
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      
//       if (userDoc.exists) {
//         return User.fromMap(userDoc.data() as Map<String, dynamic>);
//       } else {
//         throw Exception('User not found');
//       }
//     } catch (e) {
//       throw Exception('Error fetching user: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('User Data'),
//       ),
//       body: FutureBuilder<User>(
//         future: _futureUser,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (snapshot.hasData) {
//             User user = snapshot.data!;
//             return Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Name: ${user.name}', style: TextStyle(fontSize: 18)),
//                   SizedBox(height: 8),
//                   Text('Email: ${user.email}', style: TextStyle(fontSize: 18)),
//                   SizedBox(height: 8),
//                   Text('Phone: ${user.phone}', style: TextStyle(fontSize: 18)),
//                   SizedBox(height: 8),
//                   Text('Admin: ${user.isAdmin}', style: TextStyle(fontSize: 18)),
//                 ],
//               ),
//             );
//           } else {
//             return Center(child: Text('No user data found'));
//           }
//         },
//       ),
//     );
//   }
// }
