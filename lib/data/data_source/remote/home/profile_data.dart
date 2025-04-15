import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:easycut/core/class/crud.dart';
import 'package:easycut/linkapi.dart';

import '../../../../core/class/status_request.dart';

class ProfileData {
  Crud crud;

  ProfileData(this.crud);

  postData(String id) async {
    var response = await crud.postData(AppLink.userInfo, {
      "id": id,
    });
    return response.fold((l) => l, (r) => r);
  }

  deleteData(String id, String image) async {
    var response = await crud.postData(AppLink.userDelete, {
      "id": id,
      "imageold": image,
    });
    return response.fold((l) => l, (r) => r);
  }
  updateProfile(
      String userId,
      String name,
      String email,
      String phone,
      String address,
      String? password,
      String? oldImageName,
      File? newImage,
      ) async {
    try {
      Map<String, dynamic> data = {
        "id": userId,
        "name": name,
        "email": email,
        "phone": phone,
        "address": address,
      };

      // Add password only if it's not null
      if (password != null && password.isNotEmpty) {
        data["password"] = password;
      }

      print("Sending profile update data: $data"); // Debug log

      // If we have old image and no new image
      if (oldImageName != null && newImage == null) {
        data["oldimage"] = oldImageName;
        return await crud.postData(AppLink.updateProfile, data);
      }
      // If we have a new image
      else if (newImage != null) {
        data["oldimage"] = oldImageName ?? "";
        return await crud.postDataWithFile(AppLink.updateProfileWithImage, data, newImage);
      }
      // Fallback for any other case
      else {
        return await crud.postData(AppLink.updateProfile, data);
      }
    } catch (e) {
      print("Error in updateProfile: $e");
      return const Left(StatusRequest.serverException);
    }}
  }