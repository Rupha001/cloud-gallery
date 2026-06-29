import 'dart:io';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:my_flutter_app/services/gallery_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        await _loadCurrentImageIndex();
        _resumeBackup();
      }
      update();
    });
  }

  Future<void> logout() async {
    isBackupActive.value = false;
    isUploading.value = false;
    await saveBackupState();
    await FirebaseAuth.instance.signOut();
  }

  Future<void> _loadBackupState() async {
    final prefs = await SharedPreferences.getInstance();
    isBackupActive.value = prefs.getBool('isBackupActive') ?? false;

    if (!isBackupActive.value) {
      isUploading.value = false;
    }
  }

  Future<void> saveBackupState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isBackupActive', isBackupActive.value);
  }

  Future<void> _getImageStatus() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final Set<String> existingImages =
        await galleryService.getUploadedImages(user.uid);
    uploadedImages.addAll(existingImages);
    update();
  }

  Future<void> fetchAndUploadImages() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();

    if (permission == PermissionState.authorized) {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );

      if (albums.isNotEmpty) {
        final int count = await albums[0].assetCountAsync;
        final List<AssetEntity> images = await albums[0].getAssetListRange(
          start: 0,
          end: count,
        );
        galleryImages.value = images;
      }
    } else {
      PhotoManager.openSetting();
    }
  }

  Future<void> imageBackup() async {
    isBackupActive.value = !isBackupActive.value;
    if (isBackupActive.value) {
      isUploading.value = true;
      await saveBackupState();
      await _getImageStatus();
      await _uploadImages();
    } else {
      isUploading.value = false;
      await saveBackupState();
      await _getImageStatus();
    }
  }

  Future<void> _uploadImages() async {
    for (int i = currentImageIndex; i < galleryImages.length; i++) {
      if (!isBackupActive.value) {
        currentImageIndex = i;
        await saveCurrentImageIndex();
        break;
      }

      final image = galleryImages[i];
      if (uploadedImages.contains(image.id)) continue;

      await _checkAndUploadImage(image);
    }

    if (isBackupActive.value) {
      currentImageIndex = 0;
      await saveCurrentImageIndex();
    }
  }

  Future<void> _checkAndUploadImage(AssetEntity image) async {
    final String imageHash = image.id;

    final File? file = await image.file;
    if (file == null) return;

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final bool uploaded =
        await galleryService.checkAndUploadImage(user.uid, imageHash, file);
    uploadedImages.add(imageHash);
    if (uploaded) update();
  }

  Future<void> _resumeBackup() async {
    isUploading.value = true;
    await _uploadImages();
  }

  Future<void> _loadCurrentImageIndex() async {
    final prefs = await SharedPreferences.getInstance();
    currentImageIndex = prefs.getInt('currentImageIndex') ?? 0;
  }

  Future<void> saveCurrentImageIndex() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentImageIndex', currentImageIndex);
  }
}
