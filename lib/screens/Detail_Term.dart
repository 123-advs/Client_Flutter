import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter_final/screens/FlashCard.dart';
import 'package:flutter_final/screens/Ranking.dart';
import 'package:flutter_final/screens/StarTopic.dart';
import 'package:flutter_final/screens/TestChoice.dart';
import 'package:flutter_final/screens/TestWriting.dart';
import 'package:flutter_final/services/Auth_Service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_final/models/topic.dart';
import 'package:flutter_final/screens/Choose_Add_Folder.dart';
import 'package:flutter_final/screens/Create_Term.dart';
import 'package:flutter_final/services/Topic.dart';
import 'package:flutter_final/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Detail_Term extends StatefulWidget {
  final Topic topic;
  final String userName;

  const Detail_Term({Key? key, required this.topic, required this.userName})
      : super(key: key);

  @override
  _DetailTermPageState createState() => _DetailTermPageState();
}

class _DetailTermPageState extends State<Detail_Term> {
  late PageController _pageController;
  late final ValueNotifier<int> _currentPageNotifier;
  late List<Map<String, bool>> flashCardStates;
  bool isPrivate = false;
  late User? currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _pageController = PageController();
    _currentPageNotifier = ValueNotifier<int>(0);
    flashCardStates = List.generate(
      widget.topic.terms.length,
      (index) => {'termVisible': true, 'definitionVisible': false},
    );
    isPrivate = widget.topic.mode == 'private';
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

  void toggleFlashCardText(int index) {
    setState(() {
      flashCardStates[index]['termVisible'] =
          !(flashCardStates[index]['termVisible'] ?? false);
      flashCardStates[index]['definitionVisible'] =
          !(flashCardStates[index]['definitionVisible'] ?? false);
    });
  }

