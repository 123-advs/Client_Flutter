import 'package:flutter/material.dart';
import 'package:flutter_final/models/topic.dart';
import 'package:flutter_final/models/user.dart';
import 'package:flutter_final/services/Auth_Service.dart';
import 'package:flutter_final/services/Topic.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StarTopic extends StatefulWidget {
  final Topic topic;
  const StarTopic({super.key, required this.topic});

  @override
  _StarTopicState createState() => _StarTopicState();
}

class _StarTopicState extends State<StarTopic>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _onStarChanged(bool isStarYellow) {
    setState(() {
      isStarYellowInHocPage = isStarYellow;
    });
  }

  bool isStarYellowInHocPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh dấu sao'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'HỌC HẾT'),
            Tab(text: 'HỌC'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          HocHetPage(
              topic: widget.topic,
              onStarChanged: _onStarChanged), // Truyền callback vào HocHetPage
          HocPage(
            topic: widget.topic,
          ), // Truyền trạng thái ngôi sao vào HocPage
        ],
      ),
    );
  }
}

class HocHetPage extends StatefulWidget {
  final Topic topic;
  final Function(bool isStarYellow) onStarChanged;

  const HocHetPage({Key? key, required this.topic, required this.onStarChanged})
      : super(key: key);

  @override
  _HocHetPageState createState() => _HocHetPageState();
}

class _HocHetPageState extends State<HocHetPage> {
  final TopicService topicService = TopicService();
  List<Topic> topics = [];
  Topic? dataTopic;
  User? currentUser;
  List<bool> isStarYellowList = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    dataTopic = widget.topic;
    if (dataTopic != null) {
      isStarYellowList = List<bool>.generate(
        dataTopic!.terms.length,
        (index) => false,
      );
      // Khôi phục trạng thái sao từ SharedPreferences
      _restoreStarStatus();
    }
    print("Data Topic: $dataTopic");
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
      print('Current user: $currentUser');
    } catch (error) {
      print('Error getting current user: $error');
    }
  }

  Future<void> _saveStarStatus(int index, bool isStarYellow) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    if (userId != null) {
      final String topicId = dataTopic!.id;
      final String termId = dataTopic!.terms[index].id;
      // Lưu trạng thái sao của thuật ngữ vào SharedPreferences
      await prefs.setBool('$userId:$topicId:$termId', isStarYellow);
    }
  }

  Future<void> _restoreStarStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    if (userId != null) {
      final String topicId = dataTopic!.id;
      for (int i = 0; i < dataTopic!.terms.length; i++) {
        final String termId = dataTopic!.terms[i].id;
        final bool? isStarYellow = prefs.getBool('$userId:$topicId:$termId');
        if (isStarYellow != null) {
          setState(() {
            isStarYellowList[i] = isStarYellow;
          });
        }
      }
    }
  }

  void _toggleStar(int index) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('accessToken');

      if (accessToken != null) {
        final String? userId = prefs.getString('userId');

        if (userId != null) {
          final termId = dataTopic!.terms[index].id;
          final topicId = dataTopic!.id;
          final isStarYellow = isStarYellowList[index];

          await topicService.updateTopicStar(topicId, termId, !isStarYellow);

          final updatedTopic = await TopicService.getTopicById(topicId);

          setState(() {
            dataTopic = updatedTopic;
            isStarYellowList =
                dataTopic!.terms.map((term) => term.star).toList();
          });

          // Lưu trạng thái sao vào SharedPreferences
          _saveStarStatus(index, !isStarYellow);

          print("Data update Topic: $dataTopic");
        }
      }
    } catch (error) {
      print('Error toggling star: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 16, bottom: 10, top: 10),
            child: const Text(
              'Thuật ngữ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dataTopic?.terms.length ?? 0,
            itemBuilder: (context, index) {
              final term = dataTopic!.terms[index];
              return InkWell(
                onTap: () {
                  _toggleStar(index);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    term.term,
                                    style: const TextStyle(
                                      fontSize: 22,
                                    ),
                                  ),
                                  const SizedBox(height: 10.0),
                                  Text(
                                    term.definition,
                                    style: const TextStyle(
                                      fontSize: 22,
                                    ),
                                  ),
                                ],
                              ),
                              SvgPicture.asset(
                                isStarYellowList[index]
                                    ? 'assets/images/star-yellow.svg'
                                    : 'assets/images/star-white.svg',
                                width: 30,
                                height: 30,
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
}

class HocPage extends StatefulWidget {
  final Topic topic;

  const HocPage({Key? key, required this.topic}) : super(key: key);

  @override
  _HocPageState createState() => _HocPageState();
}

class _HocPageState extends State<HocPage> {
  final TopicService topicService = TopicService();
  User? currentUser;
  bool isStarYellow = false;
  Topic? dataTopic;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _fetchTopicData();
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
      print('Current user: $currentUser');
    } catch (error) {
      print('Error getting current user: $error');
    }
  }

  Future<void> _fetchTopicData() async {
    try {
      final String topicId = widget.topic.id;
      final Topic fetchedTopic = await TopicService.getTopicById(topicId);
      setState(() {
        dataTopic = fetchedTopic;
      });
    } catch (error) {
      print('Error fetching topic data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Term> starredTerms =
        dataTopic?.terms.where((term) => term.star == true).toList() ?? [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 16, bottom: 10, top: 10),
            child: const Text(
              'Thuật ngữ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: starredTerms.length,
            itemBuilder: (context, index) {
              final term = starredTerms[index];
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    term.term,
                                    style: const TextStyle(
                                      fontSize: 22,
                                    ),
                                  ),
                                  const SizedBox(height: 10.0),
                                  Text(
                                    term.definition,
                                    style: const TextStyle(
                                      fontSize: 22,
                                    ),
                                  ),
                                ],
                              ),
                              SvgPicture.asset(
                                'assets/images/star-yellow.svg',
                                width: 30,
                                height: 30,
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
}
