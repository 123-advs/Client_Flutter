import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_final/models/testChoiceMo.dart';
import 'package:flutter_final/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestChoiceService {
  static Future<TestChoiceMo?> createTestChoice(
    String topicId,
    Map<String, dynamic> optionAnswer,
    int totalQuestion,
    List<Answer> providedAnswers,
    String userId,
  ) async {
    final url = Uri.parse('${Constants.uri}/api/testchoice');

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
        return TestChoiceMo.fromJson(responseData['createdTestChoice']);
      } else {
        throw Exception('Failed to create test choice');
      }
    } catch (e) {
      throw Exception('Failed to create test choice: $e');
    }
  }

  static Future<List<TestChoiceMo>?> getChoicesByTopic(String topicId) async {
    final url = Uri.parse('${Constants.uri}/api/testchoice/topic/$topicId');
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
            json.decode(response.body)['choices'];
        List<TestChoiceMo> choices =
            responseData.map((data) => TestChoiceMo.fromJson(data)).toList();
        return choices;
      } else {
        throw Exception('Failed to get choices by topic');
      }
    } catch (e) {
      throw Exception('Failed to get choices by topic: $e');
    }
  }

  static Future<List<TestChoiceMo>> getTestChoiceByUser(String userId) async {
    final url = Uri.parse('${Constants.uri}/api/testchoice/user/$userId');
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
            json.decode(response.body)['testChoice'];
        List<TestChoiceMo> testChoices =
            responseData.map((data) => TestChoiceMo.fromJson(data)).toList();
        return testChoices;
      } else {
        throw Exception('Failed to get test choice by user');
      }
    } catch (e) {
      throw Exception('Failed to get test choice by user: $e');
    }
  }
}
