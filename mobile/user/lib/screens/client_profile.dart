import 'package:flutter/material.dart';

class ClientProfile extends StatefulWidget {
  const ClientProfile({Key? key}) : super(key: key);

  @override
  State<ClientProfile> createState() => _ClientProfileState();
}

class _ClientProfileState extends State<ClientProfile> {
  String backUrl = "https://i.ibb.co/7nGpWFf/photo-2023-01-19-20-32-55.jpg";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: double.infinity,
        child: Stack(
            fit: StackFit.loose,
            children: [
              Stack(
                fit: StackFit.loose,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0),topRight: Radius.circular(16.0)),
                    child: Image.network(
                      backUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.27,
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios, // Use the less than ("<") icon
                        color: Colors.white, // Set the color to black
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
              Positioned(
                top: MediaQuery.of(context).size.height*0.135,
                left: 0,
                right: 0,
                child: buildImage()
              ),
              Center(child: Text("Nebil Mesfin",style: TextStyle(color: Color.fromARGB(255, 36, 39, 96),fontSize: 21),),)
            ]
        ),
      ),
    );
  }
  Widget buildImage() {
   String image = "https://i.ibb.co/QQdbCzs/20230830-145110.jpg";
    return ClipOval(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle
        ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: CircleAvatar(
            radius: 90,
            child: ClipOval(
              child: Image.network(image),
            )
          ),
        ),
      ),
    );
  }
}