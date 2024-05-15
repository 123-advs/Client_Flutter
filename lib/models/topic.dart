import 'package:uuid/uuid.dart';

class Topic {
  final String id;
  final String definitionLanguage;
  final String termLanguage;
  late final String description;
  String mode;
  late final List<Term> terms;
  late final String title;
  late final String user;

  Topic({
    required this.id,
    this.definitionLanguage = 'vn',
    this.termLanguage = 'en',
    required this.description,
    required this.mode,
    required this.terms,
    required this.title,
    required this.user,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['_id'] ?? '',
      definitionLanguage: json['definitionLanguage'] ?? 'vn',
      termLanguage: json['termLanguage'] ?? 'en',
      description: json['description'] ?? '',
      mode: json['mode'] ?? '',
      terms: (json['terms'] != null)
          ? (json['terms'] as List<dynamic>)
              .map((termJson) => Term.fromJson(termJson))
              .toList()
          : [],
      title: json['title'] ?? '',
      user: json['user'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'definitionLanguage': definitionLanguage,
      'termLanguage': termLanguage,
      'description': description,
      'mode': mode,
      'terms': terms.map((term) => term.toJson()).toList(),
      'title': title,
      'user': user,
    };
  }

  @override
  String toString() {
    return 'Topic { _id: $id, definitionLanguage: $definitionLanguage, termLanguage: $termLanguage, description: $description, mode: $mode, terms: $terms, title: $title, user: $user}';
  }
}

class Term {
  final String id;
  final String definition;
  final String term;
  final bool star;

  Term({
    required this.id,
    required this.definition,
    required this.term,
    this.star = false,
  });

  factory Term.fromJson(Map<String, dynamic> json) {
    return Term(
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