  void _navigateToRankingPage(Topic topic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Ranking(topic: topic),
      ),
    );
  }

  void _navigateToStarPage(Topic topic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StarTopic(topic: topic),
      ),
    );
  }

  void _exportToCSV(Topic topic) async {
    List<List<dynamic>> rows = [];
    rows.add(['Term', 'Definition']);
    topic.terms.forEach((term) {
      rows.add([term.term, term.definition]);
    });
    String csvData = const ListToCsvConverter().convert(rows);
    final fileName = '${topic.title.replaceAll(' ', '_')}.csv';
    final filePath = await FileSaveHelper.saveFile(csvData, fileName);
    print('File path: $filePath');
    if (filePath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Xuất file CSV thành công! Vui lòng kiểm tra bộ nhớ.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Xuất file CSV thất bại! Vui lòng thử lại.')),
      );
    }
  }

  void _showBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            if (widget.topic.user == currentUser!.id)
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Thêm học phần vào thư mục'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToAddFolder();
                },
              ),
            if (widget.topic.user == currentUser!.id)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Chỉnh sửa'),
                onTap: () {
                  Navigator.pop(context);
                  _editTerm();
                },
              ),
            if (widget.topic.user == currentUser!.id)
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Trạng thái'),
                onTap: () {
                  Navigator.pop(context);
                  _showStatusDialog();
                },
              ),
            if (widget.topic.user == currentUser!.id)
              ListTile(
                leading: const Icon(Icons.file_download),
                title: const Text('Xuất file CSV'),
                onTap: () {
                  Navigator.pop(context);
                  _exportToCSV(widget.topic);
                },
              ),
            if (widget.topic.user == currentUser!.id)
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Đánh dấu sao'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToStarPage(widget.topic);
                },
              ),
            if (widget.topic.user == currentUser!.id)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Xóa học phần'),
                onTap: () {
                  _confirmDeleteTopic();
                },
              ),
            if (widget.topic.user != currentUser!.id)
              ListTile(
                leading: const Icon(Icons.save),
                title: Text(
                  currentUser!.topicSaved.contains(widget.topic.id)
                      ? 'Bỏ lưu'
                      : 'Lưu',
                ),
                onTap: () {
                  Navigator.pop(context, true);
                  if (currentUser!.topicSaved.contains(widget.topic.id)) {
                    _deleteToSaved();
                  } else {
                    _addToSaved();
                  }
                },
              )
          ],
        );
      },
    );
  }

  void _confirmDeleteTopic() {
    setState(() {
      _isLoading = true;
    });
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this topic?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
                try {
                  bool success =
                      await TopicService().deleteTopic(widget.topic.id);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Học phần xóa thành công!')),
                    );
                    Navigator.of(context).pop(true);
                    Navigator.of(context).pop(true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Học phần xóa thất bại')),
                    );
                  }
                } catch (e) {
                  print("Error deleting topic: $e");
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Topic topic = widget.topic;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          GestureDetector(
            onTap: () {
              _navigateToRankingPage(widget.topic);
            },
            child: SvgPicture.asset(
              'assets/images/ranking.svg',
              width: 30,
              height: 30,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _showBottomSheet();
            },
          ),
        ],
        title: const Text(""),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: flashCardStates.length,
                    onPageChanged: (int page) {
                      _currentPageNotifier.value = page;
                    },
                    itemBuilder: (context, index) {
                      if (index < 0 || index >= topic.terms.length) {
                        return const SizedBox.shrink();
                      }
                      return GestureDetector(
                        onTap: () {
                          toggleFlashCardText(index);
                        },
                        child: Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            margin: const EdgeInsets.symmetric(
                              vertical: 10.0,
                            ),
                            child: Card(
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      flashCardStates[index]['termVisible']!
                                          ? topic.terms[index].term
                                          : topic.terms[index].definition,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                  Positioned(
                    bottom: 20.0,
                    child: CirclePageIndicator(
                      size: 10.0,
                      selectedSize: 12.0,
                      dotColor: Colors.grey,
                      selectedDotColor: Colors.blue,
                      itemCount: topic.terms.length,
                      currentPageNotifier: _currentPageNotifier,
                      onPageSelected: (int index) {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        topic.title,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      const Text("|"),
                      const SizedBox(width: 4.0),
                      Text(topic.mode),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        'assets/images/circle_person.svg',
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 10.0),
                      Text(
                        widget.userName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      const Text("|"),
                      const SizedBox(width: 4.0),
                      Text(' ${topic.terms.length} thuật ngữ'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.title,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          _navigateToFlashCard(topic);
                        },
                        child: Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/flash-card.svg',
                                  width: 35,
                                  height: 35,
                                ),
                                const SizedBox(width: 8),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Flashcard",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Ôn lại các thuật ngữ và định nghĩa",
                                      style: TextStyle(
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
                      const SizedBox(height: 10),
                      GestureDetector(
                          onTap: () {
                            _navigateToTestChoice(topic);
                          },
                          child: Card(
                            elevation: 4,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/multiple-choice.svg',
                                    width: 35,
                                    height: 35,
                                  ),
                                  const SizedBox(width: 8),
                                  const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Trắc nghiệm",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Làm bài kiểm tra trắc nghiệm thử",
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          _navigateToTestWriting(topic);
                        },
                        child: Card(
                          elevation: 4,
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/writing.svg',
                                  width: 35,
                                  height: 35,
                                ),
                                const SizedBox(width: 8),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Gõ từ",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Nhập lại nghĩa tiếng Anh và ngược lại",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
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
      ),
    );
  }

  void _navigateToAddFolder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChooseAddFolder(topic: widget.topic),
      ),
    );
  }

  void _editTerm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Create_Term(
          termData: widget.topic.terms,
          title: widget.topic.title,
          description: widget.topic.description,
          topicData: widget.topic,
        ),
      ),
    ).then((result) {
      if (result != null && result == 'updated_success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Học phần cập nhật thành công!')),
        );
      }
    });
  }

  void _addToSaved() {
    if (currentUser != null) {
      AuthService authService = AuthService();
      authService
          .addToTopicSaved(widget.topic.id, currentUser!.id)
          .then((success) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Đã thêm học phần vào danh sách đã lưu thành công')),
          );
          _getCurrentUser();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Không thể thêm học phần vào danh sách đã lưu')),
          );
        }
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      });
    }
  }

  void _deleteToSaved() {
    if (currentUser != null) {
      AuthService.deleteToSavedTopic(widget.topic.id, currentUser!.id)
          .then((success) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Đã xóa học phần khỏi danh sách đã lưu thành công')),
          );
          _getCurrentUser();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Không thể xóa học phần khỏi danh sách đã lưu')),
          );
        }
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      });
    }
  }

  void _showStatusDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chọn trạng thái'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RadioListTile<bool>(
                    title: const Text('Public'),
                    value: false,
                    groupValue: isPrivate,
                    onChanged: (bool? value) {
                      setState(() {
                        isPrivate = value!;
                      });
                    },
                  ),
                  RadioListTile<bool>(
                    title: const Text('Private'),
                    value: true,
                    groupValue: isPrivate,
                    onChanged: (bool? value) {
                      setState(() {
                        isPrivate = value!;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleStatusChange(isPrivate);
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  void _handleStatusChange(bool isPrivate) {
    String mode = isPrivate ? 'private' : 'public';
    TopicService().updateMode(widget.topic.id, mode).then((_) {
      setState(() {
        widget.topic.mode = mode;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Trạng thái của học phần cập nhật thành công!')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    });
  }

  void _navigateToFlashCard(Topic topic) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FlashCard(topic: topic)),
    );
  }

  void _navigateToTestChoice(Topic topic) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TestChoice(topic: topic)),
    );
  }

  void _navigateToTestWriting(Topic topic) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TestWriting(topic: topic)),
    );
  }
}

class FileSaveHelper {
  static Future<String?> saveFile(String data, String fileName) async {
    final bytes = utf8.encode(data);
    final directory = await getExternalStorageDirectory();
    final file = File('${directory?.path}/$fileName');

    try {
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (e) {
      print('Error saving file: $e');
      return null;
    }
  }
}
