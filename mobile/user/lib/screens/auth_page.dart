import 'package:flutter/material.dart';
import 'package:user/screens/register_page.dart';

import 'login_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) => isLogin
      ? LoginPage(changePage: toggle)
      : RegisterPage(
          changePage: toggle,
        );

  void toggle() => setState(() => isLogin = !isLogin);
}
