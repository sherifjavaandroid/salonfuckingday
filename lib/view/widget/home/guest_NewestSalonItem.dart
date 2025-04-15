import 'package:easycut/core/constant/color.dart';
import 'package:easycut/core/constant/routes.dart';
import 'package:easycut/core/shared/widgets/big_text.dart';
import 'package:easycut/core/shared/widgets/small_text.dart';
import 'package:easycut/data/model/home_model.dart';
import 'package:easycut/data/model/salon_model.dart';
import 'package:easycut/linkapi.dart';
import 'package:easycut/view/widget/home/icon_and_text.dart';
import 'package:easycut/view/widget/home/salon_rate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class GuestNewestsalonitem extends StatelessWidget {
  final SalonModel salon;
  const GuestNewestsalonitem({
    super.key,
    required this.salon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 38, right: 38, bottom: 5, top: 5),
      child: GestureDetector(
        onTap: () {
          Get.toNamed(AppRoute.salonDetails, arguments: {
            "salonid": salon.id,
          });
        },
        child: Container(
          width: 364.w,
          height: 201.h,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColor.backgroundicons2, width: 1),
            color: AppColor.backgroundButton,
          ),
          child: Column(
            children: [
              Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: [
                  Container(
                    width: 344.w,
                    height: 126.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: const Color(0xffA3A5A7), width: 1.5.w),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                            "${AppLink.imageSalons}${salon.image}"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: FittedBox(
                        child: SalonRatingWidget(salonId: salon.id!),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BigText(
                      text: salon.name!,
                      color: AppColor.backgroundicons,
                      size: 18.sp,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/images/icon/location.png',
                        height: 25.h,
                        width: 25.w,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth: 160.w), // Limit width to 150 pixels
                          child: SmallText(
                            height: 1,
                            fontFamily: 'Cairo',
                            maxline: 2,
                            overFlow: TextOverflow
                                .ellipsis, // Ensure text truncates with "..."
                            text: "${salon.city} | ${salon.address}".trArgs(),
                            color: Colors.black,
                            size: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconAndTextWidget(
                    icon: salon.categoryId == 1
                        ? "assets/images/icon/man.png"
                        : "assets/images/icon/woman.png",
                    text: salon.categoryId == 1 ? "Men".tr : "Women".tr,
                    iconColor: AppColor.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
