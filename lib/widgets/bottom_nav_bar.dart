// lib/widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/app_router.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, AppRouter.homeRoute);
            break;
          case 1:
          // Search is usually handled within the home screen or a dedicated search screen
          // For now, it will lead to the home screen.
            Navigator.pushReplacementNamed(context, AppRouter.homeRoute);
            break;
          case 2:
            Navigator.pushReplacementNamed(context, AppRouter.wishlistRoute);
            break;
          case 3:
            Navigator.pushReplacementNamed(context, AppRouter.profileRoute);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined),
          activeIcon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          activeIcon: Icon(Icons.favorite),
          label: 'Wishlist',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: AppColors.greyText,
      backgroundColor: AppColors.white,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      elevation: 8,
    );
  }
}