import 'package:flutter/material.dart';
import 'package:flutter_final/screens/Onboarding.dart';
import 'package:flutter_final/screens/Root.dart';
import 'package:flutter_final/services/Auth_Service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      // Kiểm tra xem accessToken đã được lưu trữ hay chưa
      future: AuthService.isLoggedIn(),
      builder: (context, snapshot) {
        // Nếu có lỗi xảy ra trong quá trình kiểm tra
        if (snapshot.hasError) {
          return const MaterialApp(
            title: 'Error',
            home: Scaffold(
              body: Center(
                child: Text('Error'),
              ),
            ),
            debugShowCheckedModeBanner: false,
          );
        }
        // Nếu đang kiểm tra
        else if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            title: 'Loading',
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            debugShowCheckedModeBanner: false,
          );
        }
        // Nếu accessToken đã được lưu trữ, chuyển hướng đến trang Root
        else if (snapshot.data == true) {
          return const MaterialApp(
            title: 'Root',
            home: Root(),
            debugShowCheckedModeBanner: false,
          );
        }
        // Nếu accessToken chưa được lưu trữ, chuyển hướng đến trang Onboarding
        else {
          return const MaterialApp(
            title: 'Onboarding Screen',
            home: Onboarding(),
            debugShowCheckedModeBanner: false,
          );
        }
      },
    );
  }
}
