
import 'package:flutter/material.dart';
import '../services/watchx_database_service.dart';
import '../theme/watchx_theme.dart';

class ProductDetailsScreen extends StatefulWidget {
  final WatchItem watch;
  final bool initialFavorite;
  final VoidCallback onChanged;

  const ProductDetailsScreen({
    super.key,
    required this.watch,
    required this.initialFavorite,
    required this.onChanged,
  });

  @override
  State<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late bool _isFavorite;
  late String _selectedCaseFinish;
  late String _selectedStrap;
  int _strapExtra = 0;
  int _quantity = 1;

  final List<Map<String, dynamic>> _strapOptions = [
    {
      'title': 'Hand-stitched Black Alligator Leather',
      'tag': 'STANDARD',
      'extra': 0,
    },
    {
      'title': 'Saddle Brown Alligator Leather',
      'tag': '+\$450',
      'extra': 450,
    },
    {
      'title': 'Vulcanized High-Grip Rubber',
      'tag': 'INCLUDED',
      'extra': 0,
    },
  ];

  @override
  void initState() {
    super.initState();

    _isFavorite = widget.initialFavorite;

    _selectedCaseFinish =
        widget.watch['case_finish']?.toString() ?? 'ROSE GOLD';

    _selectedStrap = widget.watch['strap_name']?.toString() ??
        'Hand-stitched Black Alligator Leather';

    _strapExtra = (widget.watch['strap_extra'] as int?) ?? 0;
  }

  int get _totalUnitPrice {
    final base = (widget.watch['price'] as int?) ?? 0;
    return base + _strapExtra;
  }

  Future<void> _toggleFav() async {
    final next = await WatchXDatabaseService.toggleFavorite(
      widget.watch['id'].toString(),
    );

    if (!mounted) return;

    setState(() => _isFavorite = next);
    widget.onChanged();
  }

