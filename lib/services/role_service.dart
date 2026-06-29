import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/constants.dart';

class RoleService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? _cachedRole;

  static String get defaultRole => AppConstants.roleUsuario;

  static Future<String> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('user_roles').doc(uid).get();
      if (doc.exists) {
        final role = doc.data()?['role'] as String?;
        if (role != null && RolePermissions.allRoles.contains(role)) {
          _cachedRole = role;
          return role;
        }
      }
      return defaultRole;
    } catch (_) {
      return _cachedRole ?? defaultRole;
    }
  }

  static String? get cachedRole => _cachedRole;

  static Future<void> setUserRole(String uid, String role) async {
    if (!RolePermissions.allRoles.contains(role)) {
      throw Exception('Rol inválido: $role');
    }
    await _firestore.collection('user_roles').doc(uid).set({
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    _cachedRole = role;
  }

  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final snapshot = await _firestore.collection('user_roles').get();
    final users = <Map<String, dynamic>>[];

    for (final doc in snapshot.docs) {
      final userDoc = await _firestore
          .collection('users')
          .doc('info')
          .collection('profiles')
          .doc(doc.id)
          .get();

      users.add({
        'uid': doc.id,
        'role': doc.data()['role'] ?? defaultRole,
        'email': userDoc.data()?['email'] ?? doc.id,
        'name': userDoc.data()?['name'] ?? 'Sin nombre',
        'updatedAt': doc.data()['updatedAt'],
      });
    }

    return users;
  }

  static Future<List<Map<String, dynamic>>> getUsersByRole(String role) async {
    final snapshot = await _firestore
        .collection('user_roles')
        .where('role', isEqualTo: role)
        .get();
    return snapshot.docs
        .map((doc) => {
              'uid': doc.id,
              'role': doc.data()['role'],
            })
        .toList();
  }

  static Future<void> saveUserProfile(
      String uid, String email, String name) async {
    await _firestore
        .collection('users')
        .doc('info')
        .collection('profiles')
        .doc(uid)
        .set({
      'email': email,
      'name': name,
    });
  }

  static Future<String> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return defaultRole;
    return await getUserRole(user.uid);
  }
}
