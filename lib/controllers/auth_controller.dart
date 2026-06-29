import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_flutter_app/login_page.dart';
import 'package:my_flutter_app/home_page.dart';
import 'package:my_flutter_app/controllers/gallery_controller.dart';
import 'package:my_flutter_app/models/user.dart';
import 'package:my_flutter_app/services/gallery_service.dart';

class AuthController extends GetxController {
  late Rx<User?> firebaseUser;
  late Rx<UserData?> currentUser;
  StreamSubscription? _userListener;

  bool _isProfileEditEnabled = false;
  bool get isProfileEditEnabled => _isProfileEditEnabled;
  set isProfileEditEnabled(bool value) {
    _isProfileEditEnabled = value;
    update();
  }

  @override
  void onReady() async {
    firebaseUser = Rx<User?>(FirebaseAuth.instance.currentUser);
    firebaseUser.bindStream(FirebaseAuth.instance.userChanges());
    ever(firebaseUser, handleAuthChanged);
    super.onReady();
  }

  @override
  void onClose() {
    _userListener?.cancel();
    super.onClose();
  }

  Future<void> handleAuthChanged(User? user) async {
    if (user == null) {
      Get.offAll(() => LoginPage());
      return;
    }

    currentUser = Rx<UserData?>(await GalleryService().getCurrentUser());

    if (currentUser.value != null) {
      _userListener?.cancel();
      _userListener = GalleryService().listenCurrentUser().listen((doc) {
        currentUser.value = UserData.fromFirestore(doc);
        update();
      });

      Get.put<GalleryController>(GalleryController());
      Get.offAll(() => const HomePage());
      update();
    } else {
      Get.offAll(() => LoginPage());
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        final User? user = userCredential.user;
        final UserData data = UserData(
            displayName: user?.displayName,
            profileUrl: user?.photoURL,
            useremail: user?.email);

        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(data.toMap());

          Get.offAll(() => const HomePage());
        }
      }
    } catch (e) {
      Get.snackbar("Login Failed", "Unable to login. Please try again.");
    }
  }

  void logout() async {
    _userListener?.cancel();
    await GalleryService().signOut();
    await Get.delete<GalleryController>(force: true);

    firebaseUser.value = null;
    currentUser.value = null;
    _isProfileEditEnabled = false;

    Phoenix.rebirth(Get.context!);
  }
}
