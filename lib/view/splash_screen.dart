import 'package:fiwi/cubits/internet_cubit.dart';
import 'package:fiwi/view/home_screen.dart';
import 'package:fiwi/view/splash_screen.dart';
import 'package:fiwi/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var internet = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Center(
                child: BlocConsumer<InternetCubit, InternetState>(
                    listener: (context, state) {
      if (state == InternetState.gained && internet == false) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Internet conntected"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
        internet = true;
      } else if (state == InternetState.lost) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("No Internet Connection found"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
        internet = false;
      }
    }, builder: (context, state) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            // custom button
            CustomButton(
              onPressed: () async {
                Navigator.pushNamed(context, "/googlesignin");
              },
              text: "Signin with Google",
              bgcolor: Colors.white,
              color: const Color.fromARGB(255, 139, 139, 139),
            ),
            const SizedBox(height: 20),
            CustomButton(
              onPressed: () async {
                Navigator.pushNamed(context, "/phonesignin");
              },
              text: "Signin with Phone",
              color: const Color.fromARGB(255, 139, 139, 139),
              icon: Icons.phone_outlined,
              iconcolor: const Color.fromARGB(255, 58, 190, 126),
            ),
            // const SizedBox(height: 20),
            // CustomButton(
            //   onPressed: () async {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => const HomeScreen(),
            //       ),
            //     );
            //   },
            //   text: "Signin with Email",
            //   color: const Color.fromARGB(255, 139, 139, 139),
            //   icon: Icons.email_outlined,
            //   iconcolor: Colors.red,
            // )
          ],
        ),
      );
    }))));
  }
}
