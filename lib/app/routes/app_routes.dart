import 'package:get/get.dart';

import '../bindings/app_bindings.dart';
import '../../views/screens/favorites_screen.dart';
import '../../views/screens/home_screen.dart';
import '../../views/screens/search_screen.dart';

class AppRoutes {
  static const home = '/';
  static const search = '/search';
  static const favorites = '/favorites';

  static final routes = [
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: search,
      page: () => const SearchScreen(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: favorites,
      page: () => const FavoritesScreen(),
      binding: FavoritesBinding(),
    ),
  ];
}
