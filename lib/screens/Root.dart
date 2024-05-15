import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final/constants/Constants.dart';
import 'package:flutter_final/models/folder.dart';
import 'package:flutter_final/models/user.dart';
import 'package:flutter_final/screens/Create_Term.dart';
import 'package:flutter_final/screens/Home.dart';
import 'package:flutter_final/screens/Library.dart';
import 'package:flutter_final/services/Auth_Service.dart';
import 'package:flutter_final/services/Folder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Root extends StatefulWidget {
  const Root({Key? key}) : super(key: key);

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  int _bottomNavIndex = 0;
  User? currentUser;
  late String successTopic;
  late String successFolder;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    successTopic = 'success_topic';
    successFolder = 'success_folder';
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

  //List of the pages
  List<Widget> _widgetOptions() {
    return [
      Home(successTopic: successTopic),
      Library(successTopic: successTopic, successFolder: successFolder)
    ];
  }

  //List of the pages icons
  List<IconData> iconList = [
    Icons.home,
    Icons.library_books,
  ];

  //List of the pages titles
  List<String> titleList = [
    'Home',
    'Library',
  ];

  Future<void> _createFolder(
      String name, String description, String userId) async {
    try {
      final FolderService folderService = FolderService();
      await folderService.createFolder(name, description, userId, []);
      List<Folder> folders =
          await folderService.getFoldersByUserId(currentUser!.id);
      print('Danh sách thư mục mới:');
      folders.forEach((folder) {
        print('ID: ${folder.id}, Tên: ${folder.name}');
      });
      Navigator.of(context).pop('success_folder');
      setState(() {
        successFolder = 'success_folder';
      });
      print('Folder created successfully');
    } catch (error) {
      print('Error creating folder: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _bottomNavIndex,
        children: _widgetOptions(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.book),
                      title: const Text('Tạo học phần'),
                      onTap: () async {
                        // Mở Create_Term và nhận giá trị trả về
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Create_Term(),
                          ),
                        );

                        // Kiểm tra nếu kết quả là true (tạo thành công) thì thực hiện hành động tương ứng
                        if (result == true) {
                          Navigator.pop(context, 'success_topic');
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.folder),
                      title: const Text('Tạo thư mục'),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            String folderName = '';
                            String description = '';

                            return AlertDialog(
                              title: const Text('Tạo thư mục'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    onChanged: (value) {
                                      folderName = value;
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Tên thư mục',
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    onChanged: (value) {
                                      description = value;
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Mô tả',
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Hủy'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _createFolder(folderName, description,
                                        currentUser!.id);
                                  },
                                  child: const Text('Tạo'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        backgroundColor: Constants.primaryColor,
        child: const Icon(
          Icons.add,
          size: 30.0,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
          splashColor: Constants.primaryColor,
          activeColor: Constants.primaryColor,
          inactiveColor: Colors.black.withOpacity(.5),
          icons: iconList,
          activeIndex: _bottomNavIndex,
          gapLocation: GapLocation.center,
          notchSmoothness: NotchSmoothness.softEdge,
          onTap: (index) {
            setState(() {
              _bottomNavIndex = index;
            });
          }),
    );
  }
}
