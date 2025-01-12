import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class GalleryData {
  String? galleryIconURL;
  Reference? galleryIconRef;
  String? docID;
  String? id;
  DateTime addedTime;
  DateTime lastUpdatedOn;
  String lastUpdatedBy;

  GalleryData(
      {this.galleryIconURL,
      this.galleryIconRef,
      this.id,
      required this.addedTime,
      required this.lastUpdatedOn,
      required this.lastUpdatedBy,
      this.docID});

  factory GalleryData.fromFirestore(
      DocumentSnapshot doc, FirebaseStorage storageInstance) {
    Map? data = doc.data() as Map?;
    return GalleryData(
      galleryIconURL: data?['categoryIconURL'],
      id: data?['id'],
      galleryIconRef: storageInstance.ref(data?['categoryIconRef']),
      addedTime: DateTime.parse(data!['addedTime'].toDate().toString()),
      lastUpdatedOn: DateTime.parse(data['lastUpdatedOn'].toDate().toString()),
      lastUpdatedBy: data['lastUpdatedBy'] ?? '',
      docID: doc.id,
    );
  }

  factory GalleryData.fromMap(
      Map data, String docID, FirebaseStorage storageInstance) {
    return GalleryData(
      galleryIconURL: data['categoryIconURL'],
      id: data['id'],
      galleryIconRef: storageInstance.ref(data['categoryIconRef']),
      addedTime: DateTime.parse(data['addedTime'].toDate().toString()),
      lastUpdatedOn: DateTime.parse(data['lastUpdatedOn'].toDate().toString()),
      lastUpdatedBy: data['lastUpdatedBy'] ?? '',
      docID: docID,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'galleryIconURL': galleryIconURL,
      'id': id,
      'addedTime': addedTime,
      'lastUpdatedBy': lastUpdatedBy,
      'lastUpdatedOn': lastUpdatedOn,
      'categoryIconRef': galleryIconRef == null ? '' : galleryIconRef!.fullPath,
    };
    return data;
  }
}
