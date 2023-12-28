import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool _obscureTextOld = true;
  bool _obscureTextNew = true;
  bool _obscureTextConfirm = true;

  String _selectedImagePath = "";

  void _toggleOld() {
    setState(() {
      _obscureTextOld = !_obscureTextOld;
    });
  }

  void _toggleNew() {
    setState(() {
      _obscureTextNew = !_obscureTextNew;
    });
  }

  void _toggleConfirm() {
    setState(() {
      _obscureTextConfirm = !_obscureTextConfirm;
    });
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final savedImage =
          await File(pickedFile.path).copy('${appDir.path}/$fileName.png');
      setState(() {
        _selectedImagePath = savedImage.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.white,
          flexibleSpace: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Text(
                  "Edit Profile",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 18),
                ),
                SizedBox(width: 50),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Center(
              child: GestureDetector(
                onTap: _selectImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.2,
                      foregroundImage: _selectedImagePath.isNotEmpty
                          ? FileImage(File(_selectedImagePath))
                              as ImageProvider<Object>
                          : NetworkImage(
                                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSj2j9hRj3vyP_BiTwRy9GHPD3yVvP9nt0GoQ&usqp=CAU")
                              as ImageProvider<Object>,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Transform.translate(
                        offset: Offset(
                          MediaQuery.of(context).size.width *
                              0.1 *
                              cos(145 * pi / 180),
                          MediaQuery.of(context).size.width *
                              0.1 *
                              sin(175 * pi / 180),
                        ),
                        child: Icon(Icons.camera_alt_rounded, color: Color.fromARGB(255, 212, 171, 124), size: MediaQuery.of(context).size.width * 1 / 16,),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 1 / 30,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 4),
                    child: Text(
                      "Name",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height *
                        1 /
                        16, // Set the height you want here
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Enter your full name",
                        fillColor: Colors.red,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0XFF8692A6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0XFFD7B894)),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                    child: Text(
                      "Email",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height *
                        1 /
                        16, // Set the height you want here
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Enter your e-mail address",
                        fillColor: Colors.red,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0XFF8692A6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0XFFD7B894)),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                    child: Text(
                      "Old Password",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height *
                        1 /
                        16, // Set the height you want here
                    child: TextField(
                      obscureText: _obscureTextOld,
                      decoration: InputDecoration(
                        hintText: "Enter your old password",
                        fillColor: Colors.red,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureTextOld
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: _toggleOld,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0XFF8692A6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0XFFD7B894)),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                    child: Text(
                      "New Password",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height *
                        1 /
                        16, // Set the height you want here
                    child: TextField(
                      obscureText: _obscureTextNew,
                      decoration: InputDecoration(
                        hintText: "Enter your new password",
                        fillColor: Colors.red,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureTextNew
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: _toggleNew,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0XFF8692A6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0XFFD7B894)),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                    child: Text(
                      "Confirm New Password",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height *
                        1 /
                        16, // Set the height you want here
                    child: TextField(
                      obscureText: _obscureTextConfirm,
                      decoration: InputDecoration(
                        hintText: "Confirm your new password",
                        fillColor: Colors.red,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureTextConfirm
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: _toggleConfirm,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0XFF8692A6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0XFFD7B894)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * (1 / 40),
                  ),
                  Center(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.black),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                      ),
                      onPressed: () {
                        // Put the action you want to happen when the button is pressed
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Save changes',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
