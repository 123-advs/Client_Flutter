import 'package:flutter/material.dart';
import 'package:flutter_final/constants/Constants.dart';
import 'package:flutter_final/screens/Login.dart';
import 'package:flutter_final/services/Auth_Service.dart';
import 'package:flutter_final/widgets/custom_textfield.dart';
import 'package:page_transition/page_transition.dart';

class Forgot_Password extends StatefulWidget {
  const Forgot_Password({super.key});

  @override
  _Forgot_PasswordState createState() => _Forgot_PasswordState();
}

class _Forgot_PasswordState extends State<Forgot_Password> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _forgotPassword() async {
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    try {
      await AuthService.forgot_password(email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Đã có mật khẩu mới. Vui lòng kiểm tra email để đăng nhập với mật khẩu mới.'),
        ),
      );
      Navigator.pushReplacement(
        context,
        PageTransition(
          child: const Login(),
          type: PageTransitionType.bottomToTop,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email không tồn tại. Vui lòng thử lại.'),
        ),
      );
      print('Reset Password failed: $error');
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
                    'Quên\nMật khẩu',
                    style: TextStyle(
                      fontSize: 35.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  CustomTextfield(
                    controller: _emailController,
                    obscureText: false,
                    hintText: 'Nhập email',
                    icon: Icons.alternate_email,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    onTap: _forgotPassword,
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
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageTransition(
                          child: const Login(),
                          type: PageTransitionType.bottomToTop,
                        ),
                      );
                    },
                    child: Center(
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: 'Đã có tài khoản? ',
                            style: TextStyle(
                              color: Constants.blackColor,
                            ),
                          ),
                          TextSpan(
                            text: 'Đăng nhập',
                            style: TextStyle(
                              color: Constants.primaryColor,
                            ),
                          ),
                        ]),
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
