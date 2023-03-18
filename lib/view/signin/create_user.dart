import 'package:fiwi/cubits/phone_signin/phone_signin_cubit.dart';
import 'package:fiwi/cubits/phone_signin/phone_signin_state.dart';
import 'package:fiwi/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateUser extends StatefulWidget {
  const CreateUser({super.key});

  @override
  State<StatefulWidget> createState() => CreateUserState();

}

class CreateUserState extends State<CreateUser> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(body:SafeArea(child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
              child: Column(
                children: [
                  
          
                  SizedBox(height: height * 0.03),
                  const Text(
                    "Create your Profile",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  SizedBox(height: height * 0.03),
                  TextFormField(
                    cursorColor: Colors.purple,
                    // controller: phoneController,
                    
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: "Enter phone number",
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: Colors.grey.shade600,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black12),
                      ),
                      prefixIcon: Container(
                          padding: const EdgeInsets.all(12.0),
                          child: const Text("+91",
                              style: TextStyle(fontSize: 17))),
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: BlocConsumer<PhoneSigninCubit, PhoneAuthState>(
                      listener: (context, state) {
                        if (state is PhoneAuthCodeSentState) {
                          Navigator.pushNamed(context, '/otp');
                        } else if (state is PhoneAuthErrorState) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(state.error),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ));
                        }
                      },
                      builder: (context, state) {
                        if (state is PhoneAuthLoadingState) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        return CustomButton(
                            text: "Send OTP",
                            icontext: false,
                            onPressed: () {
                              // String phone = "+91${phoneController.text}";
                              // BlocProvider.of<PhoneSigninCubit>(context)
                              //     .sendOtp(phone);
                            });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),));
  }

}
