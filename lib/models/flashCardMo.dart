import 'package:uuid/uuid.dart';

class FlashCardMo {
  final String id;
  final List<TermF> termKnew;
  final List<TermF> termStudy;
  final OptionAnswer optionAnswer;
  final String topic;
  final String user;
  final DateTime createdAt;

  FlashCardMo({
    required this.id,
    required this.termKnew,
    required this.termStudy,
    required this.optionAnswer,
    required this.topic,
    required this.user,
    required DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory FlashCardMo.fromJson(Map<String, dynamic> json) {
    return FlashCardMo(
      id: json['_id'] ?? '',
      termKnew: (json['termKnew'] as List<dynamic>?)
              ?.map((term) => TermF.fromJson(term))
              .toList() ??
          [],
      termStudy: (json['termStudy'] as List<dynamic>?)
              ?.map((term) => TermF.fromJson(term))
              .toList() ??
          [],
      optionAnswer: OptionAnswer.fromJson(json['optionAnswer'] ?? {}),
      topic: json['topic'] ?? '',
      user: json['user'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'termKnew': termKnew.map((term) => term.toJson()).toList(),
      'termStudy': termStudy.map((term) => term.toJson()).toList(),
      'optionAnswer': optionAnswer.toJson(),
      'topic': topic,
      'user': user,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'FlashCardMo { id: $id, termKnew: $termKnew, termStudy: $termStudy, optionAnswer: $optionAnswer, topic: $topic, user: $user, createdAt: $createdAt }';
  }
}

class OptionAnswer {
  final String answer;
  final bool shuffle;

  OptionAnswer({
    required this.answer,
    required this.shuffle,
  });

  factory OptionAnswer.fromJson(Map<String, dynamic> json) {
    return OptionAnswer(
      answer: json['answer'],
      shuffle: json['shuffle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'answer': answer,
      'shuffle': shuffle,
    };
  }
}

class TermF {
  final String id;
  final String definition;
  final String term;
  final bool star;

  TermF({
    required this.id,
    required this.definition,
    required this.term,
    this.star = false,
  });

  factory TermF.fromJson(Map<String, dynamic> json) {
    return TermF(
      id: json['_id'] != null ? json['_id'] as String : _generateId(),
      definition: json['definition'] ?? '',
      term: json['term'] ?? '',
      star: json['star'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'definition': definition,
      'term': term,
      'star': star,
    };
  }

  static String _generateId() {
    var uuid = Uuid();
    return uuid.v4();
  }

  @override
  String toString() {
    return 'Term { id: $id, definition: $definition, term: $term, star: $star }';
  }
}
