import 'package:flutter/material.dart';

import '../services/google_drive_backup_service.dart';
import '../services/watchx_database_service.dart';
import '../theme/watchx_theme.dart';
import '../widgets/watch_cards.dart';
import 'checkout_screen.dart';
import 'my_orders_screen.dart';
import 'onboarding_screen.dart';
import 'product_details_screen.dart';

class WatchXMainShell extends StatefulWidget {
  final UserProfile user;

  const WatchXMainShell({super.key, required this.user});

  @override
  State<WatchXMainShell> createState() => _WatchXMainShellState();
}

class _WatchXMainShellState extends State<WatchXMainShell> {
  int _currentTab = 0;
  int _ordersRefreshKey = 0;

  List<WatchItem> _watches = [];
  List<WatchItem> _cartItems = [];

  Set<String> _favoriteIds = {};

  int _cartCount = 0;
  bool _isLoading = true;

  String _searchQuery = '';
  String _selectedCollection = 'ALL';
  String _selectedBrowseCategory = 'ALL';
  String _sortBy = 'FEATURED';

  final TextEditingController _atelierSearchCtrl = TextEditingController();
  final TextEditingController _browseSearchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  @override
  void dispose() {
    _atelierSearchCtrl.dispose();
    _browseSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    final activeCategory = _currentTab == 1
        ? _selectedBrowseCategory
        : _selectedCollection;

    final watches = await WatchXDatabaseService.getWatches(
      searchQuery: _searchQuery,
      categoryFilter: activeCategory,
      sortBy: _sortBy,
    );

    final favs = await WatchXDatabaseService.getFavoriteIds();
    final cartCount = await WatchXDatabaseService.getCartCount();
    final cartItems = await WatchXDatabaseService.getCartItems();

    if (!mounted) return;

    setState(() {
      _watches = watches;
      _favoriteIds = favs;
      _cartCount = cartCount;
      _cartItems = cartItems;
      _isLoading = false;
    });
  }

  Future<void> _onToggleFavorite(String watchId) async {
    await WatchXDatabaseService.toggleFavorite(watchId);
    await _refreshData();
  }

