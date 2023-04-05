import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fiwi/cubits/profile/profile_cubit.dart';
import 'package:fiwi/cubits/profile/profile_state.dart';
import 'package:fiwi/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool validation = false;
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  DateTime? dateChecker;
  Box box = Hive.box('user');
  final _auth = FirebaseAuth.instance.currentUser;
  bool isSignedInWithGoogle = false;
  bool isSignedInWithPhone = false;
  String? semesterValue;
  List<String> items = ['Semester 1', 'Semester 2', 'Semester 3', 'Semester 4'];
  TextEditingController modalController = TextEditingController();
  String edit = 'EDIT ';
  String name = 'name';
  String bio = 'bio';
  String sem = 'semester';
  String address = 'address';
  String email = 'email address';
  String phone = 'phone';
  String birthday = 'birthday';
  String designation = 'designation';
  String qualification = 'qualification';
  String rollno = 'rollno';

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

  _bottomModalTextField(String label, bool isTextArea,String value) {
    modalController.clear();
    modalController.text = value;
    String elabel = edit + label.toUpperCase();
    showModalBottomSheet(
        backgroundColor: const Color(0x00ffffff),
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  )),
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 40,
                        ),
                        Text(elabel,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87)),
                        const SizedBox(height: 20),
                        Form(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          key: _formKey,
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty && validation) {
                                return 'Please enter a valid name';
                              }
                              return null;
                            },
                            maxLines: isTextArea ? null : 1,
                            minLines: isTextArea ? 4 : 1,
                            controller: modalController,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.black12),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelText: 'Your ${label.toLowerCase()}',
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        CustomButton(
                            text: "Submit",
                            icontext: false,
                            onPressed: () {
                              validation = true;
                              if (_formKey.currentState!.validate()) {
                                print('hello');
                                BlocProvider.of<ProfileCubit>(context)
                                    .saveData({label: modalController.text});
                                Navigator.pop(context);
                              }
                            })
                      ]),
                ),
              ),
            ),
          );
        });
  }

  _bottomModalDropdown(String label,String value) {
    String elabel = edit + label;
    showModalBottomSheet(
        backgroundColor: const Color(0x00ffffff),
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                )),
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(20),
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 40,
                        ),
                        Text(elabel,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87)),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          validator: (value) {
                            if (value == null) {
                              return 'Please Select your Semester';
                            }
                            return null;
                          },
                          hint: const Text("Semester"),
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Colors.black12),
                            ),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            hintStyle: const TextStyle(color: Colors.black12),
                          ),
                          items: items
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          value: semesterValue ?? vsemester,
                          onChanged: (String? value) {
                            setState(() {
                              semesterValue = value;
                            });
                          },
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        CustomButton(
                            text: "Submit",
                            icontext: false,
                            onPressed: () {
                              // validation = true;
                              if (_formKey.currentState!.validate()) {
                                print('hello');
                                BlocProvider.of<ProfileCubit>(context)
                                    .saveData({label: semesterValue!});
                                _loadData();
                                Navigator.pop(context);
                              }
                            })
                      ]),
                ),
              ),
            ),
          );
        });
  }

  _bottomModalDOB(String label) {
    dateChecker = null;
    DateTime dob = DateTime.parse(vbirthday!);
    String elabel = edit + label.toUpperCase();
    showModalBottomSheet(
        backgroundColor: const Color(0x00ffffff),
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  )),
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 40,
                        ),
                        Text(elabel,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87)),
                        const SizedBox(height: 20),
                        Form(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          key: _formKey,
                          child: CustomButton(
                              istextleft: true,
                              color: Colors.black54,
                              bordercolor: Colors.black12,
                              text: dateChecker != selectedDate
                                  ? vbirthday != ''
                                      ? DateFormat.yMMMMd().format(dob)
                                      : "Date of Birth"
                                  : DateFormat.yMMMMd().format(selectedDate),
                              icontext: false,
                              onPressed: () async {
                                final DateTime? picked = await showDatePicker(
                                    fieldLabelText: "Date of Birth",
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime(2100));
                                if (picked != null && picked != selectedDate) {
                                  setState(() {
                                    selectedDate = picked;
                                    dateChecker = picked;
                                  });
                                }
                              }),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        CustomButton(
                            text: "Submit",
                            icontext: false,
                            onPressed: () {
                              validation = true;
                              if (_formKey.currentState!.validate()) {
                                BlocProvider.of<ProfileCubit>(context)
                                    .saveData({label: selectedDate.toString()});
                                Navigator.pop(context);
                              }
                            })
                      ]),
                ),
              ),
            );
          });
        });
  }

  Future getImage() async {
    XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery,imageQuality: 25);

    if (context.mounted && image != null) {
      BlocProvider.of<ProfileCubit>(context).uploadImage(image);
    }
    
  }

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
    if (_auth != null) {
      final googleProvider = _auth!.providerData
          .any((provider) => provider.providerId == 'google.com');

      final phoneProvider =
          _auth!.providerData.any((provider) => provider.providerId == 'phone');
      setState(() {
        isSignedInWithGoogle = googleProvider;
        isSignedInWithPhone = phoneProvider;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateDataSuccessState) {
          _loadData();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Updated Successfully"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ));
        } else if (state is ProfileErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.error),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      child: Scaffold(
        appBar: AppBar(
            title: Text(
              'Edit Profile',
              style: TextStyle(color: Colors.black87),
            ),
            leading: IconButton(
              color: Colors.black54,
              icon: Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(0.2),
              child: Container(
                height: 0.2,
                color: Colors.grey[400],
              ),
            )),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  margin: EdgeInsets.only(
                      left: width * 0.02,
                      right: width * 0.02,
                      top: height * 0.02),
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
                              // SizedBox(height: height * 0.015),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("PROFILE PICTURE",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500)),
                                  SizedBox(width: 8),
                                  IconButton(
                                      alignment: Alignment.centerRight,
                                      onPressed: () =>getImage(),
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Colors.grey,
                                      ))
                                ],
                              ),
                              Container(
                                width: 80,
                                height: 80,
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
                                  child: photo != null &&
                                          photo != ''
                                      ? CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          imageUrl: photo!,
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              CircularProgressIndicator(
                                                  value: downloadProgress
                                                      .progress),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        )
                                      : Image.asset('assets/no_image.png'),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(name.toUpperCase(),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500)),
                                  IconButton(
                                      onPressed: () {
                                        _bottomModalTextField(name, false,vname!);
                                      },
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Colors.grey,
                                      ))
                                ],
                              ),
                              Text(vname!,
                                  style: TextStyle(color: Colors.black87)),
                              SizedBox(height: height * 0.025),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(bio.toUpperCase(),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500)),
                                  IconButton(
                                      onPressed: () {
                                        _bottomModalTextField(bio, true,vbio!);
                                      },
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Colors.grey,
                                      ))
                                ],
                              ),
                              Text(vbio!,
                                  style: TextStyle(color: Colors.black87)),
                              SizedBox(height: height * 0.025),
                              role=='student'?Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(sem.toUpperCase(),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                      SizedBox(width: 8),
                                    ],
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        _bottomModalDropdown(sem,vsemester!);
                                      },
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Colors.grey,
                                      ))
                                ],
                              ):Container(),
                              role=='student'?Text(vsemester!,
                                  style: TextStyle(color: Colors.black87)):Container(),
                              role=='student'?SizedBox(height:height*0.015):Container(),
                              role=='student'?Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(rollno.toUpperCase(),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                      SizedBox(width: 8),
                                    ],
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        _bottomModalTextField(rollno,false,vrollno!);
                                      },
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Colors.grey,
                                      ))
                                ],
                              ):Container(),
                              role=='student'?Text(vrollno!,
                                  style: TextStyle(color: Colors.black87)):Container(),
                              role=='student'?SizedBox(height:height*0.015):Container(),
                              role=='admin'?Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(designation.toUpperCase(),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                      SizedBox(width: 8),
                                    ],
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        _bottomModalTextField(designation,false,vdesignation!);
                                      },
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Colors.grey,
                                      ))
                                ],
                              ):Container(),
                              role=='admin'?Text(vdesignation!,style:TextStyle(color:Colors.black87)):Container(),
                              SizedBox(height: height * 0.015),
                              role=='admin'?Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(qualification.toUpperCase(),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                      SizedBox(width: 8),
                                    ],
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        _bottomModalTextField(qualification,false,vqualification!);
                                      },
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Colors.grey,
                                      ))
                                ],
                              ):Container(),
                              role=='admin'?Text(vqualification!,style:TextStyle(color:Colors.black87)):Container(),
                              role=='admin'?SizedBox(height: height * 0.015):Container(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(address.toUpperCase(),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                      SizedBox(width: 8),
                                    ],
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        _bottomModalTextField(address, false,vaddress!);
                                      },
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Colors.grey,
                                      ))
                                ],
                              ),
                              Text(vaddress!,
                                  style: TextStyle(color: Colors.black87)),
                              SizedBox(height: height * 0.015),
                            ],
                          ),
                        )
                      ],
                    ),
                  )),
              Container(
                  margin: EdgeInsets.only(
                      left: width * 0.02,
                      right: width * 0.02,
                      top: height * 0.02),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(phone.toUpperCase(),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                      SizedBox(width: 8),
                                      isSignedInWithPhone
                                          ? Row(
                                              children: [
                                                Container(
                                                    width: 5,
                                                    height: 5,
                                                    color: Colors.grey),
                                                SizedBox(width: 8),
                                                Text('VERIFIED',
                                                    style: TextStyle(
                                                        color: Colors.green)),
                                              ],
                                            )
                                          : Container(),
                                    ],
                                  ),
                                  !isSignedInWithPhone
                                      ? IconButton(
                                          alignment: Alignment.centerRight,
                                          onPressed: () {
                                            _bottomModalTextField(phone, false,vphone!);
                                          },
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            color: Colors.grey,
                                          ))
                                      : Container()
                                ],
                              ),
                              
                              Text(vphone!,
                                  style: TextStyle(color: Colors.black87)),
                              SizedBox(height: height * 0.025),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(birthday.toUpperCase(),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500)),
                                  IconButton(
                                      onPressed: () {
                                        _bottomModalDOB(birthday);
                                      },
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Colors.grey,
                                      ))
                                ],
                              ),
                              vbirthday!=''?Text(
                                  DateFormat.yMMMMd()
                                      .format(DateTime.parse(vbirthday!)),
                                  style: TextStyle(color: Colors.black87)):Container(),
                              SizedBox(height: height * 0.025),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(email.toUpperCase(),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                      SizedBox(width: 8),
                                      isSignedInWithGoogle
                                          ? Row(
                                              children: [
                                                Container(
                                                    width: 5,
                                                    height: 5,
                                                    color: Colors.grey),
                                                SizedBox(width: 8),
                                                Text('VERIFIED',
                                                    style: TextStyle(
                                                        color: Colors.green)),
                                              ],
                                            )
                                          : Container(),
                                    ],
                                  ),
                                  !isSignedInWithGoogle
                                      ? IconButton(
                                          onPressed: () {
                                            _bottomModalTextField(
                                                email.substring(
                                                    0, email.indexOf(' ')),
                                                false,vemail!);
                                          },
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            color: Colors.grey,
                                          ))
                                      : Container()
                                ],
                              ),
                              Text(vemail!,
                                  style: TextStyle(color: Colors.black87)),
                              SizedBox(height: height * 0.015),
                            ],
                          ),
                        )
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
