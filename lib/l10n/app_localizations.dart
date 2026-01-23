import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Minimal localization layer for the auth flow.
///
/// (Ported conceptually from `old_lib/` but slimmed down to only strings we use.)
// ignore_for_file: non_constant_identifier_names
abstract class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    final value = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(value != null, 'No AppLocalizations found in context');
    return value!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = <Locale>[Locale('th'), Locale('en')];

  // App
  String get app_title;

  // Auth common
  String get email;
  String get password;
  String get confirm_password;
  String get login;
  String get login_button;
  String get register_button;
  String get or;
  String get remember_me;
  String get forgot_password;
  String get login_error;

  // Roles
  String get role_agent;
  String get role_agency;

  // Validation
  String get enter_email;
  String get enter_valid_email;
  String get enter_password;
  String get password_length_error;
  String get enter_name;
  String get enter_confirm_password;
  String get passwords_do_not_match;
  String get enter_company_name;
  String get select_business_type;

  // Login/Register titles
  String get login_agent_title;
  String get login_agency_title;
  String get register_agent_title;
  String get register_agency_title;

  // Links
  String get don_t_have_account;
  String get register_now;
  String get already_have_account;
  String get login_now;

  // Register fields
  String get full_name_hint;
  String get phone_number;
  String get business_type_hint;
  String get company_name_hint;
  String get business_type_agency;
  String get business_type_developer;
  String get business_type_independent;
  String get business_type_brokerage;

  // Policy checkbox
  String get i_have_read_and_accept;
  String get link_terms_and_conditions;
  String get link_privacy_policy;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    final languageCode = locale.languageCode;
    if (languageCode == 'en') {
      return SynchronousFuture<AppLocalizations>(AppLocalizationsEn(locale));
    }
    return SynchronousFuture<AppLocalizations>(AppLocalizationsTh(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh(super.locale);

  @override
  String get app_title => 'บ้านที่ใช่สำหรับคุณ';

  @override
  String get email => 'อีเมล';
  @override
  String get password => 'รหัสผ่าน';
  @override
  String get confirm_password => 'ยืนยันรหัสผ่าน';
  @override
  String get login => 'เข้าสู่ระบบ';
  @override
  String get login_button => 'เข้าสู่ระบบ';
  @override
  String get register_button => 'ลงทะเบียน';
  @override
  String get or => 'หรือ';
  @override
  String get remember_me => 'จดจำฉัน';
  @override
  String get forgot_password => 'ลืมรหัสผ่าน?';
  @override
  String get login_error => 'เข้าสู่ระบบไม่สำเร็จ';

  @override
  String get role_agent => 'สำหรับเอเจนต์';
  @override
  String get role_agency => 'สำหรับบริษัท';

  @override
  String get enter_email => 'กรุณากรอกอีเมล';
  @override
  String get enter_valid_email => 'กรุณากรอกอีเมลให้ถูกต้อง';
  @override
  String get enter_password => 'กรุณากรอกรหัสผ่าน';
  @override
  String get password_length_error => 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
  @override
  String get enter_name => 'กรุณากรอกชื่อ';
  @override
  String get enter_confirm_password => 'กรุณายืนยันรหัสผ่าน';
  @override
  String get passwords_do_not_match => 'รหัสผ่านไม่ตรงกัน';
  @override
  String get enter_company_name => 'กรุณากรอกชื่อบริษัท';
  @override
  String get select_business_type => 'กรุณาเลือกประเภทธุรกิจ';

  @override
  String get login_agent_title => 'เข้าสู่ระบบ';
  @override
  String get login_agency_title => 'เข้าสู่ระบบ';
  @override
  String get register_agent_title => 'ลงทะเบียน';
  @override
  String get register_agency_title => 'ลงทะเบียน';

  @override
  String get don_t_have_account => 'ยังไม่มีบัญชีผู้ใช้งาน?';
  @override
  String get register_now => 'ลงทะเบียนเลย';
  @override
  String get already_have_account => 'มีบัญชีผู้ใช้งานแล้ว?';
  @override
  String get login_now => 'เข้าสู่ระบบ';

  @override
  String get full_name_hint => 'ชื่อ-นามสกุล';
  @override
  String get phone_number => 'เบอร์โทรศัพท์';
  @override
  String get business_type_hint => 'ประเภทธุรกิจ';
  @override
  String get company_name_hint => 'ชื่อบริษัท';
  @override
  String get business_type_agency => 'บริษัทเอเจนซี่';
  @override
  String get business_type_developer => 'ผู้พัฒนาโครงการ';
  @override
  String get business_type_independent => 'เอเจนต์อิสระ';
  @override
  String get business_type_brokerage => 'นายหน้า';

  @override
  String get i_have_read_and_accept => 'ฉันได้อ่านและยอมรับ ';
  @override
  String get link_terms_and_conditions => 'ข้อตกลงและเงื่อนไขการใช้งาน';
  @override
  String get link_privacy_policy => 'นโยบายความเป็นส่วนตัว';
}

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn(super.locale);

  @override
  String get app_title => 'Home for you';

  @override
  String get email => 'Email';
  @override
  String get password => 'Password';
  @override
  String get confirm_password => 'Confirm password';
  @override
  String get login => 'Login';
  @override
  String get login_button => 'Login';
  @override
  String get register_button => 'Register';
  @override
  String get or => 'or';
  @override
  String get remember_me => 'Remember me';
  @override
  String get forgot_password => 'Forgot password?';
  @override
  String get login_error => 'Login failed';

  @override
  String get role_agent => 'Agent';
  @override
  String get role_agency => 'Company';

  @override
  String get enter_email => 'Please enter your email';
  @override
  String get enter_valid_email => 'Please enter a valid email';
  @override
  String get enter_password => 'Please enter your password';
  @override
  String get password_length_error => 'Password must be at least 6 characters';
  @override
  String get enter_name => 'Please enter your name';
  @override
  String get enter_confirm_password => 'Please confirm your password';
  @override
  String get passwords_do_not_match => 'Passwords do not match';
  @override
  String get enter_company_name => 'Please enter your company name';
  @override
  String get select_business_type => 'Please select a business type';

  @override
  String get login_agent_title => 'Login';
  @override
  String get login_agency_title => 'Login';
  @override
  String get register_agent_title => 'Register';
  @override
  String get register_agency_title => 'Register';

  @override
  String get don_t_have_account => "Don't have an account?";
  @override
  String get register_now => 'Register';
  @override
  String get already_have_account => 'Already have an account?';
  @override
  String get login_now => 'Login';

  @override
  String get full_name_hint => 'Full name';
  @override
  String get phone_number => 'Phone number';
  @override
  String get business_type_hint => 'Business type';
  @override
  String get company_name_hint => 'Company name';
  @override
  String get business_type_agency => 'Real Estate Agency';
  @override
  String get business_type_developer => 'Property Developer';
  @override
  String get business_type_independent => 'Independent Agent';
  @override
  String get business_type_brokerage => 'Brokerage Firm';

  @override
  String get i_have_read_and_accept => 'I have read and accept ';
  @override
  String get link_terms_and_conditions => 'Terms & Conditions';
  @override
  String get link_privacy_policy => 'Privacy Policy';
}

