import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/json_parsing.dart';
import '../models/address_model.dart';

/// Address book at `users/{uid}/addresses`. Exactly one address is the
/// default whenever the book is not empty.
class AddressRepository {
  AddressRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _db.collection(FirestorePaths.users).doc(uid);

  CollectionReference<Map<String, dynamic>> _book(String uid) =>
      _user(uid).collection(FirestorePaths.userAddresses);

  /// Default first, then by label.
  Stream<List<AddressModel>> watch(String uid) => _book(uid).snapshots().map(
    (s) => sortBook(
      s.docs.map((d) => AddressModel.fromMap(d.data(), id: d.id)).toList(),
    ),
  );

  Future<List<AddressModel>> fetchAll(String uid) async {
    try {
      final s = await _book(uid).get();
      return sortBook(
        s.docs.map((d) => AddressModel.fromMap(d.data(), id: d.id)).toList(),
      );
    } catch (e) {
      throw AppException.from(e);
    }
  }

  static List<AddressModel> sortBook(List<AddressModel> list) => list
    ..sort((a, b) {
      if (a.isDefault != b.isDefault) return a.isDefault ? -1 : 1;
      return a.displayLabel.toLowerCase().compareTo(
        b.displayLabel.toLowerCase(),
      );
    });

  /// Creates or updates [address]. The first address, or one marked
  /// default, becomes the only default.
  Future<AddressModel> save(String uid, AddressModel address) async {
    try {
      final existing = await _book(uid).get();
      final ref = address.id == null
          ? _book(uid).doc()
          : _book(uid).doc(address.id);
      final othersExist = existing.docs.any((d) => d.id != ref.id);
      final makeDefault = address.isDefault || !othersExist;
      final saved = address.copyWith(id: ref.id, isDefault: makeDefault);

      final batch = _db.batch()..set(ref, saved.toMap());
      if (makeDefault) {
        for (final d in existing.docs) {
          if (d.id != ref.id && asBool(d.data()['isDefault'])) {
            batch.update(d.reference, {'isDefault': false});
          }
        }
      }
      await batch.commit();
      return saved;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> setDefault(String uid, String id) async {
    try {
      final existing = await _book(uid).get();
      final batch = _db.batch();
      for (final d in existing.docs) {
        final shouldBe = d.id == id;
        if (asBool(d.data()['isDefault']) != shouldBe) {
          batch.update(d.reference, {'isDefault': shouldBe});
        }
      }
      await batch.commit();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// Deleting the default promotes another address.
  Future<void> delete(String uid, AddressModel address) async {
    try {
      final batch = _db.batch()..delete(_book(uid).doc(address.id));
      if (address.isDefault) {
        final rest = (await _book(
          uid,
        ).get()).docs.where((d) => d.id != address.id);
        if (rest.isNotEmpty) {
          batch.update(rest.first.reference, {'isDefault': true});
        }
      }
      await batch.commit();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// One-time copy of the legacy `addresses` document (matched by email).
  /// Name and phone come from the profile. The legacy document is kept.
  Future<void> migrateLegacy({
    required String uid,
    required String email,
    required String fullName,
    required String phone,
  }) async {
    try {
      final profile = await _user(uid).get();
      if (profile.data()?['addressesMigrated'] == true) return;
      final legacy = await _db
          .collection(FirestorePaths.legacyAddresses)
          .where('email', isEqualTo: email)
          .limit(5)
          .get();
      final batch = _db.batch();
      var first = true;
      for (final d in legacy.docs) {
        final m = d.data();
        final address = AddressModel(
          label: 'Home',
          fullName: fullName,
          phone: phone,
          address: asString(m['address']),
          street: asString(m['street']),
          city: asString(m['city']),
          state: asString(m['state']),
          postalCode: asString(m['postalCode']),
          country: asString(m['country']),
          isDefault: first,
        );
        if (address.formatted.isEmpty) continue;
        batch.set(_book(uid).doc(), address.toMap());
        first = false;
      }
      batch.set(_user(uid), {
        'addressesMigrated': true,
      }, SetOptions(merge: true));
      await batch.commit();
    } catch (e, st) {
      AppLogger.error('Address migration failed', e, st);
    }
  }
}
