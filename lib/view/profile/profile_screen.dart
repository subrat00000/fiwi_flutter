import 'package:cached_network_image/cached_network_image.dart';
import 'package:fiwi/cubits/auth/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<String> items = ['Log Out'];
  Box box = Hive.box('user');
  var internet = true;
  String? photo;
  String? vname;
  String? vbio;
  String? vsemester;
  String? vaddress;
  String? vemail;
  String? vphone;
  String? vbirthday;
  String? role;
  String? vdesignation;
  String? vqualification;
  String? vrollno;

  _loadData() {
    setState(() {
      photo = box.get('photo') ?? '';
      vname = box.get('name') ?? '';
      vbio = box.get('bio') ?? '';
      vsemester = box.get('semester') ?? '';
      vaddress = box.get('address') ?? '';
      vemail = box.get('email') ?? '';
      vphone = box.get('phone') ?? '';
      vbirthday = box.get('birthday') ?? '';
      role = box.get('role') ?? '';
      vdesignation = box.get('designation') ?? '';
      vqualification = box.get('qualification') ?? '';
      vrollno = box.get('rollno') ?? '';
    });
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: SingleChildScrollView(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                height: height * 0.17,
                color: Colors.purple[400],
              ),
              // Container( child:,
              //           // width: width * 0.28,
              //           ),
              Container(
                // height: height * 0.2,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color.fromARGB(255, 226, 226, 226),
                    ),
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10))),
                child: Container(
                  margin: EdgeInsets.only(left: width * 0.05),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: width * 0.28,
                          height: height * 0.04,
                          margin: const EdgeInsets.all(6),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color.fromARGB(255, 226, 226, 226),
                              ),
                              borderRadius: BorderRadius.circular(30)),
                          child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/editprofile')
                                    .then((_) => _loadData());
                              },
                              child: const Text('Edit Profile',
                                  style: TextStyle(color: Colors.black))),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(vname!,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(width: 8),
                                role == 'student'
                                    ? Container(
                                        width: 5, height: 5, color: Colors.grey)
                                    : Container(),
                                const SizedBox(width: 8),
                                role == 'student'
                                    ? Text(vsemester!,
                                        style:
                                            TextStyle(color: Colors.grey[600]))
                                    : Container(),
                                const SizedBox(width: 8),
                                role == 'student' && vrollno != ''
                                    ? Container(
                                        width: 5, height: 5, color: Colors.grey)
                                    : Container(),
                                const SizedBox(width: 8),
                                role == 'student' && vrollno != ''
                                    ? Text(vrollno!,
                                        style:
                                            TextStyle(color: Colors.grey[600]))
                                    : Container()
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(vbio!,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontSize: 14,
                                )),
                            const SizedBox(height: 8),
                            Text(vaddress!,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  color: Colors.black45,
                                  fontSize: 12,
                                )),
                            const SizedBox(height: 10),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: height * 0.02,
              ),
              Container(
                  margin:
                      EdgeInsets.only(left: width * 0.02, right: width * 0.02),
                  // height: height * 0.2,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color.fromARGB(255, 226, 226, 226),
                      ),
                      borderRadius: BorderRadius.circular(10)),
                  child: Container(
                    margin: EdgeInsets.only(
                      left: width * 0.05,
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: height * 0.015),
                              Row(
                                children: [
                                  const Text("PHONE",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500)),
                                  const SizedBox(width: 8),
                                  Container(
                                      width: 5, height: 5, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  const Text('VERIFIED',
                                      style: TextStyle(color: Colors.green)),
                                ],
                              ),
                              Text(vphone!,
                                  style: const TextStyle(color: Colors.black87)),
                              SizedBox(height: height * 0.025),
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("BIRTHDAY",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                              vbirthday!=''?Text(
                                  DateFormat.yMMMMd()
                                      .format(DateTime.parse(vbirthday!)),
                                  style: const TextStyle(color: Colors.black87)):Container(),
                              SizedBox(height: height * 0.025),
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("EMAIL",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                              Text(vemail!,
                                  style: const TextStyle(color: Colors.black87)),
                              SizedBox(height: height * 0.015),
                            ],
                          ),
                        )
                      ],
                    ),
                  ))
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
                child: PopupMenuButton(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: Colors.white,
                  ),
                  onSelected: (value) {
                    if (value == 0) {
                      BlocProvider.of<AuthCubit>(context).logOut();
                      Navigator.pop(context);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<int>(
                        value: 0,
                        child: Text("Log Out"),
                      ),
                    ];
                  },
                ),
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
                    child: photo != null && photo != ''
                        ? CachedNetworkImage(
                            fit: BoxFit.contain,
                            imageUrl: photo!,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                        value: downloadProgress.progress),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          )
                        : Image.asset('assets/no_image.png'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
