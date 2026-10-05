class SmsMessage {
  final String sender;
  final String body;
  final DateTime receivedAt;

  SmsMessage({
    required this.sender,
    required this.body,
    required this.receivedAt,
  });
}