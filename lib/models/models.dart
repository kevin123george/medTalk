class Chat {
  const Chat({
    required this.sender,
    required this.subject,
    required this.content,
  });

  final User sender;
  final String subject;
  final String content;
}

class Name {
  const Name({
    required this.first,
    required this.last,
  });

  final String first;
  final String last;

  String get fullName => '$first $last';
}

class User {
  const User({
    required this.name,
    required this.avatarUrl,
    required this.lastActive,
    required this.id,
  });

  final int id;
  final Name name;
  final String avatarUrl;
  final DateTime lastActive;
}
