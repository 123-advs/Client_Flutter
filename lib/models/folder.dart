class Folder {
  final String id;
  final String name;
  final String description;
  final List<String> topics;
  final String user;

  Folder({
    required this.id,
    required this.name,
    required this.description,
    required this.topics,
    required this.user,
  });

  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      topics: (json['topics'] != null) ? List<String>.from(json['topics']) : [],
      user: json['user'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'topics': topics,
      'user': user,
    };
  }

  @override
  String toString() {
    return 'User { _id: $id, name: $name, description: $description, topics: $topics, user: $user }';
  }
}
