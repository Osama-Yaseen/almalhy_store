// MainLayout with full navigation and demo category screen
import 'package:almalhy_store/screens/category/category_screen.dart';
import 'package:almalhy_store/screens/confirmed_cart_Screen.dart';
import 'package:almalhy_store/screens/profile.dart';
import 'package:almalhy_store/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentIndex = 0;

  final screens = const [
    HomeScreen(),
    CategoryScreen(),
    ConfirmedCartsScreen(),
    ProfileScreen(),
    DemoScreen(title: 'الإشعارات'),
  ];

  final List<IconData> icons = [
    Icons.home,
    Icons.grid_view,
    Icons.local_shipping,
    Icons.person_outline,
    Icons.notifications,
  ];

  final List<String> labels = [
    'الرئيسية',
    'الأقسام',
    'الطلبات',
    'حسابي',
    'الإشعارات',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NotificationListener<TabSwitchNotification>(
        onNotification: (notification) {
          setState(() => currentIndex = notification.tabIndex);
          return true; // stop propagation
        },
        child: Stack(
          children: List.generate(
            screens.length,
            (i) => Offstage(
              offstage: i != currentIndex,
              child: TickerMode(enabled: i == currentIndex, child: screens[i]),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: AppColors.background,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(icons.length, (index) {
              final isActive = currentIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    currentIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isActive
                            ? AppColors.primary.withOpacity(0.15)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icons[index],
                        color: isActive ? AppColors.primary : Colors.black45,
                        size: 22,
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 6),
                        Text(
                          labels[index],
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class DemoScreen extends StatelessWidget {
  final String title;
  const DemoScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(title),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// A notification that tells MainLayout which tab to switch to
class TabSwitchNotification extends Notification {
  final int tabIndex;
  TabSwitchNotification(this.tabIndex);
}
