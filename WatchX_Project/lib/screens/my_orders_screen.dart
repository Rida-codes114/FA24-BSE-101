import 'package:flutter/material.dart';

import '../services/watchx_database_service.dart';
import 'order_confirmation_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  List<OrderItem> _orders = [];
  bool _isLoading = true;
  String? _error;

  static const Color background = Color(0xFF0B0B0B);
  static const Color cardColor = Color(0xFF171717);
  static const Color gold = Color(0xFFD4AF70);
  static const Color muted = Color(0xFF999999);

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final user = await WatchXDatabaseService.getActiveUser();

      final orders = await WatchXDatabaseService.getOrders(
        userEmail: user?['email']?.toString() ?? '',
      );

      if (!mounted) return;

      setState(() {
        _orders = orders;
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
    if (value == null) return 'Date unavailable';

    final date = DateTime.tryParse(value.toString());

    if (date == null) return 'Date unavailable';

    final localDate = date.toLocal();

    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final year = localDate.year;

    return '$day/$month/$year';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.redAccent;
      case 'shipped':
        return Colors.blueAccent;
      default:
        return gold;
    }
  }

  Widget _statusBadge(String status) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.7,
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderItem order) {
    final orderId = order['id']?.toString() ?? '';
    final status = order['status']?.toString() ?? 'Pending';

    final total = (order['total'] as num?)?.toInt() ?? 0;

    final customerName = order['customer_name']?.toString() ?? 'Customer';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.watch_outlined, color: gold, size: 25),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WATCHX ORDER',
                      style: TextStyle(
                        color: gold,
                        fontSize: 10,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      orderId,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              _statusBadge(status),
            ],
          ),

          const SizedBox(height: 18),

          const Divider(color: Colors.white12),

          const SizedBox(height: 10),

          _infoRow(Icons.person_outline, 'Customer', customerName),

          const SizedBox(height: 13),

          _infoRow(
            Icons.calendar_today_outlined,
            'Order Date',
            _formatDate(order['created_at']),
          ),

          const SizedBox(height: 13),

          _infoRow(
            Icons.payment_outlined,
            'Payment',
            order['payment_method']?.toString() ?? 'Cash on Delivery',
          ),

          const SizedBox(height: 18),

          const Divider(color: Colors.white12),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(color: muted, fontSize: 13),
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

          const SizedBox(height: 17),

          SizedBox(
            width: double.infinity,
            height: 45,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        OrderConfirmationScreen(orderId: orderId),
                  ),
                ).then((_) {
                  _loadOrders();
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: gold,
                side: const BorderSide(color: gold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'VIEW ORDER DETAILS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: muted, size: 17),

        const SizedBox(width: 10),

        Text(title, style: const TextStyle(color: muted, fontSize: 12)),

        const Spacer(),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyOrders() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: gold,
                size: 48,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'NO ORDERS YET',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Your orders will appear here after you complete a purchase.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 13, height: 1.5),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.black,
              ),
              child: const Text('CONTINUE SHOPPING'),
            ),
          ],
        ),
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

        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            onPressed: _loadOrders,
            icon: const Icon(Icons.refresh, color: gold),
            tooltip: 'Refresh Orders',
          ),
        ],
      ),

      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: gold))
            : _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: gold, size: 45),

                      const SizedBox(height: 15),

                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: _loadOrders,
                        child: const Text('TRY AGAIN'),
                      ),
                    ],
                  ),
                ),
              )
            : _orders.isEmpty
            ? _buildEmptyOrders()
            : RefreshIndicator(
                color: gold,
                backgroundColor: cardColor,
                onRefresh: _loadOrders,
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    Text(
                      '${_orders.length} ORDER${_orders.length == 1 ? '' : 'S'}',
                      style: const TextStyle(
                        color: gold,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 18),

                    ..._orders.map(_buildOrderCard),
                  ],
                ),
              ),
      ),
    );
  }
}
