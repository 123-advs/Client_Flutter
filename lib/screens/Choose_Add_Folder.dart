import 'package:flutter/material.dart';
import 'package:flutter_final/models/topic.dart';
import 'package:flutter_final/services/Folder.dart';
import 'package:flutter_final/models/folder.dart';
import 'package:flutter_final/services/Topic.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChooseAddFolder extends StatefulWidget {
  final Topic topic;

  const ChooseAddFolder({super.key, required this.topic});

  @override
  _ChooseAddFolderState createState() => _ChooseAddFolderState();
}

class _ChooseAddFolderState extends State<ChooseAddFolder> {
  final FolderService folderService = FolderService();
  List<Folder> folders = [];
  List<bool> isSelected = [];

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('userId');
      final List<Folder> fetchedFolders =
          await folderService.getFoldersByUserId(userId ?? '');
      setState(() {
        folders = fetchedFolders;
        isSelected = List<bool>.filled(fetchedFolders.length, false);
        _checkFolderStatus();
      });
    } catch (e) {
      print('Error loading folders: $e');
    }
  }

  void _checkFolderStatus() {
    for (int i = 0; i < folders.length; i++) {
      if (folders[i].topics.contains(widget.topic.id)) {
        isSelected[i] = true;
      }
    }
  }

  void _handleAddToFolder() async {
    try {
      List<String> selectedFolderIds = [];
      List<String> unselectedFolderIds = [];
      for (int i = 0; i < folders.length; i++) {
        if (isSelected[i]) {
          selectedFolderIds.add(folders[i].id);
        } else {
          unselectedFolderIds.add(folders[i].id);
        }
      }
      if (selectedFolderIds.isNotEmpty) {
        // Thêm topic vào các folder được chọn
        await TopicService()
            .addTopicToFolders(widget.topic.id, selectedFolderIds);
      }
      if (unselectedFolderIds.isNotEmpty) {
        // Xóa topic khỏi các folder không được chọn
        await TopicService()
            .removeTopicFromFolders(widget.topic.id, unselectedFolderIds);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật thư mục')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm vào thư mục'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              _handleAddToFolder();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: folders.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        isSelected[index] = !isSelected[index];
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Card(
                        elevation: 4,
                        color: isSelected[index]
                            ? Colors.green.withOpacity(0.5)
                            : null, // Màu cam
                        borderOnForeground: isSelected[index],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(
                            color: isSelected[index]
                                ? Colors.transparent
                                : Colors.white,
                            width: isSelected[index] ? 2.0 : 0.0,
                          ),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.folder),
                          title: Text(
                            folders[index].name,
                            style: TextStyle(
                              color: isSelected[index] ? Colors.white : null,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              isSelected[index] = !isSelected[index];
                            });
                          },
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
}
