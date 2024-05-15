import 'package:flutter/material.dart';
import 'package:flutter_final/constants/Constants.dart';
import 'package:flutter_final/screens/Login.dart';
import 'package:flutter_final/screens/Verify_Code.dart';
import 'package:flutter_final/services/Auth_Service.dart';
import 'package:flutter_final/widgets/custom_textfield.dart';
import 'package:page_transition/page_transition.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  bool isPasswordMatched(String password, String confirmPassword) {
    return password == confirmPassword;
  }

  void _register() async {
    final firstname = _firstnameController.text.trim();
    final lastname = _lastnameController.text.trim();
    final email = _emailController.text.trim();
    final mobile = _mobileController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (!isPasswordMatched(password, confirmPassword)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Lỗi'),
          content: const Text('Mật khẩu không hợp lệ.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.register(firstname, lastname, email, mobile, password);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Đăng ký thành công. Vui lòng kiểm tra email để nhập mã xác nhận.'),
        ),
      );
      Navigator.pushReplacement(
        context,
        PageTransition(
          child: Verify_Code(email: email, password: password),
          type: PageTransitionType.bottomToTop,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Đăng ký không thành công hoặc email đã được đăng ký. Vui lòng thử lại.'),
        ),
      );
      print('Register failed: $error');
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
                  Image.asset('assets/images/register.png'),
                  const Text(
                    'Đăng ký',
                    style: TextStyle(
                      fontSize: 35.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  CustomTextfield(
                    controller: _firstnameController,
                    obscureText: false,
                    hintText: 'Nhập tên',
                    icon: Icons.person,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  CustomTextfield(
                    controller: _lastnameController,
                    obscureText: false,
                    hintText: 'Nhập họ',
                    icon: Icons.person,
                  ),
                  const SizedBox(
                    height: 15,
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
                    controller: _mobileController,
                    obscureText: false,
                    hintText: 'Nhập số điện thoại',
                    icon: Icons.phone,
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
                    height: 15,
                  ),
                  CustomTextfield(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    hintText: 'Nhập lại mật khẩu',
                    icon: Icons.lock,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: _register,
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
                          'Đăng ký',
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
                          child: const Login(),
                          type: PageTransitionType.bottomToTop,
                        ),
                      );
                    },
                    child: Center(
                      child: Text.rich(
                        TextSpan(
                          children: [
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
