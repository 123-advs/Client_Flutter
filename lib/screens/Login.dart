import 'package:flutter/material.dart';
import 'package:flutter_final/constants/Constants.dart';
import 'package:flutter_final/screens/Forgot_Password.dart';
import 'package:flutter_final/screens/Register.dart';
import 'package:flutter_final/screens/Root.dart';
import 'package:flutter_final/widgets/custom_textfield.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_final/services/auth_service.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.login(email, password);
      Navigator.pushReplacement(
        context,
        PageTransition(
          child: const Root(),
          type: PageTransitionType.bottomToTop,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng nhập không thành công. Vui lòng thử lại.'),
        ),
      );
      print('Login failed: $error');
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
                  Image.asset('assets/images/login.png'),
                  const Text(
                    'Đăng nhập',
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
                  CustomTextfield(
                    controller: _passwordController,
                    obscureText: true,
                    hintText: 'Nhập mật khẩu',
                    icon: Icons.lock,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: _login,
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
                          'Đăng nhập',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageTransition(
                          child: const Forgot_Password(),
                          type: PageTransitionType.bottomToTop,
                        ),
                      );
                    },
                    child: Center(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Quên mật khẩu? ',
                              style: TextStyle(
                                color: Constants.blackColor,
                              ),
                            ),
                            TextSpan(
                              text: 'Reset Here',
                              style: TextStyle(
                                color: Constants.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('HOẶC'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: size.width,
                    decoration: BoxDecoration(
                      border: Border.all(color: Constants.primaryColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 15,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          height: 30,
                          child: Image.asset('assets/images/google.png'),
                        ),
                        Text(
                          'Đăng nhập với Google',
                          style: TextStyle(
                            color: Constants.blackColor,
                            fontSize: 18.0,
                          ),
                        ),
                      ],
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
                          child: const Register(),
                          type: PageTransitionType.bottomToTop,
                        ),
                      );
                    },
                    child: Center(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Chưa có tài khoản? ',
                              style: TextStyle(
                                color: Constants.blackColor,
                              ),
                            ),
                            TextSpan(
                              text: 'Đăng ký',
                              style: TextStyle(
                                color: Constants.primaryColor,
                              ),
                            ),
                          ],
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
