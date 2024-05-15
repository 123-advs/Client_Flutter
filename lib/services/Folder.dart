import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_final/models/folder.dart';
import 'package:flutter_final/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FolderService {
  Future<Folder> createFolder(String name, String description, String userId,
      List<String> topics) async {
    final url = Uri.parse('${Constants.uri}/api/folder');
    final Map<String, dynamic> body = {
      'name': name,
      'description': description,
      'user': userId,
      'topics': topics,
    };
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('accessToken');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return Folder.fromJson(responseData);
      } else {
        throw Exception('Failed to create folder');
      }
    } catch (e) {
      throw Exception('Failed to create folder: $e');
    }
  }

  Future<List<Folder>> getFoldersByUserId(String userId) async {
    final url = Uri.parse('${Constants.uri}/api/folder/folderbyuser/$userId');
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('accessToken');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        if (responseData['folders'] != null &&
            responseData['folders'] is List) {
          List<dynamic> folderDataList = responseData['folders'];
          List<Folder> folders = folderDataList
              .map<Folder>((data) => Folder.fromJson(data))
              .toList();
          return folders;
        } else {
          throw Exception('No folder data or invalid format');
        }
      } else {
        throw Exception('Failed to get folders by user');
      }
    } catch (e) {
      throw Exception('Failed to get folders by user: $e');
    }
  }

  Future<Folder> getFolder(String folderId) async {
    final url = Uri.parse('${Constants.uri}/api/folder/$folderId');
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('accessToken');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        return Folder.fromJson(responseData['folderData']);
      } else {
        throw Exception('Failed to get folder');
      }
    } catch (e) {
      throw Exception('Failed to get folder: $e');
    }
  }

  Future<Folder> updateFolder(
      String folderId, String name, String description) async {
    final url = Uri.parse('${Constants.uri}/api/folder/$folderId');
    final Map<String, dynamic> body = {
      'name': name,
      'description': description,
    };
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('accessToken');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return Folder.fromJson(responseData);
      } else {
        throw Exception('Failed to update folder');
      }
    } catch (e) {
      throw Exception('Failed to update folder: $e');
    }
  }

  Future<bool> deleteFolder(String folderId) async {
    final url = Uri.parse('${Constants.uri}/api/folder/$folderId');
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('accessToken');
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete folder');
      }
    } catch (e) {
      throw Exception('Failed to delete folder: $e');
    }
  }

  Future<Folder> addTopicsToFolder(String folderId, List<String> topics) async {
    final url = Uri.parse('${Constants.uri}/api/folder/$folderId/topics');
    final Map<String, dynamic> body = {
      'topics': topics,
    };
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('accessToken');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return Folder.fromJson(responseData['updatedFolder']);
      } else {
        throw Exception('Failed to add topics to folder');
      }
    } catch (e) {
      throw Exception('Failed to add topics to folder: $e');
    }
  }

  Future<Folder> deleteTopicsFromFolder(
      String folderId, List<String> topics) async {
    final url = Uri.parse('${Constants.uri}/api/folder/$folderId/topics');
    final Map<String, dynamic> body = {
      'topics': topics,
    };
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('accessToken');
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return Folder.fromJson(responseData['updatedFolder']);
      } else {
        throw Exception('Failed to delete topics from folder');
      }
    } catch (e) {
      throw Exception('Failed to delete topics from folder: $e');
    }
  }
}
