import 'package:flutter/material.dart';
import 'package:e_pay/utils/constants.dart';
import 'package:e_pay/models/models.dart';
import 'package:e_pay/screens/product_details_screen.dart';
import 'package:e_pay/screens/onboarding_screen.dart';
import 'package:e_pay/screens/chat_screen.dart';
import 'package:e_pay/l10n/app_localizations.dart';
import 'package:e_pay/widgets/language_selector.dart';
import 'package:e_pay/widgets/theme_toggle.dart';
import 'package:e_pay/services/auth_service.dart';
import 'package:e_pay/services/theme_service.dart';
import 'package:e_pay/services/language_service.dart';
import 'package:e_pay/services/data_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DataService _dataService = DataService();
  String? _selectedCategoryId;
  
  // Futures for data fetching
  late Future<List<Category>> _categoriesFuture;
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Listen to strict language changes to refresh data labels
    LanguageService().localeNotifier.addListener(_refreshData);
  }

  @override
  void dispose() {
    LanguageService().localeNotifier.removeListener(_refreshData);
    super.dispose();
  }

  void _loadData() {
    _categoriesFuture = _dataService.getCategories();
    _productsFuture = _dataService.getProducts(categoryId: _selectedCategoryId);
  }

  void _refreshData() {
    setState(() {
      _loadData();
    });
  }

  Future<void> _handleRefresh() async {
    _refreshData();
    try {
      await Future.wait([_categoriesFuture, _productsFuture]);
    } catch (e) {
      // Ignore errors during refresh as UI will show them
    }
  }

  void _onCategorySelected(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _productsFuture = _dataService.getProducts(categoryId: categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Auth Data
    final user = AuthService().currentUser;
    final userName = user?.userMetadata?['full_name'] ?? 'User';
    final userAvatar = user?.userMetadata?['avatar_url'];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [AppColors.backgroundDark, AppColors.surfaceDark]
              : [Colors.white, AppColors.accent.withOpacity(0.05)],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: AppColors.accent,
            child: CustomScrollView(
              slivers: [
                // 1. Header with Logo
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Row(
                      children: [
                        // Logo Image
                        Image.asset('assets/logo.png', height: 40), 
                        const Gap(12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${loc.translate('hello_user')} ${userName.split(' ')[0]}", 
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: isDark ? AppColors.textGrayLight : AppColors.textGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const ThemeToggle(),
                        const Gap(8),
                        const LanguageSelector(compact: true),
                        const Gap(12),
                        // Avatar with Menu
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'logout') {
                              await AuthService().signOut();
                              if (context.mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                                  (route) => false,
                                );
                              }
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                             
                            PopupMenuItem<String>(
                              value: 'logout',
                              child: Row(
                                children: const [
                                  Icon(Icons.logout, color: Colors.red),
                                  Gap(8),
                                  Text('Logout', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.accent, width: 2),
                            ),
                            child: ClipOval(
                              child: userAvatar != null 
                                ? Image.network(userAvatar, fit: BoxFit.cover) 
                                : const Icon(Icons.person),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SliverToBoxAdapter(child: Gap(16)),

                // 2. Categories Horizontal List
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 50,
                    child: FutureBuilder<List<Category>>(
                      future: _categoriesFuture,
                      builder: (context, snapshot) {
                         // Add "All" option manually
                        final allCategory = Category(id: 'all', name: loc.translate('cat_all'), icon: '🔥');
                        var categories = [allCategory];
                        
                        if (snapshot.hasData) {
                          categories.addAll(snapshot.data!);
                        }

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                             final cat = categories[index];
                             return _buildCategoryPill(cat.name, cat.id, icon: cat.icon);
                          },
                        );
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: Gap(24)),

                // 3. Products Grid (Sliver)
                FutureBuilder<List<Product>>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverToBoxAdapter(
                        child: Center(child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        )),
                      );
                    }
                    if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: Center(child: Text("Error: ${snapshot.error}")),
                      );
                    }
                    
                    final products = snapshot.data ?? [];
                    if (products.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(child: Text("No products found")),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = products[index];
                            return _buildProductCard(product, isDark);
                          },
                          childCount: products.length,
                        ),
                      ),
                    );
                  },
                ),
                
                // Bottom padding
                const SliverToBoxAdapter(child: Gap(80)),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => const ChatScreen(paymentMethod: 'Support'))
          );
        },
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }

  Widget _buildProductCard(Product product, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.05),
               blurRadius: 10,
               offset: const Offset(0, 4),
             ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.borderRadius)),
                  color: Colors.grey.shade200,
                  image: product.imageUrl.isNotEmpty ? DecorationImage(
                    image: NetworkImage(product.imageUrl),
                    fit: BoxFit.cover,
                  ) : null,
                ),
                child: product.imageUrl.isEmpty 
                  ? const Center(child: Icon(Icons.image_not_supported, color: Colors.grey))
                  : null,
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? AppColors.textLight : AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(4),
                    // Show price range or lowest offer
                    if (product.offers.isNotEmpty)
                       Text(
                         '${product.offers.first.price} TND', // Simplified, could find min
                         style: TextStyle(
                             fontWeight: FontWeight.bold, 
                             color: AppColors.accent,
                             fontSize: 12
                         ),
                       )
                     else
                       Text('No offers', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPill(String name, String id, {String? icon}) {
    final isSelected = (_selectedCategoryId == null && id == 'all') || _selectedCategoryId == id;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
         if (id == 'all') _onCategorySelected(null);
         else _onCategorySelected(id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : (isDark ? AppColors.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Text(icon, style: const TextStyle(fontSize: 16)),
              const Gap(8),
            ],
            Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.white : (isDark ? AppColors.textLight : AppColors.textDark),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
