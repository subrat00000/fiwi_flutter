import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color bgcolor;
  final Color color;
  final Color bordercolor;
  final IconData? icon;
  final String? imgicon;
  final Color iconcolor;
  final bool icontext;
  final bool istextleft;
  final double elevation;
  final double borderRadius;
  

  const CustomButton(
      {super.key,
      required this.text,
      required this.onPressed,
      this.bgcolor = Colors.white,
      this.color = Colors.purple,
      this.icon,
      this.imgicon,
      this.iconcolor = Colors.purple,
      this.bordercolor = Colors.purple,
      this.istextleft = false,
      this.elevation = 0,
      this.icontext = true,
      this.borderRadius = 10});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(elevation),
          foregroundColor: MaterialStateProperty.all<Color>(color),
          backgroundColor: MaterialStateProperty.all<Color>(bgcolor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                side: BorderSide(color: bordercolor)),
          ),
        ),
        child: icontext
            ? Row(
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
            : istextleft
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      text,
                      textAlign: TextAlign.left,
                    ),
                  )
                : Center(
                    child: Text(text, style: const TextStyle(fontSize: 16)),
                  ),
      ),
    );
  }
}
