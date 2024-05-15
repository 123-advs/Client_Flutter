import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_final/models/testWritingMo.dart';
import 'package:flutter_final/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestWritingService {
  static Future<TestWritingMo?> createTestWriting(
    String topicId,
    Map<String, dynamic> optionAnswer,
    int totalQuestion,
    List<Answer> providedAnswers,
    String userId,
  ) async {
    final url = Uri.parse('${Constants.uri}/api/testwriting');

    final Map<String, dynamic> body = {
      'topic': topicId,
      'optionAnswer': optionAnswer,
      'totalQuestion': totalQuestion,
      'answers': providedAnswers,
      'user': userId,
    };

    final String bodyJson = jsonEncode(body);

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('accessToken');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: bodyJson,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return TestWritingMo.fromJson(responseData['createdTestWriting']);
      } else {
        throw Exception('Failed to create test writing');
      }
    } catch (e) {
      throw Exception('Failed to create test writing: $e');
    }
  }

  static Future<List<TestWritingMo>?> getWritingsByTopic(String topicId) async {
    final url = Uri.parse('${Constants.uri}/api/testwriting/topic/$topicId');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData =
            json.decode(response.body)['writings'];
        List<TestWritingMo> writings =
            responseData.map((data) => TestWritingMo.fromJson(data)).toList();
        return writings;
      } else {
        throw Exception('Failed to get writings by topic');
      }
    } catch (e) {
      throw Exception('Failed to get writings by topic: $e');
    }
  }

  static Future<List<TestWritingMo>> getTestWritingByUser(
      String userId) async {
    final url = Uri.parse('${Constants.uri}/api/testwriting/user/$userId');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData =
            json.decode(response.body)['testWriting'];
        List<TestWritingMo> testWritings =
            responseData.map((data) => TestWritingMo.fromJson(data)).toList();
        return testWritings;
      } else {
        throw Exception('Failed to get test writing by user');
      }
    } catch (e) {
      throw Exception('Failed to get test writing by user: $e');
    }
  }
}
