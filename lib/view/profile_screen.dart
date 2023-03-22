import 'package:cached_network_image/cached_network_image.dart';
import 'package:fiwi/cubits/google_signin/google_signin_cubit.dart';
import 'package:fiwi/cubits/google_signin/google_signin_state.dart';
import 'package:fiwi/cubits/internet_cubit.dart';
import 'package:fiwi/view/home_screen.dart';
import 'package:fiwi/view/splash_screen.dart';
import 'package:fiwi/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var internet = true;
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: SingleChildScrollView(
      child: Stack(
        children: [
          Column(
            children: <Widget>[
              Container(
                height: height * 0.17,
                color: Colors.purple[400],
              ),
              Align(
                alignment: Alignment.centerRight,
                child:Container(
                  
              width: width * 0.28,
              height: height * 0.04,
              margin: const EdgeInsets.all(6),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              decoration: BoxDecoration(color:Colors.white,border:Border.all(color: Color.fromARGB(255, 226, 226, 226),),borderRadius: BorderRadius.circular(30) ),
                child: TextButton(
                    onPressed: () {},
                    child: const Text("Edit Profile",
                        style: TextStyle(color: Colors.black))),
              ),),
              const SizedBox(height: 30),
              Center(
                  child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 105, horizontal: 35),
                child: Column(
                  children: [
                    Image.asset(
                      "assets/image1.png",
                      height: 300,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Let's get started",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Never a better time than now to start.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              )),
            ],
          ),
          Transform.translate(
              offset: Offset(width * 0.66, height * 0.04),
              child: Container(
                width: width * 0.12,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                decoration: const BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(45, 255, 255, 255),
                    offset: Offset(0.001, 0.001), //(x,y)
                    blurRadius: 0.05,
                  ),
                ], shape: BoxShape.circle),
                height: height * 0.12,
                child: IconButton(
                    onPressed: () {
                      var a;
                    },
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: Colors.white,
                    )),
              )),
          Transform.translate(
              offset: Offset(width * 0.82, height * 0.04),
              child: Container(
                width: width * 0.12,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                decoration: const BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(45, 255, 255, 255),
                    offset: Offset(0.001, 0.001), //(x,y)
                    blurRadius: 0.05,
                  ),
                ], shape: BoxShape.circle),
                height: height * 0.12,
                child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                    )),
              )),
          Transform.translate(
            offset: Offset(width * 0.03, -height * 0.013),
            child: Container(
              width: width * 0.28,
              height: height * 0.28,
              margin: const EdgeInsets.all(6),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              decoration: const BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.001, 0.001), //(x,y)
                  blurRadius: 0.05,
                ),
              ], shape: BoxShape.circle),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    decoration: const BoxDecoration(boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                      ),
                    ], shape: BoxShape.circle),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      child: CachedNetworkImage(
                        imageUrl: "http://via.placeholder.com/350x150",
                        fit: BoxFit.cover,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) =>
                                CircularProgressIndicator(
                                    value: downloadProgress.progress),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
