import 'package:flutter/material.dart';

import '../services/watchx_database_service.dart';
import 'order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _addressController = TextEditingController();

  final TextEditingController _cityController = TextEditingController();

  bool _isLoading = false;

  double _subtotal = 0;
  int _itemCount = 0;

  final int deliveryFee = 0;

  static const Color backgroundColor = Color(0xFF0B0B0B);
  static const Color cardColor = Color(0xFF171717);
  static const Color goldColor = Color(0xFFD4AF70);
  static const Color whiteColor = Colors.white;
  static const Color greyColor = Color(0xFFAAAAAA);

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final cartItems = await WatchXDatabaseService.getCartItems();

      double subtotal = 0;
      int count = 0;

      for (final item in cartItems) {
        final price = double.tryParse(item['price'].toString()) ?? 0;

        final quantity = int.tryParse(item['quantity'].toString()) ?? 0;

        subtotal += price * quantity;
        count += quantity;
      }

      if (!mounted) return;

      setState(() {
        _subtotal = subtotal;
        _itemCount = count;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Unable to load cart: $e')));
    }
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_itemCount == 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Your cart is empty.')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final orderId = await WatchXDatabaseService.placeOrder(
        customerName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        paymentMethod: 'Cash on Delivery',
        deliveryFee: deliveryFee,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderConfirmationScreen(orderId: orderId),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Unable to place order: $e')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();

    super.dispose();
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: whiteColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 9),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: whiteColor, fontSize: 14),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter $label';
            }

            if (label == 'Phone Number' && value.trim().length < 10) {
              return 'Please enter a valid phone number';
            }

            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: greyColor, fontSize: 13),
            prefixIcon: Icon(icon, color: goldColor, size: 20),
            filled: true,
            fillColor: cardColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF333333)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: goldColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String title, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isTotal ? whiteColor : greyColor,
              fontSize: isTotal ? 15 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? goldColor : whiteColor,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double total = _subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: whiteColor),
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: whiteColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DELIVERY INFORMATION',
                  style: TextStyle(
                    color: goldColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 20),

                _buildField(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  controller: _nameController,
                  icon: Icons.person_outline,
                ),

                const SizedBox(height: 18),

                _buildField(
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  controller: _phoneController,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 18),

                _buildField(
                  label: 'Delivery Address',
                  hint: 'Enter your complete address',
                  controller: _addressController,
                  icon: Icons.location_on_outlined,
                  maxLines: 2,
                ),

                const SizedBox(height: 18),

                _buildField(
                  label: 'City',
                  hint: 'Enter your city',
                  controller: _cityController,
                  icon: Icons.location_city_outlined,
                ),

                const SizedBox(height: 30),

                const Text(
                  'PAYMENT METHOD',
                  style: TextStyle(
                    color: goldColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 15),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: goldColor, width: 1),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.money, color: goldColor, size: 28),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cash on Delivery',
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Pay when your order arrives',
                              style: TextStyle(color: greyColor, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.check_circle, color: goldColor),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  'ORDER SUMMARY',
                  style: TextStyle(
                    color: goldColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 15),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF333333)),
                  ),
                  child: Column(
                    children: [
                      _summaryRow('Total Items', _itemCount.toString()),

                      _summaryRow(
                        'Subtotal',
                        'Rs. ${_subtotal.toStringAsFixed(0)}',
                      ),

                      _summaryRow(
                        'Delivery Fee',
                        deliveryFee == 0
                            ? 'FREE'
                            : 'Rs. ${deliveryFee.toStringAsFixed(0)}',
                      ),

                      const Divider(color: Color(0xFF444444), height: 25),

                      _summaryRow(
                        'Total Amount',
                        'Rs. ${total.toStringAsFixed(0)}',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goldColor,
                      disabledBackgroundColor: goldColor.withValues(alpha: 0.5),
                      foregroundColor: backgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 23,
                            width: 23,
                            child: CircularProgressIndicator(
                              color: backgroundColor,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'PLACE ORDER',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
