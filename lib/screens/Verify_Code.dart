import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_final/constants/Constants.dart';
import 'package:flutter_final/screens/Login.dart';
import 'package:flutter_final/screens/Register.dart';
import 'package:flutter_final/screens/Root.dart';
import 'package:flutter_final/services/Auth_Service.dart';
import 'package:flutter_final/widgets/custom_textfield.dart';
import 'package:page_transition/page_transition.dart';

class Verify_Code extends StatefulWidget {
  final String email;
  final String password;
  const Verify_Code({Key? key, required this.email, required this.password})
      : super(key: key);

  @override
  _Verify_CodeState createState() => _Verify_CodeState();
}

class _Verify_CodeState extends State<Verify_Code> {
  late Timer _timer;
  int _minutes = 3;
  int _seconds = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (timer) {
        if (_minutes == 0 && _seconds == 0) {
          timer.cancel();
          Navigator.pushReplacement(
            context,
            PageTransition(
              child: const Register(),
              type: PageTransitionType.bottomToTop,
            ),
          );
        } else {
          setState(() {
            if (_seconds == 0) {
              _minutes -= 1;
              _seconds = 59;
            } else {
              _seconds -= 1;
            }
          });
        }
      },
    );
  }

  final TextEditingController _codeController = TextEditingController();

  Future<void> verifyCode() async {
    setState(() {
      _isLoading = true;
    });

    final code = int.parse(_codeController.text.trim());
    try {
      await AuthService.verifyCode(widget.email, code, widget.password);
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
          content: Text('Xác thực mã không thành công. Vui lòng thử lại.'),
        ),
      );
      print('Code verification failed: $error');
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
                  const Text('Mã xác nhận',
                      style: TextStyle(
                        fontSize: 35.0,
                        fontWeight: FontWeight.w700,
                      )),
                  if (_minutes > 0 || _seconds > 0) ...[
                    const SizedBox(
                      height: 30,
                    ),
                    CustomTextfield(
                      controller: _codeController,
                      obscureText: false,
                      hintText: 'Nhập mã xác nhận',
                      icon: Icons.numbers,
                    ),
                  ],
                  if (_minutes > 0 || _seconds > 0) ...[
                    const SizedBox(
                      height: 15,
                    ),
                    CountdownTimer(minutes: _minutes, seconds: _seconds),
                  ],
                  const SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    onTap: verifyCode,
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
                    height: 15,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          PageTransition(
                              child: const Login(),
                              type: PageTransitionType.bottomToTop));
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

class CountdownTimer extends StatelessWidget {
  final int minutes;
  final int seconds;

  const CountdownTimer({
    required this.minutes,
    required this.seconds,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
