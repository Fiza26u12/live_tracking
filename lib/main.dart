import 'package:flutter/material.dart';
import 'package:flutter_task/screens/drop_screen.dart';
import 'package:get/get.dart';
import 'controllers/location_controller.dart';

import 'screens/ride_options_screen.dart';
import 'screens/confirm_pickup_screen.dart';
import 'screens/route_preview_screen.dart';

void main() {
  Get.put(LocationController());
  runApp(const RapidoCloneApp());
}

class RapidoCloneApp extends StatelessWidget {
  const RapidoCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rapido Clone',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),

      home: DropScreen(),

      getPages: [
        GetPage(name: '/drop', page: () => DropScreen()),
        GetPage(name: '/ride-options', page: () => const RideOptionsScreen()),
        GetPage(
          name: '/confirm-pickup',
          page: () => const ConfirmPickupScreen(),
        ),
        GetPage(name: '/route-preview', page: () => const RoutePreviewScreen()),
      ],
    );
  }
}
