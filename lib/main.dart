import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_flutter_app/controllers/auth_controller.dart';


late FirebaseApp defaultApp;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  defaultApp = await Firebase.initializeApp();
  // runApp(const GalleryApp());
  await FirebaseFirestore.instance.clearPersistence();

  Get.put<AuthController>(AuthController());

  runApp(Phoenix(child: const GalleryApp()));
}

class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      useInheritedMediaQuery: true,
      designSize: const Size(360, 690),
      builder: (context, child) {
        return GlobalLoaderOverlay(
          child: GetMaterialApp(
            title: 'Gallery APP',
            theme: ThemeData(
              primarySwatch: Colors.deepPurple,
              useMaterial3: true,
            ),
            home: const LoadingWidget(),
            localizationsDelegates: const [],
          ),
        );
      },
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: SizedBox(
        width: 400,
        height: 400,
        // child: Image.asset('assets/jomin_logo_with_tag.png', width: 600),
      ),
    );
  }
}
