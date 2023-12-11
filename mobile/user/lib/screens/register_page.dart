import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../routes/app_routes.dart';
import '../services/auth_controller.dart';
import '../services/profile_controller.dart';
import '../utils/colors.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback changePage;

  const RegisterPage({super.key, required this.changePage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? nameError,emailError, passwordError;
  late FocusNode nameFocusNode,emailFocusNode, passwordFocusNode;

  @override
  void initState() {
    super.initState();
    nameFocusNode = FocusNode();
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    nameFocusNode.addListener(() => setState(() {}));
    emailFocusNode.addListener(() => setState(() {}));
    passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();

    super.dispose();
  }

  bool isSaved = false;
  bool isPressed = true;
  bool isLoading = false;

  final formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
        borderSide: BorderSide(color: theme),
        borderRadius: BorderRadius.circular(15));

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
                        "Sign Up",
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
                              controller: nameController,
                              focusNode: nameFocusNode,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              cursorColor: Color.fromARGB(224, 14, 187, 158),
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 30,vertical: 0),
                                  hintText: "Full name",
                                  hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14),
                                  fillColor: Color.fromARGB(233, 233, 233, 233),
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
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value != null&& value.isEmpty) {
                                  nameError = "Enter a valid name";
                                  return nameError;
                                }
                                if(value?.split(" ").length == 1){
                                  nameError = "Enter your last name";
                                  return nameError;
                                }
                                else{
                                  nameError = null;
                                  return null;
                                }
                              }),
                        ),
                        nameError != null && isSaved
                            ? errorMessage(nameError.toString())
                            : Container(),

                        Container(
                          margin: EdgeInsets.only(top: 15),
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
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              cursorColor: Color.fromARGB(224, 14, 187, 158),
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 30,vertical: 0),
                                  hintText: "Email",
                                  hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14),
                                  fillColor: Color.fromARGB(233, 233, 233, 233),
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
                        emailError != null && isSaved
                            ? errorMessage(emailError.toString())
                            : Container(),
                        Container(
                          margin: EdgeInsets.only(top: 15),
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
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            cursorColor: Color.fromARGB(224, 14, 187, 158),
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 0),
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
                                fillColor: Color.fromARGB(233, 233, 233, 233),
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
                        passwordError != null && isSaved
                            ? errorMessage(passwordError.toString())
                            : Container(),
                        SizedBox(
                          height: screenHeight * 0.025,
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
                  onPressed: signup,
                  child: Text('Sign Up',style: TextStyle(fontSize: 20,color: Colors.white),),
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
                        onPressed: signup,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              child: SvgPicture.asset("assets/images/google.svg"),
                            ),
                            SizedBox(width: 10,),
                            Text('Sign up with google',style: TextStyle(fontSize: 13,color: Colors.black,fontWeight: FontWeight.bold),),
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
                        onPressed: signup,
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              child: SvgPicture.asset("assets/images/facebook.svg",color:Color(0xFF1976D2),),
                            ),
                            SizedBox(width: 10,),
                            Expanded(child: Text('Sign up with facebook',style: TextStyle(fontSize: 13,color: Colors.black,fontWeight: FontWeight.bold),)),
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
                        text: "Already have an account?",
                        style: textTheme.displayMedium?.copyWith(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w400)),
                    TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = widget.changePage,
                        text: " Sign in",
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

  Future signup() async {
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
      await authController.register(
          email: emailController.text,
          firstName: nameController.text.split(" ")[0],
          lastName: nameController.text.split(" ")[1],
          password: passwordController.text);

      Navigator.pop(context);
      if (authController.isRegistered.isTrue) {
        Get.offAllNamed(AppRoutes.authPage);
        if (mounted) {
          Flushbar(
            flushbarPosition: FlushbarPosition.BOTTOM,
            margin: const EdgeInsets.fromLTRB(10, 20, 10, 5),
            titleSize: 20,
            messageSize: 17,
            backgroundColor: Colors.green,
            borderRadius: BorderRadius.circular(8),
            message: authController.statusMessage.toString(),
            duration: const Duration(seconds: 5),
          ).show(context);
        }
      } else {
        if (mounted) {
          Flushbar(
            flushbarPosition: FlushbarPosition.BOTTOM,
            margin: const EdgeInsets.fromLTRB(10, 20, 10, 5),
            titleSize: 20,
            messageSize: 17,
            backgroundColor: Colors.red,
            borderRadius: BorderRadius.circular(8),
            message: authController.statusMessage.toString(),
            duration: const Duration(seconds: 5),
          ).show(context);
        }
      }
    }
  }
  Widget errorMessage(String? error) {
    return Container(
        alignment: Alignment.topLeft,
        margin: const EdgeInsets.only(top: 5, left: 10),
        child: Text(
          error.toString(),
          style: const TextStyle(color: Colors.red),
        ));
  }
  }
