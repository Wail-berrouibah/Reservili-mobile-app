// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'ريزرفيلي';

  @override
  String get appTagline => 'إدارة الحجوزات';

  @override
  String get welcome => 'مرحبًا';

  @override
  String get accessCodePrompt => 'أدخل رمز الدخول المقدّم من المالك.';

  @override
  String get codeBoundToPhone => 'هذا الرمز مرتبط بهاتفك.';

  @override
  String get continueLabel => 'متابعة';

  @override
  String get invalidCode => 'رمز غير صالح';

  @override
  String get connectionError => 'خطأ في الاتصال';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get homes => 'المساكن';

  @override
  String get reservations => 'الحجوزات';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get availability => 'التوفّر';

  @override
  String get add => 'إضافة';

  @override
  String get recentReservations => 'الحجوزات الأخيرة';

  @override
  String get noReservations => 'لا توجد حجوزات';

  @override
  String get upcomingReservationsHint => 'ستظهر الحجوزات القادمة هنا.';

  @override
  String get book => 'احجز';

  @override
  String get noHomes => 'لا توجد مساكن';

  @override
  String get addFirstHome => 'أضف أوّل مسكن لك.';

  @override
  String get homeDetails => 'تفاصيل المسكن';

  @override
  String get homeNotFound => 'المسكن غير موجود';

  @override
  String persons(int count) {
    return '$count أشخاص';
  }

  @override
  String pricePerNight(String price) {
    return '$price دج / ليلة';
  }

  @override
  String get createReservation => 'إنشاء حجز';

  @override
  String get activeReservationsNone => 'لا توجد حجوزات نشطة.';

  @override
  String get addHome => 'إضافة مسكن';

  @override
  String get name => 'الاسم';

  @override
  String get location => 'الموقع';

  @override
  String get capacity => 'السعة';

  @override
  String get pricePerNightLabel => 'السعر لكل ليلة (دج)';

  @override
  String get save => 'حفظ';

  @override
  String get required => 'حقل مطلوب';

  @override
  String get invalidValue => 'قيمة غير صالحة';

  @override
  String get chooseDates => 'اختر التواريخ';

  @override
  String get search => 'بحث';

  @override
  String get noHomesAvailable => 'لا توجد مساكن متاحة';

  @override
  String get tryOtherDates => 'جرّب تواريخ أخرى.';

  @override
  String get newReservation => 'حجز جديد';

  @override
  String get home => 'المسكن';

  @override
  String get chooseHome => 'يرجى اختيار مسكن';

  @override
  String get guestName => 'اسم العميل';

  @override
  String get phone => 'الهاتف';

  @override
  String get phoneRequired => 'الرقم مطلوب';

  @override
  String get invalidPhone => 'رقم غير صالح';

  @override
  String get emailOptional => 'البريد الإلكتروني (اختياري)';

  @override
  String get invalidEmail => 'بريد إلكتروني غير صالح';

  @override
  String get guestsCount => 'عدد الأشخاص';

  @override
  String get notesOptional => 'ملاحظات (اختياري)';

  @override
  String get confirmReservation => 'تأكيد الحجز';

  @override
  String get reservationCreated => 'تم إنشاء الحجز.';

  @override
  String get datesUnavailable => 'هذه التواريخ غير متاحة.';

  @override
  String get invalidDates => 'تواريخ غير صالحة.';

  @override
  String get reservationDetails => 'تفاصيل الحجز';

  @override
  String get reservationNotFound => 'الحجز غير موجود';

  @override
  String get arrival => 'الوصول';

  @override
  String get departure => 'المغادرة';

  @override
  String get nights => 'الليالي';

  @override
  String get personsLabel => 'الأشخاص';

  @override
  String get notes => 'ملاحظات';

  @override
  String get confirm => 'تأكيد';

  @override
  String get reschedule => 'إعادة جدولة';

  @override
  String get cancelReservation => 'إلغاء الحجز';

  @override
  String get cancelConfirmTitle => 'إلغاء الحجز؟';

  @override
  String get cancelConfirmBody => 'هذا الإجراء نهائي.';

  @override
  String get no => 'لا';

  @override
  String get yesCancel => 'نعم، إلغاء';

  @override
  String get newDates => 'تواريخ جديدة';

  @override
  String get reservationRescheduled => 'تمت إعادة جدولة الحجز.';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get about => 'حول التطبيق';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusConfirmed => 'مؤكَّدة';

  @override
  String get statusCancelled => 'ملغاة';

  @override
  String get client => 'العميل';

  @override
  String get reminderTitle => 'تذكير بالحجز';

  @override
  String reservationEndsTomorrow(String home) {
    return 'حجز $home ينتهي غدًا';
  }
}
