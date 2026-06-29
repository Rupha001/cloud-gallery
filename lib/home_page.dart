import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_flutter_app/controllers/gallery_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'FullScreen_Imagepage.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Digital Sky',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: CircleAvatar(
              radius: 17.5,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? const Icon(Icons.person, size: 20)
                  : null,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
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
                                  : null,
                              child: user?.photoURL == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(
                              user?.displayName ?? 'No name',
                              style: Theme.of(dialogContext)
                                  .textTheme
                                  .titleMedium!,
                            ),
                            subtitle: Text(
                              user?.email ?? 'No user signed in',
                              style:
                                  Theme.of(dialogContext).textTheme.titleSmall!,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            'Enable Backup',
                            style: Theme.of(dialogContext).textTheme.titleSmall,
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
                          const SizedBox(height: 24),
                          TextButton(
                            onPressed: () {
                              Get.find<GalleryController>().logout();
                            },
                            child: Text(
                              'Logout',
                              style:
                                  Theme.of(dialogContext).textTheme.titleMedium,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                              children: [
                                Text(
                                  'V 1.0.0+1',
                                  style: Theme.of(dialogContext)
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
      body: GetBuilder<GalleryController>(
        global: true,
        builder: (galleryController) {
          return Obx(
            () => galleryController.galleryImages.isEmpty
                ? Center(
                    child: Text(
                      'No images available',
                      style: Theme.of(context).textTheme.titleSmall,
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
                      final image = galleryController.galleryImages[index];
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
          );
        },
      ),
    );
  }
}
