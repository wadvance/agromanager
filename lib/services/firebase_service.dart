import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/crop.dart';
import '../models/livestock.dart';
import '../models/inventory_item.dart';
import '../models/finance_record.dart';
import '../models/farm_task.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  static User? get currentUser => _auth.currentUser;
  static bool get isSignedIn => _auth.currentUser != null;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<UserCredential> signInWithEmail(
      String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  static Future<UserCredential> registerWithEmail(
      String email, String password, String name) async {
    final credential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await credential.user?.updateDisplayName(name);
    return credential;
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  static String get _userId => _auth.currentUser!.uid;

  static Future<void> syncCrops(List<Crop> crops) async {
    final batch = _firestore.batch();
    for (final crop in crops) {
      final ref = _firestore
          .collection('users')
          .doc(_userId)
          .collection('crops')
          .doc(crop.id.toString());
      batch.set(ref, crop.toMap());
    }
    await batch.commit();
  }

  static Future<List<Crop>> getCrops() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('crops')
        .orderBy('plantingDate', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = int.tryParse(doc.id);
      return Crop.fromMap(data);
    }).toList();
  }

  static Future<void> syncLivestock(List<Livestock> animals) async {
    final batch = _firestore.batch();
    for (final animal in animals) {
      final ref = _firestore
          .collection('users')
          .doc(_userId)
          .collection('livestock')
          .doc(animal.id.toString());
      batch.set(ref, animal.toMap());
    }
    await batch.commit();
  }

  static Future<List<Livestock>> getLivestock() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('livestock')
        .orderBy('birthDate', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = int.tryParse(doc.id);
      return Livestock.fromMap(data);
    }).toList();
  }

  static Future<void> syncInventory(List<InventoryItem> items) async {
    final batch = _firestore.batch();
    for (final item in items) {
      final ref = _firestore
          .collection('users')
          .doc(_userId)
          .collection('inventory')
          .doc(item.id.toString());
      batch.set(ref, item.toMap());
    }
    await batch.commit();
  }

  static Future<List<InventoryItem>> getInventory() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('inventory')
        .orderBy('name')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = int.tryParse(doc.id);
      return InventoryItem.fromMap(data);
    }).toList();
  }

  static Future<void> syncFinances(List<FinanceRecord> records) async {
    final batch = _firestore.batch();
    for (final record in records) {
      final ref = _firestore
          .collection('users')
          .doc(_userId)
          .collection('finances')
          .doc(record.id.toString());
      batch.set(ref, record.toMap());
    }
    await batch.commit();
  }

  static Future<List<FinanceRecord>> getFinances() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('finances')
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = int.tryParse(doc.id);
      return FinanceRecord.fromMap(data);
    }).toList();
  }

  static Future<void> syncTasks(List<FarmTask> tasks) async {
    final batch = _firestore.batch();
    for (final task in tasks) {
      final ref = _firestore
          .collection('users')
          .doc(_userId)
          .collection('tasks')
          .doc(task.id.toString());
      batch.set(ref, task.toMap());
    }
    await batch.commit();
  }

  static Future<List<FarmTask>> getTasks() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .orderBy('createdDate', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = int.tryParse(doc.id);
      return FarmTask.fromMap(data);
    }).toList();
  }

  static Future<void> syncAll({
    required List<Crop> crops,
    required List<Livestock> livestock,
    required List<InventoryItem> inventory,
    required List<FinanceRecord> finances,
    required List<FarmTask> tasks,
  }) async {
    await Future.wait([
      syncCrops(crops),
      syncLivestock(livestock),
      syncInventory(inventory),
      syncFinances(finances),
      syncTasks(tasks),
    ]);
  }
}
