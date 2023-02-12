import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:smart_attendee/auth/sign_in/sign_in_screen.dart';
import 'package:smart_attendee/auth/sign_in/web_login.dart';

import '../sign_up/sign_up_screen.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLogin = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return const SignInScreen();
        } else {
          return const LoginDesktop();
        }
      }),
    );
  }

  // void toggle() => setState(() {
  //       isLogin = !isLogin;
  //     });

  // void setScreen() {
  //   isLogin
  //       ? SignInScreen(onClickedSignUp: toggle)
  //       : SignUpPage(onClickedSignIn: toggle);
  // }
}
