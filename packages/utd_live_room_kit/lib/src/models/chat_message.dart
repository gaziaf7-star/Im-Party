class UTDChatMessage {
  final String senderUserId;
  final String senderName;

  /// The message body. UNTRUSTED, peer-supplied input relayed verbatim by the
  /// backend (no server-side sanitization). Render as plain text only — never
  /// pass to an HTML/WebView/markdown sink. See security_edits M7.
  final String text;
  final DateTime timestamp;
  final Map<String, dynamic> userData;
  final String messageID;

  UTDChatMessage({
    required this.senderUserId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.userData = const {},
    String? messageID,
  }) : messageID =
            messageID ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, String> get attributes =>
      userData.map((k, v) => MapEntry(k, v.toString()));

  Map<String, dynamic> toJson() => {
        'message': 'chatMessage',
        'senderUserId': senderUserId,
        'senderName': senderName,
        'text': text,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'messageID': messageID,
        if (userData.isNotEmpty) 'userData': userData,
      };

  factory UTDChatMessage.fromJson(Map<String, dynamic> json) {
    return UTDChatMessage(
      senderUserId: json['senderUserId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? '',
      text: json['text'] as String? ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        json['timestamp'] as int? ?? 0,
      ),
      userData: (json['userData'] as Map<String, dynamic>?) ?? {},
      messageID: json['messageID'] as String?,
    );
  }

  static bool isChat(Map<String, dynamic> json) =>
      json['message'] == 'chatMessage';
}
