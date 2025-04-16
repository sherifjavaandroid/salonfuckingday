import 'package:easycut/core/constant/routes.dart';
import 'package:easycut/core/services/services.dart';
import 'package:easycut/data/model/booking_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/data_source/remote/home/book_op.dart';

class BookingDetailController extends GetxController {
  final BookingModel booking;

  // Services
  final MyServices myServices = Get.find();
  late BookingOperationsData bookingOperations;

  // State variables for booking actions
  bool canModifyBooking = false; // Can cancel or reschedule
  bool canRateBooking = false;   // Can rate the service
  bool isAlreadyRated = false;   // Already rated
  bool isPastBooking = false;    // Booking date is in the past

  BookingDetailController({
    required this.booking,
  }) {
    bookingOperations = BookingOperationsData(Get.find());
    _initializeController();
  }

  Future<void> _initializeController() async {
    _checkBookingTiming();
    await _checkIfRated();
    update();
  }

  void _checkBookingTiming() {
    try {
      // Check if booking is in the past
      if (booking.day == null || booking.time == null) {
        isPastBooking = false;
        canModifyBooking = false;
        return;
      }

      // Parse booking date and time
      final dateFormat = DateFormat('yyyy-MM-dd');
      final bookingDate = dateFormat.parse(booking.day!);

      // Parse time (assuming format like "14:30" or "2:30 PM")
      final timeParts = booking.time!.split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1].split(' ').first); // Handle potential AM/PM

      // Create DateTime object for booking date and time
      final bookingDateTime = DateTime(
        bookingDate.year,
        bookingDate.month,
        bookingDate.day,
        hour,
        minute,
      );

      // Check if booking is in past
      final now = DateTime.now();
      isPastBooking = bookingDateTime.isBefore(now);

      // Can modify (cancel/reschedule) if:
      // 1. Booking is approved (status = 1) or pending (status = 0)
      // 2. Booking is in the future
      // 3. More than 6 hours until booking time
      final sixHoursBeforeBooking = bookingDateTime.subtract(const Duration(hours: 6));
      canModifyBooking = (booking.approve == "0" || booking.approve == "1") &&
          !isPastBooking &&
          now.isBefore(sixHoursBeforeBooking);

      // Can rate if:
      // 1. Booking was approved (status = 1)
      // 2. Booking date has passed
      canRateBooking = booking.approve == "1" && isPastBooking && !isAlreadyRated;

    } catch (e) {
      if (kDebugMode) {
        print("Error checking booking timing: $e");
      }
      // Default to safe values
      isPastBooking = false;
      canModifyBooking = false;
      canRateBooking = false;
    }
  }

  Future<void> _checkIfRated() async {
    try {
      final response = await bookingOperations.checkBookingRated(
        int.parse(booking.id.toString()),
      );

      if (response != null && response['status'] == 'success') {
        isAlreadyRated = response['is_rated'] == true;

        // Update canRateBooking based on whether it's already rated
        canRateBooking = canRateBooking && !isAlreadyRated;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error checking if booking is rated: $e");
      }
      // Assume not rated to let user try
      isAlreadyRated = false;
    }
    update();
  }

  void showRatingScreen() {
    if (!canRateBooking) {
      String message = isAlreadyRated
          ? "You have already rated this booking".tr
          : "This booking cannot be rated".tr;

      Get.snackbar(
        'Information'.tr,
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Navigate to rating screen
    Get.toNamed(AppRoute.rateBooking, arguments: {
      'bookingId': int.parse(booking.id.toString()),
      'salonName': booking.salonname,
      'bookingDate': booking.day,
    });
  }
}