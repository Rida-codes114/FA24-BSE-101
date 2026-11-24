import 'package:flutter/material.dart';

import '../services/watchx_database_service.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final String orderId;

  const OrderConfirmationScreen({super.key, required this.orderId});

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  Map<String, dynamic>? _order;
  List<OrderItem> _items = [];
  bool _isLoading = true;
  String? _error;

  static const Color background = Color(0xFF0B0B0B);
  static const Color cardColor = Color(0xFF171717);
  static const Color gold = Color(0xFFD4AF70);
  static const Color muted = Color(0xFF999999);

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    try {
      final order = await WatchXDatabaseService.getOrderById(widget.orderId);

      if (order == null) {
        throw Exception('Order details could not be found.');
      }

      final items = await WatchXDatabaseService.getOrderItems(widget.orderId);

      if (!mounted) return;

      setState(() {
        _order = order;
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(dynamic value) {
    if (value == null) return 'Not available';

    final date = DateTime.tryParse(value.toString());

    if (date == null) return 'Not available';

    final localDate = date.toLocal();

    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final year = localDate.year;

    final hour = localDate.hour % 12 == 0 ? 12 : localDate.hour % 12;
    final minute = localDate.minute.toString().padLeft(2, '0');
    final period = localDate.hour >= 12 ? 'PM' : 'AM';

    return '$day/$month/$year  $hour:$minute $period';
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: muted, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: gold,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _buildProductCard(OrderItem item) {
    final name = item['watch_name']?.toString() ?? 'Watch';
    final brand = item['brand']?.toString() ?? '';
    final imageUrl = item['image_url']?.toString() ?? '';
    final price = (item['unit_price'] as num?)?.toInt() ?? 0;
    final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
    final lineTotal = (item['line_total'] as num?)?.toInt() ?? price * quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 75,
                    height: 75,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _imagePlaceholder();
                    },
                  )
                : _imagePlaceholder(),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brand,
                  style: const TextStyle(
                    color: gold,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Rs. $price  x  $quantity',
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Rs. $lineTotal',
            style: const TextStyle(
              color: gold,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 75,
      height: 75,
      color: const Color(0xFF242424),
      child: const Icon(Icons.watch_outlined, color: gold, size: 32),
    );
  }

  Widget _buildOrderDetails() {
    final order = _order!;

    final subtotal = (order['subtotal'] as num?)?.toInt() ?? 0;
    final deliveryFee = (order['delivery_fee'] as num?)?.toInt() ?? 0;
    final total = (order['total'] as num?)?.toInt() ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          Center(
            child: Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: gold,
                size: 55,
              ),
            ),
          ),

          const SizedBox(height: 18),

          const Center(
            child: Text(
              'ORDER PLACED!',
              style: TextStyle(
                color: gold,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),

          const SizedBox(height: 9),

          const Center(
            child: Text(
              'Thank you for shopping with WatchX.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 14),
            ),
          ),

          const SizedBox(height: 28),

          _sectionCard(
            title: 'Order Information',
            child: Column(
              children: [
                _detailRow('Order ID', order['id'].toString()),
                _detailRow('Order Date', _formatDate(order['created_at'])),
                _detailRow(
                  'Order Status',
                  order['status']?.toString() ?? 'Pending',
                ),
                _detailRow(
                  'Payment Method',
                  order['payment_method']?.toString() ?? 'Cash on Delivery',
                ),
              ],
            ),
          ),

          _sectionCard(
            title: 'Customer Information',
            child: Column(
              children: [
                _detailRow(
                  'Customer Name',
                  order['customer_name']?.toString() ?? '',
                ),
                _detailRow('Phone Number', order['phone']?.toString() ?? ''),
                _detailRow(
                  'Delivery Address',
                  order['address']?.toString() ?? '',
                ),
                _detailRow('City', order['city']?.toString() ?? ''),
              ],
            ),
          ),

          _sectionCard(
            title: 'Ordered Products',
            child: _items.isEmpty
                ? const Text(
                    'No products found for this order.',
                    style: TextStyle(color: muted),
                  )
                : Column(children: _items.map(_buildProductCard).toList()),
          ),

          _sectionCard(
            title: 'Payment Summary',
            child: Column(
              children: [
                _detailRow('Subtotal', 'Rs. $subtotal'),
                _detailRow(
                  'Delivery Fee',
                  deliveryFee == 0 ? 'Free' : 'Rs. $deliveryFee',
                ),
                const Divider(color: Colors.white24, height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Rs. $total',
                      style: const TextStyle(
                        color: gold,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.only(bottom: 22),
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: gold.withValues(alpha: 0.35)),
            ),
            child: const Row(
              children: [
                Icon(Icons.local_shipping_outlined, color: gold, size: 27),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your order is currently Pending. Please keep your phone available for delivery updates.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            width: double.infinity,
            height: 53,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'CONTINUE SHOPPING',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Order Confirmation',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: gold))
            : _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: gold, size: 50),
                      const SizedBox(height: 15),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                ),
              )
            : _buildOrderDetails(),
      ),
    );
  }
}
