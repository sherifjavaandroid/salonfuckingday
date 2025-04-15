// import 'package:easycut/controller/home/home_controller.dart';
// import 'package:easycut/core/constant/color.dart';
// import 'package:easycut/core/services/location_services.dart';
// import 'package:easycut/core/shared/widgets/big_text.dart';
// import 'package:easycut/core/shared/widgets/small_text.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
//
// class LocationSettings extends StatelessWidget {
//   const LocationSettings({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final LocationServices locationServices = Get.find<LocationServices>();
//     final HomeControllerImp homeController = Get.find<HomeControllerImp>();
//
//     return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//     BigText(text: "Location Settings".tr),
//     SizedBox(height: 10.h),
//
//     // Location permission status
//     Container(
//     padding: EdgeInsets.all(12.r),
//     decoration: BoxDecoration(
//     border: Border.all(color: AppColor.backgroundicons2, width: 1),
//     color: Colors.white,
//     borderRadius: BorderRadius.circular(8),
//     ),
//     child: Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//     Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//     Expanded(
//     child: Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//     SmallText(
//     text: "Use Location Services".tr,
//     fontWeight: FontWeight.bold,
//     size: 16.sp,
//     ),
//     SizedBox(height: 5.h),
//     Obx(() => SmallText(
//     text: locationServices.hasPermission.value
//     ? "Enabled".tr
//         : "Disabled".tr,
//     color: locationServices.hasPermission.value
//     ? Colors.green
//         : Colors.red,
//     )),
//     ],
//     ),
//     ),
//     Obx(() => Switch(
//     value: homeController.isLocationEnabled.value,
//     activeColor: AppColor.selectedColor,
//     onChanged: (bool value) async {
//     if (value && !locationServices.hasPermission.value) {
//     bool permitted = await LocationPermissionHelper.requestLocationPermission(context);
//     if (!permitted) return;
//
//     await locationServices.getCurrentPosition();
//     }
//
//     homeController.isLocationEnabled.value = value;
//     if (value) {
//     homeController.refreshSalonsWithLocation();
//     }
//     },
//     )),
//     ],
//     ),
//
//     Divider(color: AppColor.backgroundicons2),
//
//     // Current location
//     Obx(() => locationServices.isLoading.value
//     ? const Center(child: CircularProgressIndicator())
//         : Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//     SmallText(
//     text: "Current Location".tr,
//     fontWeight: FontWeight.bold,
//     size: 16.sp,
//     ),
//     SizedBox(height: 5.h),
//     SmallText(
//     text: locationServices.address.value.isNotEmpty
//     ? locationServices.address.value
//         : "Location not available".tr,
//     ),
//     SizedBox(height: 10.h),
//
//     // Update location button
//     ElevatedButton.icon(
//     onPressed: () async {
//     await locationServices.getCurrentPosition();
//     if (homeController.isLocationEnabled.value) {
//     homeController.refreshSalonsWithLocation();
//     }
//     },
//     icon: const Icon(Icons.my_location),
//     label: Text("Update Location".tr),