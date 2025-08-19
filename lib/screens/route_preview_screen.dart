import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/location_controller.dart';

class RoutePreviewScreen extends StatelessWidget {
  const RoutePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LocationController>();

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
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Text(
                        "Ride: ${controller.selectedRideType.value}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      )),
                      const SizedBox(height: 8),
                      Obx(() => Text(
                        "Pickup: ${controller.pickupAddress.value.isNotEmpty ? controller.pickupAddress.value : "Not selected"}",
                        style: const TextStyle(color: Colors.green),
                      )),
                      Obx(() => Text(
                        "Drop: ${controller.dropAddress.value.isNotEmpty ? controller.dropAddress.value : "Not selected"}",
                        style: const TextStyle(color: Colors.red),
                      )),

                      const Divider(),
                      Obx(() => Text("ETA: ${controller.eta.value} mins")),
                      Obx(() => Text("Fare: ₹${controller.estimatedFare.value.toStringAsFixed(0)}")),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.snackbar(
                              "Booking Confirmed",
                              "Your ${controller.selectedRideType.value} is on the way!",
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow[700],
                            foregroundColor: Colors.black,
                          ),
                          child: const Text("Book Now"),
                        )
,
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
