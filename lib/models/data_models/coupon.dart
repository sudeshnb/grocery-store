class Coupon {
  final String code;
  final String type;
  final num value;
  final DateTime expiryDate;

  Coupon(
      {required this.code,
      required this.type,
      required this.value,
      required this.expiryDate});

  factory Coupon.fromMap(Map<String, dynamic> data, [String? id]) {
    return Coupon(
      code: (id == null) ? data['code'] : id,
      type: data['type'],
      value: num.parse(data['value'].toString()),
      expiryDate: DateTime.parse(data['expiry_date']),
    );
  }
}

