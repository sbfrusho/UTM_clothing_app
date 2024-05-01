// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class SignInController extends GetxController{

  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isPasswordVisible = false.obs;

  Future<UserCredential?> signInMethod(
    String userEmail,
    String userPassword,
  ) async{
    try{
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: userEmail,
        password: userPassword,
      );

      return userCredential;
    }on FirebaseAuthException catch(e){
      Get.snackbar("Error", e.message.toString());
    }
    return null;
  }
}