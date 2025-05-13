import 'package:almalhy_store/screens/auth/forgot_password_screen.dart';
import 'package:almalhy_store/screens/auth/reset_password_screen.dart';
import 'package:almalhy_store/screens/auth/location_picker_screen.dart';
import 'package:almalhy_store/screens/auth/otp_screen.dart';
import 'package:almalhy_store/screens/edit_profile_screen.dart';
import 'package:almalhy_store/screens/invoice_screen.dart';
import 'package:almalhy_store/screens/product/products_screen.dart';
import 'package:almalhy_store/screens/cart_screen.dart'; // ← import your CartScreen
import 'package:almalhy_store/screens/auth/login_screen.dart';
import 'package:almalhy_store/screens/auth/register_screen.dart';
import 'package:almalhy_store/screens/home/main_layout.dart';
import 'package:almalhy_store/screens/splash_screen.dart';
import 'package:almalhy_store/screens/category/sub_categories_screen.dart';
import 'package:get/get.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const locationPicker = '/location-picker';
  static const verifyOtp = '/verify-otp';
  static const forGotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const home = '/home';
  static const products = '/products';
  static const subCategories = '/subcategories';
  static const cart = '/cart';
  static const editProfile = '/editProfile'; // ← new
  static const invoice = '/invoice';
  static const invoiceDetail = '/invoice-detail';
  // static const invoice           = '/invoice';        // ← optional
}

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(name: AppRoutes.register, page: () => const RegisterScreen()),
    GetPage(
      name: AppRoutes.locationPicker,
      page: () => const LocationPickerScreen(),
    ),
    GetPage(
      name: AppRoutes.verifyOtp,
      page:
          () => OtpScreen(
            phone: Get.arguments["phone"],
            otp: Get.arguments["otp"],
          ),
    ),
    GetPage(
      name: AppRoutes.forGotPassword,
      page: () => const ForgotPasswordScreen(),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordScreen(),
    ),
    GetPage(name: AppRoutes.home, page: () => const MainLayout()),
    GetPage(name: AppRoutes.products, page: () => const ProductsScreen()),
    GetPage(
      name: AppRoutes.subCategories,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return SubCategoriesScreen(
          parentId: args['parentId'] as int,
          title: args['categoryTitle'] as String,
        );
      },
    ),
    //GetPage(name: AppRoutes.invoiceDetail, page: () => const ConfirmedCartsScreen()),

    // ← here’s the Cart screen route:
    GetPage(name: AppRoutes.cart, page: () => const CartScreen()),
    GetPage(name: AppRoutes.editProfile, page: () => const EditProfileScreen()),
    GetPage(name: AppRoutes.invoice, page: () => const InvoiceScreen()),
    // If/when you add an invoice screen, just uncomment:
    // GetPage(
    //   name: AppRoutes.invoice,
    //   page: () => const InvoiceScreen(),
    // ),
  ];
}
