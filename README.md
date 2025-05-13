Almalhy Store Flutter AppA Flutter-based e-commerce application showcasing a dynamic store front for FreshBasket. This app fetches categories and brands from live APIs, implements user authentication, and provides a seamless shopping experience.
📋 PrerequisitesFlutter 3.29.3 or later
Dart 3.7.2 or later
A connected Android or iOS device/emulator
(Optional) Xcode installed for iOS builds
🔧 Installation & SetupClone the repository
git clone https://github.com/Osama-Yaseen/almalhy_store.git
cd almalhy_storeInstall dependencies
flutter pub getConfigure API keys & environment
If you use Google APIs (e.g., Maps), ensure your ios/Runner/Info.plist and Android manifest have your restricted API key.
No additional environment variables are required for the default public API endpoints.
Run the app
Android:
flutter runiOS:
flutter run -d ios🚀 Using the AppBrowse categories on the Home screen (limited to the first six active categories).
Tap a category to view its products.
View brands in the Brands section.
Add items to the cart and manage quantities directly from the product list.
View your cart, adjust quantities, and proceed to checkout.
📁 Project Structurealmalhy_store/
├── android/            # Android-specific files
├── ios/                # iOS-specific files (Info.plist, etc.)
├── lib/                # Dart source code
│   ├── cubit/          # Cubit state management
│   ├── models/         # Data models
│   ├── screens/        # UI screens
│   ├── services/       # API integration, Dio setup
│   └── main.dart       # App entry point
├── pubspec.yaml        # Dependencies and assets
└── .gitignore          # Flutter build & IDE ignores🤝 ContributingFeel free to fork this repo, create feature branches, and submit pull requests. For major changes, please open an issue first to discuss your ideas.
📄 LicenseThis project is licensed under the MIT License.
