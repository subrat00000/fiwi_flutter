import 'package:firebase_auth/firebase_auth.dart';
import 'package:fiwi/cubits/create_user/create_user_cubit.dart';
import 'package:fiwi/cubits/create_user/create_user_state.dart';
import 'package:fiwi/cubits/phone_signin/phone_signin_cubit.dart';
import 'package:fiwi/cubits/phone_signin/phone_signin_state.dart';
import 'package:fiwi/repositories/exit.dart';
import 'package:fiwi/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateUser extends StatefulWidget {
  const CreateUser({super.key});

  @override
  State<StatefulWidget> createState() => CreateUserState();
}

class CreateUserState extends State<CreateUser> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool validation = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController address = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String? semesterValue;
  List<String> items = ['Semester 1', 'Semester 2', 'Semester 3', 'Semester 4'];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        fieldLabelText: "Date of Birth",
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    if (_auth.currentUser != null) {
      final googleProvider = _auth.currentUser!.providerData
          .any((provider) => provider.providerId == 'google.com');
      if(googleProvider){
        email.text = _auth.currentUser!.email!;
      }
    }
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () {
        return Exit().showExitDialog(context);
      },
      child: Scaffold(
          body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: height * 0.01),
                      const Text(
                        "Create your Profile",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: height * 0.03),
                      TextFormField(
                        validator: (value) {
                          if ((value!.isEmpty || value.length < 6) &&
                              validation) {
                            return 'Please enter a valid name';
                          }
                          return null;
                        },
                        controller: name,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black12),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelText: 'Full Name',
                        ),
                      ),
                      SizedBox(height: height * 0.03),
                      TextFormField(
                        validator: (value) {
                          final emailRegex =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
                          if ((value!.isEmpty || !emailRegex.hasMatch(value)) &&
                              validation) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        controller: email,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black12),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelText: 'Email Address',
                        ),
                      ),
                      SizedBox(height: height * 0.02),
                      CustomButton(
                          istextleft: true,
                          color: Colors.black54,
                          bordercolor: Colors.black12,
                          text: "Date of Birth(Optional)",
                          icontext: false,
                          onPressed: () => _selectDate(context)),
                      SizedBox(height: height * 0.03),
                      DropdownButtonFormField<String>(
                        validator: (value) {
                          if (value == null && validation) {
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
                      SizedBox(height: height * 0.03),
                      TextFormField(
                        controller: address,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black12),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelText: 'Current Address(Optional)',
                        ),
                      ),
                      SizedBox(height: height * 0.03),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: BlocConsumer<CreateUserCubit,
                            CreateUserProfileState>(
                          listener: (context, state) {
                            if (state is CreateUserProfileSuccessState) {
                              Navigator.pushNamed(context, '/inactive');
                            } else if (state is CreateUserProfileErrorState) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(state.e),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ));
                            }
                          },
                          builder: (context, state) {
                            if (state is CreateUserProfileLoadingState) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            return CustomButton(
                                text: "Submit",
                                icontext: false,
                                onPressed: () {
                                  validation = true;
                                  if (_formKey.currentState!.validate()) {
                                    BlocProvider.of<CreateUserCubit>(context)
                                        .createUser(
                                            name.text,
                                            email.text,
                                            address.text,
                                            selectedDate.toString(),
                                            semesterValue!);
                                  }
                                });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      )),
    );
  }
}
