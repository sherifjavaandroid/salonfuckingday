import 'package:easycut/core/constant/routes.dart';
import 'package:easycut/core/services/services.dart';
import 'package:easycut/data/data_source/remote/main/booking_data.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../api_services.dart';


class RescheduleBookingController extends GetxController {
  final int bookingId;
  final int salonId;

  // Services
  final MyServices myServices = Get.find();
  late ApiService apiService;
  late BookingData bookingData;

  // State variables
  bool isLoading = false;
  String? selectedDate;
  String? selectedTimeSlot;
  List<String> availableTimeSlots = [];

  bool get canReschedule => selectedDate != null && selectedTimeSlot != null;

  RescheduleBookingController({
    required this.bookingId,
    required this.salonId,
  }) {
    apiService = ApiService();
    bookingData = BookingData(Get.find());
    if (kDebugMode) {
      print(
          "RescheduleBookingController initialized with bookingId: $bookingId, salonId: $salonId");
    }
  }

  void setSelectedDate(DateTime date) {
    // Format date for display and API
    final formatter = DateFormat('yyyy-MM-dd');
    selectedDate = formatter.format(date);

    // Clear previously selected time slot
    selectedTimeSlot = null;

    // Fetch available time slots for this date
    fetchAvailableTimeSlots();
    update();
  }

  void selectTimeSlot(String timeSlot) {
    selectedTimeSlot = timeSlot;
    update();
  }

  Future<void> fetchAvailableTimeSlots() async {
    if (selectedDate == null) return;

    isLoading = true;
    update();

    try {
      // Fetch services associated with this booking to calculate duration
      final serviceIds = await _getBookingServiceIds();

      if (kDebugMode) {
        print("Service IDs for booking: $serviceIds");
      }

      if (serviceIds.isEmpty) {
        if (kDebugMode) {
          print("No services found for this booking");
        }
        availableTimeSlots = [];
        isLoading = false;
        update();
        return;
      }

      // Note: We're keeping the original booking data call for time slots
      // since it appears to be a specialized endpoint not in our current API service
      availableTimeSlots = await bookingData.fetchAvailableTimes(
        salonId.toString(),
        selectedDate!,
        serviceIds,
      );

      if (kDebugMode) {
        print("Available time slots: $availableTimeSlots");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching available time slots: $e");
      }

      // Clear available time slots in case of error
      availableTimeSlots = [];

      // Show error message
      Get.snackbar('Error'.tr, 'Failed to load available time slots'.tr,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<List<String>> _getBookingServiceIds() async {
    try {
      final response = await apiService.getBookingServices(bookingId);

      if (kDebugMode) {
        print("Booking services response: $response");
      }

      if (response['status'] == 'success') {
        if (response['services'] != null && response['services'] is List) {
          return (response['services'] as List)
              .map((service) => service['service_id'].toString())
              .toList();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching booking services: $e");
      }
    }

    return [];
  }

  Future<void> rescheduleBooking() async {
    if (!canReschedule) {
      Get.snackbar('Error'.tr, 'Please select both date and time'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading = true;
    update();

    try {
      if (kDebugMode) {
        print(
            "Rescheduling booking $bookingId to date: $selectedDate, time: $selectedTimeSlot");
      }

      final response = await apiService.rescheduleBooking(
        bookingId: bookingId,
        newDate: selectedDate!,
        newTime: selectedTimeSlot!,
      );

      if (kDebugMode) {
        print("Reschedule response: $response");
      }

      if (response['status'] == 'success') {
        Get.snackbar(
            'Success'.tr, 'Your booking has been rescheduled successfully'.tr,
            snackPosition: SnackPosition.BOTTOM);

        // Navigate back to bookings page
        Get.offAllNamed(AppRoute.home);
      } else {
        Get.snackbar('Error'.tr,
            response['message'] ?? 'Failed to reschedule booking'.tr,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error rescheduling booking: $e");
      }
      Get.snackbar(
          'Error'.tr, 'An error occurred while rescheduling your booking'.tr,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading = false;
      update();
    }
  }
}