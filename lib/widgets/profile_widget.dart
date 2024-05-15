import 'package:flutter/material.dart';
import 'package:flutter_final/constants/Constants.dart';

class ProfileWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final Function()? onPressed; // Thêm thuộc tính Function() để xử lý onPressed

  const ProfileWidget({
    Key? key,
    required this.icon,
    required this.title,
    this.onPressed, // Chấp nhận hàm onPressed trong constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed, // Sử dụng hàm onPressed khi người dùng nhấn vào
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Constants.blackColor.withOpacity(.5),
                  size: 24,
                ),
                const SizedBox(
                  width: 16,
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: Constants.blackColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Constants.blackColor.withOpacity(.4),
              size: 16,
            )
          ],
        ),
      ),
    );
  }
}
