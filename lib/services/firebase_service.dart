import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> saveDevices(String userId, List<Map<String, dynamic>> devices) async {
    final ref = _firestore.collection('sessions').doc(userId);
    await ref.set({
      'devices': devices,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> loadDevices(String userId) async {
    final snapshot = await _firestore.collection('sessions').doc(userId).get();
    final data = snapshot.data();
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(data['devices']);
  }
}
