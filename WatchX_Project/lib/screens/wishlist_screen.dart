import 'package:flutter/material.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final Color gold = const Color(0xFFD6B66C);
  final Color background = const Color(0xFF101010);
  final Color cardColor = const Color(0xFF1C1C1C);

  final List<Map<String, dynamic>> wishlist = [
    {
      'name': 'Classic Gold Watch',
      'brand': 'WATCHX PREMIUM',
      'price': 18500,
      'image':
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500',
    },
    {
      'name': 'Silver Chronograph',
      'brand': 'WATCHX CLASSIC',
      'price': 22000,
      'image':
          'https://images.unsplash.com/photo-1524805444758-089113d48a6d?w=500',
    },
    {
      'name': 'Luxury Black Watch',
      'brand': 'WATCHX ELITE',
      'price': 26500,
      'image':
          'https://images.unsplash.com/photo-1523170335258-f5ed11844a49?w=500',
    },
  ];

  void removeItem(int index) {
    setState(() {
      wishlist.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Watch removed from wishlist')),
    );
  }

  void addToCart(String name) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$name added to cart')));
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
          'MY WISHLIST',
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
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Favorites',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${wishlist.length} saved watches',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: wishlist.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite_border, size: 65, color: gold),
                            const SizedBox(height: 15),
                            const Text(
                              'Your wishlist is empty',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Save your favorite watches here.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: wishlist.length,
                        itemBuilder: (context, index) {
                          final item = wishlist[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    item['image'],
                                    width: 105,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 105,
                                        height: 120,
                                        color: Colors.black,
                                        child: Icon(
                                          Icons.watch,
                                          color: gold,
                                          size: 40,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 14),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['brand'],
                                        style: TextStyle(
                                          color: gold,
                                          fontSize: 10,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 7),
                                      Text(
                                        item['name'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Rs. ${item['price']}',
                                        style: TextStyle(
                                          color: gold,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      SizedBox(
                                        height: 36,
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              addToCart(item['name']),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: gold,
                                            foregroundColor: Colors.black,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                          ),
                                          child: const Text(
                                            'ADD TO CART',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                IconButton(
                                  onPressed: () => removeItem(index),
                                  icon: const Icon(
                                    Icons.favorite,
                                    color: Color(0xFFD6B66C),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
