import 'package:flutter/material.dart';
import 'package:flutter_final/constants/Constants.dart';
import 'package:flutter_final/models/topic.dart';
import 'package:flutter_final/models/user.dart';
import 'package:flutter_final/screens/Detail_Term.dart';
import 'package:flutter_final/screens/Profile.dart';
import 'package:flutter_final/services/Auth_Service.dart';
import 'package:flutter_final/services/Topic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  final String? successTopic;
  const Home({Key? key, this.successTopic}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
    _reloadData();
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
  void didUpdateWidget(covariant Home oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.successTopic == 'success_topic') {
      _reloadData();
    }
  }

  void _reloadData() {
    _getCurrentUser();
    _loadUsers();
    _loadTopics();
    _loadTopicPublic();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hi! ${currentUser?.lastname} ${currentUser?.firstname}',
          style: TextStyle(
            color: Constants.blackColor,
            fontWeight: FontWeight.w500,
            fontSize: 24,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.person,
              color: Constants.blackColor,
              size: 30.0,
            ),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                PageTransition(
                  child: const Profile(),
                  type: PageTransitionType.bottomToTop,
                ),
              );
              if (result == true) {
                _getCurrentUser();
                _loadUsers();
                _loadTopics();
                _loadTopicPublic();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    width: size.width * .9,
                    decoration: BoxDecoration(
                      color: Constants.primaryColor.withOpacity(.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.black54.withOpacity(.6),
                        ),
                        const Expanded(
                            child: TextField(
                          showCursor: false,
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm học phần cộng đồng',
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        )),
                        Icon(
                          Icons.mic,
                          color: Colors.black54.withOpacity(.6),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10.0),
            Container(
              padding: const EdgeInsets.only(left: 16, bottom: 20, top: 20),
              child: const Text(
                'Học phần',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
            SizedBox(
              height: size.height * 0.19,
              child: topics.isEmpty
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
                      itemCount: topics.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        final topic = topics[index];
                        String userName = _getUserName(topics[index].user);
                        return InkWell(
                          onTap: () {
                            _navigateToDetailTerm(topic, userName);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 300,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(25.0),
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
                                      const SizedBox(height: 5.0),
                                      Text(
                                        '${topic.terms.length} thuật ngữ',
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/circle_person.svg',
                                            width: 20,
                                            height: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            userName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
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
            ),
            Container(
              padding: const EdgeInsets.only(left: 16, bottom: 20, top: 20),
              child: const Text(
                'Các học phần tương ứng Public',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
            SizedBox(
              height: size.height * 0.19,
              child: topicPublic.isEmpty
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
                      itemCount: topicPublic.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        final topic = topicPublic[index];
                        String userName =
                            _getUserName1(topicPublic[index].user);
                        return InkWell(
                          onTap: () {
                            _navigateToDetailTerm(topic, userName);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 300,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(25.0),
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
                                      const SizedBox(height: 5.0),
                                      Text(
                                        '${topic.terms.length} thuật ngữ',
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/circle_person.svg',
                                            width: 20,
                                            height: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            userName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
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
            ),
          ],
        ),
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
