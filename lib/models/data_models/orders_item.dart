import 'package:grocery/models/data_models/coupon.dart';
import 'package:grocery/models/data_models/orders_product_item.dart';
import 'package:grocery/models/data_models/shipping_method.dart';

class OrdersItem {
  final String id;
  final List<OrdersProductItem> products;
  final ShippingMethod shippingMethod;
  final String orderPrice;
  final String total;
  final String status;
  final String date;
  final String paymentMethod;
  final Coupon? coupon;
  final String? deliveryComment;
  final String? adminComment;

  factory OrdersItem.fromMap(Map<String, dynamic> data, String id) {
    return OrdersItem(
      id: id,
      paymentMethod: data["payment_method"] ?? "Cash in delivery",
      products: OrdersProductItem.fromMap(data['products']),
      shippingMethod: ShippingMethod(
        title: data['shipping_method']['title'],
        price: data['shipping_method']['price'].toString(),
      ),
      adminComment: data['admin_comment'],
      deliveryComment: data['delivery_comment']!=null
          ? data['delivery_comment']['comment']
          : null,
      orderPrice: data['order'].toString(),
      total: data['total'].toString(),
      status: data['status'] ?? "Processing",
      date: data['date'],
      coupon:
          data['coupon']!=null ? Coupon.fromMap(data['coupon']) : null,
    );
  }

  OrdersItem(
      {required this.id,
      required this.products,
      required this.shippingMethod,
      required this.orderPrice,
      required this.total,
      required this.paymentMethod,
      required this.status,
      required this.date,
      this.coupon,
      this.deliveryComment,
      this.adminComment});
}
