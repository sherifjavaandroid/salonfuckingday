import 'dart:io';
import 'package:easycut/core/class/status_request.dart';
import 'package:easycut/core/constant/routes.dart';
import 'package:easycut/core/functions/handling_data_controller.dart';
import 'package:easycut/core/services/services.dart';
import 'package:easycut/data/data_source/remote/home/profile_data.dart';
import 'package:easycut/data/model/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditController extends GetxController {
  GlobalKey<FormState> formState = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  ProfileData profileData = ProfileData(Get.find());
  MyServices myServices = Get.find();
  StatusRequest statusRequest = StatusRequest.success;

  ProfileModel currentProfile = ProfileModel();
  File? profileImage;
  bool isPasswordVisible = true;
  bool updatePassword = false;
  String originalImagePath = "";

  togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    update();
  }

  toggleUpdatePassword() {
    updatePassword = !updatePassword;
    if (!updatePassword) {
      passwordController.clear();
      confirmPasswordController.clear();
    }
    update();
  }

  selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      profileImage = File(image.path);
      update();
    }
  }

  @override
  void onInit() {
    super.onInit();

    // Initialize controllers with current user data
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    // Get current user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  getData() async {
    int? userId = myServices.sharedPreferences.getInt('id');
    if (userId == null) {
      Get.offAllNamed(AppRoute.login);
      return;
    }

    statusRequest = StatusRequest.loading;
    update();

    var response = await profileData.postData(userId.toString());
    statusRequest = handlingData(response);

    if (statusRequest == StatusRequest.success) {
      if (response['status'] == 'success') {
        var data = response['profile'] as Map<String, dynamic>;
        currentProfile = ProfileModel.fromJson(data);

        // Fill controllers with current  data
        nameController.text = currentProfile.name ?? "";
        emailController.text = currentProfile.email ?? "";
        phoneController.text = currentProfile.phone ?? "";
        addressController.text = currentProfile.address ?? "";
        originalImagePath = currentProfile.image ?? "";
      } else {
        Get.snackbar(
          'Warning'.tr,
          'Failed to load profile data'.tr,
          snackPosition: SnackPosition.TOP,
          colorText: Colors.red,
        );
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }

  Future<bool> updateProfile() async {
    var formData = formState.currentState;
    if (!formData!.validate()) return false;

    // Password validation
    if (updatePassword && passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Error'.tr,
        'Passwords do not match'.tr,
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.red,
      );
      return false;
    }

    statusRequest = StatusRequest.loading;
    update();

    try {
      var response = await profileData.updateProfile(
        currentProfile.id.toString(),
        nameController.text,
        emailController.text,
        phoneController.text,
        addressController.text,
        updatePassword ? passwordController.text : null,
        originalImagePath,
        profileImage,
      );

      statusRequest = handlingData(response);

      if (statusRequest == StatusRequest.success) {
        if (response['status'] == 'success') {
          // Update local storage with new user data
          myServices.sharedPreferences.setString('name', nameController.text);

          if (profileImage != null || response['image'] != null) {
            myServices.sharedPreferences.setString('image', response['image'] ?? originalImagePath);
          }

          Get.snackbar(
            'Success'.tr,
            'Profile updated successfully'.tr,
            snackPosition: SnackPosition.BOTTOM,
            colorText: Colors.green,
          );

          return true;
        } else {
          Get.snackbar(
            'Error'.tr,
            response['message'] ?? 'Failed to update profile'.tr,
            snackPosition: SnackPosition.BOTTOM,
            colorText: Colors.red,
          );
          statusRequest = StatusRequest.failure;
          return false;
        }
      } else {
        Get.snackbar(
          'Error'.tr,
          'Server error'.tr,
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.red,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error'.tr,
        'An unexpected error occurred'.tr,
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.red,
      );
      statusRequest = StatusRequest.serverException;
      return false;
    } finally {
      update();
    }
  }
}