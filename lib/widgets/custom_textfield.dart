import 'package:flutter/material.dart';
import 'package:flutter_final/constants/Constants.dart';

class CustomTextfield extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final bool obscureText;
  final String hintText;

  const CustomTextfield({
    super.key,
    required this.controller,
    required this.icon,
    required this.obscureText,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(
        color: Constants.blackColor,
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: Icon(
          icon,
          color: Constants.blackColor.withOpacity(.3),
        ),
        hintText: hintText,
      ),
      cursorColor: Constants.blackColor.withOpacity(.5),
    );
  }
}
