import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color bgcolor;
  final Color color;
  final IconData icon;
  final Color iconcolor;

  const CustomButton(
      {super.key,
      required this.text,
      required this.onPressed,
      this.bgcolor = Colors.white,
      this.color = Colors.purple,
      this.icon = Icons.adb,
      this.iconcolor = Colors.purple});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(color),
          backgroundColor: MaterialStateProperty.all<Color>(bgcolor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: const BorderSide(color: Colors.purple)),
          ),
        ),
        // icon: const Icon(Icons.group),
        // label:  Text(text, style: const TextStyle(fontSize: 16)),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.center,
          // mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: MediaQuery.of(context).size.width*0.04),
            icon==Icons.adb?Image.asset('assets/search32.png',width: MediaQuery.of(context).size.width*0.05,):Icon(icon,color: iconcolor),
            SizedBox(width: MediaQuery.of(context).size.width*0.05),
            Text(text, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
