import 'package:flutter/material.dart';
import 'package:flutter_final/models/folder.dart';
import 'package:flutter_final/models/topic.dart';
import 'package:flutter_final/models/user.dart';
import 'package:flutter_final/screens/Choose_Add_Term.dart';
import 'package:flutter_final/services/Auth_Service.dart';
import 'package:flutter_final/services/Folder.dart';
import 'package:flutter_final/services/Topic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Detail_Folder extends StatefulWidget {
  final Folder folder;
  final String userName;

  const Detail_Folder({Key? key, required this.folder, required this.userName})
      : super(key: key);

  @override
  _DetailFolderPageState createState() => _DetailFolderPageState();
}

class _DetailFolderPageState extends State<Detail_Folder> {
  final TopicService topicService = TopicService();
  List<Topic> topics = [];
  User? currentUser;
  late Folder folder;
  List<User> users = [];
  List<User> filteredUsers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFolder();
    folder = widget.folder;
    _loadTopics();
    _loadUsers();
    _getCurrentUser();

    if (true) {
      _loadFolder();
      _loadTopics();
      _loadUsers();
      _getCurrentUser();
      setState(() {
        folder;
      });
    }
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

  Future<void> _loadFolder() async {
    try {
      final FolderService folderService = FolderService();
      final Folder fetchedFolder =
          await folderService.getFolder(widget.folder.id);
      setState(() {
        folder = fetchedFolder;
      });
      print("Data folder new: $folder");
    } catch (error) {
      print('Error loading folder: $error');
    }
  }

  Future<void> _loadUsers() async {
    try {
      final List<User> fetchedUsers = await AuthService.getUsers();
      setState(() {
        users = fetchedUsers;
      });
      print("List User: $users");
    } catch (error) {
      print('Error loading users: $error');
    }
  }

  Future<void> _loadTopics() async {
    try {
      final List<Topic> fetchedTopics = await topicService.getAllTopics();

      final List<Topic> filteredTopics = fetchedTopics.where((topic) {
        return folder.topics.contains(topic.id);
      }).toList();

      setState(() {
        topics = filteredTopics;
        filteredUsers =
            _filterUsers(topics.map((topic) => topic.user).toList());
      });
    } catch (e) {
      print('Error loading topics: $e');
    }
  }

  List<User> _filterUsers(List<String> userIds) {
    return users.where((user) => userIds.contains(user.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _showBottomSheet(context);
            },
          ),
        ],
        title: const Text("Thư mục"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 16, 211, 120),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  folder.name,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Text(
                      '${folder.topics.length} Học phần',
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '|',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SvgPicture.asset(
                      'assets/images/circle_person.svg',
                      width: 30,
                      height: 30,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.userName,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: topics.length,
              itemBuilder: (context, index) {
                final topic = topics[index];
                String userName = _getUserName(topics[index].user);
                return InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  topic.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${topic.terms.length} thuật ngữ',
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/circle_person.svg',
                                      width: 30,
                                      height: 30,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      userName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
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

  String _getUserName(String userId) {
    User? user = filteredUsers.firstWhere(
      (user) => user.id == userId,
      orElse: () => User(
        id: '',
        firstname: '',
        lastname: '',
        email: '',
        mobile: '',
        password: '',
        images: '',
        topicSaved: [],
        confirmationCode: '',
      ),
    );
    return '${user.lastname} ${user.firstname}';
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Sửa'),
                onTap: () {
                  _editFolder(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Thêm học phần'),
                onTap: () {
                  _navigateToAddTerm(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Xóa'),
                onTap: () {
                  Navigator.of(context).pop();
                  _confirmDeleteFolder(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToAddTerm(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Choose_Add_Term(folder: folder),
      ),
    );
    if (result == true) {
      _loadFolder();
      _loadTopics();
      _loadUsers();
      _getCurrentUser();
      setState(() {
        folder;
      });
    }
  }

  void _editFolder(BuildContext context) async {
    TextEditingController nameController =
        TextEditingController(text: folder.name);
    TextEditingController descriptionController =
        TextEditingController(text: folder.description);

    setState(() {
      _isLoading = true;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sửa thư mục'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên thư mục',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                String newName = nameController.text;
                String newDescription = descriptionController.text;
                await _updateFolder(context, newName, newDescription);
                setState(() {
                  _isLoading = false;
                });
                Navigator.of(context).pop(true);
                Navigator.of(context).pop(true);
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteFolder(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa thư mục này?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _deleteFolder(context);
                Navigator.of(context).pop(true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Xóa thành công'),
                    duration: Duration(seconds: 2),
                  ),
                );
                final FolderService folderService = FolderService();
                List<Folder> folders =
                    await folderService.getFoldersByUserId(currentUser!.id);
                print('Danh sách thư mục mới:');
                folders.forEach((folder) {
                  print('ID: ${folder.id}, Tên: ${folder.name}');
                });
                Navigator.of(context).pop(true);
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateFolder(
      BuildContext context, String newName, String newDescription) async {
    try {
      FolderService folderService = FolderService();
      await folderService.updateFolder(folder.id, newName, newDescription);
      // Truyền dữ liệu mới của folder khi cập nhật thành công
      var updatedFolderData = {
        'name': newName,
        'description': newDescription,
        'id': folder.id
      };
      Navigator.of(context).pop(updatedFolderData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thành công'),
          duration: Duration(seconds: 2),
        ),
      );
      print("Dữ liệu của folder sau khi update: $updatedFolderData");
    } catch (error) {
      print('Error updating folder: $error');
    }
  }

  Future<void> _deleteFolder(BuildContext context) async {
    try {
      FolderService folderService = FolderService();
      await folderService.deleteFolder(folder.id);
    } catch (error) {
      print('Error deleting folder: $error');
    }
  }
}
