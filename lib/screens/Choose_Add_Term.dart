import 'package:flutter/material.dart';
import 'package:flutter_final/models/flashCardMo.dart';
import 'package:flutter_final/models/folder.dart';
import 'package:flutter_final/models/testChoiceMo.dart';
import 'package:flutter_final/models/testWritingMo.dart';
import 'package:flutter_final/models/topic.dart';
import 'package:flutter_final/models/user.dart';
import 'package:flutter_final/services/Auth_Service.dart';
import 'package:flutter_final/services/FlashCardSer.dart';
import 'package:flutter_final/services/Folder.dart';
import 'package:flutter_final/services/TestChoiceSer.dart';
import 'package:flutter_final/services/TestWritingSer.dart';
import 'package:flutter_final/services/Topic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Choose_Add_Term extends StatefulWidget {
  final Folder folder;

  const Choose_Add_Term({Key? key, required this.folder}) : super(key: key);

  @override
  _ChooseAddTermState createState() => _ChooseAddTermState();
}

class _ChooseAddTermState extends State<Choose_Add_Term>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final GlobalKey<_CreatePageState> _createPageKey =
      GlobalKey<_CreatePageState>();

  final GlobalKey<_LearnPageState> _learnPageKey = GlobalKey<_LearnPageState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _handleTickPressed() {
    final createPageState = _createPageKey.currentState;
    final learnPageState = _learnPageKey.currentState;
    if (createPageState != null) {
      createPageState._addTopicsToFolder().then((success) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật học phần thành công')),
          );
          Navigator.of(context).pop(true);
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật học phần không thành công')),
          );
        }
      });
    }

    if (learnPageState != null) {
      learnPageState._addTopicsToFolder().then((success) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật học phần thành công')),
          );
          Navigator.of(context).pop(true);
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật học phần không thành công')),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm học phần'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'ĐÃ TẠO'),
            Tab(text: 'ĐÃ HỌC'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _handleTickPressed,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CreatePage(key: _createPageKey, folder: widget.folder),
          LearnPage(key: _learnPageKey, folder: widget.folder),
        ],
      ),
    );
  }
}

class CreatePage extends StatefulWidget {
  final Folder folder;
  final VoidCallback? onTickPressed;

