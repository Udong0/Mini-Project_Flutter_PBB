import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/glitch_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Backup a list of glitches to Firestore
  Future<void> backupGlitches(List<Glitch> glitches, String userId) async {
    final batch = _db.batch();

    for (var glitch in glitches) {
      // Create a document reference in the users/userId/glitches collection
      var docRef = _db
          .collection('users')
          .doc(userId)
          .collection('glitches')
          .doc(glitch.id.toString());

      batch.set(docRef, glitch.toMap());
    }

    await batch.commit();
  }
}
