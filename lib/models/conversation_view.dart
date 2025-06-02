
class ConversationView {
  final int conversationId;
  final String carTitle;
  final String carImageUrl;
  final String sellerName;
  final String carPrice;
  final DateTime lastMessageAt;

  ConversationView({
    required this.conversationId,
    required this.carTitle,
    required this.carImageUrl,
    required this.sellerName,
    required this.carPrice,
    required this.lastMessageAt,
  });

  factory ConversationView.fromJson(Map<String, dynamic> json) {
    return ConversationView(
      conversationId: json['conversationId'],
      carTitle: json['carTitle'],
      carImageUrl: json['carImageUrl'],
      sellerName: json['sellerName'],
      carPrice: json['carPrice'],
      lastMessageAt: DateTime.parse(json['lastMessageAt']),
    );
  }
}
