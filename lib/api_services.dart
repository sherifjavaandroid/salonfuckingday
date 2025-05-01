import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:easycut/core/services/services.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final MyServices _myServices = Get.find<MyServices>();
  final String baseUrl = 'https://dashboard.easycuteg.com/api';

  // Helper method to print request and response details
  void _printRequestDetails(String method, String url, dynamic body, Map<String, String> headers) {
    if (kDebugMode) {
      print('📤 REQUEST [$method] $url');
      print('📤 HEADERS: $headers');
      if (body != null) {
        print('📤 BODY: $body');
      }
    }
  }

  void _printResponseDetails(http.Response response) {
    if (kDebugMode) {
      print('📥 RESPONSE STATUS: ${response.statusCode}');
      print('📥 RESPONSE BODY: ${response.body}');
    }
  }

  // Get current user ID
  int? get userId {
    return _myServices.sharedPreferences.getInt('id');
  }

  // Generic headers for all requests
  Map<String, String> get headers {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  // 1. Update user profile
  Future<Map<String, dynamic>> updateUserProfile({
    required int userId,
    required String name,
    required String email,
    required String phone,
    required String address,
    String? password,
  }) async {
    final url = '$baseUrl/v1/auth/profile/update';
    final body = {
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      if (password != null && password.isNotEmpty) 'password': password,
    };

    _printRequestDetails('POST', url, body, headers);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      _printResponseDetails(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating profile: $e');
      }
      rethrow;
    }
  }

  // 2. Search for salons
  Future<List<dynamic>> searchSalons(String query) async {
    final url = '$baseUrl/salon/search?search=$query';

    _printRequestDetails('GET', url, null, headers);

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      _printResponseDetails(response);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to search salons: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error searching salons: $e');
      }
      rethrow;
    }
  }

  // 3. Submit salon rating feedback
  Future<Map<String, dynamic>> submitSalonFeedback({
    required int salonId,
    required int userId,
    required int rating,
  }) async {
    final url = '$baseUrl/v1/auth/salon/feedback';
    final body = {
      'salon_id': salonId,
      'user_id': userId,
      'rating': rating,
    };

    _printRequestDetails('POST', url, body, headers);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      _printResponseDetails(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to submit feedback: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting feedback: $e');
      }
      rethrow;
    }
  }

  // 4. Get salon ratings
  Future<Map<String, dynamic>> getSalonRatings(int salonId, int userId) async {
    final url = '$baseUrl/v1/auth/salon/ratings/$salonId?user_id=$userId';

    _printRequestDetails('GET', url, null, headers);

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      _printResponseDetails(response);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get salon ratings: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting salon ratings: $e');
      }
      rethrow;
    }
  }

  // 5. Check if booking has been rated
  Future<Map<String, dynamic>> checkBookingRated(int bookingId) async {
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final url = '$baseUrl/v1/auth/rating/check?bookingId=$bookingId&user_id=$userId';

    _printRequestDetails('GET', url, null, headers);

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      _printResponseDetails(response);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to check booking rating: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking booking rating: $e');
      }
      rethrow;
    }
  }

  // 6. Submit booking rating
  Future<Map<String, dynamic>> submitBookingRating({
    required int bookingId,
    required int serviceQuality,
    required int cleanliness,
    required int customerService,
    String? comment,
  }) async {
    final url = '$baseUrl/v1/auth/rating/submit';
    final body = {
      'bookingId': bookingId,
      'serviceQuality': serviceQuality,
      'cleanliness': cleanliness,
      'customerService': customerService,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    };

    _printRequestDetails('POST', url, body, headers);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      _printResponseDetails(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to submit booking rating: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting booking rating: $e');
      }
      rethrow;
    }
  }

  // 7. Reschedule booking
  Future<Map<String, dynamic>> rescheduleBooking({
    required int bookingId,
    required String newDate,
    required String newTime,
  }) async {
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final url = '$baseUrl/v1/auth/booking/reschedule';
    final body = {
      'bookingId': bookingId,
      'user_id': userId,
      'newDate': newDate,
      'newTime': newTime,
    };

    _printRequestDetails('POST', url, body, headers);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      _printResponseDetails(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to reschedule booking: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error rescheduling booking: $e');
      }
      rethrow;
    }
  }

  // 8. Cancel booking
  Future<Map<String, dynamic>> cancelBooking(int bookingId) async {
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final url = '$baseUrl/v1/auth/booking/cancel';
    final body = {
      'bookingId': bookingId,
      'user_id': userId,
    };

    _printRequestDetails('POST', url, body, headers);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      _printResponseDetails(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to cancel booking: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cancelling booking: $e');
      }
      rethrow;
    }
  }

  // 9. Get booking services
  Future<Map<String, dynamic>> getBookingServices(int bookingId) async {
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final url = '$baseUrl/v1/auth/booking/services?bookingId=$bookingId&user_id=$userId';

    _printRequestDetails('GET', url, null, headers);

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      _printResponseDetails(response);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get booking services: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting booking services: $e');
      }
      rethrow;
    }
  }

  // 10. Get booking details
  Future<Map<String, dynamic>> getBookingDetails(int bookingId) async {
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final url = '$baseUrl/v1/auth/booking/details?bookingId=$bookingId&user_id=$userId';

    _printRequestDetails('GET', url, null, headers);

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      _printResponseDetails(response);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get booking details: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting booking details: $e');
      }
      rethrow;
    }
  }
}