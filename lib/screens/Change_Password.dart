import 'package:flutter/material.dart';
import 'package:flutter_final/constants/Constants.dart';
import 'package:flutter_final/services/Auth_Service.dart';
import 'package:flutter_final/widgets/custom_textfield.dart';

class Change_Password extends StatefulWidget {
  const Change_Password({super.key});

  @override
  _Change_PasswordState createState() => _Change_PasswordState();
}

class _Change_PasswordState extends State<Change_Password> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  Future<void> _changePassword() async {
    setState(() {
      _isLoading = true;
    });

    final String oldPassword = _oldPasswordController.text.trim();
    final String newPassword = _newPasswordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu không trùng khớp!'),
          duration: Duration(seconds: 2),
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      await AuthService.changePassword(oldPassword, newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu đã thay đổi thành công!.'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu thay đổi thất bại!. Vui lòng thử lại.'),
          duration: Duration(seconds: 2),
        ),
      );
      print('Change password failed: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/reset-password.png'),
                  const Text(
                    'Thay đổi mật khẩu',
                    style: TextStyle(
                      fontSize: 35.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  CustomTextfield(
                    controller: _oldPasswordController,
                    obscureText: true,
                    hintText: 'Enter Old Password',
                    icon: Icons.lock,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  CustomTextfield(
                    controller: _newPasswordController,
                    obscureText: true,
                    hintText: 'Enter New Password',
                    icon: Icons.lock,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  CustomTextfield(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    hintText: 'Confirm New Password',
                    icon: Icons.lock,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    onTap: _changePassword,
                    child: Container(
                      width: size.width,
                      decoration: BoxDecoration(
                        color: Constants.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 20,
                      ),
                      child: const Center(
                        child: Text(
                          'Xác nhận',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
