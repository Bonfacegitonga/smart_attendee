import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final CollectionReference colRef =
      FirebaseFirestore.instance.collection("Users");
  final CollectionReference collectionRef =
      FirebaseFirestore.instance.collection('Classes');

  Future<void> deleteDocuments(selectedIds, bool isSelectionMode) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (String id in selectedIds) {
      batch.delete(collectionRef.doc(id));
    }

    await batch.commit();
    isSelectionMode = false;
  }
}
