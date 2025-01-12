import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_flutter_app/models/user.dart';

class GalleryService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static final GalleryService _instance = GalleryService._internal();
  GalleryService._internal();

  factory GalleryService() {
    return _instance;
  }

  UserData? _currentUser;

  Future<bool> checkAndUploadImage(
      String uid, String imageHash, File file) async {
    try {
      final querySnapshot = await firestore
          .collection('users')
          .doc(uid)
          .collection('my_photos')
          .where('imageHash', isEqualTo: imageHash)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return false;
      }

      final DocumentReference docRef = await firestore
          .collection('users')
          .doc(uid)
          .collection('my_photos')
          .add({
        'galleryIconURL': '',
        'imageHash': imageHash,
        'uid': uid,
        'addedTime': FieldValue.serverTimestamp(),
        'lastUpdatedOn': FieldValue.serverTimestamp(),
        'lastUpdatedBy': 'App',
      });

      final String docID = docRef.id; 
      final String fileName = 'image.jpg';
      final Reference storageRef =
          storage.ref().child('usersGallery/$uid/$docID/$fileName');

      await storageRef.putFile(file);
      final String downloadURL = await storageRef.getDownloadURL();
      await docRef.update({'galleryIconURL': downloadURL});

      return true;
    } catch (e) {
      print('Error in checkAndUploadImage: $e');
      return false;
    }
  }

  Future<Set<String>> getUploadedImages(String uid) async {
    try {
      final querySnapshot = await firestore
          .collection('users')
          .doc(uid)
          .collection('my_photos')
          .get();
      return querySnapshot.docs
          .map((doc) => doc['imageHash'] as String)
          .toSet();
    } catch (e) {
      print('Error in getUploadedImages: $e');
      return {};
    }
  }

  Future<bool> signOut() async {
    try {
      _currentUser = null;
      await _auth.signOut();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> listenCurrentUser() {
    return firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .snapshots();
  }

  Future<UserData?> getCurrentUser() async {
    try {
      final doc =
          await firestore.collection('users').doc(_auth.currentUser!.uid).get();
      if (!doc.exists) {
        print('doc no exists');
        return null;
      }
      _currentUser = UserData.fromFirestore(doc);
      return _currentUser;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
