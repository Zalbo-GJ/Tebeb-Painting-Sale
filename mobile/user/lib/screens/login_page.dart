import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:user/utils/colors.dart';

import '../routes/app_routes.dart';
import '../services/auth_controller.dart';
import '../services/profile_controller.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback changePage;
  const LoginPage({Key? key, required this.changePage}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? emailError, passwordError;
  late FocusNode emailFocusNode, passwordFocusNode;

  @override
  void initState() {
    super.initState();

    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    emailFocusNode.addListener(() => setState(() {}));
    passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode = FocusNode();

    super.dispose();
  }

  bool isSaved = false;
  bool isPressed = true;
  bool isLoading = false;

  final formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
        borderSide: Divider.createBorderSide(context),
        borderRadius: BorderRadius.circular(10));

    TextTheme textTheme = Theme.of(context).textTheme;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Color secondbackgroundColor = Theme.of(context).cardColor;
    return CupertinoPageScaffold(
      backgroundColor: Color.fromARGB(255, 9, 64, 56),
      child: isLoading
          ? CircularProgressIndicator(color: Colors.green[900])
          : Material(
        color:Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(top: 80,left: 15,right: 15),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: screenHeight * 0.34,
                  child: Column(children: [
                    Container(child: Image.asset('assets/images/logo_with_name.png',height: screenHeight * 0.3,width: screenWidth,fit: BoxFit.cover,)),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Sign In",
                        style: textTheme.displayMedium?.copyWith(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ]),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Form(
                    key: formkey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 25),
                          decoration: BoxDecoration(
                            color: secondbackgroundColor,
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 10,
                                offset: const Offset(1, 1),
                                color: Color.fromARGB(54, 188, 187, 187),
                              )
                            ],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: TextFormField(
                              controller: emailController,
                              focusNode: emailFocusNode,
                              cursorColor:
                              Color.fromARGB(224, 14, 187, 158),
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 50,vertical: 20),
                                  prefixIcon: Container(
                                    width: 55,
                                    height: 55,
                                  margin: EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(color: theme,borderRadius: BorderRadius.circular(10),),
                                  child: Icon(
                                    Icons.mail,
                                    color: Colors.white,
                                  ),
                                ),
                                hintText: "Email",
                                hintStyle: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14),
                                fillColor: secondbackgroundColor,
                                filled: true,
                                border: inputBorder,
                                enabledBorder: inputBorder,
                                errorStyle:
                                const TextStyle(fontSize: 0.01),
                                errorBorder: OutlineInputBorder(
                                  borderSide:
                                  const BorderSide(color: Colors.red),
                                  borderRadius:
                                  BorderRadius.circular(15.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                  const BorderSide(color: Color(0xFFCEB69A)),
                                  borderRadius:
                                  BorderRadius.circular(10.0),
                                )
                              ),
                              style: textTheme.displayMedium?.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value != null &&
                                    !value.contains('@') ||
                                    !value!.contains('.')) {
                                  emailError = "Enter a valid Email";
                                  return emailError;
                                } else {
                                  emailError = null;
                                  return null;
                                }
                              }),
                        ),
                        // emailError != null && isSaved
                        //     ? errorMessage(emailError.toString())
                        //     : Container(),

                        SizedBox(
                          height: screenHeight * 0.025,
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: secondbackgroundColor,
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 10,
                                offset: Offset(1, 1),
                                color: Color.fromARGB(54, 188, 187, 187),
                              )
                            ],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: TextFormField(
                            controller: passwordController,
                            focusNode: passwordFocusNode,
                            cursorColor:
                            Color.fromARGB(224, 14, 187, 158),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 50,vertical: 20),
                              prefixIcon: Container(
                                width: 55,
                                height: 55,
                                margin: EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(color: theme,borderRadius: BorderRadius.circular(10),),
                                child: Icon(
                                  Icons.lock,
                                  color: Colors.white,
                                ),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isPressed = !isPressed;
                                  });
                                },
                                icon: isPressed
                                    ? Icon(Icons.visibility_off_outlined,
                                    color: passwordFocusNode.hasFocus
                                        ? const Color.fromARGB(
                                        224, 14, 187, 158)
                                        : Colors.grey)
                                    : Icon(Icons.visibility_outlined,
                                    color: passwordFocusNode.hasFocus
                                        ? const Color.fromARGB(
                                        224, 14, 187, 158)
                                        : Colors.grey),
                              ),
                              hintText: "Password",
                              hintStyle: TextStyle(
                                  color: Colors.grey[400], fontSize: 14),
                              fillColor: secondbackgroundColor,
                              filled: true,
                              border: inputBorder,
                              enabledBorder: inputBorder,
                              errorStyle: const TextStyle(fontSize: 0.01),
                              errorBorder: OutlineInputBorder(
                                borderSide:
                                const BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                  const BorderSide(color: Color(0xFFCEB69A)),
                                  borderRadius:
                                  BorderRadius.circular(10.0),
                                )
                            ),
                            style: textTheme.displayMedium?.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w400),
                            keyboardType: TextInputType.text,
                            obscureText: isPressed,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value != null && value.isEmpty) {
                                passwordError = 'Enter a password';
                                return passwordError;
                              } else if (value!.length < 8) {
                                passwordError =
                                'password length can\'t be lessthan 8';
                                return passwordError;
                              } else {
                                passwordError = null;
                                return null;
                              }
                            },
                          ),
                        ),
                        // passwordError != null && isSaved
                        //     ? errorMessage(passwordError.toString())
                        //     : Container(),
                        SizedBox(
                          height: screenHeight * 0.025,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            // onTap: () =>
                            // Get.toNamed(AppRoute.forgotpasswordPage),
                            child: Text(
                              "Forgot password?",
                              style: textTheme.titleLarge?.copyWith(
                                  color: Colors.black,
                                  fontSize: 15,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.036,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(10))),
                      fixedSize: Size(screenWidth * 0.5, 50),
                      backgroundColor: theme),
                  onPressed: login,
                  child: Text('Sign In',style: TextStyle(fontSize: 20,color: Colors.white),),
                ),
                SizedBox(
                  height: screenHeight * 0.025,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: Container(
                          color: Colors.grey,
                          height: 1,
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.016,
                      ),
                      const Text(
                        "Or",
                        style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                            fontSize: 17),
                      ),
                      SizedBox(
                        width: screenWidth * 0.016,
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(
                          color: Colors.grey,
                          height: 1,
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                            fixedSize: Size(screenWidth * 0.5, 50),
                            backgroundColor: theme),
                        onPressed: login,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              child: SvgPicture.asset("assets/images/google.svg"),
                            ),
                            SizedBox(width: 10,),
                            Text('Sign in with google',style: TextStyle(fontSize: 13,color: Colors.black,fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                      SizedBox(height: 20,),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                            fixedSize: Size(screenWidth * 0.5, 50),
                            backgroundColor: theme),
                        onPressed: login,
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              child: SvgPicture.asset("assets/images/facebook.svg",color:Color(0xFF1976D2),),
                            ),
                            SizedBox(width: 10,),
                            Expanded(child: Text('Sign in with facebook',style: TextStyle(fontSize: 13,color: Colors.black,fontWeight: FontWeight.bold),)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.032,
                ),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: "Don't have an account?",
                        style: textTheme.displayMedium?.copyWith(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w400)),
                    TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = widget.changePage,
                        text: " Sign Up",
                        style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 17,
                            fontWeight: FontWeight.w700))
                  ]),
                ),
                SizedBox(
                  height: screenHeight * 0.05,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future login() async {
    isSaved = false;
    final form = formkey.currentState!;
    setState(() {
      isSaved = true;
    });
    if (form.validate()) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: CircularProgressIndicator(color: Colors.green[900]),
          ));
      AuthController authController = Get.put(AuthController());
      await authController.loginUser(
          email: emailController.text,
          password: passwordController.text);

      if (authController.isAuthenticated.value) {
        Get.offAllNamed(AppRoutes.landingPage);
        ProfileController profileController = Get.put(ProfileController());
        await profileController.getAuthenticatedUser();
      } else {
        Navigator.pop(context);
        Flushbar(
          flushbarPosition: FlushbarPosition.BOTTOM,
          margin: const EdgeInsets.fromLTRB(10, 20, 10, 5),
          titleSize: 20,
          messageSize: 17,
          messageColor: Colors.red,
          backgroundColor: Colors.white,
          borderRadius: BorderRadius.circular(8),
          message: "unable to login",
          duration: const Duration(seconds: 5),
        ).show(context);
      }
    }
  }
}
