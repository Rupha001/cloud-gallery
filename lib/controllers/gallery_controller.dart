import 'dart:io';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:my_flutter_app/services/gallery_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_flutter_app/login_page.dart';

class GalleryController extends GetxController {
  RxList<AssetEntity> galleryImages = <AssetEntity>[].obs;
  RxSet<String> uploadedImages = <String>{}.obs;
  RxBool isBackupActive = false.obs;
  RxBool isUploading = false.obs;
  int currentImageIndex = 0;

  final GalleryService galleryService = GalleryService();

  @override
  void onInit() {
    super.onInit();

    _loadBackupState().then((_) async {
      await _getImageStatus();
      await fetchAndUploadImages();

      if (isBackupActive.value) {
        print('Backup is active. Resuming...');
        await _loadCurrentImageIndex();
        _resumeBackup();
      } else {
        print('Backup is not active.');
      }
      update();
    });
  }

  Future<void> logout() async {
    isBackupActive.value = false;
    isUploading.value = false;
    final FirebaseAuth auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    await auth.signOut();
    await googleSignIn.signOut();

    Get.offAll(() => const LoginPage());
  }

  Future<void> _loadBackupState() async {
    final prefs = await SharedPreferences.getInstance();
    isBackupActive.value = prefs.getBool('isBackupActive') ?? false;
    print('rup: ${isBackupActive.value}');
    print('rup backup: ${prefs.getBool('isBackupActive')}');

    if (!isBackupActive.value) {
      isUploading.value = false;
    }
  }

  Future<void> saveBackupState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isBackupActive', isBackupActive.value);
    print('Backup state saved: ${isBackupActive.value}');
  }

  Future<void> _getImageStatus() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user logged in");
      return;
    }
    final Set<String> existingImages =
        await galleryService.getUploadedImages(user.uid);
    uploadedImages.addAll(existingImages);
    print("Uploaded images: $uploadedImages");

    update();
  }

  Future<void> fetchAndUploadImages() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();

    if (permission == PermissionState.authorized) {
      print('Permission granted');
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );

      if (albums.isNotEmpty) {
        final List<AssetEntity> images = await albums[0].getAssetListRange(
          start: 0,
          end: albums[0].assetCount,
        );

        galleryImages.value = images;
      } else {
        print('No albums found');
      }
    } else {
      print("Permission denied");
      PhotoManager.openSetting();
      return;
    }
  }

  Future<void> imageBackup() async {
    isBackupActive.value = !isBackupActive.value;
    if (isBackupActive.value) {
      isUploading.value = true;
      await saveBackupState();
      print('Backup resumed');
      print('aereyyy:${isBackupActive.value}');
      _getImageStatus();
      await _uploadImages();
    } else {
      isUploading.value = false;
      await saveBackupState();
      print('Backup paused');
      print('aereyyy2:${isBackupActive.value}');
      _getImageStatus();
    }
    print('aereyyy1:${isBackupActive.value}');
  }

  Future<void> _uploadImages() async {
    for (int i = currentImageIndex; i < galleryImages.length; i++) {
      if (!isBackupActive.value) {
        currentImageIndex = i;
        await saveCurrentImageIndex();
        print('Backup paused at index: $currentImageIndex');
        break;
      }

      final image = galleryImages[i];
      if (uploadedImages.contains(image.id)) {
        print('Image already uploaded: ${image.id}');
        continue;
      }

      print('Uploading image at index: $i');
      await _checkAndUploadImage(image);
    }

    if (isBackupActive.value) {
      print('All images uploaded');
      currentImageIndex = 0;
      await saveCurrentImageIndex();
    }
  }

  Future<void> _checkAndUploadImage(AssetEntity image) async {
    final String imageHash = image.id;

    final File? file = await image.file;
    if (file == null) return;

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user logged in");
      return;
    }

    final bool uploaded =
        await galleryService.checkAndUploadImage(user.uid, imageHash, file);
    if (uploaded) {
      uploadedImages.add(imageHash);
      print('Image uploaded successfully: $imageHash');
      update();
    } else {
      uploadedImages.add(imageHash);
      print('Image already exists: $imageHash');
    }
  }

  Future<void> _resumeBackup() async {
    print('Resuming backup process');
    isUploading.value = true;
    await _uploadImages();
  }

  Future<void> _loadCurrentImageIndex() async {
    final prefs = await SharedPreferences.getInstance();
    currentImageIndex = prefs.getInt('currentImageIndex') ?? 0;
    print('Current image index loaded: $currentImageIndex');
  }

  Future<void> saveCurrentImageIndex() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentImageIndex', currentImageIndex);
    print('Current image index saved: $currentImageIndex');
  }
}
