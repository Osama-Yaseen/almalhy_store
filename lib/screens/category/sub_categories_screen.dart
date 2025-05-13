// lib/presentation/screens/sub_categories_screen.dart

import 'package:almalhy_store/cubit/cateogory/category_cubit.dart';
import 'package:almalhy_store/cubit/cateogory/category_state.dart';
import 'package:almalhy_store/models/category_model.dart';
import 'package:almalhy_store/routes/app_pages.dart';
import 'package:almalhy_store/theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class SubCategoriesScreen extends StatefulWidget {
  final int parentId;
  final String title;

  const SubCategoriesScreen({
    super.key,
    required this.parentId,
    required this.title,
  });

  @override
  State<SubCategoriesScreen> createState() => _SubCategoriesScreenState();
}

class _SubCategoriesScreenState extends State<SubCategoriesScreen> {
  /// our drill-down stack of levels
  final List<int> _parentStack = [];
  final List<String> _titleStack = [];

  @override
  void initState() {
    super.initState();
    // push the initial level
    _parentStack.add(widget.parentId);
    _titleStack.add(widget.title);
    _loadCurrent();
  }

  void _loadCurrent() {
    final currentId = _parentStack.last;
    context.read<CategoryCubit>().loadSubCategories(currentId);
  }

  /// call when a user taps a category
  void _onTapCategory(CategoryModel c) {
    final localized = _localizedName(c);
    if (c.isFinalLevel) {
      Get.toNamed(
        AppRoutes.products,
        arguments: {'categoryId': c.id, 'categoryTitle': localized},
      );
    } else {
      // push a new level onto our stack
      setState(() {
        _parentStack.add(c.id);
        _titleStack.add(localized);
      });
      _loadCurrent();
    }
  }

  String _localizedName(CategoryModel c) =>
      context.locale.languageCode == 'ar' ? c.nameAr : c.nameEn;

  Future<bool> _onWillPop() async {
    if (_parentStack.length > 1) {
      // if we're not at root, pop one level
      setState(() {
        _parentStack.removeLast();
        _titleStack.removeLast();
      });
      _loadCurrent();
      return false; // don't pop the page
    }
    return true; // at root → actually pop
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: BackButton(
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            _titleStack.last,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          backgroundColor: AppColors.primary,
        ),
        body: BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CategoryLoaded) {
              final subs = state.categories;
              if (subs.isEmpty) {
                return Center(child: Text(tr('no_sub_categories')));
              }
              return Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  itemCount: subs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    final c = subs[index];
                    return GestureDetector(
                      onTap: () => _onTapCategory(c),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.secondery,
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Expanded(
                              child: Builder(
                                builder: (ctx) {
                                  final url = c.logo;
                                  if (url == null || url.isEmpty) {
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
                                    loadingBuilder: (ctx, child, prog) {
                                      if (prog == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      );
                                    },
                                    errorBuilder: (ctx, err, stack) {
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
                              lang == 'ar' ? c.nameAr : c.nameEn,
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
            } else if (state is CategoryError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
