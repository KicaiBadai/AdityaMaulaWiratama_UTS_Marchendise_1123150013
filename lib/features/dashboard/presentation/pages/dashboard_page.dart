import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import internal (pastikan path sesuai dengan project kamu)
import '../../domain/repositories/product_provider.dart';
import '../../data/models/product_model.dart';
import '../widgets/product_card.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/theme_provider.dart'; // Import ThemeProvider

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedCategory = 'All';
  int _selectedIndex = 0;

  final List<String> _categories = [
    'All',
    'Electronics',
    'Fashion',
    'Shoes',
    'Accessories',
  ];

  @override
  void initState() {
    super.initState();
    // Memanggil data saat pertama kali page dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // --- LOGIC HELPER ---

  String _formatPrice(double price) {
    // Cara simpel formatting rupiah tanpa library intl
    final str = price.toInt().toString();
    final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return 'Rp ${str.replaceAllMapped(regex, (Match m) => '${m[1]}.')}';
  }

  List<ProductModel> _getFilteredProducts(List<ProductModel> products) {
    final query = _searchCtrl.text.toLowerCase();
    return products.where((p) {
      final matchCategory =
          _selectedCategory == 'All' ||
          p.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchSearch =
          query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query);
      return matchCategory && matchSearch;
    }).toList();
  }

  // --- UI COMPONENTS ---

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody(productProvider)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBody(ProductProvider provider) {
    return switch (provider.status) {
      ProductStatus.loading ||
      ProductStatus.initial => const Center(child: CircularProgressIndicator()),
      ProductStatus.error => _buildErrorState(provider),
      ProductStatus.loaded => _buildProductGrid(provider.products),
    };
  }

  Widget _buildHeader() {
    final isDark = context.watch<ThemeProvider>().isDark;

    return Column(
      children: [
        // Top Bar: Theme Switcher
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pasar Malam',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    size: 20,
                    color: isDark ? Colors.amber : Colors.grey,
                  ),
                  Switch(
                    value: isDark,
                    onChanged: (_) =>
                        context.read<ThemeProvider>().toggleTheme(),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Cari produk favoritmu...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildBannerCard(),
        const SizedBox(height: 16),
        _buildCategoriesRow(),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'For You',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesRow() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedCategory = category),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(List<ProductModel> products) {
    final filtered = _getFilteredProducts(products);

    if (filtered.isEmpty) {
      return const Center(child: Text('Produk tidak ditemukan'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) =>
          ProductCard(product: filtered[index], formatPrice: _formatPrice),
    );
  }

  Widget _buildErrorState(ProductProvider provider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.red),
        Text(provider.error ?? 'Error'),
        ElevatedButton(
          onPressed: () => provider.fetchProducts(),
          child: const Text('Coba Lagi'),
        ),
      ],
    );
  }

  Widget _buildBannerCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Colors.blueAccent],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Diskon 50%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Khusus hari ini!',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Icon(Icons.shopping_bag, size: 40, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Fav'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
