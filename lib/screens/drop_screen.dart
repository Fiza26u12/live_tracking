import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import '../controllers/location_controller.dart';
import 'ride_options_screen.dart';

class DropScreen extends StatelessWidget {
  DropScreen({Key? key}) : super(key: key);

  final locationController = Get.find<LocationController>();
  final pickupController = TextEditingController();
  final dropController = TextEditingController();
  final pickupFocus = FocusNode();
  final dropFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          locationController.buildMapWithPolyline(),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GooglePlaceAutoCompleteTextField(
                            textEditingController: pickupController,
                            focusNode: pickupFocus,
                            googleAPIKey:
                                "AIzaSyB_CMs9yu7PP9B6Mvx6PnZJvDM7ivwz7Zs",
                            inputDecoration: const InputDecoration(
                              hintText: "Enter pickup location",
                              labelText: "Pickup",
                              labelStyle: TextStyle(color: Colors.black),
                              contentPadding: EdgeInsets.only(left: 12, top: 5),
                              border: InputBorder.none,
                            ),
                            debounceTime: 600,
                            isLatLngRequired: true,
                            getPlaceDetailWithLatLng: (Prediction prediction) {
                              if (prediction.lat != null &&
                                  prediction.lng != null) {
                                locationController.setPickup(
                                  LatLng(
                                    double.parse(prediction.lat!),
                                    double.parse(prediction.lng!),
                                  ),
                                  prediction.description ?? "",
                                );
                              }
                            },
                            itemClick: (Prediction prediction) {
                              pickupController.text =
                                  prediction.description ?? "";
                              pickupController.selection =
                                  TextSelection.fromPosition(
                                    TextPosition(
                                      offset: pickupController.text.length,
                                    ),
                                  );
                              if (prediction.lat != null &&
                                  prediction.lng != null) {
                                locationController.setPickup(
                                  LatLng(
                                    double.parse(prediction.lat!),
                                    double.parse(prediction.lng!),
                                  ),
                                  prediction.description ?? "",
                                );
                              }
                              pickupFocus.unfocus();
                            },
                          ),
                          const SizedBox(height: 16),

                          GooglePlaceAutoCompleteTextField(
                            textEditingController: dropController,
                            focusNode: dropFocus,
                            googleAPIKey:
                                "AIzaSyB_CMs9yu7PP9B6Mvx6PnZJvDM7ivwz7Zs",
                            inputDecoration: const InputDecoration(
                              hintText: "Enter drop location",
                              labelText: "Drop",
                              labelStyle: TextStyle(color: Colors.black),
                              contentPadding: EdgeInsets.only(left: 12, top: 5),
                              border: InputBorder.none,
                            ),
                            debounceTime: 600,
                            isLatLngRequired: true,
                            getPlaceDetailWithLatLng: (Prediction prediction) {
                              if (prediction.lat != null &&
                                  prediction.lng != null) {
                                locationController.setDestination(
                                  LatLng(
                                    double.parse(prediction.lat!),
                                    double.parse(prediction.lng!),
                                  ),
                                  prediction.description ?? "",
                                );
                              }
                            },
                            itemClick: (Prediction prediction) {
                              dropController.text =
                                  prediction.description ?? "";
                              dropController.selection =
                                  TextSelection.fromPosition(
                                    TextPosition(
                                      offset: dropController.text.length,
                                    ),
                                  );
                              if (prediction.lat != null &&
                                  prediction.lng != null) {
                                locationController.setDestination(
                                  LatLng(
                                    double.parse(prediction.lat!),
                                    double.parse(prediction.lng!),
                                  ),
                                  prediction.description ?? "",
                                );
                              }
                              dropFocus.unfocus();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (pickupController.text.isEmpty ||
                          dropController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Please select pickup and drop locations",
                            ),
                          ),
                        );
                        return;
                      }

                      await locationController.fetchRoute();
                      Get.to(() => RideOptionsScreen());
                    },
                    child: const Text(
                      "Next",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
