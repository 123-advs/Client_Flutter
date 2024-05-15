class TestChoiceMo {
  final String id;
  final List<Answer> answers;
  final OptionAnswer optionAnswer;
  final int overall;
  final String topic;
  final int totalQuestion;
  final String user;
  final DateTime createdAt;

  TestChoiceMo({
    required this.id,
    required this.answers,
    required this.optionAnswer,
    required this.overall,
    required this.topic,
    required this.totalQuestion,
    required this.user,
    required DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory TestChoiceMo.fromJson(Map<String, dynamic> json) {
    return TestChoiceMo(
      id: json['_id'] ?? '',
      answers: (json['answers'] as List<dynamic>?)
              ?.map((answer) => Answer.fromJson(answer))
              .toList() ??
          [],
      optionAnswer: OptionAnswer.fromJson(json['optionAnswer'] ?? {}),
      overall: json['overall'] ?? 0,
      topic: json['topic'] ?? '',
      totalQuestion: json['totalQuestion'] ?? 0,
      user: json['user'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'answers': answers.map((answer) => answer.toJson()).toList(),
      'optionAnswer': optionAnswer.toJson(),
      'overall': overall,
      'topic': topic,
      'totalQuestion': totalQuestion,
      'user': user,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'TestWriting { _id: $id, answers: $answers, optionAnswer: $optionAnswer, overall: $overall, topic: $topic, totalQuestion: $totalQuestion, user: $user, createdAt: $createdAt}';
  }
}

class Answer {
  final String answer;
  final bool result;
  final TermW term;

  Answer({
    required this.answer,
    required this.result,
    required this.term,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      answer: json['answer'],
      result: json['result'],
      term: TermW.fromJson(json['term']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'answer': answer,
      'result': result,
      'term': term.toJson(),
    };
  }
}

class OptionAnswer {
  final String answer;
  final int numberQues;
  final bool showAns;
  final bool shuffle;

  OptionAnswer({
    required this.answer,
    required this.numberQues,
    required this.showAns,
    required this.shuffle,
  });

  factory OptionAnswer.fromJson(Map<String, dynamic> json) {
    return OptionAnswer(
      answer: json['answer'],
      numberQues: json['numberQues'],
      showAns: json['showAns'],
      shuffle: json['shuffle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'answer': answer,
      'numberQues': numberQues,
      'showAns': showAns,
      'shuffle': shuffle,
    };
  }
}

class TermW {
  final String definition;
  final String term;

  TermW({
    required this.definition,
    required this.term,
  });

  factory TermW.fromJson(Map<String, dynamic> json) {
    return TermW(
      definition: json['definition'],
      term: json['term'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'definition': definition,
      'term': term,
    };
  }
}
