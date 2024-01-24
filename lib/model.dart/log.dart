class Log {
  final String id;
  final String activity;
  final DateTime created_at;
  final String username;

  Log({
    required this.id,
    required this.activity,
    required this.created_at,
    required this.username,
  });

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
      id: json['id'] ?? '',
      activity: json['activity'] ?? '',
      created_at: DateTime.parse(json['created_at'] ?? ''),
      username: json['username'] ?? '', // Corrected assignment
      );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activity': activity,
      'created_at': created_at.toString(),
      'username': username, // Menyimpan informasi nama pengguna ke log
    };
  }
}
