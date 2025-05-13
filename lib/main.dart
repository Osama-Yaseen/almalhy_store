import 'package:almalhy_store/cubit/auth/auth_cubit.dart';
import 'package:almalhy_store/cubit/cart/cart_cubit.dart';
import 'package:almalhy_store/cubit/cateogory/category_cubit.dart';
import 'package:almalhy_store/cubit/cities/cities_cubit.dart';
import 'package:almalhy_store/cubit/home/home_cubit.dart';
import 'package:almalhy_store/cubit/product/product_cubit.dart';
import 'package:almalhy_store/cubit/static_page/static_page_cubit.dart';
import 'package:almalhy_store/services/auth_service.dart';
import 'package:almalhy_store/services/city_service.dart';
import 'package:almalhy_store/services/home_services.dart';
import 'package:almalhy_store/services/products_services.dart';
import 'package:almalhy_store/services/static_page_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:easy_localization/easy_localization.dart';
import 'routes/app_pages.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: const AlmalhyApp(),
    ),
  );
}

class AlmalhyApp extends StatelessWidget {
  const AlmalhyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthService>(create: (_) => AuthService()),
        RepositoryProvider<CityService>(create: (_) => CityService()),
        RepositoryProvider<HomeService>(create: (_) => HomeService()),
        RepositoryProvider<ProductService>(create: (_) => ProductService()),
        RepositoryProvider<StaticPageService>(
          create: (_) => StaticPageService(),
        ),
      ],

      child: MultiBlocProvider(
        providers: [
          BlocProvider<CitiesCubit>(
            lazy: false,
            create: (ctx) => CitiesCubit(CityService())..fetchCities(),
          ),
          BlocProvider(create: (ctx) => AuthCubit(ctx.read<AuthService>())),
          BlocProvider(create: (ctx) => HomeCubit(ctx.read<HomeService>())),
          BlocProvider(
            create: (ctx) => ProductCubit(ctx.read<ProductService>()),
          ),
          BlocProvider(create: (ctx) => CategoryCubit(ctx.read<HomeService>())),
          BlocProvider(create: (_) => CartCubit()),
          BlocProvider(
            create: (ctx) => StaticPageCubit(ctx.read<StaticPageService>()),
          ),
        ],
        child: GetMaterialApp(
          title: 'Almalhy',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
        ), // or your GetMaterialApp
      ),
    );
  }
}
