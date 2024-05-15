import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_final/models/flashCardMo.dart';
import 'package:flutter_final/models/testChoiceMo.dart';
import 'package:flutter_final/models/testWritingMo.dart';
import 'package:flutter_final/models/topic.dart';
import 'package:flutter_final/models/user.dart';
import 'package:flutter_final/services/Auth_Service.dart';
import 'package:flutter_final/services/FlashCardSer.dart';
import 'package:flutter_final/services/TestChoiceSer.dart';
import 'package:flutter_final/services/TestWritingSer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Ranking extends StatefulWidget {
  final Topic topic;
  const Ranking({super.key, required this.topic});

  @override
  _RankingState createState() => _RankingState();
}

class _RankingState extends State<Ranking> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'FLASHCARD'),
            Tab(text: 'CHOICE TEST'),
            Tab(text: 'WRITING TEST'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FlashCardPage(topic: widget.topic),
          ChoiceTestPage(topic: widget.topic),
          WritingTestPage(topic: widget.topic),
        ],
      ),
    );
  }
}

class FlashCardPage extends StatefulWidget {
  final Topic topic;

  const FlashCardPage({super.key, required this.topic});

  @override
  _FlashCardPageState createState() => _FlashCardPageState();
}

class _FlashCardPageState extends State<FlashCardPage> {
  List<FlashCardMo> flashcards = [];
  User? currentUser;
  List<User> users = [];
  List<User> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _loadFlashCardByTopic(widget.topic.id);
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

  Future<void> _loadFlashCardByTopic(String topicId) async {
    try {
      final List<FlashCardMo>? fetchedFlashCards =
          await FlashCardService.getFlashCardByTopic(widget.topic.id);
      if (fetchedFlashCards != null) {
        setState(() {
          flashcards = fetchedFlashCards;
          flashcards.sort((a, b) {
            if (b.termKnew.length != a.termKnew.length) {
              return b.termKnew.length.compareTo(a.termKnew.length);
            } else {
              return a.createdAt.compareTo(b.createdAt);
            }
          });

          filteredUsers = _filterUsers(
              flashcards.map((flashcard) => flashcard.user).toList());
        });
        // print('Fetched choices: $fetchedChoices');
        // print('Filtered Users: $filteredUsers');
      }
    } catch (e) {
      print('Error loading flash card: $e');
    }
  }

  List<User> _filterUsers(List<String> userIds) {
    return users.where((user) => userIds.contains(user.id)).toList();
  }

  Color _getCardColor(int index) {
    if (index == 0) {
      return Colors.yellow;
    } else if (index == 1) {
      return Colors.grey;
    } else if (index == 2) {
      return Colors.brown;
    } else {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: flashcards.length,
            itemBuilder: (context, index) {
              String userName = _getUserName(flashcards[index].user);
              return InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 100,
                    child: Card(
                      color: _getCardColor(index),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Text(
                              flashcards[index].termKnew.length.toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              (index + 1).toString(),
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
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
}

class ChoiceTestPage extends StatefulWidget {
  final Topic topic;
  const ChoiceTestPage({Key? key, required this.topic}) : super(key: key);

  @override
  _ChoiceTestPageState createState() => _ChoiceTestPageState();
}

class _ChoiceTestPageState extends State<ChoiceTestPage> {
  List<TestChoiceMo> choices = [];
  User? currentUser;
  List<User> users = [];
  List<User> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _loadChoicesByTopic(widget.topic.id);
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

  Future<void> _loadChoicesByTopic(String topicId) async {
    try {
      final List<TestChoiceMo>? fetchedChoices =
          await TestChoiceService.getChoicesByTopic(widget.topic.id);
      if (fetchedChoices != null) {
        setState(() {
          choices = fetchedChoices;
          choices.sort((a, b) {
            if (b.overall != a.overall) {
              return b.overall.compareTo(a.overall);
            } else {
              return a.createdAt.compareTo(b.createdAt);
            }
          });

          filteredUsers =
              _filterUsers(choices.map((choice) => choice.user).toList());
        });
        print('Fetched choices: $fetchedChoices');
        print('Filtered Users: $filteredUsers');
      }
    } catch (e) {
      print('Error loading choices: $e');
    }
  }

  List<User> _filterUsers(List<String> userIds) {
    return users.where((user) => userIds.contains(user.id)).toList();
  }

  Color _getCardColor(int index) {
    if (index == 0) {
      return Colors.yellow;
    } else if (index == 1) {
      return Colors.grey;
    } else if (index == 2) {
      return Colors.brown;
    } else {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: choices.length,
            itemBuilder: (context, index) {
              String userName = _getUserName(choices[index].user);
              return InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 100,
                    child: Card(
                      color: _getCardColor(index),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Text(
                              choices[index].overall.toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              (index + 1).toString(),
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
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
}

class WritingTestPage extends StatefulWidget {
  final Topic topic;

  const WritingTestPage({Key? key, required this.topic}) : super(key: key);

  @override
  _WritingTestPageState createState() => _WritingTestPageState();
}

class _WritingTestPageState extends State<WritingTestPage> {
  List<TestWritingMo> writings = [];
  User? currentUser;
  List<User> users = [];
  List<User> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _loadWritingsByTopic(widget.topic.id);
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

  Future<void> _loadWritingsByTopic(String topicId) async {
    try {
      final List<TestWritingMo>? fetchedWritings =
          await TestWritingService.getWritingsByTopic(widget.topic.id);
      if (fetchedWritings != null) {
        setState(() {
          writings = fetchedWritings;
          writings.sort((a, b) {
            if (b.overall != a.overall) {
              return b.overall.compareTo(a.overall);
            } else {
              return a.createdAt.compareTo(b.createdAt);
            }
          });

          filteredUsers =
              _filterUsers(writings.map((writing) => writing.user).toList());
        });
        print('Fetched Writing: $fetchedWritings');
        print('Filtered Users: $filteredUsers');
      }
    } catch (e) {
      print('Error loading writings: $e');
    }
  }

  List<User> _filterUsers(List<String> userIds) {
    return users.where((user) => userIds.contains(user.id)).toList();
  }

  Color _getCardColor(int index) {
    if (index == 0) {
      return Colors.yellow;
    } else if (index == 1) {
      return Colors.grey;
    } else if (index == 2) {
      return Colors.brown;
    } else {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: writings.length,
            itemBuilder: (context, index) {
              String userName = _getUserName(writings[index].user);
              return InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 100,
                    child: Card(
                      color: _getCardColor(index),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Text(
                              writings[index].overall.toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              (index + 1).toString(),
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
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
}
