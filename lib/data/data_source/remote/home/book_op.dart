import 'package:easycut/core/class/crud.dart';
import 'package:easycut/linkapi.dart';

class BookingOperationsData {
  final Crud crud;

  BookingOperationsData(this.crud);

  // Get booking details
  Future<Map<String, dynamic>?> getBookingDetails(int bookingId) async {
    var response = await crud.postData(AppLink.viewBookingDetails, {
      "booking_id": bookingId.toString(),
    });

    return response.fold((failure) => null, (success) => success);
  }

  // Get services associated with a booking
  Future<Map<String, dynamic>?> getBookingServices(int bookingId) async {
    var response = await crud.postData(AppLink.viewBookingServices, {
      "booking_id": bookingId.toString(),
    });

    return response.fold((failure) => null, (success) => success);
  }

  // Cancel a booking
  Future<Map<String, dynamic>?> cancelBooking(int bookingId) async {
    var response = await crud.postData(AppLink.cancelBooking, {
      "booking_id": bookingId.toString(),
    });

    return response.fold((failure) => null, (success) => success);
  }

  // Reschedule a booking
  Future<Map<String, dynamic>?> rescheduleBooking({
    required int bookingId,
    required String newDate,
    required String newTime,
  }) async {
    var response = await crud.postData(AppLink.rescheduleBooking, {
      "booking_id": bookingId.toString(),
      "new_date": newDate,
      "new_time": newTime,
    });

    return response.fold((failure) => null, (success) => success);
  }

  // Submit a rating for a booking
  Future<Map<String, dynamic>?> submitBookingRating({
    required int bookingId,
    required int serviceQuality,
    required int cleanliness,
    required int customerService,
    String? comment,
  }) async {
    var response = await crud.postData(AppLink.rateBooking, {
      "booking_id": bookingId.toString(),
      "service_quality": serviceQuality.toString(),
      "cleanliness": cleanliness.toString(),
      "customer_service": customerService.toString(),
      if (comment != null && comment.isNotEmpty) "comment": comment,
    });

    return response.fold((failure) => null, (success) => success);
  }

  // Check if a booking has been rated
  Future<Map<String, dynamic>?> checkBookingRated(int bookingId) async {
    var response = await crud.postData(AppLink.checkBookingRated, {
      "booking_id": bookingId.toString(),
    });

    return response.fold((failure) => null, (success) => success);
  }

  // Get all completed but unrated bookings for a user
  Future<Map<String, dynamic>?> getUnratedBookings(String userId) async {
    var response = await crud.postData(AppLink.viewUnratedBookings, {
      "user_id": userId,
    });

    return response.fold((failure) => null, (success) => success);
  }
}