import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService{
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();
  FirebaseFirestore? _firestore;

  FirebaseFirestore get getFirestore {
    _firestore = FirebaseFirestore.instance;
    return _firestore!;
  }
}