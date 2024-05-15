import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_final/models/topic.dart';
import 'package:flutter_final/models/user.dart';
import 'package:flutter_final/services/Auth_Service.dart';
import 'package:flutter_final/services/Topic.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';

class Create_Term extends StatefulWidget {
  final List<Term>? termData;
  final String? title;
  final String? description;
  final Topic? topicData;

  const Create_Term(
      {super.key, this.termData, this.title, this.description, this.topicData});

  @override
  _CreateTermState createState() => _CreateTermState();
}

class _CreateTermState extends State<Create_Term> {
  User? currentUser;
  String title = '';
  String description = '';
  List<Map<String, String>> cardList = [];
  bool _showDescriptionTextField = false;
  final TopicService topicService = TopicService();

  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late List<TextEditingController> idiomControllers;
  late List<TextEditingController> definitionControllers;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    titleController = TextEditingController(text: widget.title);
    descriptionController = TextEditingController(text: widget.description);
    idiomControllers = [];
    definitionControllers = [];
    if (widget.termData != null) {
      for (int i = 0; i < widget.termData!.length; i++) {
        cardList.add({
          'idiom': widget.termData![i].term,
          'definition': widget.termData![i].definition,
        });
        idiomControllers
            .add(TextEditingController(text: widget.termData![i].term));
        definitionControllers
            .add(TextEditingController(text: widget.termData![i].definition));
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    for (var controller in idiomControllers) {
      controller.dispose();
    }
    for (var controller in definitionControllers) {
      controller.dispose();
    }
    super.dispose();
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

  Future<void> _importFromCSV() async {
    setState(() {
      _isLoading = true;
    });
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        var file = File(result.files.single.path!);
        String fileName = result.files.single.name;

        String csvContent = await file.readAsString();

        List<String> lines = csvContent.split('\n');

        List<Term> terms = [];
        for (String line in lines) {
          List<String> data = line.split(',');
          if (data.length >= 2) {
            String idiom = data[0].trim();
            String definition = data[1].trim();
            terms.add(
                Term(id: Uuid().v4(), term: idiom, definition: definition));
          }
        }

        await topicService.createTopic(
            fileName.replaceAll('.csv', ''), '', currentUser!.id, terms);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Học phần đã được tạo từ file CSV!'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
      } else {
        print('Error picking CSV file');
      }
    } catch (e) {
      print('Error picking CSV file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lỗi khi chọn tập tin CSV!'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createTopic() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<Term> terms = [];
      var uuid = Uuid();
      for (int i = 0; i < cardList.length; i++) {
        String idiom = cardList[i]['idiom'] ?? '';
        String definition = cardList[i]['definition'] ?? '';
        terms.add(Term(id: uuid.v4(), definition: definition, term: idiom));
      }
      await topicService.createTopic(
          title, description, currentUser!.id, terms);

      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Học phần tạo thành công!'),
          duration: Duration(seconds: 2),
        ),
      );
      print('Topic created successfully');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Học phần tạo thất bại! Vui lòng thử lại.'),
          duration: Duration(seconds: 2),
        ),
      );
      print("Error creating topic: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateTopic() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<Term> terms = [];
      var uuid = const Uuid();
      for (int i = 0; i < cardList.length; i++) {
        String idiom = cardList[i]['idiom'] ?? '';
        String definition = cardList[i]['definition'] ?? '';
        terms.add(Term(id: uuid.v4(), definition: definition, term: idiom));
      }
      await topicService.updateTopic(widget.topicData!.id, {
        'title': title,
        'description': description,
        'terms': terms.map((term) => term.toJson()).toList(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Học phần cập nhật thành công!'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop(true);
      Navigator.of(context).pop(true);
    } catch (e) {
      print("Error updating topic: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _createOrUpdateTopic() async {
    setState(() {
      title = titleController.text;
      description = descriptionController.text;
    });
    if (widget.topicData != null) {
      await _updateTopic();
    } else {
      await _createTopic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          leading: IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Handle settings icon pressed
            },
          ),
          title: const Text('Tạo học phần'),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _createOrUpdateTopic,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                  onChanged: (value) {
                    setState(() {
                      title = value;
                    });
                  },
                  controller: titleController,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _importFromCSV,
                      child: const Row(
                        children: [
                          Icon(Icons.file_upload),
                          SizedBox(width: 10),
                          Text('Import From csv file'),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showDescriptionTextField =
                              !_showDescriptionTextField;
                        });
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.description),
                          SizedBox(width: 10),
                          Text('Mô tả'),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_showDescriptionTextField) ...[
                  const SizedBox(height: 20),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Mô tả',
                    ),
                    onChanged: (value) {
                      setState(() {
                        description = value;
                      });
                    },
                    controller: descriptionController,
                  ),
                  const SizedBox(height: 20),
                ],
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _buildCardListWithSpacing(),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              cardList.add({'idiom': '', 'definition': ''});
              idiomControllers.add(TextEditingController());
              definitionControllers.add(TextEditingController());
            });
          },
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: _isLoading
            ? Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildCard(int index) {
    TextEditingController idiomController = idiomControllers.length > index
        ? idiomControllers[index]
        : TextEditingController();
    TextEditingController definitionController =
        definitionControllers.length > index
            ? definitionControllers[index]
            : TextEditingController();

    idiomController.addListener(() {
      setState(() {
        cardList[index]['idiom'] = idiomController.text;
      });
    });

    definitionController.addListener(() {
      setState(() {
        cardList[index]['definition'] = definitionController.text;
      });
    });
    return GestureDetector(
      onLongPress: () {
        _showDeleteConfirmationDialog(index);
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Thành ngữ ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Nhập thành ngữ',
                ),
                controller: idiomController,
              ),
              const SizedBox(height: 16),
              Text(
                'Định nghĩa ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Nhập định nghĩa',
                ),
                controller: definitionController,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa thành ngữ này?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                _deleteCard(index);
                Navigator.of(context).pop();
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCard(int index) {
    setState(() {
      cardList.removeAt(index);
      idiomControllers.removeAt(index);
      definitionControllers.removeAt(index);
    });
  }

  List<Widget> _buildCardListWithSpacing() {
    List<Widget> cardListWithSpacing = [];
    for (int i = 0; i < cardList.length; i++) {
      cardListWithSpacing.add(_buildCard(i));
      cardListWithSpacing.add(const SizedBox(height: 20));
    }
    return cardListWithSpacing;
  }
}
