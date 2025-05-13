import 'package:almalhy_store/cubit/auth/auth_cubit.dart';
import 'package:almalhy_store/cubit/cart/cart_cubit.dart';
import 'package:almalhy_store/cubit/cart/cart_state.dart';
import 'package:almalhy_store/cubit/static_page/static_page_cubit.dart';
import 'package:almalhy_store/cubit/static_page/static_page_state.dart';
import 'package:almalhy_store/routes/app_pages.dart';
import 'package:almalhy_store/screens/home/main_layout.dart';
import 'package:almalhy_store/screens/static_page_dialog_Screen.dart';
import 'package:almalhy_store/theme/app_theme.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../cubit/home/home_cubit.dart';
import '../../cubit/home/home_state.dart';
import '../../models/category_model.dart';
import '../../models/brand_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      _hasLoaded = true;
      // Now it’s safe to read inherited widgets like EasyLocalization
      final langCode = context.locale.languageCode;
      context.read<HomeCubit>().loadData(langCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return Center(
            child: LoadingAnimationWidget.hexagonDots(
              color: AppColors.primary,
              size: 50,
            ),
          );
        } else if (state is HomeLoaded) {
          return BlocBuilder<CartCubit, CartState>(
            builder: (context, cartState) {
              // build a simple id→qty map for the UI
              final cartMap = <int, int>{};
              int badgeCount = 0;
              if (cartState is CartLoaded) {
                for (final item in cartState.items) {
                  cartMap[item.product.id] = item.quantity;
                  badgeCount += item.quantity;
                }
              }
              return Scaffold(
                backgroundColor: AppColors.background,
                appBar: AppBar(
                  backgroundColor: AppColors.primary,
                  centerTitle: true,
                  title: const Text(
                    'المالحي',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  leading: Builder(
                    builder:
                        (context) => IconButton(
                          icon: const Icon(Icons.dashboard),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                  ),
                  actions: [
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart),
                          onPressed: () => Get.toNamed(AppRoutes.cart),
                        ),
                        if (badgeCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: CircleAvatar(
                              radius: 8,
                              backgroundColor: Colors.red,
                              child: Text(
                                '$badgeCount',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                drawer: Drawer(
                  backgroundColor: AppColors.background,
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DrawerHeader(
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.asset(
                                  'assets/images/logo2.jpg',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'أهلاً بك 👋',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.contact_mail),
                                title: const Text('تواصل معنا'),
                                onTap: () {
                                  showStaticPageDialog(
                                    context,
                                    'https://store-api.almalhy.com/public/api/v1/en/widgets/contact',
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.privacy_tip),
                                title: const Text('سياسة الخصوصية'),
                                onTap: () {
                                  showStaticPageDialog(
                                    context,
                                    'https://store-api.almalhy.com/public/api/v1/en/widgets/privacy',
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.policy),
                                title: const Text('الشروط والأحكام'),
                                onTap: () {
                                  showStaticPageDialog(
                                    context,
                                    'https://store-api.almalhy.com/public/api/v1/en/widgets/terms',
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary.withOpacity(
                                0.9,
                              ),
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              context.read<AuthCubit>().logout();
                              Get.offAllNamed(AppRoutes.login);
                            },
                            icon: const Icon(Icons.logout),
                            label: const Text('تسجيل الخروج'),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      _buildBannerCarousel(state.banners),
                      const SizedBox(height: 12),
                      _buildSectionHeaderWithAction(
                        context.tr('main_sections'),
                        context,
                        true,
                      ),
                      const SizedBox(height: 12),
                      _buildCategoryGrid(
                        state.categories.take(6).toList(),
                        context.locale.languageCode,
                      ),
                      const SizedBox(height: 12),
                      _buildSectionHeaderWithAction(
                        context.tr('brands'),
                        context,
                        false,
                      ),
                      _buildBrandList(state.brands),
                    ],
                  ),
                ),
              );
            },
          );
        } else if (state is HomeError) {
          return Center(child: Text(context.tr('error_loading')));
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildBannerCarousel(List<String>? banners) {
    // If there are no banners, show a single placeholder
    if (banners == null || banners.isEmpty) {
      return Container(
        height: 180,
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
        ),
      );
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 180,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        enlargeCenterPage: true,
        viewportFraction: 0.92,
      ),
      items:
          banners.map((imageUrl) {
            return Builder(
              builder: (context) {
                // If URL is null or empty, show placeholder
                if (imageUrl.isEmpty) {
                  return Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    // show a spinner while loading
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 180,
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    // on error, show a neutral placeholder
                    errorBuilder: (ctx, error, stack) {
                      return Container(
                        height: 180,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }).toList(),
    );
  }

  Widget _buildSectionHeaderWithAction(
    String title,
    BuildContext context,
    bool viewAllText,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          viewAllText
              ? GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        TabSwitchNotification(1).dispatch(context);
                      },
                      child: Text(
                        context.tr('see_all'),
                        style: const TextStyle(
                          color: AppColors.secondery,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.secondery,
                    ),
                  ],
                ),
              )
              : Padding(padding: EdgeInsets.all(2)),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(List<CategoryModel> categories, String lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            // inside HomeScreen’s GridView.builder onTap:
            onTap: () {
              final localizedTitle = lang == 'ar' ? cat.nameAr : cat.nameEn;

              if (cat.isFinalLevel) {
                // 1️⃣ FINAL LEVEL → go straight to products
                Get.toNamed(
                  AppRoutes.products,
                  arguments: {
                    'categoryId': cat.id,
                    'categoryTitle': localizedTitle,
                  },
                );
              } else {
                // 2️⃣ NOT FINAL LEVEL → drill down into sub-categories
                Get.toNamed(
                  AppRoutes.subCategories,
                  arguments: {
                    'parentId': cat.id,
                    'categoryTitle': localizedTitle,
                  },
                );
              }
            },

            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.secondery,
                    blurRadius: 0,
                    offset: Offset(5, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final url = cat.logo;
                        if (url == null || url.isEmpty) {
                          // no URL → show placeholder
                          return const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: Colors.grey,
                            ),
                          );
                        }

                        return Image.network(
                          url,
                          fit: BoxFit.contain,
                          width: 60,
                          height: 60,
                          // show a loader while the bytes come in
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          // if download fails (404, network error) or decode fails (corrupt image),
                          // we’ll hit this and show a fallback
                          errorBuilder: (context, error, stack) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 48,
                                color: Colors.grey,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lang == 'ar' ? cat.nameAr : cat.nameEn,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBrandList(List<BrandModel> brands) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: brands.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final logoUrl = brands[index].logo;
          return CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            child: ClipOval(
              child:
                  (logoUrl != null && logoUrl.isNotEmpty)
                      ? Image.network(
                        logoUrl,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        // if it fails to load (404, corrupt, etc.), show an icon
                        errorBuilder:
                            (ctx, error, stack) => const Icon(
                              Icons.storefront_outlined,
                              size: 36,
                              color: Colors.grey,
                            ),
                      )
                      : const Icon(
                        Icons.storefront_outlined,
                        size: 36,
                        color: Colors.grey,
                      ),
            ),
          );
        },
      ),
    );
  }
}
