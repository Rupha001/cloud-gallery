import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_flutter_app/controllers/auth_controller.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Digital Sky",
              style: Theme.of(Get.context!).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            SignInButton(
              Buttons.google,
              onPressed: () {
                Get.find<AuthController>().signInWithGoogle();
              },
            ),
          ],
        ),
      ),
    );
  }
}
