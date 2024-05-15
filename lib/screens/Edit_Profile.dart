import 'package:flutter/material.dart';
import 'package:flutter_final/constants/Constants.dart';
import 'package:flutter_final/models/user.dart';
import 'package:flutter_final/services/Auth_Service.dart';
import 'package:flutter_final/widgets/custom_textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Edit_Profile extends StatefulWidget {
  final User? currentUser;
  final Function(User) onUpdateProfile;

  const Edit_Profile({
    super.key,
    required this.currentUser,
    required this.onUpdateProfile,
  });

  @override
  _Edit_ProfileState createState() => _Edit_ProfileState();
}

class _Edit_ProfileState extends State<Edit_Profile> {
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.currentUser != null) {
      _firstnameController.text = widget.currentUser!.firstname;
      _lastnameController.text = widget.currentUser!.lastname;
      _mobileController.text = widget.currentUser!.mobile;
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    final firstname = _firstnameController.text.trim();
    final lastname = _lastnameController.text.trim();
    final mobile = _mobileController.text.trim();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('userId');

      if (userId != null) {
        await AuthService.updateUser(userId, firstname, lastname, mobile);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thông tin đã được cập nhật thành công!'),
            duration: Duration(seconds: 2),
          ),
        );

        widget.onUpdateProfile(
          User(
            id: widget.currentUser!.id,
            email: widget.currentUser!.email,
            password: widget.currentUser!.password,
            confirmationCode: widget.currentUser!.confirmationCode,
            images: widget.currentUser!.images,
            topicSaved: widget.currentUser!.topicSaved,
            firstname: firstname,
            lastname: lastname,
            mobile: mobile,
          ),
        );

        Navigator.of(context).pop();
      }
    } catch (error) {
      print('Update user info failed: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thông tin thất bại. Vui lòng thử lại.'),
          duration: Duration(seconds: 2),
        ),
      );
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
                    'Thay đổi thông tin',
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
                    hintText: 'Enter First Name',
                    icon: Icons.person,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  CustomTextfield(
                    controller: _lastnameController,
                    obscureText: false,
                    hintText: 'Enter Last Name',
                    icon: Icons.person,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  CustomTextfield(
                    controller: _mobileController,
                    obscureText: false,
                    hintText: 'Enter Mobile',
                    icon: Icons.phone,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    onTap: _updateProfile,
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
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
