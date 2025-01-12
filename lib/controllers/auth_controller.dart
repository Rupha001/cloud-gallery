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
  bool _isProfileEditEnabled = false;
  bool get isProfileEditEnabled => _isProfileEditEnabled;
  set isProfileEditEnabled(bool value) {
    _isProfileEditEnabled = value;
    update();
  }

  @override
  void onReady() async {
    //run every time auth state changes
    firebaseUser = Rx<User?>(FirebaseAuth.instance.currentUser);
    firebaseUser.bindStream(FirebaseAuth.instance.userChanges());
    ever(firebaseUser, handleAuthChanged);
    super.onReady();
  }

  handleAuthChanged(User? user) async {
    //get user data from firestore
    if (user == null) {
      print('user is null, navigate to login page');
      // if the user is not found then the user is navigated to the Register Screen
      Get.offAll(() => LoginPage());
    } else {
      GalleryService().listenCurrentUser().listen((doc) {
        currentUser.value = (UserData.fromFirestore(doc));

        update();
      });
      // if the user exists and logged in the the user is navigated to the Home Screen
      currentUser = Rx<UserData?>(await GalleryService().getCurrentUser());

      if (currentUser.value != null) {
        print('user is logged in,intialize gallery');
        //init receipt controller once login is valid
        Get.put<GalleryController>(GalleryController());
        print('init gallery controller...');

        print('naviagte to homepage');
        Get.offAll(() => const HomePage());
        update();
      } else {
        print('user is null, return to loginpage');
        Get.offAll(() => LoginPage());
      }
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
        UserData data = UserData(
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
      print('Error during Google Sign-In: $e');
      Get.snackbar("Login Failed", "Unable to login. Please try again.");
    }
  }

  // void refreshUser() async {
  //   currentUser = Rx<UserData?>(await GalleryService().getCurrentUser());
  // }

  void logout() async {
    await GalleryService().signOut();
    await Get.delete<GalleryController>(force: true);

    Phoenix.rebirth(Get.context!); // Restarting app
    // Get.reset();
    firebaseUser.value = null;
    currentUser.value = null;
    _isProfileEditEnabled = false;
  }
}
