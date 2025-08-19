import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/location_controller.dart';
import 'confirm_pickup_screen.dart';

class RideOptionsScreen extends StatelessWidget {
  const RideOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LocationController>();

    final rideOptions = [
      {"type": "Bike", "multiplier": 8.0},
      {"type": "Auto", "multiplier": 12.0},
      {"type": "Cab Economy", "multiplier": 15.0},
    ];

    return Scaffold(
      body: Stack(
        children: [
          controller.buildMapWithPolyline(),

          SafeArea(
            child: Column(
              children: [
                const Spacer(),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Choose your ride",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Obx(
                        () => Column(
                          children: rideOptions.map((option) {
                            final fare =
                                controller.estimatedFare.value *
                                (option["multiplier"] as double) /
                                10;

                            return ListTile(
                              leading: Icon(
                                option["type"] == "Bike"
                                    ? Icons.pedal_bike
                                    : option["type"] == "Auto"
                                    ? Icons.local_taxi
                                    : Icons.directions_car,
                              ),
                              title: Text(option["type"] as String),
                              subtitle: Text(
                                "ETA: ${controller.eta.value} mins",
                              ),
                              trailing: Text("₹${fare.toStringAsFixed(0)}"),
                              onTap: () {
                                controller.selectedRideType.value =
                                    option["type"] as String;
                                Get.to(() => const ConfirmPickupScreen());
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
