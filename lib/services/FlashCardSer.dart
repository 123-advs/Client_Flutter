import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_final/models/flashCardMo.dart';
import 'package:flutter_final/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlashCardService {
  static Future<FlashCardMo?> createFlashCard(
    String topicId,
    List<TermF> providedTermKnew,
    List<TermF> providedTermStudy,
    Map<String, dynamic> optionAnswer,
    String userId,
  ) async {
    final url = Uri.parse('${Constants.uri}/api/flashcard');

    final Map<String, dynamic> body = {
      'topic': topicId,
      'termKnew': providedTermKnew,
      'termStudy': providedTermStudy,
      'optionAnswer': optionAnswer,
      'user': userId,
    };

    final String bodyJson = jsonEncode(body);

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('accessToken');
      if (accessToken == null) {
        throw Exception('Access token not found.');
      }

      final http.Response response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: bodyJson,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return FlashCardMo.fromJson(responseData['createdFlashCard']);
      } else {
        print(
            'Failed to create flash card. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception(
            'Failed to create flash card. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to create flash card: $e');
      throw Exception('Failed to create flash card: $e');
    }
  }

  static Future<List<FlashCardMo>?> getFlashCardByTopic(String topicId) async {
    final url = Uri.parse('${Constants.uri}/api/flashcard/topic/$topicId');
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
            json.decode(response.body)['flashCards'];
        List<FlashCardMo> flashCards =
            responseData.map((data) => FlashCardMo.fromJson(data)).toList();
        return flashCards;
      } else {
        throw Exception('Failed to get choices by topic');
      }
    } catch (e) {
      throw Exception('Failed to get choices by topic: $e');
    }
  }

  static Future<List<FlashCardMo>> getFlashCardByUser(String userId) async {
    final url = Uri.parse('${Constants.uri}/api/flashcard/$userId');
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
            json.decode(response.body)['flashCards'];
        List<FlashCardMo> flashCards =
            responseData.map((data) => FlashCardMo.fromJson(data)).toList();
        return flashCards;
      } else {
        throw Exception('Failed to get flash cards by user');
      }
    } catch (e) {
      throw Exception('Failed to get flash cards by user: $e');
    }
  }

  static Future<FlashCardMo?> updateFlashCardByTopic(
    String topicId,
    List<TermF> termKnew,
    List<TermF> termStudy,
    Map<String, dynamic> optionAnswer,
    String userId,
  ) async {
    final url = Uri.parse('${Constants.uri}/api/flashcard/topic/$topicId');

    final Map<String, dynamic> body = {
      'termKnew': termKnew,
      'termStudy': termStudy,
      'optionAnswer': optionAnswer,
      'user': userId,
    };

    final String bodyJson = jsonEncode(body);

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('accessToken');
      if (accessToken == null) {
        throw Exception('Access token not found.');
      }

      final http.Response response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: bodyJson,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return FlashCardMo.fromJson(responseData['updatedFlashCard']);
      } else {
        print(
            'Failed to update flash card. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception(
            'Failed to update flash card. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to update flash card: $e');
      throw Exception('Failed to update flash card: $e');
    }
  }
}
