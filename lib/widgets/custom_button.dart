import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color bgcolor;
  final Color color;
  final IconData icon;

  const CustomButton(
      {super.key,
      required this.text,
      required this.onPressed,
      this.bgcolor = Colors.white,
      this.color = Colors.purple,
      this.icon = Icons.adb});

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
                side: BorderSide(color: color)),
          ),
        ),
        // icon: const Icon(Icons.group),
        // label:  Text(text, style: const TextStyle(fontSize: 16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, style: const TextStyle(fontSize: 16)),
            SizedBox(width: MediaQuery.of(context).size.width*0.24),
            icon==Icons.adb?Image.asset('assets/search32.png'):Icon(icon)
          ],
        ),
      ),
    );
  }
}
