import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_flutter_app/controllers/gallery_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photo_manager/photo_manager.dart';
import 'FullScreen_Imagepage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> requestGalleryPermission() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();
    if (permission == PermissionState.authorized) {
      print('Permission granted');
    } else {
      print("Permission denied");
      PhotoManager.openSetting();
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Digital Sky',
          style: Theme.of(Get.context!).textTheme.titleLarge,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : const AssetImage('assets/default_profile.png')
                          as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            onPressed: () {
              Get.put(GalleryController());
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundImage: user?.photoURL != null
                                  ? NetworkImage(user!.photoURL!)
                                  : const AssetImage(
                                          'assets/default_profile.png')
                                      as ImageProvider,
                            ),
                            title: Text(
                              user?.displayName ?? 'No name',
                              style:
                                  Theme.of(Get.context!).textTheme.titleMedium!,
                            ),
                            subtitle: Text(
                              user?.email ?? 'No user signed in',
                              style:
                                  Theme.of(Get.context!).textTheme.titleSmall!,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            'Enable Backup',
                            style: Theme.of(Get.context!).textTheme.titleSmall,
                          ),
                          Obx(() {
                            return IconButton(
                              icon: Icon(
                                Get.find<GalleryController>()
                                        .isBackupActive
                                        .value
                                    ? Icons.cloud_done
                                    : Icons.cloud_off,
                                color: Get.find<GalleryController>()
                                        .isBackupActive
                                        .value
                                    ? Colors.green
                                    : Colors.grey,
                                size: 40,
                              ),
                              onPressed: () {
                                Get.find<GalleryController>().imageBackup();
                              },
                            );
                          }),
                          const SizedBox(height: 350),
                          TextButton(
                            onPressed: () {
                              Get.find<GalleryController>().logout();
                            },
                            child: Text(
                              'Logout',
                              style:
                                  Theme.of(Get.context!).textTheme.titleMedium,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                              children: [
                                Text(
                                  'V 1.0.0+1',
                                  style: Theme.of(Get.context!)
                                      .textTheme
                                      .titleSmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      // Gallery UI
      body: GetBuilder<GalleryController>(
        init: GalleryController(),
        global: true,
        builder: (galleryController) {
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
              ),
              Expanded(
                child: Obx(
                  () => galleryController.galleryImages.isEmpty
                      ? Center(
                          child: Text(
                            'No images available',
                            style: Theme.of(Get.context!).textTheme.titleSmall,
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                          ),
                          itemCount: galleryController.galleryImages.length,
                          itemBuilder: (context, index) {
                            final image =
                                galleryController.galleryImages[index];
                            return GestureDetector(
                              onTap: () {
                                Get.to(() => FullScreenImagePage(image: image));
                              },
                              child: Stack(
                                children: [
                                  AssetEntityImage(
                                    image,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                  Obx(() {
                                    print(
                                        'cloud icon done ${galleryController.uploadedImages}');
                                    return galleryController.uploadedImages
                                            .contains(image.id)
                                        ? const Positioned(
                                            top: 5,
                                            left: 5,
                                            child: Icon(
                                              Icons.cloud_upload,
                                              color: Colors.blue,
                                              size: 20,
                                            ),
                                          )
                                        : const SizedBox.shrink();
                                  }),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
