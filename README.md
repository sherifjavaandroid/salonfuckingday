https://easycuteg.com/users/profile/update.php

{
"id": "123",
"name": asd
"email": "example@mail.com", 
"phone": "0123456789",    
"address":  "asdasdasd"
"oldimage": "asdasdasd.jpg", 
"password": "asdasdasdasd"   
}

res
{
"status": "success",
"message": "تم تحديث البيانات بنجاح"
}

-------------------------------------------------------
تقسيمه الكاتيجوري

GET /api/salons?classification=luxury

Headers:
Authorization: Bearer {token}



------------------------------


GET https://easycuteg.com/users/home/home.php

GET https://easycuteg.com/users/home/home.php?lat=30.0444&lng=31.2357


res

{
"status": "success",
"popsalons": [
{
"id": 1,
"name": "Luxury Salon & Spa",
"email": "info@luxurysalon.com",
"gender": "male",
"phone": "+20123456789",
"rate": 4.8,
"chairs": 5,
"category_id": 1,
"subscription": 1,
"image": "salon1.jpg",
"approve": 1,
"country": "Egypt",
"city": "Cairo",
"address": "Downtown, 123 Main St",
"classification": "luxury",
"created_at": "2023-01-15T10:00:00Z",
"updated_at": "2023-04-16T14:30:00Z"
},
{
"id": 2,
"name": "Economic Cuts",
"email": "info@economiccuts.com",
"gender": "female",
"phone": "+20123456780",
"rate": 4.5,
"chairs": 3,
"category_id": 2,
"subscription": 1,
"image": "salon2.jpg",
"approve": 1,
"country": "Egypt",
"city": "Alexandria",
"address": "City Center, 456 High St",
"classification": "economic",
"created_at": "2023-02-20T09:15:00Z",
"updated_at": "2023-04-10T11:45:00Z"
}
],
"nearsalons": [
// Similar structure to popsalons
],
"newsalons": [
// Similar structure to popsalons
]
}


------------------------------













solve errors build
edit profile data done
solve navigation
solve registeration
home cats
location permissions


نسخة عربية وإنجليزية للتطبيق 1.
(English / Arabic (دعم تعدد اللغات ●
إمكانية التبديل بين اللغتين من داخل اإلعدادات ●
(Localization (توطين كافة النصوص ●
(صفحة تعديل معلومات المستخدم )الملف الشخصي 2.
الحقول: اًلسم، رقم الهاتف، البريد اإللكتروني، العنوان، كلمة المرور، صورة المستخدم ●
حفظ التغييرات مع رسالة تأكيد

و رابط مشاركة لكل صالون Code QR 3.
يحتوي على رابط الصالون QR توليد كود ●
زر "مشاركة الصالون" يمكن المستخدم من مشاركة الرابط على واتساب / فيسبوك .. إلخ ●




لتحديد موقع المستخدم GPS استخدام ●
.عرض أقرب الصالونات بنا اء على الموقع الجغرافي ●
(Access Location (السماح بالوصول إلى الموقع 8.
.طلب إذن المستخدم للوصول للموقع عند فتح التطبيق ألول مرة ●
.استخدام الموقع لتحديد العناوين وتحسين نتائج البحث 