  Future<void> _onQuickAddToCart(WatchItem watch) async {
    await WatchXDatabaseService.addToCart(watch['id'].toString(), 1);

    await _refreshData();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: WatchXColors.cardDark,
        content: Text(
          '${watch['name']} added to Salon bag.',
          style: const TextStyle(color: WatchXColors.goldPrimary),
        ),
      ),
    );
  }

  Future<void> _openProductDetails(WatchItem watch) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(
          watch: watch,
          initialFavorite: _favoriteIds.contains(watch['id'].toString()),
          onChanged: _refreshData,
        ),
      ),
    );

    await _refreshData();
  }

  Future<void> _removeFromSalonBag(String watchId) async {
    await WatchXDatabaseService.removeFromCart(watchId);
    await _refreshData();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: WatchXColors.cardDark,
        content: Text(
          'Watch removed from Salon Bag.',
          style: TextStyle(color: WatchXColors.goldPrimary),
        ),
      ),
    );
  }

  Future<void> _changeSalonBagQuantity(String watchId, int quantity) async {
    await WatchXDatabaseService.updateCartQuantity(watchId, quantity);
    await _refreshData();
  }

  Future<void> _openCheckout() async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your Salon bag is empty. Add a watch first.'),
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
    );

    await _refreshData();

    if (mounted) {
      setState(() {
        _ordersRefreshKey++;
      });
    }
  }

  void _changeTab(int index) {
    setState(() {
      _currentTab = index;

      if (index == 4) {
        _ordersRefreshKey++;
      }
    });

    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WatchXColors.bgBlack,
      body: MobileFrameWrapper(
        child: Scaffold(
          backgroundColor: WatchXColors.bgBlack,
          appBar: _buildTopHeader(),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: WatchXColors.goldPrimary,
                  ),
                )
              : IndexedStack(
                  index: _currentTab,
                  children: [
                    _buildAtelierHomeScreen(),
                    _buildExploreWatchesScreen(),
                    _buildVaultScreen(),
                    _buildSalonBagScreen(),
                    MyOrdersScreen(key: ValueKey(_ordersRefreshKey)),
                    _buildPatronAndDriveScreen(),
                  ],
                ),
          bottomNavigationBar: _buildBottomNav(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildTopHeader() {
    final fullName = widget.user['full_name']?.toString() ?? 'Collector';

    return AppBar(
      backgroundColor: WatchXColors.bgBlack,
      elevation: 0,
      titleSpacing: 16,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: WatchXColors.surfaceDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: WatchXColors.borderDark),
            ),
            child: const Icon(
              Icons.watch,
              color: WatchXColors.goldPrimary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WATCHX',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: WatchXColors.textWhite,
                ),
              ),
              Text(
                'PRIVATE SALON',
                style: TextStyle(
                  fontSize: 8,
                  letterSpacing: 1.5,
                  color: WatchXColors.goldMuted,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => _changeTab(1),
          icon: const Icon(
            Icons.search,
            color: WatchXColors.textWhite,
            size: 20,
          ),
        ),
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: WatchXColors.cardDark,
                content: Text(
                  'All WatchX services are ready.',
                  style: TextStyle(color: WatchXColors.goldPrimary),
                ),
              ),
            );
          },
          icon: const Icon(
            Icons.notifications_none,
            color: WatchXColors.textWhite,
            size: 20,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 14, left: 4),
          child: GestureDetector(
            onTap: () => _changeTab(5),
            child: CircleAvatar(
              radius: 15,
              backgroundColor: WatchXColors.cardDark,
              child: Text(
                fullName.isNotEmpty
                    ? fullName.substring(0, 1).toUpperCase()
                    : 'W',
                style: const TextStyle(
                  color: WatchXColors.goldPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAtelierHomeScreen() {
    final displayName =
        widget.user['full_name']?.toString().split(' ').first ?? 'Collector';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, $displayName!',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: WatchXColors.textWhite,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Discover your perfect timepiece.',
            style: TextStyle(fontSize: 12, color: WatchXColors.textMuted),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _atelierSearchCtrl,
            style: const TextStyle(color: WatchXColors.textWhite, fontSize: 13),
            onChanged: (val) {
              _searchQuery = val;
              _refreshData();
            },
            decoration: InputDecoration(
              hintText: 'Search your favorite watches',
              hintStyle: const TextStyle(
                color: WatchXColors.textMuted,
                fontSize: 13,
              ),
              filled: true,
              fillColor: WatchXColors.cardDark,
              prefixIcon: const Icon(
                Icons.search,
                color: WatchXColors.textMuted,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: WatchXColors.borderDark),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: WatchXColors.goldPrimary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1F1A12), Color(0xFF110F0C)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: WatchXColors.goldPrimary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SALON PREMIERE',
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 1.4,
                          color: WatchXColors.goldPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Elegance in Every Second',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: WatchXColors.textWhite,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Explore our exclusive watch collection.',
                        style: TextStyle(
                          fontSize: 11,
                          color: WatchXColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1523170335258-f5ed11844a49?auto=format&fit=crop&w=600&q=80',
                      height: 125,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.watch,
                        size: 56,
                        color: WatchXColors.goldPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'CURATED COLLECTIONS',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.5,
              color: WatchXColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                WatchFilterPill(
                  label: 'ALL COLLECTIONS',
                  selected: _selectedCollection == 'ALL',
                  onTap: () {
                    _selectedCollection = 'ALL';
                    _refreshData();
                  },
                ),
                const SizedBox(width: 8),
                WatchFilterPill(
                  label: 'MEN\'S WATCHES',
                  selected: _selectedCollection == 'MEN\'S WATCHES',
                  onTap: () {
                    _selectedCollection = 'MEN\'S WATCHES';
                    _refreshData();
                  },
                ),
                const SizedBox(width: 8),
                WatchFilterPill(
                  label: 'WOMEN\'S WATCHES',
                  selected: _selectedCollection == 'WOMEN\'S WATCHES',
                  onTap: () {
                    _selectedCollection = 'WOMEN\'S WATCHES';
                    _refreshData();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Featured Masterpieces',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: WatchXColors.textWhite,
                ),
              ),
              GestureDetector(
                onTap: () => _changeTab(1),
                child: const Text(
                  'VIEW ALL >',
                  style: TextStyle(
                    fontSize: 11,
                    color: WatchXColors.goldPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _watches.isEmpty
              ? _buildEmptyState('No matching watches found.')
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _watches.length > 4 ? 4 : _watches.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, idx) {
                    final watch = _watches[idx];
                    final isFav = _favoriteIds.contains(watch['id'].toString());

                    return AtelierWatchCard(
                      watch: watch,
                      isFavorite: isFav,
                      onFavoriteTap: () =>
                          _onToggleFavorite(watch['id'].toString()),
                      onTap: () => _openProductDetails(watch),
                    );
                  },
                ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: WatchXColors.cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: WatchXColors.borderDark),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AtelierTrustBadge(
                  icon: Icons.verified_user_outlined,
                  title: 'WARRANTY',
                  subtitle: '5-Year Global',
                ),
                AtelierTrustBadge(
                  icon: Icons.lock_outline,
                  title: 'SECURE',
                  subtitle: 'Safe Shopping',
                ),
                AtelierTrustBadge(
                  icon: Icons.support_agent,
                  title: 'SUPPORT',
                  subtitle: 'Customer Care',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreWatchesScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Explore Watches',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: WatchXColors.textWhite,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_watches.length} watches available',
            style: const TextStyle(fontSize: 12, color: WatchXColors.textMuted),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _browseSearchCtrl,
            style: const TextStyle(color: WatchXColors.textWhite, fontSize: 13),
            onChanged: (val) {
              _searchQuery = val;
              _refreshData();
            },
            decoration: InputDecoration(
              hintText: 'Search watches...',
              hintStyle: const TextStyle(
                color: WatchXColors.textMuted,
                fontSize: 13,
              ),
              filled: true,
              fillColor: WatchXColors.cardDark,
              prefixIcon: const Icon(
                Icons.search,
                color: WatchXColors.textMuted,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: WatchXColors.borderDark),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: WatchXColors.goldPrimary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: WatchXColors.cardDark,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: WatchXColors.borderDark),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sortBy,
                isExpanded: true,
                dropdownColor: WatchXColors.cardDark,
                style: const TextStyle(
                  fontSize: 12,
                  color: WatchXColors.textWhite,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'FEATURED',
                    child: Text('Sort: Featured'),
                  ),
                  DropdownMenuItem(
                    value: 'PRICE_LOW',
                    child: Text('Price: Low to High'),
                  ),
                  DropdownMenuItem(
                    value: 'PRICE_HIGH',
                    child: Text('Price: High to Low'),
                  ),
                  DropdownMenuItem(value: 'RATING', child: Text('Top Rated')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    _sortBy = val;
                    _refreshData();
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                WatchFilterPill(
                  label: 'ALL WATCHES',
                  selected: _selectedBrowseCategory == 'ALL',
                  onTap: () {
                    _selectedBrowseCategory = 'ALL';
                    _refreshData();
                  },
                ),
                const SizedBox(width: 8),
                WatchFilterPill(
                  label: 'TOURBILLON',
                  selected: _selectedBrowseCategory == 'TOURBILLON',
                  onTap: () {
                    _selectedBrowseCategory = 'TOURBILLON';
                    _refreshData();
                  },
                ),
                const SizedBox(width: 8),
                WatchFilterPill(
                  label: 'SPORTS CHRONO',
                  selected: _selectedBrowseCategory == 'SPORTS CHRONO',
                  onTap: () {
                    _selectedBrowseCategory = 'SPORTS CHRONO';
                    _refreshData();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _watches.isEmpty
              ? _buildEmptyState('No watches match this filter.')
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _watches.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.66,
                  ),
                  itemBuilder: (context, idx) {
                    final watch = _watches[idx];
                    final isFav = _favoriteIds.contains(watch['id'].toString());

                    return CatalogWatchCard(
                      watch: watch,
                      isFavorite: isFav,
                      onFavoriteTap: () =>
                          _onToggleFavorite(watch['id'].toString()),
                      onQuickAddTap: () => _onQuickAddToCart(watch),
                      onTap: () => _openProductDetails(watch),
                    );
                  },
                ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: WatchXColors.cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: WatchXColors.borderDark),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.diamond_outlined,
                  color: WatchXColors.goldPrimary,
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bespoke Sourcing',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: WatchXColors.textWhite,
                        ),
                      ),
                      Text(
                        'Explore exclusive timepieces.',
                        style: TextStyle(
                          fontSize: 11,
                          color: WatchXColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaultScreen() {
    final favWatches = _watches
        .where((w) => _favoriteIds.contains(w['id'].toString()))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'My Wishlist',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: WatchXColors.textWhite,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${favWatches.length} saved watches',
          style: const TextStyle(fontSize: 12, color: WatchXColors.textMuted),
        ),
        const SizedBox(height: 16),
        if (favWatches.isEmpty)
          _buildEmptyState(
            'Your wishlist is empty. Tap the heart icon on any watch to save it.',
          )
        else
          ...favWatches.map(
            (w) => Card(
              color: WatchXColors.cardDark,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: WatchXColors.borderDark),
              ),
              child: ListTile(
                onTap: () => _openProductDetails(w),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    w['image_url'].toString(),
                    width: 54,
                    height: 54,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.watch,
                      color: WatchXColors.goldPrimary,
                    ),
                  ),
                ),
                title: Text(
                  w['name'].toString(),
                  style: const TextStyle(
                    color: WatchXColors.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${w['brand']} • ${formatWatchPrice(w['price'])}',
                  style: const TextStyle(
                    color: WatchXColors.goldPrimary,
                    fontSize: 12,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.favorite,
                    color: WatchXColors.goldPrimary,
                  ),
                  onPressed: () => _onToggleFavorite(w['id'].toString()),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSalonBagScreen() {
    int subtotal = 0;

    for (final watch in _cartItems) {
      final price = (watch['price'] as num?)?.toInt() ?? 0;
      final quantity = (watch['quantity'] as num?)?.toInt() ?? 1;

      subtotal += price * quantity;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Shopping Cart',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: WatchXColors.textWhite,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$_cartCount item(s) in your cart',
          style: const TextStyle(fontSize: 12, color: WatchXColors.textMuted),
        ),
        const SizedBox(height: 16),
        if (_cartItems.isEmpty)
          _buildEmptyState('Your cart is currently empty.')
        else ...[
          ..._cartItems.map((watch) {
            final watchId = watch['id'].toString();
            final name = watch['name']?.toString() ?? 'Watch';
            final image = watch['image_url']?.toString() ?? '';
            final price = (watch['price'] as num?)?.toInt() ?? 0;
            final quantity = (watch['quantity'] as num?)?.toInt() ?? 1;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: WatchXColors.cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: WatchXColors.borderDark),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      image,
                      width: 75,
                      height: 85,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 75,
                          height: 85,
                          color: WatchXColors.surfaceDark,
                          child: const Icon(
                            Icons.watch,
                            color: WatchXColors.goldPrimary,
                            size: 30,
                          ),
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
                            color: WatchXColors.textWhite,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          formatWatchPrice(price),
                          style: const TextStyle(
                            color: WatchXColors.goldPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _changeSalonBagQuantity(
                                watchId,
                                quantity - 1,
                              ),
                              icon: const Icon(Icons.remove),
                              color: WatchXColors.goldPrimary,
                              iconSize: 18,
                              visualDensity: VisualDensity.compact,
                            ),
                            Text(
                              '$quantity',
                              style: const TextStyle(
                                color: WatchXColors.textWhite,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => _changeSalonBagQuantity(
                                watchId,
                                quantity + 1,
                              ),
                              icon: const Icon(Icons.add),
                              color: WatchXColors.goldPrimary,
                              iconSize: 18,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete watch',
                    onPressed: () => _removeFromSalonBag(watchId),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 25,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: WatchXColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: WatchXColors.borderDark),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SUBTOTAL',
                  style: TextStyle(
                    color: WatchXColors.textMuted,
                    fontSize: 11,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  formatWatchPrice(subtotal),
                  style: const TextStyle(
                    color: WatchXColors.goldPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _openCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: WatchXColors.goldPrimary,
                foregroundColor: WatchXColors.bgBlack,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'PROCEED TO CHECKOUT',
                style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPatronAndDriveScreen() {
    return _PatronDriveTab(
      user: widget.user,
      onRestored: _refreshData,
      onOpenOrders: () => _changeTab(4),
      onOpenFavorites: () => _changeTab(2),
      onLogout: () async {
        final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: WatchXColors.cardDark,
            title: const Text(
              'Logout',
              style: TextStyle(color: WatchXColors.textWhite),
            ),
            content: const Text(
              'Are you sure you want to logout from WatchX?',
              style: TextStyle(color: WatchXColors.textMuted),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(color: WatchXColors.textMuted),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: WatchXColors.goldPrimary,
                  foregroundColor: WatchXColors.bgBlack,
                ),
                child: const Text('LOGOUT'),
              ),
            ],
          ),
        );

        if (shouldLogout != true) return;

        await WatchXDatabaseService.logoutUser();

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          (route) => false,
        );
      },
    );
  }

  Widget _buildEmptyState(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: WatchXColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WatchXColors.borderDark),
      ),
      child: Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(color: WatchXColors.textMuted, fontSize: 13),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentTab,
      type: BottomNavigationBarType.fixed,
      backgroundColor: WatchXColors.surfaceDark,
      selectedItemColor: WatchXColors.goldPrimary,
      unselectedItemColor: WatchXColors.textMuted,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      onTap: _changeTab,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'HOME',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.grid_view),
          activeIcon: Icon(Icons.grid_view_rounded),
          label: 'BROWSE',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          activeIcon: Icon(Icons.favorite),
          label: 'WISHLIST',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            isLabelVisible: _cartCount > 0,
            label: Text(
              '$_cartCount',
              style: const TextStyle(
                color: WatchXColors.bgBlack,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: WatchXColors.goldPrimary,
            child: const Icon(Icons.shopping_bag_outlined),
          ),
          activeIcon: Badge(
            isLabelVisible: _cartCount > 0,
            label: Text(
              '$_cartCount',
              style: const TextStyle(
                color: WatchXColors.bgBlack,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: WatchXColors.goldPrimary,
            child: const Icon(Icons.shopping_bag),
          ),
          label: 'CART',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: 'ORDERS',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'PROFILE',
        ),
      ],
    );
  }
}

// ======================================================
// PROFILE TAB
// ======================================================

class _PatronDriveTab extends StatefulWidget {
  final UserProfile user;
  final VoidCallback onRestored;
  final VoidCallback onOpenOrders;
  final VoidCallback onOpenFavorites;
  final VoidCallback onLogout;

  const _PatronDriveTab({
    required this.user,
    required this.onRestored,
    required this.onOpenOrders,
    required this.onOpenFavorites,
    required this.onLogout,
  });

  @override
  State<_PatronDriveTab> createState() => _PatronDriveTabState();
}

class _PatronDriveTabState extends State<_PatronDriveTab> {
  bool _busy = false;

  String _statusMessage = 'Your database backup and restore options are ready.';

  String get _userName => widget.user['full_name']?.toString() ?? 'WatchX User';

  String get _userEmail => widget.user['email']?.toString() ?? '';

  String get _userInitial {
    final name = _userName.trim();
    return name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'W';
  }

  Future<void> _runBackup() async {
    setState(() {
      _busy = true;
      _statusMessage = 'Uploading database to Google Drive...';
    });

    final result = await GoogleDriveBackupService.backupDatabaseToDrive();

    if (!mounted) return;

    setState(() {
      _busy = false;
      _statusMessage = result;
    });
  }

  Future<void> _runRestore() async {
    final shouldRestore = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: WatchXColors.cardDark,
        title: const Text(
          'Restore Database',
          style: TextStyle(color: WatchXColors.textWhite),
        ),
        content: const Text(
          'Restoring will replace the current local database with your Google Drive backup. Continue?',
          style: TextStyle(color: WatchXColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: WatchXColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: WatchXColors.goldPrimary,
              foregroundColor: WatchXColors.bgBlack,
            ),
            child: const Text('RESTORE'),
          ),
        ],
      ),
    );

    if (shouldRestore != true) return;

    setState(() {
      _busy = true;
      _statusMessage = 'Restoring database from Google Drive...';
    });

    final result = await GoogleDriveBackupService.restoreDatabaseFromDrive();

    widget.onRestored();

    if (!mounted) return;

    setState(() {
      _busy = false;
      _statusMessage = result;
    });
  }

  Widget _profileAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: WatchXColors.cardDark,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: WatchXColors.borderDark),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: WatchXColors.surfaceDark,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: WatchXColors.goldPrimary, size: 21),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: WatchXColors.textWhite,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: WatchXColors.textMuted, fontSize: 11),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: WatchXColors.textMuted,
          size: 15,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          letterSpacing: 1.5,
          color: WatchXColors.goldPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        const Text(
          'My Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: WatchXColors.textWhite,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Manage your WatchX account and preferences.',
          style: TextStyle(fontSize: 12, color: WatchXColors.textMuted),
        ),
        const SizedBox(height: 18),

        // PROFILE HEADER
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF292216), Color(0xFF15120D)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: WatchXColors.goldPrimary.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: WatchXColors.surfaceDark,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: WatchXColors.goldPrimary,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    _userInitial,
                    style: const TextStyle(
                      color: WatchXColors.goldPrimary,
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: WatchXColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _userEmail,
                      style: const TextStyle(
                        fontSize: 11,
                        color: WatchXColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: WatchXColors.surfaceDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: WatchXColors.goldPrimary.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                      child: const Text(
                        'WATCHX MEMBER',
                        style: TextStyle(
                          color: WatchXColors.goldPrimary,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ACCOUNT OPTIONS
        _sectionTitle('MY ACCOUNT'),

        _profileAction(
          icon: Icons.person_outline,
          title: 'Personal Information',
          subtitle: 'View your registered account details',
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                backgroundColor: WatchXColors.cardDark,
                title: const Text(
                  'Account Information',
                  style: TextStyle(color: WatchXColors.textWhite),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Full Name',
                      style: TextStyle(
                        color: WatchXColors.goldPrimary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userName,
                      style: const TextStyle(color: WatchXColors.textWhite),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Email Address',
                      style: TextStyle(
                        color: WatchXColors.goldPrimary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userEmail,
                      style: const TextStyle(color: WatchXColors.textWhite),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text(
                      'CLOSE',
                      style: TextStyle(color: WatchXColors.goldPrimary),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        _profileAction(
          icon: Icons.favorite_border,
          title: 'My Wishlist',
          subtitle: 'View your saved watches',
          onTap: widget.onOpenFavorites,
        ),

        _profileAction(
          icon: Icons.receipt_long_outlined,
          title: 'My Orders',
          subtitle: 'View your order history',
          onTap: widget.onOpenOrders,
        ),

        // BACKUP SECTION
        _sectionTitle('DATA & BACKUP'),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: WatchXColors.cardDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: WatchXColors.borderDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.cloud_sync_outlined,
                    color: WatchXColors.goldPrimary,
                    size: 22,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Google Drive Backup',
                      style: TextStyle(
                        color: WatchXColors.textWhite,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              const Text(
                'Back up your WatchX SQLite database to Google Drive or restore a previously saved database.',
                style: TextStyle(
                  color: WatchXColors.textMuted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _busy ? null : _runBackup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WatchXColors.goldPrimary,
                        foregroundColor: WatchXColors.bgBlack,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.cloud_upload_outlined, size: 17),
                      label: const Text(
                        'BACKUP',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : _runRestore,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: WatchXColors.goldPrimary),
                        foregroundColor: WatchXColors.goldPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.cloud_download_outlined, size: 17),
                      label: const Text(
                        'RESTORE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_busy) ...[
                const SizedBox(height: 15),
                const LinearProgressIndicator(
                  color: WatchXColors.goldPrimary,
                  backgroundColor: WatchXColors.surfaceDark,
                ),
              ],
              const SizedBox(height: 13),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: WatchXColors.surfaceDark,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  _statusMessage,
                  style: const TextStyle(
                    fontSize: 11,
                    color: WatchXColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        // APP INFORMATION
        _sectionTitle('APPLICATION'),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: WatchXColors.cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: WatchXColors.borderDark),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.watch_outlined,
                color: WatchXColors.goldPrimary,
                size: 25,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WATCHX',
                      style: TextStyle(
                        color: WatchXColors.textWhite,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.3,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Wrist Watch E-Commerce Application',
                      style: TextStyle(
                        color: WatchXColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'v1.0.0',
                style: TextStyle(color: WatchXColors.goldPrimary, fontSize: 11),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        // LOGOUT
        SizedBox(
          height: 49,
          child: OutlinedButton.icon(
            onPressed: _busy ? null : widget.onLogout,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text(
              'LOG OUT',
              style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1),
            ),
          ),
        ),

        const SizedBox(height: 18),

        const Center(
          child: Text(
            'WATCHX  •  ELEGANCE IN EVERY SECOND',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: WatchXColors.textMuted,
              fontSize: 9,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}
