import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/errors/app_exception.dart';
import '../models/address_model.dart';

class AddressRepository {
  AddressRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _addresses =>
      _db.collection(FirestorePaths.addresses);

  Future<AddressModel?> fetchForUser(String email) async {
    try {
      final snapshot = await _addresses
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return AddressModel.fromMap(doc.data(), id: doc.id);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// Updates the existing document, or creates one keyed by [uid].
  Future<AddressModel> save(AddressModel address, {required String uid}) async {
    try {
      final ref = address.id != null
          ? _addresses.doc(address.id)
          : _addresses.doc(uid);
      await ref.set(address.toMap(), SetOptions(merge: true));
      return AddressModel.fromMap(address.toMap(), id: ref.id);
    } catch (e) {
      throw AppException.from(e);
    }
  }
}
