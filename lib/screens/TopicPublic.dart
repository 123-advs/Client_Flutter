import 'package:flutter/material.dart';
import 'package:flutter_final/models/topic.dart';
import 'package:flutter_final/models/user.dart';
import 'package:flutter_final/screens/Detail_Term.dart';
import 'package:flutter_final/services/Auth_Service.dart';
import 'package:flutter_final/services/Topic.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TopicPublic extends StatefulWidget {
  TopicPublic({Key? key}) : super(key: key);

  @override
  _TopicPublicState createState() => _TopicPublicState();
}

class _TopicPublicState extends State<TopicPublic> {
  late TextEditingController _searchController = TextEditingController();
  final TopicService topicService = TopicService();
  List<Topic> topics = [];
  List<Topic> topicPublic = [];
  List<User> users = [];
  List<User> filteredUsers = [];
  List<User> filteredUsersPublic = [];
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _loadUsers();
    _loadTopics();
    _loadTopicPublic();
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

      final String? accessToken = prefs.getString('accessToken');
      print('Access token: $accessToken');
      print('Current Id: $currentUser');
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
        filteredUsers =
            _filterUsers(topics.map((topic) => topic.user).toList());
      });
      print('Fetched topics: $topics');
      print('Filtered Users: $filteredUsers');
    } catch (e) {
      print('Error loading topics: $e');
    }
  }

  Future<void> _loadTopicPublic() async {
    await _getCurrentUser();
    try {
      final List<Topic> fetchedTopicPublic =
          await topicService.getAllPublicTopics();

      final List<User> fetchedFilteredUsersPublic =
          _filterUsers(fetchedTopicPublic.map((topic) => topic.user).toList());

      setState(() {
        topicPublic = fetchedTopicPublic
            .where((topic) => topic.user != currentUser!.id)
            .toList();
        filteredUsersPublic = fetchedFilteredUsersPublic;
      });
    } catch (e) {
      print('Error loading topic public: $e');
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
      _loadTopics();
      _loadTopicPublic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Topic Public'),
      ),
      body: SingleChildScrollView(
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
                'Học phần cộng đồng',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
            topicPublic.isEmpty
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
                    itemCount: topicPublic.length,
                    itemBuilder: (context, index) {
                      final topic = topicPublic[index];
                      String userName = _getUserName1(topicPublic[index].user);
                      return GestureDetector(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
      ),
    );
  }

  String _getUserName1(String userId) {
    User? user = filteredUsersPublic.firstWhere(
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
