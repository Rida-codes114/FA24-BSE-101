import 'package:flutter/material.dart';

import '../services/watchx_database_service.dart';

class CartCheckoutScreen extends StatefulWidget {
  const CartCheckoutScreen({super.key});

  @override
  State<CartCheckoutScreen> createState() => _CartCheckoutScreenState();
}

class _CartCheckoutScreenState extends State<CartCheckoutScreen> {
  final Color gold = const Color(0xFFD6B66C);
  final Color background = const Color(0xFF101010);
  final Color cardColor = const Color(0xFF1C1C1C);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  List<WatchItem> cartItems = [];

  bool isLoading = true;

  final int deliveryCharges = 250;

  @override
  void initState() {
    super.initState();
    loadCartItems();
  }

  // Load cart items from database
  Future<void> loadCartItems() async {
    try {
      final items = await WatchXDatabaseService.getCartItems();

      if (!mounted) return;

      setState(() {
        cartItems = items;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Unable to load cart: $e')));
    }
  }

  // Calculate subtotal
  int get subtotal {
    return cartItems.fold(0, (total, item) {
      final price = (item['price'] as num?)?.toInt() ?? 0;
      final quantity = (item['quantity'] as num?)?.toInt() ?? 1;

      return total + (price * quantity);
    });
  }

  // Calculate total
  int get total {
    return cartItems.isEmpty ? 0 : subtotal + deliveryCharges;
  }

  // Update quantity
  Future<void> updateQuantity(int index, int change) async {
    final item = cartItems[index];

    final String watchId = item['id'].toString();

    final int currentQuantity = (item['quantity'] as num?)?.toInt() ?? 1;

    final int newQuantity = currentQuantity + change;

    if (newQuantity <= 0) return;

    try {
      await WatchXDatabaseService.updateCartQuantity(watchId, newQuantity);

      await loadCartItems();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to update quantity: $e')));
    }
  }

  // Remove item from cart
  Future<void> removeItem(int index) async {
    final String watchId = cartItems[index]['id'].toString();

    try {
      await WatchXDatabaseService.removeFromCart(watchId);

      await loadCartItems();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Watch removed from cart')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Unable to remove item: $e')));
    }
  }

  // Validate order details (demo only)
  void placeOrder() {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Your cart is empty')));
      return;
    }

    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all delivery details')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: Text('Order Details Ready!', style: TextStyle(color: gold)),
          content: const Text(
            'Your delivery details have been validated. '
            'The order saving process will be connected next.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text('OK', style: TextStyle(color: gold)),
            ),
          ],
        );
      },
    );
  }

  // Section heading
  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Delivery input fields
  Widget inputField({
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: gold),
          filled: true,
          fillColor: cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // Order summary row
  Widget summaryRow(String title, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isTotal ? Colors.white : Colors.grey,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? gold : Colors.white,
              fontSize: isTotal ? 17 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Cart product card
  Widget cartItemCard(int index) {
    final item = cartItems[index];

    final String name = item['name']?.toString() ?? 'Watch';
    final String imageUrl = item['image_url']?.toString() ?? '';
    final int price = (item['price'] as num?)?.toInt() ?? 0;
    final int quantity = (item['quantity'] as num?)?.toInt() ?? 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              width: 90,
              height: 105,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 90,
                  height: 105,
                  color: Colors.black,
                  child: Icon(Icons.watch, color: gold, size: 40),
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Rs. $price',
                  style: TextStyle(color: gold, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    _quantityButton(
                      Icons.remove,
                      () => updateQuantity(index, -1),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '$quantity',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),

                    _quantityButton(Icons.add, () => updateQuantity(index, 1)),
                  ],
                ),

                const SizedBox(height: 12),

                // Visible Remove button
                SizedBox(
                  height: 34,
                  child: OutlinedButton.icon(
                    onPressed: () => removeItem(index),
                    icon: const Icon(Icons.delete_outline, size: 17),
                    label: const Text('Remove'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Quantity button
  Widget _quantityButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 27,
        height: 27,
        decoration: BoxDecoration(
          border: Border.all(color: gold),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: gold, size: 16),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'SHOPPING CART',
          style: TextStyle(
            color: gold,
            fontSize: 18,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: gold),
      ),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: gold))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle('Your Cart'),

                    if (cartItems.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              color: gold,
                              size: 55,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Your cart is empty',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Add watches from the product details page.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...List.generate(
                        cartItems.length,
                        (index) => cartItemCard(index),
                      ),

                    const SizedBox(height: 15),

                    sectionTitle('Delivery Details'),

                    inputField(
                      hint: 'Full Name',
                      controller: nameController,
                      icon: Icons.person_outline,
                    ),

                    inputField(
                      hint: 'Phone Number',
                      controller: phoneController,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),

                    inputField(
                      hint: 'Complete Delivery Address',
                      controller: addressController,
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                    ),

                    inputField(
                      hint: 'City',
                      controller: cityController,
                      icon: Icons.location_city,
                    ),

                    const SizedBox(height: 12),

                    sectionTitle('Payment Method'),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: gold, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.money, color: gold, size: 28),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cash on Delivery',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Pay when your order arrives',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.check_circle, color: gold),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    sectionTitle('Order Summary'),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          summaryRow('Subtotal', 'Rs. $subtotal'),
                          summaryRow(
                            'Delivery Charges',
                            cartItems.isEmpty
                                ? 'Rs. 0'
                                : 'Rs. $deliveryCharges',
                          ),
                          const Divider(color: Colors.white24, height: 22),
                          summaryRow(
                            'Total Amount',
                            'Rs. $total',
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: placeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gold,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
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
    );
  }
}
