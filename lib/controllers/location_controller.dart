import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationController extends GetxController {
  final currentLatLng = Rxn<LatLng>();
  final destinationLatLng = Rxn<LatLng>();

  final pickupAddress = "".obs;
  final dropAddress = "".obs;

  final mapController = Rxn<GoogleMapController>();
  final polylines = <Polyline>{}.obs;

  final distanceText = "".obs;
  final durationText = "".obs;
  final distanceKm = 0.0.obs;
  final durationSeconds = 0.obs;

  final fare = 0.0.obs;

  final selectedRideType = "Standard".obs;
  final eta = 0.obs;
  final estimatedFare = 0.0.obs;

  Stream<Position>? _positionStream;

  @override
  void onInit() {
    super.onInit();
    _startTracking();
  }

  Future<void> _startTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("Error", "Location services are disabled.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar("Error", "Location permission denied");
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Get.snackbar("Error", "Location permission permanently denied");
      return;
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    );

    _positionStream!.listen((Position position) async {
      currentLatLng.value = LatLng(position.latitude, position.longitude);

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && pickupAddress.value.isEmpty) {
        pickupAddress.value =
            "${placemarks.first.name}, ${placemarks.first.locality}";
      }

      if (mapController.value != null) {
        mapController.value!.animateCamera(
          CameraUpdate.newLatLng(currentLatLng.value!),
        );
      }

      if (destinationLatLng.value != null) {
        await fetchRoute();
      }
    });
  }

  void setDestination(LatLng latLng, String address) {
    destinationLatLng.value = latLng;
    dropAddress.value = address;
    fetchRoute();
  }

  LatLng? get pickupLatLng => currentLatLng.value;

  void setPickup(LatLng latLng, String address) {
    currentLatLng.value = latLng;
    pickupAddress.value = address;
  }

  Future<void> fetchRoute() async {
    if (currentLatLng.value == null || destinationLatLng.value == null) return;

    const String apiKey = "AIzaSyB_CMs9yu7PP9B6Mvx6PnZJvDM7ivwz7Zs";
    final url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${currentLatLng.value!.latitude},${currentLatLng.value!.longitude}&destination=${destinationLatLng.value!.latitude},${destinationLatLng.value!.longitude}&key=$apiKey";

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    if (data["routes"].isNotEmpty) {
      final route = data["routes"][0];
      final polylinePoints = decodePolyline(
        route["overview_polyline"]["points"],
      );

      polylines.value = {
        Polyline(
          polylineId: const PolylineId("route"),
          color: Colors.blue,
          width: 5,
          points: polylinePoints,
        ),
      };

      final leg = route["legs"][0];
      final dist = leg["distance"];
      final dur = leg["duration"];

      distanceText.value = dist["text"];
      durationText.value = dur["text"];
      distanceKm.value = (dist["value"] as num).toDouble() / 1000.0;
      durationSeconds.value = (dur["value"] as num).toInt();

      fare.value = (distanceKm.value * 10) + (durationSeconds.value / 60 * 1);

      eta.value = (durationSeconds.value / 60).ceil();
      estimatedFare.value = fare.value;
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }

  Widget buildMapWithPolyline() {
    return Obx(
      () => GoogleMap(
        initialCameraPosition: CameraPosition(
          target: currentLatLng.value ?? const LatLng(28.61, 77.20),
          zoom: 14,
        ),
        myLocationEnabled: true,
        markers: {
          if (currentLatLng.value != null)
            Marker(
              markerId: const MarkerId("pickup"),
              position: currentLatLng.value!,
              infoWindow: const InfoWindow(title: "Pickup"),
            ),
          if (destinationLatLng.value != null)
            Marker(
              markerId: const MarkerId("drop"),
              position: destinationLatLng.value!,
              infoWindow: const InfoWindow(title: "Drop"),
            ),
        },
        polylines: polylines.value,
        onMapCreated: (controller) => mapController.value = controller,
      ),
    );
  }
}
