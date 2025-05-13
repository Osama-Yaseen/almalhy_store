import 'package:almalhy_store/cubit/home/home_cubit.dart';
import 'package:almalhy_store/cubit/home/home_state.dart';
import 'package:almalhy_store/routes/app_pages.dart';
import 'package:almalhy_store/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(tr('main_sections')),
        centerTitle: true,
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoaded) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: state.allCategories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final cat = state.allCategories[index];
                  final lang = context.locale.languageCode;

                  return GestureDetector(
                    onTap: () {
                      final localizedTitle =
                          lang == 'ar' ? cat.nameAr : cat.nameEn;

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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.secondery,
                            blurRadius: 0,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
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
          } else if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Center(child: Text(tr('error_loading')));
          }
        },
      ),
    );
  }
}