  Future<void> _addToCart() async {
    await WatchXDatabaseService.addToCart(
      widget.watch['id'].toString(),
      _quantity,
    );

    widget.onChanged();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: WatchXColors.cardDark,
        content: Text(
          'Added $_quantity x ${widget.watch['name']} ($_selectedCaseFinish) to Salon bag.',
          style: const TextStyle(
            color: WatchXColors.goldPrimary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.watch;

    return Scaffold(
      backgroundColor: WatchXColors.bgBlack,
      body: MobileFrameWrapper(
        child: Scaffold(
          backgroundColor: WatchXColors.bgBlack,
          appBar: AppBar(
            backgroundColor: WatchXColors.bgBlack,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: WatchXColors.textWhite,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'TIMEPIECE DETAILS',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.8,
                color: WatchXColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.share_outlined,
                  color: WatchXColors.textWhite,
                  size: 20,
                ),
                onPressed: () {},
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: WatchXColors.surfaceDark,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: WatchXColors.borderDark,
                      ),
                    ),
                    child: Text(
                      w['edition_banner']?.toString() ??
                          '•  LIMITED EDITION • CERTIFIED',
                      style: const TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.5,
                        color: WatchXColors.goldPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF1F1A12),
                        Color(0xFF0E0C0A),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: WatchXColors.borderDark,
                    ),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          w['image_url'].toString(),
                          height: 190,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.watch,
                            size: 72,
                            color: WatchXColors.goldPrimary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 18,
                            height: 4,
                            decoration: BoxDecoration(
                              color: WatchXColors.goldPrimary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            width: 6,
                            height: 4,
                            decoration: BoxDecoration(
                              color: WatchXColors.borderDark,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            width: 6,
                            height: 4,
                            decoration: BoxDecoration(
                              color: WatchXColors.borderDark,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      w['brand']?.toString() ?? '',
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.5,
                        color: WatchXColors.goldPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      w['reference_code']?.toString() ?? 'REF. WX-01',
                      style: const TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.2,
                        color: WatchXColors.textMuted,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  w['name']?.toString() ?? '',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: WatchXColors.textWhite,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 15,
                      color: WatchXColors.goldPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${w['rating']} (${w['reviews']} verified collector reviews)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: WatchXColors.textMuted,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: WatchXColors.cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: WatchXColors.borderDark,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${formatWatchPrice(_totalUnitPrice)} USD',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: WatchXColors.goldPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: WatchXColors.surfaceDark,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: WatchXColors.borderDark,
                              ),
                            ),
                            child: Text(
                              w['stock_text']?.toString() ?? 'In Stock',
                              style: const TextStyle(
                                fontSize: 11,
                                color: WatchXColors.textWhite,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        '✓ Taxes & insured armored courier delivery included',
                        style: TextStyle(
                          fontSize: 11,
                          color: WatchXColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'MASTERPIECE SYNOPSIS',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    color: WatchXColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  w['synopsis']?.toString() ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: WatchXColors.textMuted,
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'CASE FINISH',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.5,
                        color: WatchXColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '18K $_selectedCaseFinish',
                      style: const TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.2,
                        color: WatchXColors.goldPrimary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: ['ROSE GOLD', 'TITANIUM', 'DLC BLACK']
                      .map((finish) {
                    final active = _selectedCaseFinish == finish;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCaseFinish = finish;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                            right: finish == 'DLC BLACK' ? 0 : 8,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: active
                                ? WatchXColors.surfaceDark
                                : WatchXColors.cardDark,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: active
                                  ? WatchXColors.goldPrimary
                                  : WatchXColors.borderDark,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 14,
                                color: finish == 'ROSE GOLD'
                                    ? WatchXColors.goldPrimary
                                    : finish == 'TITANIUM'
                                        ? Colors.grey
                                        : Colors.black54,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                finish,
                                style: const TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 1.0,
                                  color: WatchXColors.textWhite,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 18),

                const Text(
                  'STRAP CONFIGURATION',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    color: WatchXColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                ..._strapOptions.map((opt) {
                  final title = opt['title'].toString();
                  final selected = _selectedStrap == title;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedStrap = title;
                        _strapExtra = (opt['extra'] as int?) ?? 0;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: WatchXColors.cardDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? WatchXColors.goldPrimary
                              : WatchXColors.borderDark,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            size: 18,
                            color: selected
                                ? WatchXColors.goldPrimary
                                : WatchXColors.textMuted,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 12,
                                color: WatchXColors.textWhite,
                              ),
                            ),
                          ),
                          Text(
                            opt['tag'].toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.1,
                              color: WatchXColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 14),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.0,
                  children: [
                    _DetailSpecTile(
                      title: 'SWISS CERTIFIED',
                      value: '100% Certified Swiss Made',
                    ),
                    _DetailSpecTile(
                      title: 'WARRANTY',
                      value: '5-Year Global Protection',
                    ),
                    _DetailSpecTile(
                      title: 'CALIBRE',
                      value: w['calibre']?.toString() ?? '',
                    ),
                    _DetailSpecTile(
                      title: 'RESERVE',
                      value: w['reserve']?.toString() ?? '',
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                const Text(
                  'HAUTE HORLOGERIE TECHNICALS',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    color: WatchXColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: WatchXColors.cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: WatchXColors.borderDark,
                    ),
                  ),
                  child: Column(
                    children: [
                      _TechRow(
                        label: 'MOVEMENT DIAMETER',
                        value: w['diameter']?.toString() ?? '43.0 mm',
                      ),
                      _TechRow(
                        label: 'CASE THICKNESS',
                        value: w['thickness']?.toString() ?? '11.8 mm',
                      ),
                      _TechRow(
                        label: 'POWER RESERVE',
                        value: w['reserve']?.toString() ?? '72 Hours',
                      ),
                      _TechRow(
                        label: 'VIBRATION FREQUENCY',
                        value: w['frequency']?.toString() ?? '28,800 vph',
                      ),
                      _TechRow(
                        label: 'WATER RESISTANCE',
                        value: w['water_resistance']?.toString() ??
                            '50 Metres (5 ATM)',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: WatchXColors.cardDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: WatchXColors.borderDark,
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (_quantity > 1) {
                                setState(() => _quantity--);
                              }
                            },
                            icon: const Icon(
                              Icons.remove,
                              size: 16,
                              color: WatchXColors.textWhite,
                            ),
                          ),
                          Text(
                            '$_quantity',
                            style: const TextStyle(
                              color: WatchXColors.textWhite,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() => _quantity++);
                            },
                            icon: const Icon(
                              Icons.add,
                              size: 16,
                              color: WatchXColors.textWhite,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: WatchXColors.cardDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: WatchXColors.borderDark,
                        ),
                      ),
                      child: IconButton(
                        onPressed: _toggleFav,
                        icon: Icon(
                          _isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: WatchXColors.goldPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _addToCart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WatchXColors.goldPrimary,
                            foregroundColor: WatchXColors.bgBlack,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'ADD TO CART  ${formatWatchPrice(_totalUnitPrice * _quantity)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailSpecTile extends StatelessWidget {
  final String title;
  final String value;

  const _DetailSpecTile({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: WatchXColors.cardDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: WatchXColors.borderDark,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 9,
              letterSpacing: 1.2,
              color: WatchXColors.goldPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: WatchXColors.textWhite,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TechRow extends StatelessWidget {
  final String label;
  final String value;

  const _TechRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 1.1,
              color: WatchXColors.textMuted,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: WatchXColors.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
