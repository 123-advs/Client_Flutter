import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_final/models/folder.dart';
import 'package:flutter_final/models/topic.dart';
import 'package:flutter_final/models/user.dart';
import 'package:flutter_final/screens/Detail_Folder.dart';
import 'package:flutter_final/screens/Detail_Term.dart';
import 'package:flutter_final/services/Auth_Service.dart';
import 'package:flutter_final/services/Folder.dart';
import 'package:flutter_final/services/Topic.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Library extends StatefulWidget {
  final String? successTopic;
  final String? successFolder;
  const Library({Key? key, this.successTopic, this.successFolder});

  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<Library> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'HỌC PHẦN'),
            Tab(text: 'THƯ MỤC'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          HocPhanPage(
              successTopic: widget.successTopic,
              successFolder: widget.successFolder),
          ThuMucPage(
              successTopic: widget.successTopic,
              successFolder: widget.successFolder),
        ],
      ),
    );
  }
}

class HocPhanPage extends StatefulWidget {
  final String? successTopic;
  final String? successFolder;

  HocPhanPage({Key? key, this.successTopic, this.successFolder})
      : super(key: key);
  @override
  _HocPhanPageState createState() => _HocPhanPageState();
}

class _HocPhanPageState extends State<HocPhanPage> {
  final TopicService topicService = TopicService();
  List<Topic> topics = [];
  late TextEditingController _searchController = TextEditingController();
  User? currentUser;
  List<User> users = [];
  List<User> usersSave = [];
  List<User> filteredUsers = [];
  List<User> filteredUsersSave = [];
  List<String> topicSavedIds = [];
  List<Topic> allTopic = [];
  List<Topic> savedTopics = [];
  String? success_topic;

  @override
  void initState() {
    super.initState();
    _reloadData();
    _getCurrentUser();
    _loadTopicsUser();
    _loadUsers();
    _loadSavedTopics();
    success_topic = widget.successTopic;
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
        topicSavedIds = currentUser?.topicSaved ?? [];
        print("topicSavedIds: $topicSavedIds");
      }
      final String? accessToken = prefs.getString('accessToken');
      print('Access token: $accessToken');
      print('Current user: $currentUser');
    } catch (error) {
      print('Error getting current user: $error');
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

  Future<void> _loadTopicsUser() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('userId');
      final List<Topic> fetchedTopics =
          await topicService.getTopicsByUser(userId ?? '');
      setState(() {
        topics = fetchedTopics;
        filteredUsers =
            _filterUsers(topics.map((topic) => topic.user).toList());
      });
    } catch (e) {
      print('Error loading topics: $e');
    }
  }

  Future<void> _loadSavedTopics() async {
    await _getCurrentUser();
    try {
      final List<Topic> allTopics = await topicService.getAllTopics();
      final List<Topic> savedTopics = allTopics
          .where((topic) => topicSavedIds.contains(topic.id.toString()))
          .toList();
      setState(() {
        allTopic = allTopics;
        this.savedTopics = savedTopics;
        filteredUsersSave =
            _filterUsers(savedTopics.map((topic) => topic.user).toList());
      });
      print("List Id topic saved: $topicSavedIds");
      print("All topics: $allTopics");
      print("Saved Topics: $savedTopics");
    } catch (e) {
      print('Error loading saved topics: $e');
    }
  }

  List<User> _filterUsers(List<String> userIds) {
    return users.where((user) => userIds.contains(user.id)).toList();
  }

  void _navigateToDetailTerm(Topic topic, String userName) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Detail_Term(
          topic: topic,
          userName: userName,
        ),
      ),
    );
    if (result == true) {
      _loadTopicsUser();
    }
  }

  @override
  void didUpdateWidget(covariant HocPhanPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (success_topic == 'success_topic') {
      _reloadData();
    }
  }

  void _reloadData() {
    _getCurrentUser();
    _loadTopicsUser();
    _loadUsers();
    _loadSavedTopics();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 16, bottom: 10, top: 10),
            child: const Text(
              'Học phần',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
          topics.isEmpty
              ? const Center(
                  child: Text(
                    'Không có học phần nào',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: topics.length,
                  itemBuilder: (context, index) {
                    final topic = topics[index];
                    String userName = _getUserName(topics[index].user);
                    return InkWell(
                      onTap: () {
                        _navigateToDetailTerm(topic, userName);
                      },
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
                                    const SizedBox(height: 10.0),
                                    Text(
                                      '${topic.terms.length} thuật ngữ',
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 10.0),
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
          Container(
            padding: const EdgeInsets.only(left: 16, bottom: 10, top: 10),
            child: const Text(
              'Đã lưu',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: savedTopics.length,
            itemBuilder: (context, index) {
              final topic = savedTopics[index];
              String userName = _getUserNameSaveTopic(savedTopics[index].user);
              return InkWell(
                onTap: () {
                  _navigateToDetailTerm(topic, userName);
                },
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
                              const SizedBox(height: 10.0),
                              Text(
                                '${topic.terms.length} thuật ngữ',
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 10.0),
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

  String _getUserNameSaveTopic(String userId) {
    User? user = filteredUsersSave.firstWhere(
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
}

class ThuMucPage extends StatefulWidget {
  final String? successFolder;
  final String? successTopic;

  ThuMucPage({Key? key, this.successFolder, this.successTopic})
      : super(key: key);
  @override
  _ThuMucPageState createState() => _ThuMucPageState();
}

class _ThuMucPageState extends State<ThuMucPage> {
  final FolderService folderService = FolderService();
  List<Folder> folders = [];
  User? currentUser;
  List<User> users = [];
  List<User> filteredUsers = [];
  String? success_folder;

  @override
  void initState() {
    super.initState();
    _reloadData();
    _getCurrentUser();
    _loadFolders();
    _loadUsers();
    success_folder = widget.successFolder;
  }

  Future<void> _getCurrentUser() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userData = prefs.getString('currentUser');

      if (userData != null) {
        final User user = User.fromJson(jsonDecode(userData));
        setState(() {
          currentUser = user;
        });
      }
    } catch (error) {
      print('Error getting current user: $error');
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

  Future<void> _loadFolders() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('userId');
      final List<Folder> fetchedFolders =
          await folderService.getFoldersByUserId(userId ?? '');
      setState(() {
        folders = fetchedFolders;
        filteredUsers =
            _filterUsers(folders.map((folder) => folder.user).toList());
      });
    } catch (e) {
      print('Error loading folders: $e');
    }
  }

  List<User> _filterUsers(List<String> userIds) {
    return users.where((user) => userIds.contains(user.id)).toList();
  }

  @override
  void didUpdateWidget(covariant ThuMucPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (success_folder == 'success_topic') {
      _reloadData();
    }
  }

  void _reloadData() {
    _getCurrentUser();
    _loadFolders();
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: folders.isEmpty
              ? const Center(
                  child: Text(
                    'Không có thư mục nào',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: folders.length,
                  itemBuilder: (context, index) {
                    final folder = folders[index];
                    String userName = _getUserName(folders[index].user);
                    return InkWell(
                      onTap: () {
                        _navigateToDetailFolder(context, folder, userName);
                      },
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
                                      folder.name,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
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
                                          width: 25,
                                          height: 25,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          userName,
                                          style: const TextStyle(
                                            fontSize: 18,
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
      ],
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

  void _navigateToDetailFolder(
      BuildContext context, Folder folder, String userName) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Detail_Folder(
          folder: folder,
          userName: userName,
        ),
      ),
    );
    if (result == true) {
      _loadFolders();
    }
  }
}