  const CreatePage({Key? key, required this.folder, this.onTickPressed})
      : super(key: key);

  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final TopicService topicService = TopicService();
  List<Topic> topics = [];
  User? currentUser;
  List<bool> isSelected = [];
  List<User> users = [];
  List<User> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _loadTopics();
    _loadUsers();
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
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('userId');
      final List<Topic> fetchedTopics =
          await topicService.getTopicsByUser(userId ?? '');
      setState(() {
        topics = fetchedTopics;
        isSelected = List<bool>.filled(fetchedTopics.length, false);
        for (int i = 0; i < fetchedTopics.length; i++) {
          if (widget.folder.topics.contains(fetchedTopics[i].id)) {
            isSelected[i] = true;
          }
        }
        filteredUsers =
            _filterUsers(topics.map((topic) => topic.user).toList());
      });
    } catch (e) {
      print('Error loading topics: $e');
    }
  }

  Future<bool> _addTopicsToFolder() async {
    try {
      final List<String> selectedTopicIds = [];
      final List<String> unselectedTopicIds = [];
      for (int i = 0; i < topics.length; i++) {
        if (isSelected[i]) {
          selectedTopicIds.add(topics[i].id);
        } else {
          unselectedTopicIds.add(topics[i].id);
        }
      }

      await FolderService()
          .addTopicsToFolder(widget.folder.id, selectedTopicIds);

      if (unselectedTopicIds.isNotEmpty) {
        await FolderService()
            .deleteTopicsFromFolder(widget.folder.id, unselectedTopicIds);
      }

      return true;
    } catch (e) {
      print('Error adding topics to folder: $e');
      return false;
    }
  }

  List<User> _filterUsers(List<String> userIds) {
    return users.where((user) => userIds.contains(user.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              String userName = _getUserName(topics[index].user);
              return InkWell(
                onTap: () {
                  setState(() {
                    isSelected[index] = !isSelected[index];
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: isSelected[index]
                        ? Colors.green.withOpacity(0.5)
                        : null,
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
}

class LearnPage extends StatefulWidget {
  final Folder folder;
  final VoidCallback? onTickPressed;

  const LearnPage({Key? key, required this.folder, this.onTickPressed})
      : super(key: key);

  @override
  _LearnPageState createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  final TopicService topicService = TopicService();
  List<Topic> topics = [];
  User? currentUser;
  List<bool> isSelected = [];
  List<User> users = [];
  List<User> filteredUsers = [];
  List<FlashCardMo> flashCard = [];
  List<TestChoiceMo> testChoice = [];
  List<TestWritingMo> testWriting = [];
  Set<String> allIds = Set<String>();

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _loadUsers();
    _loadFlashCardsByUser();
    _loadTestChoiceByUser();
    _loadTestWritingByUser();
    _loadTopics();
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

  Future<void> _loadFlashCardsByUser() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('userId');
      final List<FlashCardMo> flashCards =
          await FlashCardService.getFlashCardByUser(userId ?? '');
      setState(() {
        flashCard = flashCards;
        List<String> ids = flashCards.map((item) => item.topic).toList();
        allIds.addAll(ids);
      });

      print("Danh sách flash card: $flashCard");
    } catch (e) {
      print('Error loading flash cards: $e');
    }
  }

  Future<void> _loadTestChoiceByUser() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('userId');
      final List<TestChoiceMo> testChoices =
          await TestChoiceService.getTestChoiceByUser(userId ?? '');
      setState(() {
        testChoice = testChoices;
        List<String> ids =
            testChoice.map((testChoice) => testChoice.topic).toList();
        allIds.addAll(ids);
      });

      print("Danh sách test choice: $testChoice");
    } catch (e) {
      print('Error loading testchoice: $e');
    }
  }

  Future<void> _loadTestWritingByUser() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('userId');
      final List<TestWritingMo> testWritings =
          await TestWritingService.getTestWritingByUser(userId ?? '');

      setState(() {
        testWriting = testWritings;
        List<String> ids =
            testWritings.map((testWriting) => testWriting.topic).toList();
        allIds.addAll(ids);
      });

      print("Danh sách test writing: $testWriting");
    } catch (e) {
      print('Error loading testWriting: $e');
    }
  }

  Future<void> _loadTopics() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('userId');

      final List<Topic> fetchedTopics =
          await topicService.getTopicsByUser(userId ?? '');

      final filteredTopics =
          fetchedTopics.where((topic) => allIds.contains(topic.id)).toList();
      setState(() {
        topics = filteredTopics;
        isSelected = List<bool>.filled(filteredTopics.length, false);
        for (int i = 0; i < filteredTopics.length; i++) {
          if (widget.folder.topics.contains(filteredTopics[i].id)) {
            isSelected[i] = true;
          }
        }
        filteredUsers =
            _filterUsers(filteredTopics.map((topic) => topic.user).toList());
      });
      print("Danh sách topic: $allIds");
    } catch (e) {
      print('Error loading topics: $e');
    }
  }

  Future<bool> _addTopicsToFolder() async {
    try {
      final List<String> selectedTopicIds = [];
      final List<String> unselectedTopicIds = [];
      for (int i = 0; i < topics.length; i++) {
        if (isSelected[i]) {
          selectedTopicIds.add(topics[i].id);
        } else {
          unselectedTopicIds.add(topics[i].id);
        }
      }

      await FolderService()
          .addTopicsToFolder(widget.folder.id, selectedTopicIds);

      if (unselectedTopicIds.isNotEmpty) {
        await FolderService()
            .deleteTopicsFromFolder(widget.folder.id, unselectedTopicIds);
      }

      return true;
    } catch (e) {
      print('Error adding topics to folder: $e');
      return false;
    }
  }

  List<User> _filterUsers(List<String> userIds) {
    return users.where((user) => userIds.contains(user.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              String userName = _getUserName(topics[index].user);
              return InkWell(
                onTap: () {
                  setState(() {
                    isSelected[index] = !isSelected[index];
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: isSelected[index]
                        ? Colors.green.withOpacity(0.5)
                        : null,
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
}
