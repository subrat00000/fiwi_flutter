import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color bgcolor;
  final Color color;
  final IconData? icon;
  final String? imgicon;
  final Color iconcolor;
  final bool icontext;

  const CustomButton(
      {super.key,
      required this.text,
      required this.onPressed,
      this.bgcolor = Colors.white,
      this.color = Colors.purple,
      this.icon,
      this.imgicon,
      this.iconcolor = Colors.purple,
      this.icontext = true});

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
        child: icontext
            ? Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                  icon != null ? Icon(icon, color: iconcolor) : Container(),
                  imgicon != null
                      ? Image.asset(
                          imgicon!,
                          width: MediaQuery.of(context).size.width * 0.05,
                        )
                      : Container(),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                  Text(text, style: const TextStyle(fontSize: 16)),
                ],
              )
            : Center(
                child: Text(text, style: const TextStyle(fontSize: 16)),
              ),
      ),
    );
  }
}
