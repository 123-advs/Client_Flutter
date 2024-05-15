import 'dart:convert';
import 'package:flutter_final/models/topic.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_final/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TopicService {
  Future<Topic> createTopic(
      String title, String description, String userId, List<Term> terms) async {
    final url = Uri.parse('${Constants.uri}/api/topic');
    if (terms.length < 3) {
      throw Exception('Số lượng terms ít hơn 3, không thể tạo topic.');
    }
    final Map<String, dynamic> body = {
      'title': title,
      'description': description,
      'user': userId,
      'terms': terms.map((term) => term.toJson()).toList(),
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
        return Topic.fromJson(responseData);
      } else {
        throw Exception('Failed to create topic');
      }
    } catch (e) {
      throw Exception('Failed to create topic: $e');
    }
  }

  static Future<Topic> getTopicById(String topicId) async {
    final Uri url = Uri.parse('${Constants.uri}/api/topic/$topicId');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');

    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return Topic.fromJson(responseData['topicData']);
      } else {
        throw Exception(
            'Failed to get topic by ID with status: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to get topic by ID: $error');
    }
  }

  Future<List<Topic>> getAllTopics() async {
    final url = Uri.parse('${Constants.uri}/api/topic');

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

        if (responseData['allTopics'] != null &&
            responseData['allTopics'] is List) {
          List<dynamic> topicDataList = responseData['allTopics'];
          List<Topic> topics =
              topicDataList.map<Topic>((data) => Topic.fromJson(data)).toList();
          return topics;
        } else {
          throw Exception('No topic data or invalid format');
        }
      } else {
        throw Exception('Failed to get topics');
      }
    } catch (e) {
      throw Exception('Failed to get topics: $e');
    }
  }

  Future<List<Topic>> getAllPublicTopics() async {
    final url = Uri.parse('${Constants.uri}/api/topic/mode/public');

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

        if (responseData['topics'] != null && responseData['topics'] is List) {
          List<dynamic> topicDataList = responseData['topics'];
          List<Topic> topics =
              topicDataList.map<Topic>((data) => Topic.fromJson(data)).toList();
          return topics;
        } else {
          throw Exception('No public topics or invalid format');
        }
      } else {
        throw Exception('Failed to get public topics');
      }
    } catch (e) {
      throw Exception('Failed to get public topics: $e');
    }
  }

  Future<List<Topic>> getTopicsByUser(String userId) async {
    final url = Uri.parse('${Constants.uri}/api/topic/topicbyuser/$userId');

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

        if (responseData['topics'] != null && responseData['topics'] is List) {
          List<dynamic> topicDataList = responseData['topics'];
          List<Topic> topics =
              topicDataList.map<Topic>((data) => Topic.fromJson(data)).toList();
          return topics;
        } else {
          throw Exception('No topic data or invalid format');
        }
      } else {
        throw Exception('Failed to get topics by user');
      }
    } catch (e) {
      throw Exception('Failed to get topics by user: $e');
    }
  }

  Future<bool> deleteTopic(String topicId) async {
    final url = Uri.parse('${Constants.uri}/api/topic/$topicId');

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
        final dynamic responseData = json.decode(response.body);
        return responseData['success'] ?? false;
      } else {
        throw Exception('Failed to delete topic');
      }
    } catch (e) {
      throw Exception('Failed to delete topic: $e');
    }
  }

  Future<Topic> updateMode(String topicId, String mode) async {
    final url = Uri.parse('${Constants.uri}/api/topic/updatemode/$topicId');
    final Map<String, dynamic> body = {
      'mode': mode,
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
        return Topic.fromJson(responseData['updatedTopic']);
      } else {
        throw Exception('Failed to update mode');
      }
    } catch (e) {
      throw Exception('Failed to update mode: $e');
    }
  }

  Future<Topic> updateTopic(
      String topicId, Map<String, dynamic> updateData) async {
    final url = Uri.parse('${Constants.uri}/api/topic/$topicId');
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('accessToken');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return Topic.fromJson(responseData['updatedTopic']);
      } else {
        throw Exception('Failed to update topic');
      }
    } catch (e) {
      throw Exception('Failed to update topic: $e');
    }
  }

  Future<bool> addTopicToFolders(String topicId, List<String> folderIds) async {
    final url = Uri.parse('${Constants.uri}/api/topic/$topicId/add-to-folders');
    final Map<String, dynamic> body = {
      'folderIds': folderIds,
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
        final dynamic responseData = json.decode(response.body);
        return responseData['success'] ?? false;
      } else {
        throw Exception('Failed to add topic to folders');
      }
    } catch (e) {
      throw Exception('Failed to add topic to folders: $e');
    }
  }

  Future<bool> removeTopicFromFolders(
      String topicId, List<String> folderIds) async {
    final url =
        Uri.parse('${Constants.uri}/api/topic/$topicId/remove-from-folders');
    final Map<String, dynamic> body = {
      'folderIds': folderIds,
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
        final dynamic responseData = json.decode(response.body);
        return responseData['success'] ?? false;
      } else {
        throw Exception('Failed to remove topic from folders');
      }
    } catch (e) {
      throw Exception('Failed to remove topic from folders: $e');
    }
  }

  Future<Topic> updateTopicStar(
      String topicId, String termId, bool star) async {
    final url =
        Uri.parse('${Constants.uri}/api/topic/$topicId/terms/$termId/star');
    final Map<String, dynamic> body = {
      'termId': termId,
      'star': star,
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
        return Topic.fromJson(responseData['updatedTerm']);
      } else {
        throw Exception('Failed to update topic star');
      }
    } catch (e) {
      throw Exception('Failed to update topic star: $e');
    }
  }
}
