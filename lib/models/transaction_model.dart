class TransactionItem {
  final int id;
  final double amount;
  final int type;
  final String type_name;
  final String desc;
  final String created_at;
  final String url;

  TransactionItem({
    required this.id,
    required this.amount,
    required this.type,
    required this.type_name,
    required this.desc,
    required this.created_at,
    required this.url,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'],
      amount: json['amount'],
      type: json['type'],
      type_name: json['type_name'],
      desc: json['desc'],
      created_at: json['created_at'],
      url: json['url'],
    );
  }
}
