import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  String? displayName;
  String? profileUrl;
  String? useremail;

  UserData({
    required this.displayName,
    required this.profileUrl,
    required this.useremail,
  });

  factory UserData.fromFirestore(
    DocumentSnapshot doc,
  ) {
    Map? data = doc.data() as Map?;
    return UserData(
      displayName: data!['userID'],
      profileUrl: data['fullName'],
      useremail: data['useremail'],
    );
  }
  factory UserData.fromMap(String? docID, Map data) {
    return UserData(
      displayName: data['displayName'],
      profileUrl: data['profileUrl'],
      useremail: data['useremail'],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'displayName': displayName,
      'profileUrl': profileUrl,
      'useremail': useremail,
    };
    return data;
  }
}
