// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get app_title => 'บ้านที่ใช่สำหรับคุณ';

  @override
  String get family_members => 'สมาชิกในครอบครัว';

  @override
  String get family_members_subtitle =>
      'กรอกข้อมูลสมาชิกเพื่อค้นหาบ้านที่เข้ากับทุกคนในครอบครัว';

  @override
  String get real_estate => 'อสังหาริมทรัพย์';

  @override
  String get real_estate_subtitle => 'กรอกข้อมูลเพื่อค้นหาบ้านที่เหมาะสมที่สุด';

  @override
  String get add_member => 'เพิ่มสมาชิก';

  @override
  String get clear_data => 'ล้างข้อมูล';

  @override
  String get search_homes => 'ค้นหาบ้านที่ใช่';

  @override
  String get location => 'ตำแหน่งที่ตั้ง';

  @override
  String get location_hint => 'สุขุมวิท, สีลม, กรุงเทพฯ, ...';

  @override
  String get property_type => 'ประเภทอสังหาริมทรัพย์';

  @override
  String get property_type_hint => 'กรุณาเลือก';

  @override
  String get budget_range => 'ช่วงงบประมาณ';

  @override
  String get budget_hint => '0';

  @override
  String get budget_note => 'สามารถระบุเพียงช่องใดช่องหนึ่งได้';

  @override
  String get condo => 'คอนโด';

  @override
  String get house => 'บ้านเดี่ยว';

  @override
  String get name => 'ชื่อ';

  @override
  String get name_hint => 'ชื่อ นามสกุล';

  @override
  String get birthdate => 'วันเกิด';

  @override
  String get birthdate_hint => 'วว/ดด/ปปปป';

  @override
  String get gender => 'เพศ';

  @override
  String get gender_male => 'ชาย';

  @override
  String get gender_female => 'หญิง';

  @override
  String get gender_other => 'อื่นๆ';

  @override
  String get weight => 'น้ำหนักโชคชะตา';

  @override
  String get weight_hint => '0';

  @override
  String get height => 'ส่วนสูง';

  @override
  String get height_hint => '0';

  @override
  String get congenital_disease => 'โรคประจำตัว';

  @override
  String get congenital_disease_hint => 'เบาหวาน, หอบหืด, ...';

  @override
  String get phone_number => 'หมายเลขโทรศัพท์';

  @override
  String get license_plate => 'หมายเลขทะเบียนรถ';

  @override
  String get license_plate_hint => 'กรุณาระบุเฉพาะตัวเลข';

  @override
  String get lock_weight => 'ล็อคค่าน้ำหนัก';

  @override
  String get allergy => 'อาการแพ้';

  @override
  String get allergy_hint => 'ฝุ่น, เกสรดอกไม้, ...';

  @override
  String get bedrooms => 'ห้องนอน';

  @override
  String get bathrooms => 'ห้องน้ำ';

  @override
  String get area => 'พื้นที่';

  @override
  String get search_filter => 'ตัวกรองการค้นหา';

  @override
  String get amenities => 'สิ่งอำนวยความสะดวก';

  @override
  String get fireplace => 'เตาผิง';

  @override
  String get swimming_pool => 'สระว่ายน้ำ';

  @override
  String get garage => 'โรงจอดรถ';

  @override
  String get garden => 'สวน';

  @override
  String get playground => 'สนามเด็กเล่น';

  @override
  String get search => 'ค้นหา';

  @override
  String get results_for => 'บ้านที่ใช่สำหรับคุณ';

  @override
  String get properties_found => 'รายการ';

  @override
  String get compatibility_score => 'คะแนนความเข้ากันได้';

  @override
  String get score_before_filters => 'คะแนนก่อนการกรอง';

  @override
  String get unit_sqm => 'ตร.ม.';

  @override
  String bath_count(Object count) {
    return '$count ห้องน้ำ';
  }

  @override
  String bed_count(Object count) {
    return '$count ห้องนอน';
  }

  @override
  String area_sqm(Object area) {
    return '$area ตร.ม.';
  }

  @override
  String floor_count(Object count) {
    return '$count ชั้น';
  }

  @override
  String price_per_sqm(Object price) {
    return '$price บาท/ตร.ม.';
  }

  @override
  String get yourHomeAgent => 'YourHome Agent';

  @override
  String get viewHouse => 'ขอดูบ้าน';

  @override
  String get schedule_viewing => 'นัดชมบ้าน';

  @override
  String people_interested(Object count) {
    return '$count คนกำลังสนใจ!';
  }

  @override
  String get inquire => 'สอบถาม';

  @override
  String get showFilterOnMap => 'แสดงตัวกรองในแผนที่';

  @override
  String get showOnMap => 'แสดงในแผนที่';

  @override
  String get list_view => 'แสดงผลแบบรายการ';

  @override
  String get map_view => 'แสดงผลแบบแผนที่';

  @override
  String get compatibility => 'ความเข้ากันได้';

  @override
  String get register => 'ลงทะเบียน';

  @override
  String get login => 'เข้าสู่ระบบ';

  @override
  String get no_locations_found =>
      'ไม่พบอสังหาริมทรัพย์ที่ตรงกับตัวกรองปัจจุบัน';

  @override
  String get hero_search_prefix => 'ค้นหาบ้านที่';

  @override
  String get ticker_word_1 => 'ใช่';

  @override
  String get ticker_word_2 => 'ถูกใจ';

  @override
  String get ticker_word_3 => 'ถูกโฉลก';

  @override
  String get login_agent_title => 'เข้าสู่ระบบตัวแทน';

  @override
  String get login_agent_subtitle => 'เข้าสู่ระบบบัญชีตัวแทนของคุณ';

  @override
  String get login_admin_title => 'เข้าสู่ระบบผู้ดูแล';

  @override
  String get login_admin_subtitle => 'เข้าสู่ระบบบัญชีผู้ดูแลของคุณ';

  @override
  String get login_agency_title => 'เข้าสู่ระบบบริษัท';

  @override
  String get login_agency_subtitle => 'เข้าสู่ระบบบัญชีบริษัทของคุณ';

  @override
  String get email => 'อีเมล';

  @override
  String get password => 'รหัสผ่าน';

  @override
  String get forgot_password => 'ลืมรหัสผ่าน?';

  @override
  String get remember_me => 'จดจำฉัน';

  @override
  String get login_button => 'ลงชื่อเข้าใช้';

  @override
  String get sign_in_with_google => 'Google';

  @override
  String get sign_in_with_facebook => 'Facebook';

  @override
  String get or => 'หรือ';

  @override
  String get don_t_have_account => 'ยังไม่มีบัญชี?';

  @override
  String get register_now => 'ลงทะเบียน';

  @override
  String get already_have_account => 'มีบัญชีอยู่แล้ว?';

  @override
  String get login_now => 'เข้าสู่ระบบ';

  @override
  String get full_name => 'ชื่อ';

  @override
  String get full_name_hint => 'ชื่อ-นามสกุล';

  @override
  String get confirm_password => 'ยืนยันรหัสผ่าน';

  @override
  String get agent_license_number => 'หมายเลขใบอนุญาต';

  @override
  String get agent_license_hint => 'หมายเลขใบอนุญาต';

  @override
  String get business_type => 'ประเภทธุรกิจ';

  @override
  String get business_type_hint => 'กรุณาเลือก';

  @override
  String get company_name => 'ชื่อบริษัท';

  @override
  String get company_name_hint => 'ชื่อบริษัท';

  @override
  String get register_button => 'ลงทะเบียน';

  @override
  String get register_agent_title => 'ลงทะเบียนตัวแทน';

  @override
  String get register_admin_title => 'ลงทะเบียนผู้ดูแลระบบ';

  @override
  String get register_agency_title => 'ลงทะเบียนองค์กร';

  @override
  String get thb => 'บาท';

  @override
  String get hero_slogan_part1 => 'ชีวิตที่ดี';

  @override
  String get hero_slogan_part2 => 'บ้านที่ใช่สำหรับคุณ';

  @override
  String get hero_subtitle =>
      'เพราะเราเชื่อว่าบ้านที่ใช่ จะช่วยให้ชีวิตเราดียิ่งขึ้น';

  @override
  String get select_role_title => 'เลือกบทบาทของคุณ';

  @override
  String get select_role_subtitle => 'เลือกวิธีการเข้าใช้งานแพลตฟอร์ม';

  @override
  String get enter_email => 'กรุณากรอกอีเมลของคุณ';

  @override
  String get enter_valid_email => 'กรุณากรอกอีเมลที่ถูกต้อง';

  @override
  String get enter_password => 'กรุณากรอกรหัสผ่านของคุณ';

  @override
  String get password_length_error =>
      'รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร';

  @override
  String get sign_in_cancelled => 'ยกเลิกการลงชื่อเข้าใช้';

  @override
  String get enter_name => 'กรุณากรอกชื่อของคุณ';

  @override
  String get confirm_password_hint => 'ยืนยันรหัสผ่าน';

  @override
  String get enter_confirm_password => 'กรุณายืนยันรหัสผ่านของคุณ';

  @override
  String get passwords_do_not_match => 'รหัสผ่านไม่ตรงกัน';

  @override
  String get select_business_type => 'กรุณาเลือกประเภทธุรกิจ';

  @override
  String get enter_license_number => 'กรุณากรอกหมายเลขใบอนุญาตของคุณ';

  @override
  String get enter_company_name => 'กรุณากรอกชื่อบริษัทของคุณ';

  @override
  String get business_type_agency => 'ตัวแทนอสังหาริมทรัพย์';

  @override
  String get business_type_developer => 'ผู้พัฒนาอสังหาริมทรัพย์';

  @override
  String get business_type_independent => 'ตัวแทนอิสระ';

  @override
  String get business_type_brokerage => 'บริษัทนายหน้า';

  @override
  String get role_agent => 'สำหรับตัวแทน (Agent)';

  @override
  String get role_agency => 'สำหรับองค์กร (Agency)';

  @override
  String get role_admin => 'สำหรับผู้ดูแลระบบ (Admin)';

  @override
  String get create_property => 'สร้างอสังหาริมทรัพย์';

  @override
  String get create_property_subtitle =>
      'กรอกข้อมูลด้านล่างเพื่อสร้างรายการอสังหาริมทรัพย์ใหม่';

  @override
  String get basic_information => 'ข้อมูลพื้นฐาน';

  @override
  String get specifications => 'รายละเอียด';

  @override
  String get property_location => 'ตำแหน่งที่ตั้ง';

  @override
  String get photos => 'รูปภาพ';

  @override
  String get built_date => 'ปีที่สร้าง (YYYY-MM-DD)';

  @override
  String get type => 'ประเภท';

  @override
  String get status => 'สถานะ';

  @override
  String get bedrooms_label => 'ห้องนอน';

  @override
  String get bathrooms_label => 'ห้องน้ำ';

  @override
  String get garage_spaces => 'ที่จอดรถ';

  @override
  String get price_thb => 'ราคา (บาท)';

  @override
  String get land_size => 'ขนาดที่ดิน (ตร.วา)';

  @override
  String get building_size => 'ขนาดอาคาร (ตร.ม.)';

  @override
  String get house_color => 'สีบ้าน';

  @override
  String get available_from => 'พร้อมให้เข้าอยู่';

  @override
  String get description => 'รายละเอียด';

  @override
  String get house_number => 'เลขที่บ้าน';

  @override
  String get direction => 'ทิศทาง';

  @override
  String get select_direction => 'เลือกทิศทาง (ไม่บังคับ)';

  @override
  String get city => 'เมือง';

  @override
  String get state => 'จังหวัด';

  @override
  String get country => 'ประเทศ';

  @override
  String get postal_code => 'รหัสไปรษณีย์';

  @override
  String get latitude => 'ละติจูด';

  @override
  String get longitude => 'ลองจิจูด';

  @override
  String get address => 'ที่อยู่';

  @override
  String get property_location_title => 'ตำแหน่งอสังหาริมทรัพย์';

  @override
  String get property_location_subtitle =>
      'คลิกบนแผนที่หรือใช้ตำแหน่งปัจจุบันของคุณเพื่อตั้งค่าตำแหน่งอสังหาริมทรัพย์';

  @override
  String get use_current_location => 'ใช้ตำแหน่งปัจจุบัน';

  @override
  String get clear_location => 'ล้างตำแหน่ง';

  @override
  String get set_by_map => 'ตั้งโดยคลิกบนแผนที่';

  @override
  String get click_to_upload => 'คลิกเพื่ออัปโหลด';

  @override
  String get or_drag_drop => 'หรือลากและวาง';

  @override
  String get image_format_note => 'JPEG/PNG/WebP ไม่เกิน 5MB ต่อไฟล์';

  @override
  String get take_photo => 'ถ่ายรูป';

  @override
  String get use_camera => 'ใช้กล้องของอุปกรณ์เพื่อถ่ายรูป';

  @override
  String get selected_photos => 'รูปภาพที่เลือก';

  @override
  String photo_count(Object count) {
    return 'เลือก $count รูป';
  }

  @override
  String get clear_all => 'ล้างทั้งหมด';

  @override
  String get back => 'กลับ';

  @override
  String get create => 'สร้างอสังหาริมทรัพย์';

  @override
  String get property_created_success => 'สร้างอสังหาริมทรัพย์สำเร็จ!';

  @override
  String get error_creating_property =>
      'เกิดข้อผิดพลาดในการสร้างอสังหาริมทรัพย์';

  @override
  String get error_picking_images => 'เกิดข้อผิดพลาดในการเลือกรูปภาพ';

  @override
  String get this_field_required => 'ฟิลด์นี้จำเป็นต้องกรอก';

  @override
  String get please_enter_valid_number => 'กรุณากรอกตัวเลขที่ถูกต้อง';

  @override
  String get north => 'เหนือ';

  @override
  String get northeast => 'ตะวันออกเฉียงเหนือ';

  @override
  String get east => 'ตะวันออก';

  @override
  String get southeast => 'ตะวันออกเฉียงใต้';

  @override
  String get south => 'ใต้';

  @override
  String get southwest => 'ตะวันตกเฉียงใต้';

  @override
  String get west => 'ตะวันตก';

  @override
  String get northwest => 'ตะวันตกเฉียงเหนือ';

  @override
  String get property_type_house => 'บ้านเดี่ยว';

  @override
  String get property_type_condominium => 'คอนโดมิเนียม';

  @override
  String get property_type_townhouse => 'ทาวน์เฮาส์';

  @override
  String get property_type_villa => 'วิลล่า';

  @override
  String get property_type_duplex => 'ดูเพล็กซ์';

  @override
  String get property_type_penthouse => 'เพนต์เฮาส์';

  @override
  String get property_type_studio => 'สตูดิโอ';

  @override
  String get property_type_commercial => 'เชิงพาณิชย์';

  @override
  String get property_type_land => 'ที่ดิน';

  @override
  String get property_type_other => 'อื่นๆ';

  @override
  String get status_available => 'พร้อมขาย';

  @override
  String get status_pending => 'รอดำเนินการ';

  @override
  String get status_sold => 'ขายแล้ว';

  @override
  String get color_white => 'ขาว';

  @override
  String get color_brown => 'น้ำตาล';

  @override
  String get color_gray => 'เทา';

  @override
  String get color_red => 'แดง';

  @override
  String get color_orange => 'ส้ม';

  @override
  String get color_purple => 'ม่วง';

  @override
  String get color_gold => 'ทอง';

  @override
  String get color_blue => 'น้ำเงิน';

  @override
  String get color_black => 'ดำ';

  @override
  String get color_yellow => 'เหลือง';

  @override
  String get color_green => 'เขียว';

  @override
  String get color_silver => 'เงิน';

  @override
  String get edit_property => 'แก้ไขอสังหาริมทรัพย์';

  @override
  String get edit_property_subtitle =>
      'อัปเดตข้อมูลด้านล่างเพื่อแก้ไขรายการอสังหาริมทรัพย์ของคุณ';

  @override
  String get current_photos => 'รูปภาพปัจจุบัน';

  @override
  String get new_photos_to_add => 'รูปภาพใหม่ที่จะเพิ่ม';

  @override
  String get save => 'บันทึก';

  @override
  String get property_updated_success => 'อัปเดตอสังหาริมทรัพย์สำเร็จ!';

  @override
  String get error_updating_property =>
      'เกิดข้อผิดพลาดในการอัปเดตอสังหาริมทรัพย์';

  @override
  String get add_available_time_slot => 'เพิ่มช่วงเวลาที่ว่าง';

  @override
  String get date => 'วันที่';

  @override
  String get start_time => 'เวลาเริ่มต้น';

  @override
  String get end_time => 'เวลาสิ้นสุด';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get end_time_must_be_after_start_time =>
      'เวลาสิ้นสุดต้องอยู่หลังเวลาเริ่มต้น';

  @override
  String get availability_created_success => 'สร้างช่วงเวลาที่ว่างสำเร็จ!';

  @override
  String get error_creating_availability =>
      'เกิดข้อผิดพลาดในการสร้างช่วงเวลาที่ว่าง';

  @override
  String get home_details_title => 'รายละเอียดบ้าน';

  @override
  String get furniture_status_label => 'สถานะเฟอร์นิเจอร์';

  @override
  String get furniture_full => 'เฟอร์นิเจอร์ครบ';

  @override
  String get furniture_full_subtitle => 'ตกแต่งเรียบร้อย พร้อมเข้าอยู่ทันที';

  @override
  String get sale_status_label => 'สถานะการขาย';

  @override
  String get sale_ready => 'พร้อมโอน';

  @override
  String get sale_ready_subtitle => 'เอกสารครบถ้วน พร้อมโอนได้ทันที';

  @override
  String get area_label => 'พื้นที่';

  @override
  String get ownership_label => 'ประเภทกรรมสิทธิ์';

  @override
  String get ownership_transfer => 'โอนกรรมสิทธิ์';

  @override
  String get direction_label => 'ทิศบ้าน';

  @override
  String get house_age_label => 'อายุบ้าน';

  @override
  String get not_specified => 'ไม่ได้ระบุ';

  @override
  String get feature_floors_label => 'จำนวนชั้น';

  @override
  String get feature_bedrooms_label => 'ห้องนอน';

  @override
  String get feature_bathrooms_label => 'ห้องน้ำ';

  @override
  String get feature_parking_label => 'ที่จอดรถ';

  @override
  String parking_count(Object count) {
    return '$count ที่จอดรถ';
  }

  @override
  String get more_details_title => 'รายละเอียดเพิ่มเติม';

  @override
  String get more_details_description =>
      'บ้านเดี่ยวสวยงาม ตั้งอยู่ในทำเลทอง ใกล้ BTS ห้างสรรพสินค้า โรงพยาบาล และโรงเรียน เหมาะสำหรับทั้งการอยู่อาศัยและการลงทุน';

  @override
  String get show_more => 'ดูเพิ่มเติม';

  @override
  String get show_less => 'ย่อ';

  @override
  String get nearby_title => 'สถานที่ใกล้เคียง';

  @override
  String get nearby_travel => 'การเดินทาง';

  @override
  String get nearby_shopping => 'ห้างสรรพสินค้า & ร้านค้า';

  @override
  String get nearby_education => 'สถานศึกษา';

  @override
  String get nearby_item_bus_stop => 'ป้ายรถเมล์';

  @override
  String get nearby_item_bts_ari => 'BTS อารีย์';

  @override
  String get nearby_item_mrt_phahonyothin => 'MRT พหลโยธิน';

  @override
  String get nearby_item_7eleven => '7-Eleven';

  @override
  String get nearby_item_big_c_extra => 'Big C Extra';

  @override
  String get nearby_item_central_plaza => 'เซ็นทรัลพลาซา';

  @override
  String get nearby_item_demo_school => 'โรงเรียนสาธิต';

  @override
  String get sort_by_compatibility => 'เรียงจากความเข้ากันมากไปน้อย';

  @override
  String get sort_by_price_low_to_high => 'เรียงจากราคาน้อยไปมาก';

  @override
  String get sort_by_price_high_to_low => 'เรียงจากราคามากไปน้อย';

  @override
  String get sort_by_newest => 'เรียงจากประกาศใหม่ไปเก่า';

  @override
  String get parking_spaces => 'จำนวนที่จอดรถ';

  @override
  String get usable_area => 'พื้นที่ใช้สอย';

  @override
  String get area_less_than_30 => 'น้อยกว่า 30 ตร.ม.';

  @override
  String get area_30_50 => '30 - 50 ตร.ม.';

  @override
  String get area_50_100 => '50 - 100 ตร.ม.';

  @override
  String get area_100_1000 => '100 - 1,000 ตร.ม.';

  @override
  String get area_1000_5000 => '1,000 - 5,000 ตร.ม.';

  @override
  String get area_more_than_5000 => 'มากกว่า 5,000 ตร.ม.';

  @override
  String get five_or_more => '≥5';

  @override
  String get voice_location_prompt => 'พูดชื่อทำเลที่ต้องการค้นหา เช่น บางนา';

  @override
  String get voice_budget_min_prompt =>
      'พูดงบประมาณเริ่มต้น เช่น 3 ล้าน หรือ 3000000';

  @override
  String get voice_budget_max_prompt =>
      'พูดงบประมาณสูงสุด เช่น 5 ล้าน หรือ 5000000';

  @override
  String get voice_property_type_prompt =>
      'พูดประเภทอสังหา เช่น บ้าน หรือ คอนโด';

  @override
  String get voice_member_name_prompt => 'คุณชื่ออะไร?';

  @override
  String get voice_member_dob_prompt =>
      'วันเกิดของคุณคือวันอะไร? กรุณาพูดเป็นวัน เดือน ปี เช่น 01 01 1990';

  @override
  String get voice_member_gender_prompt =>
      'เพศของคุณคืออะไร? เช่น ผู้ชาย หรือ ผู้หญิง';

  @override
  String get voice_member_phone_prompt =>
      'เบอร์โทรศัพท์ของคุณคืออะไร? กรุณาพูดเป็นตัวเลข';

  @override
  String get voice_member_car_plate_prompt =>
      'ทะเบียนรถของคุณคืออะไร? สามารถพูดเป็นตัวเลข';

  @override
  String get voice_member_weight_prompt =>
      'น้ำหนักความสำคัญของสมาชิกคนนี้กี่เปอร์เซ็นต์? เช่น 50';

  @override
  String get voice_input_title => 'กรอกข้อมูลด้วยเสียง';

  @override
  String get voice_listening => 'กำลังฟัง...';

  @override
  String get voice_speaking => 'กำลังพูด...';

  @override
  String get voice_listening_to_you => 'กำลังฟังเสียงของคุณ...';

  @override
  String get voice_waiting_response => 'รอคำตอบ...';

  @override
  String get copyright => 'Copyright © 2025 youragent.site';

  @override
  String get terms_and_conditions => 'ข้อตกลงและเงื่อนไขการใช้งาน';

  @override
  String get privacy_policy => 'นโยบายข้อมูลส่วนบุคคล';

  @override
  String get reserved_rights => 'ข้อสงวนสิทธิ์';

  @override
  String get logout_title => 'ออกจากระบบ';

  @override
  String get logout_message => 'คุณต้องการออกจากระบบใช่หรือไม่';

  @override
  String get logout_button => 'ออกจากระบบ';

  @override
  String get cancel_button => 'ยกเลิก';

  @override
  String get notifications_title => 'แจ้งเตือน';

  @override
  String get read_all => 'อ่านทั้งหมด';

  @override
  String get no_notifications => 'ไม่มีแจ้งเตือน';

  @override
  String get now => 'ตอนนี้';

  @override
  String minutes_ago(Object count) {
    return '$count นาทีที่แล้ว';
  }

  @override
  String hours_ago(Object count) {
    return '$count ชั่วโมงที่แล้ว';
  }

  @override
  String days_ago(Object count) {
    return '$count วันที่แล้ว';
  }

  @override
  String get my_properties => 'อสังหาริมทรัพย์ของฉัน';

  @override
  String get create_property_button => '+ สร้างอสังหาริมทรัพย์';

  @override
  String get availability_calendar_view => 'มุมมองปฏิทิน';

  @override
  String availability_count_available(Object count) {
    return 'มี $count ช่วงเวลา';
  }

  @override
  String get profile_bio => 'ประวัติส่วนตัว';

  @override
  String get profile_languages => 'ภาษา';

  @override
  String get profile_experience => 'ปีที่ทำงาน';

  @override
  String get profile_company => 'ชื่อบริษัท';

  @override
  String get profile_license => 'หมายเลขใบอนุญาต';

  @override
  String get profile_radius => 'รัศมีที่ให้บริการ';

  @override
  String get profile_service_area => 'จุดศูนย์กลางพื้นที่บริการ';

  @override
  String get profile_not_set => 'ยังไม่ได้ตั้ง';

  @override
  String get profile_agent_code => 'รหัสเพื่อเชื่อมต่อกับบริษัท';

  @override
  String get profile_share_code_desc =>
      'แชร์ข้อมูลประจำตัวนี้กับบริษัทเพื่อให้พวกเขาสามารถเพิ่มคุณในพอร์ตโฟลิโอของพวกเขาได้ ข้อมูลประจำตัวนี้สามารถใช้ได้เพียงครั้งเดียว';

  @override
  String get profile_copy => 'คัดลอก';

  @override
  String get profile_professional_info => 'ข้อมูลอาชีพ';

  @override
  String get available_times_title => 'เวลาที่ว่าง';

  @override
  String get available_times_subtitle => 'จัดการช่วงเวลาที่ว่างของคุณ';

  @override
  String get calendar_view => 'มุมมองปฏิทิน';

  @override
  String get add_time_slot => 'เพิ่มช่วงเวลาที่ว่าง';

  @override
  String get start_date => 'วันที่เริ่มต้น';

  @override
  String get end_date => 'วันที่สิ้นสุด';

  @override
  String get filter => 'กรอง';

  @override
  String get all => 'ทั้งหมด';

  @override
  String get no_available_times => 'ไม่มีเวลาที่ว่าง';

  @override
  String get no_available_times_hint => 'เริ่มต้นด้วยการสร้างช่วงเวลาใหม่';

  @override
  String get status_unavailable => 'ไม่พร้อมให้บริการ';

  @override
  String get back_to_availability => '← กลับไปยังเวลาที่ว่าง';

  @override
  String get availability_tips_title =>
      'เคล็ดลับสำหรับการตั้งค่าความพร้อมใช้งาน';

  @override
  String get tip_no_overlap =>
      'คุณไม่สามารถสร้างช่วงเวลาที่ทับซ้อนกันในวันที่เดียวกันได้';

  @override
  String get tip_no_past_dates => 'ไม่สามารถตั้งช่วงเวลาสำหรับวันที่ผ่านมาแล้ว';

  @override
  String get tip_end_after_start => 'เวลาสิ้นสุดต้องอยู่หลังเวลาเริ่มต้น';

  @override
  String get tip_consider_schedule =>
      'พิจารณาตารางเวลาของคุณเมื่อตั้งค่าความพร้อมใช้งาน';

  @override
  String get create_time_slot => 'สร้างช่วงเวลา';

  @override
  String get delete_time_slot => 'ลบช่วงเวลา';

  @override
  String get delete_time_slot_confirm =>
      'คุณแน่ใจหรือไม่ว่าต้องการลบช่วงเวลานี้?';

  @override
  String get delete => 'ลบ';

  @override
  String get time_slot_deleted => 'ลบช่วงเวลาสำเร็จ';

  @override
  String get list_view_button => 'แสดงรายการ';

  @override
  String get success => 'สำเร็จ';

  @override
  String get error => 'เกิดข้อผิดพลาด';

  @override
  String get login_error => 'ข้อผิดพลาดในการเข้าสู่ระบบ';

  @override
  String get confirm => 'ยืนยัน';

  @override
  String get confirm_delete_property =>
      'คุณต้องการลบอสังหาริมทรัพย์นี้หรือไม่?';

  @override
  String get confirm_create_property =>
      'คุณต้องการสร้างอสังหาริมทรัพย์นี้หรือไม่?';

  @override
  String get confirm_update_property =>
      'คุณต้องการอัปเดตอสังหาริมทรัพย์นี้หรือไม่?';

  @override
  String get confirm_delete_contract => 'คุณต้องการลบสัญญานี้ใช่หรือไม่?';

  @override
  String get property_deleted_success => 'ลบอสังหาริมทรัพย์สำเร็จ';

  @override
  String get error_deleting_property => 'เกิดข้อผิดพลาดในการลบอสังหาริมทรัพย์';

  @override
  String get contract_deleted_success => 'ลบสัญญาสำเร็จ';

  @override
  String get error_deleting_contract => 'เกิดข้อผิดพลาดในการลบสัญญา';

  @override
  String get error_deleting => 'เกิดข้อผิดพลาดในการลบ';

  @override
  String get general_information => 'ข้อมูลทั่วไป';

  @override
  String get property_location_section => 'ตำแหน่งที่ตั้ง';

  @override
  String get property_details_section => 'รายละเอียดทรัพย์';

  @override
  String get additional_details_section => 'รายละเอียดเพิ่มเติม';

  @override
  String get property_images_section => 'รูปภาพทรัพย์';

  @override
  String get lessor_information => 'ข้อมูลผู้ให้เช่า';

  @override
  String get lessee_information => 'ข้อมูลผู้เช่า';

  @override
  String get rental_property_information => 'ข้อมูลทรัพย์ที่ให้เช่า';

  @override
  String get lease_period => 'ระยะเวลาเช่า';

  @override
  String get rental_fee_and_payment => 'ค่าเช่าและการชำระเงิน';

  @override
  String get terms_and_conditions_section => 'เงื่อนไขการใช้งาน';

  @override
  String get signature => 'ลายเซ็น';

  @override
  String get create_rental_contract => 'สร้างสัญญาเช่า';

  @override
  String get electrical_appliances_photos => 'รูปภาพเครื่องใช้ไฟฟ้า';

  @override
  String get furniture_photos => 'รูปภาพเฟอร์นิเจอร์';

  @override
  String get properties => 'อสังหาริมทรัพย์';

  @override
  String get appointments => 'นัดหมาย';

  @override
  String get confirm_cancel =>
      'คุณแน่ใจหรือไม่ว่าต้องการยกเลิก? การเปลี่ยนแปลงที่ยังไม่ได้บันทึกจะสูญหายทั้งหมด';

  @override
  String get confirm_cancel_create =>
      'คุณแน่ใจหรือไม่ว่าต้องการยกเลิก? ข้อมูลที่กรอกไว้จะสูญหายทั้งหมด';

  @override
  String get yes => 'ใช่';

  @override
  String get no => 'ไม่';

  @override
  String get confirmation_and_signature => 'การยืนยันและลงนาม';

  @override
  String get contract_number => 'เลขที่สัญญา';

  @override
  String get contract_type => 'ประเภทสัญญา';

  @override
  String get rental_contract => 'สัญญาเช่า';

  @override
  String get general_rental_contract => 'สัญญาเช่าทั่วไป';

  @override
  String get purchase_sale_contract => 'สัญญาจะซื้อจะขาย';

  @override
  String get contract_date => 'วันที่ทำสัญญา';

  @override
  String get create_new_account => 'สร้างบัญชีใหม่';

  @override
  String get individual => 'บุคคลธรรมดา';

  @override
  String get juristic_person => 'นิติบุคคล';

  @override
  String get full_name_or_company => 'ชื่อ-นามสกุล / ชื่อบริษัท';

  @override
  String get enter_full_name => 'กรอกชื่อ-นามสกุล';

  @override
  String get id_card_or_tax_id => 'เลขบัตรประชาชน / เลขนิติบุคคล';

  @override
  String get enter_id_card => 'กรอกเลขบัตรประชาชน';

  @override
  String get authorized_signatory => 'ผู้มีอำนาจลงนาม';

  @override
  String get property_type_label => 'ประเภททรัพย์';

  @override
  String get select_property_type => 'เลือกประเภททรัพย์';

  @override
  String get condominium => 'คอนโดมิเนียม';

  @override
  String get single_house => 'บ้านเดี่ยว';

  @override
  String get project_name => 'ชื่อโครงการ';

  @override
  String get house_or_room_number => 'เลขที่บ้าน/ห้อง';

  @override
  String get floor_label => 'ชั้น';

  @override
  String get soi_alley_village => 'ซอย/ตรอก/หมู่บ้าน (ถ้ามี)';

  @override
  String get road_if_any => 'ถนน (ถ้ามี)';

  @override
  String get select_country => 'เลือกประเทศ';

  @override
  String get select_province => 'เลือกจังหวัด';

  @override
  String get district => 'เขต/อำเภอ';

  @override
  String get select_district => 'เลือกเขต/อำเภอ';

  @override
  String get subdistrict => 'แขวง/ตำบล';

  @override
  String get select_subdistrict => 'เลือกแขวง/ตำบล';

  @override
  String get quantity => 'จำนวน';

  @override
  String get no_images => 'ไม่มีรูปภาพ';

  @override
  String get add_item => 'เพิ่มรายการ';

  @override
  String get contract_start_date => 'วันที่เริ่มสัญญา';

  @override
  String get select_date => 'เลือกวันที่';

  @override
  String get contract_end_date => 'วันที่สิ้นสุด';

  @override
  String get lease_renewal_format => 'รูปแบบการต่อสัญญา';

  @override
  String get select_renewal_format => 'เลือกรูปแบบการต่อสัญญา';

  @override
  String get renewal_conditions => 'เงื่อนไขต่อสัญญา';

  @override
  String get rental_fee => 'ค่าเช่า';

  @override
  String get common_fee => 'ค่าส่วนกลาง';

  @override
  String get other_service_fee => 'ค่าบริการอื่น';

  @override
  String get total_monthly_payment => 'รวมยอดชำระรายเดือน';

  @override
  String get advance_rental => 'ค่าเช่าล่วงหน้า';

  @override
  String get damage_deposit => 'เงินประกันความเสียหาย';

  @override
  String get total_payment_before_move_in => 'รวมยอดชำระก่อนเข้าอยู่';

  @override
  String get payment_due_date => 'วันที่กำหนดชำระ';

  @override
  String get of_every_month => 'ของทุกเดือน';

  @override
  String get water_fee => 'ค่าน้ำประปา';

  @override
  String get per_unit => 'บาท/หน่วย';

  @override
  String get payment_channel => 'ช่องทางการชำระเงิน';

  @override
  String get select_payment_channel => 'เลือกช่องทางการชำระเงิน';

  @override
  String get branch => 'สาขา';

  @override
  String get account_name => 'ชื่อบัญชี';

  @override
  String get account_number => 'เลขบัญชี';

  @override
  String get additional_conditions_optional => 'เงื่อนไขเพิ่มเติม (ไม่บังคับ)';

  @override
  String get additional_conditions => 'เงื่อนไขเพิ่มเติม';

  @override
  String get lessee => 'ผู้เช่า';

  @override
  String get lessor => 'ผู้ให้เช่า';

  @override
  String get test_system => 'นายทดสอบ ระบบ';

  @override
  String get property_owner => 'นายเจ้าของ ทรัพย์';

  @override
  String get sq_wa => 'ตร.ว.';

  @override
  String get sq_m => 'ตร.ม.';

  @override
  String get baht_per_month => 'บาท/เดือน';

  @override
  String get baht => 'บาท';

  @override
  String get months => 'เดือน';

  @override
  String get items_per_page => 'จำนวนต่อหน้า';

  @override
  String get dashboard_overview => 'ภาพรวมแดชบอร์ด';

  @override
  String get contracts => 'เอกสารสัญญา';

  @override
  String get availability => 'ตารางเวลา';

  @override
  String get edit_profile => 'แก้ไขโปรไฟล์';

  @override
  String get legal_entity => 'นิติบุคคล';

  @override
  String get residential_lease => 'สัญญาเช่าที่อยู่อาศัย';

  @override
  String get commercial_lease => 'สัญญาเช่าพาณิชย์';

  @override
  String get select_status => 'เลือกสถานะ';

  @override
  String get select_color => 'เลือกสี';

  @override
  String get select_type => 'เลือกประเภท';

  @override
  String get upload_at_least_one_image => 'กรุณาอัปโหลดรูปภาพอย่างน้อย 1 รูป';

  @override
  String images_added(Object count) {
    return 'เพิ่ม $count รูปภาพแล้ว';
  }

  @override
  String get select_file => 'เลือกไฟล์ของคุณ';

  @override
  String get retry => 'ลองอีกครั้ง';

  @override
  String get property_not_found => 'ไม่พบอสังหาริมทรัพย์';

  @override
  String get no_profile_data => 'ไม่มีข้อมูลโปรไฟล์';

  @override
  String get new_ticket => 'ตั๋วใหม่';

  @override
  String get send_reply => 'ส่งคำตอบ';

  @override
  String get add_floor_plan => 'เพิ่มแผนผังชั้น';

  @override
  String get view_floor_plan => 'ดูแผนผังชั้น';

  @override
  String get back_to_login => 'กลับไปหน้าเข้าสู่ระบบ';

  @override
  String get bookings => 'การจอง';

  @override
  String get chats => 'แชท';

  @override
  String get time_slots => 'ช่องเวลา';

  @override
  String get support => 'สนับสนุน';

  @override
  String get profile => 'โปรไฟล์';

  @override
  String get dashboard => 'แดชบอร์ด';

  @override
  String get search_contract_number => 'ค้นหาเลขที่สัญญา';

  @override
  String get search_property_name => 'ค้นหาชื่ออสังหาฯ';

  @override
  String get search_lessor => 'ค้นหาผู้ให้เช่า';

  @override
  String get search_lessee => 'ค้นหาผู้เช่า';

  @override
  String get select_contract_status => 'เลือกสถานะสัญญา';

  @override
  String get select_property_type_contract => 'เลือกประเภทอสังหาฯ';

  @override
  String get contract_status_incomplete => 'ยังไม่สมบูรณ์';

  @override
  String get contract_status_complete => 'สมบูรณ์';

  @override
  String get month_january => 'มกราคม';

  @override
  String get month_february => 'กุมภาพันธ์';

  @override
  String get month_march => 'มีนาคม';

  @override
  String get month_april => 'เมษายน';

  @override
  String get month_may => 'พฤษภาคม';

  @override
  String get month_june => 'มิถุนายน';

  @override
  String get month_july => 'กรกฎาคม';

  @override
  String get month_august => 'สิงหาคม';

  @override
  String get month_september => 'กันยายน';

  @override
  String get month_october => 'ตุลาคม';

  @override
  String get month_november => 'พฤศจิกายน';

  @override
  String get month_december => 'ธันวาคม';

  @override
  String get email_not_verified => 'ยังไม่ได้ยืนยัน';

  @override
  String get full_name_label => 'ชื่อเต็ม';

  @override
  String get email_address => 'ที่อยู่อีเมล';

  @override
  String get mobile_number => 'หมายเลขโทรศัพท์มือถือ';

  @override
  String get personal_info => 'ข้อมูลส่วนตัว';

  @override
  String get account_info => 'ข้อมูลบัญชี';

  @override
  String get member_since => 'สมาชิกตั้งแต่';

  @override
  String get last_updated => 'อัปเดตล่าสุด';

  @override
  String get account_status_active => 'ใช้งานได้';

  @override
  String get account_status => 'สถานะบัญชี';

  @override
  String get years_suffix => 'ปี';

  @override
  String get my_profile => 'โปรไฟล์ของฉัน';

  @override
  String get today => 'วันนี้';

  @override
  String get day_sun => 'อา';

  @override
  String get day_mon => 'จ';

  @override
  String get day_tue => 'อ';

  @override
  String get day_wed => 'พ';

  @override
  String get day_thu => 'พฤ';

  @override
  String get day_fri => 'ศ';

  @override
  String get day_sat => 'ส';

  @override
  String get legend => 'คำอธิบาย';

  @override
  String get error_occurred => 'เกิดข้อผิดพลาด';

  @override
  String get agent_summary => 'สรุปสำหรับเอเจนต์';

  @override
  String get view_properties_list => 'ดูรายการทรัพย์สิน';

  @override
  String get i_have_read_and_accept => 'ฉันได้อ่านและยอมรับ ';

  @override
  String get link_terms_and_conditions => 'ข้อตกลงและเงื่อนไขการใช้งาน';

  @override
  String get link_privacy_policy => 'นโยบายความเป็นส่วนตัว';

  @override
  String get please_enter => 'กรุณากรอก';

  @override
  String get please_select => 'กรุณาเลือก';

  @override
  String get field_required => 'จำเป็นต้องระบุข้อมูล';

  @override
  String get loading => 'กำลังดำเนินการ...';

  @override
  String get management => 'จัดการ';

  @override
  String get no_data_found => 'ไม่พบข้อมูล';

  @override
  String get people => 'คน';

  @override
  String get property_types => 'ประเภทอสังหาฯ';

  @override
  String get all_buyers_renters => 'ผู้ซื้อ/ผู้เช่าทั้งหมด';

  @override
  String get all_buyers => 'ผู้ซื้อทั้งหมด';

  @override
  String get all_renters => 'ผู้เช่าทั้งหมด';

  @override
  String get help_center => 'ศูนย์ช่วยเหลือ';
}
