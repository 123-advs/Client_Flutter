import 'package:flutter/material.dart';
import 'package:flutter_final/constants/Constants.dart';
import 'package:flutter_final/models/user.dart';
import 'package:flutter_final/screens/Change_Password.dart';
import 'package:flutter_final/screens/Edit_Profile.dart';
import 'package:flutter_final/screens/Login.dart';
import 'package:flutter_final/screens/TopicPublic.dart';
import 'package:flutter_final/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('userId');

      if (userId != null) {
        final User? user = await AuthService.getUserById(userId);
        setState(() {
          currentUser = user;
        });
      }
    } catch (error) {
      print('Error getting current user: $error');
    }
  }

  void _handleChangePasswordPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Change_Password()),
    );
  }

  void _handleEditProfilePressed() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Edit_Profile(
          currentUser: currentUser,
          onUpdateProfile: (User updatedUser) {
            setState(() {
              currentUser = updatedUser;
            });
          },
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _handleLogoutPressed();
                Navigator.of(context).pop();
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  void _handleTopicPublicPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TopicPublic()),
    );
  }

  void _handleLogoutPressed() async {
    try {
      await AuthService.logout();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    } catch (error) {
      print('Failed to logout: $error');
    }
  }

  void _handleGalleryTap() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      try {
        User? updatedUser = await AuthService.updateImage(pickedImage.path);
        if (updatedUser != null) {
          setState(() {
            currentUser = updatedUser;
          });
        }
      } catch (error) {
        print('Error updating image: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            color: Constants.blackColor,
            fontWeight: FontWeight.w500,
            fontSize: 24,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Constants.blackColor,
          ),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          height: size.height,
          width: size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: _handleGalleryTap,
                child: Container(
                  width: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Constants.primaryColor.withOpacity(.5),
                      width: 5.0,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: currentUser?.images != null &&
                            currentUser!.images.isNotEmpty
                        ? NetworkImage(currentUser!.images)
                        : const AssetImage('assets/images/circle_person.jpg')
                            as ImageProvider,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text(
                      '${currentUser?.lastname ?? ''} ${currentUser?.firstname ?? 'Loading...'}',
                      style: TextStyle(
                        color: Constants.blackColor,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      height: 24,
                      child: Image.asset("assets/images/verified.png"),
                    ),
                  ],
                ),
              ),
              Text(
                currentUser?.email ?? 'Loading...',
                style: TextStyle(
                  color: Constants.blackColor.withOpacity(.3),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: size.width,
                child: InkWell(
                  onTap: _handleChangePasswordPressed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lock,
                              color: Constants.blackColor.withOpacity(.5),
                              size: 24,
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Text(
                              'Thay đổi mật khẩu',
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
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: size.width,
                child: InkWell(
                  onTap: _handleEditProfilePressed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: Constants.blackColor.withOpacity(.5),
                              size: 24,
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Text(
                              'Thay đổi thông tin',
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
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: size.width,
                child: InkWell(
                  onTap: _handleTopicPublicPressed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.book,
                              color: Constants.blackColor.withOpacity(.5),
                              size: 24,
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Text(
                              'Danh sách học phần public',
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
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: size.width,
                child: InkWell(
                  onTap: _showLogoutConfirmationDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.logout_sharp,
                              color: Constants.blackColor.withOpacity(.5),
                              size: 24,
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Text(
                              'Đăng xuất',
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
