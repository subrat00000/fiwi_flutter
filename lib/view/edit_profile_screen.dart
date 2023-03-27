import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fiwi/cubits/profile/profile_cubit.dart';
import 'package:fiwi/cubits/profile/profile_state.dart';
import 'package:fiwi/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool validation = false;
  final _formKey = GlobalKey<FormState>();
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

  _bottomModalTextField(String label, bool isTextArea) {
    modalController.clear();
    String elabel = edit + label.toUpperCase();
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
          );
        });
  }

  _bottomModalDropdown(String label) {
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
                            borderSide: const BorderSide(color: Colors.black12),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          hintStyle: const TextStyle(color: Colors.black12),
                        ),
                        items:
                            items.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        value: semesterValue,
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
                            // if (_formKey.currentState!.validate()) {
                            //   BlocProvider.of<CreateUserCubit>(context)
                            //       .createUser(
                            //           name.text,
                            //           email.text,
                            //           address.text,
                            //           selectedDate.toString());
                            // }
                          })
                    ]),
              ),
            ),
          );
        });
  }

  @override
  void initState() {
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
                                      onPressed: () {},
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
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl:
                                        'https://firebasestorage.googleapis.com/v0/b/fiwi-7c575.appspot.com/o/subrat3.png?alt=media&token=965ff841-d453-427d-8baf-03f14319351c',
                                    progressIndicatorBuilder: (context, url,
                                            downloadProgress) =>
                                        CircularProgressIndicator(
                                            value: downloadProgress.progress),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
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
                                        _bottomModalTextField(name, false);
                                      },
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Colors.grey,
                                      ))
                                ],
                              ),
                              Text(box.get('name'),
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
                                        _bottomModalTextField(bio, true);
                                      },
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Colors.grey,
                                      ))
                                ],
                              ),
                              Text(
                                  box.get('bio') != null
                                      ? box.get('bio')
                                      : 'Your bio',
                                  style: TextStyle(color: Colors.black87)),
                              SizedBox(height: height * 0.025),
                              Row(
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
                                        _bottomModalDropdown(sem);
                                      },
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Colors.grey,
                                      ))
                                ],
                              ),
                              Text(
                                  box.get('sem') != null
                                      ? box.get('sem')
                                      : 'Choose your Semester',
                                  style: TextStyle(color: Colors.black87)),
                              SizedBox(height: height * 0.015),
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
                                        _bottomModalTextField(address, false);
                                      },
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Colors.grey,
                                      ))
                                ],
                              ),
                              Text(
                                  box.get('address') != null
                                      ? box.get('address')
                                      : 'Your Address',
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
                              // SizedBox(height: height * 0.015),
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
                                  IconButton(
                                      alignment: Alignment.centerRight,
                                      onPressed: () {
                                        _bottomModalTextField(phone, false);
                                      },
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Colors.grey,
                                      ))
                                ],
                              ),

                              Text(
                                  box.get('phone') != null
                                      ? box.get('phone')
                                      : 'Your Phone number',
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
                                        _bottomModalTextField(birthday, false);
                                      },
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Colors.grey,
                                      ))
                                ],
                              ),
                              Text(
                                  box.get('birthday') != null
                                      ? box.get('birthday')
                                      : 'Your Birthday',
                                  style: TextStyle(color: Colors.black87)),
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
                                  IconButton(
                                      onPressed: () {
                                        _bottomModalTextField(
                                            email.substring(
                                                0, email.indexOf(' ')),
                                            false);
                                      },
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Colors.grey,
                                      ))
                                ],
                              ),
                              Text(
                                  box.get('email') != null
                                      ? box.get('email')
                                      : 'Your Email',
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
