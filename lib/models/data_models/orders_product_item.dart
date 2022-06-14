class OrdersProductItem {
  final String title;
  final String quantity;
  final String price;

  static List<OrdersProductItem> fromMap(List data) {
    return data.map((order) {
      return OrdersProductItem(
        title: order['title'],
        quantity: order['quantity'],
        price: order['price'].toString(),
      );
    }).toList();
  }

  OrdersProductItem(
      {required this.title, required this.quantity, required this.price});
}
