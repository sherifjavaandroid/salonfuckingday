import 'package:easycut/core/class/status_request.dart';
import 'package:easycut/core/functions/handling_data_controller.dart';
import 'package:easycut/core/services/services.dart';
import 'package:easycut/data/data_source/remote/home/home_data.dart';
import 'package:easycut/data/model/salon_model.dart';
import 'package:easycut/data/model/salonrates.dart';
import 'package:easycut/data/model/searchsalon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class HomeController extends GetxController {
  void initialData();
  Future<void> getData();
  bool get isLoggedIn;
  void filterByClassification(String classification);
}

class HomeControllerImp extends HomeController {
  final MyServices myServices = Get.find();
  var currentRating = 0.0.obs;
  var totalRate = 0.obs;
  var isLoading = true.obs;
  int? id;
  List<SearchsalonModel> searchResults = [];

  // Classification filter
  RxString currentClassification = "all".obs;
  List<SalonModel> _allPopSalons = [];
  List<SalonModel> _allNearSalons = [];
  List<SalonModel> _allNewSalons = [];

  String? name;
  String? gender;
  String? country;
  String? city;
  String? image;

  final HomeData homeData = HomeData(Get.find());
  StatusRequest statusRequest = StatusRequest.success;
  List<SalonModel> popSalons = [];
  List<SalonModel> nearSalons = [];
  List<SalonModel> newSalons = [];

  @override
  void initialData() {
    id = myServices.sharedPreferences.getInt('id');

    name = myServices.sharedPreferences.getString('name');
    gender = myServices.sharedPreferences.getString('gender');
    country = myServices.sharedPreferences.getString('country');
    city = myServices.sharedPreferences.getString('city');
    image = myServices.sharedPreferences.getString('image');
  }

  @override
  Future<void> getData() async {
    statusRequest = StatusRequest.loading;
    update();

    try {
      var response = await homeData.viewSalons();
      if (kDebugMode) {
        print('Response: $response');
      }
      if (kDebugMode) {
        print('userid: $id');
      }
      statusRequest = handlingData(response);

      if (statusRequest == StatusRequest.success) {
        if (response['status'] == 'success') {
          _allNearSalons = (response['nearsalons'] ?? []).map<SalonModel>((element) {
            return SalonModel.fromJson(element as Map<String, dynamic>);
          }).toList();

          _allPopSalons = (response['popsalons'] ?? []).map<SalonModel>((element) {
            return SalonModel.fromJson(element as Map<String, dynamic>);
          }).toList();

          _allNewSalons = (response['newsalons'] ?? []).map<SalonModel>((element) {
            return SalonModel.fromJson(element as Map<String, dynamic>);
          }).toList();

          // Initialize displayed lists with all salons
          nearSalons = List.from(_allNearSalons);
          popSalons = List.from(_allPopSalons);
          newSalons = List.from(_allNewSalons);
        } else {
          Get.snackbar(
            'Warning'.tr,
            'There is no data for your country'.tr,
            snackPosition: SnackPosition.TOP,
            colorText: Colors.red,
          );
          statusRequest = StatusRequest.failure;
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error'.tr,
        'An error occurred while fetching data.'.tr,
        snackPosition: SnackPosition.TOP,
        colorText: Colors.red,
      );
      statusRequest = StatusRequest.failure;
      if (kDebugMode) {
        print("Error fetching salons: $e");
      }
    } finally {
      update();
    }
  }

  @override
  void filterByClassification(String classification) {
    currentClassification.value = classification;

    if (classification == "all") {
      // Reset to show all salons
      nearSalons = List.from(_allNearSalons);
      popSalons = List.from(_allPopSalons);
      newSalons = List.from(_allNewSalons);
    } else {
      // Filter salons by classification
      nearSalons = _allNearSalons.where((salon) => salon.classification == classification).toList();
      popSalons = _allPopSalons.where((salon) => salon.classification == classification).toList();
      newSalons = _allNewSalons.where((salon) => salon.classification == classification).toList();
    }
    update();
  }

  Future<void> fetchRating(int salonId) async {
    isLoading.value = true;
    try {
      final response = await homeData.getsalonRating(salonId);
      if (response['status'] == 'success') {
        SalonratesModel salonRates = SalonratesModel.fromJson(response);
        if (kDebugMode) {
          print("Salon Rating: ${salonRates.data?.averageRating}");
        }
      } else {
        if (kDebugMode) {
          print("Failed to fetch rating: ${response['message']}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching rating: $e");
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchSalon(String search) async {
    statusRequest = StatusRequest.loading;
    update();

    try {
      var response = await homeData.searchSalon(search, id!);

      if (kDebugMode) {
        print('Response: $response');
        print('userid: $id');
      }

      if (response is List) {
        // API returns a direct list, so we parse it accordingly
        searchResults = response
            .map((e) => SearchsalonModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // Filter search results if a classification is selected
        if (currentClassification.value != "all") {
          searchResults = searchResults.where((salon) =>
          salon.classification == currentClassification.value).toList();
        }

        statusRequest = searchResults.isNotEmpty
            ? StatusRequest.success
            : StatusRequest.failure;
      } else {
        // API returned an unexpected format
        searchResults.clear();
        statusRequest = StatusRequest.failure;
        Get.snackbar(
          'Warning'.tr,
          'Unexpected response format.'.tr,
          snackPosition: SnackPosition.TOP,
          colorText: Colors.red,
        );
      }
    } catch (e) {
      searchResults.clear();
      statusRequest = StatusRequest.serverFailure;
      Get.snackbar(
        'Error'.tr,
        'An error occurred while fetching data.'.tr,
        snackPosition: SnackPosition.TOP,
        colorText: Colors.red,
      );
      if (kDebugMode) {
        print("Error fetching salons: $e");
      }
    } finally {
      update();
    }
  }

  @override
  void onInit() {
    initialData();
    getData();
    super.onInit();
  }

  @override
  bool get isLoggedIn => id == null;
}