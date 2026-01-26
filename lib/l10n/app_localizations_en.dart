// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'Home for you';

  @override
  String get family_members => 'Family Members';

  @override
  String get family_members_subtitle => 'Fill in member details to find homes that fit everyone in the family';

  @override
  String get real_estate => 'Real Estate';

  @override
  String get real_estate_subtitle => 'Fill in details to find the most suitable home';

  @override
  String get add_member => 'Add Member';

  @override
  String get clear_data => 'Clear Data';

  @override
  String get search_homes => 'Search Homes';

  @override
  String get location => 'Location';

  @override
  String get location_hint => 'Sukhumvit, Silom, Bangkok, ...';

  @override
  String get property_type => 'Property Type';

  @override
  String get property_type_hint => 'Please select';

  @override
  String get budget_range => 'Budget Range';

  @override
  String get budget_hint => '0';

  @override
  String get budget_note => 'You can specify only one field';

  @override
  String get condo => 'Condo';

  @override
  String get house => 'Single House';

  @override
  String get name => 'Name';

  @override
  String get name_hint => 'First name Last name';

  @override
  String get birthdate => 'Birth Date';

  @override
  String get birthdate_hint => 'DD/MM/YYYY';

  @override
  String get gender => 'Gender';

  @override
  String get gender_male => 'Male';

  @override
  String get gender_female => 'Female';

  @override
  String get gender_other => 'Other';

  @override
  String get weight => 'Weight';

  @override
  String get weight_hint => '0';

  @override
  String get height => 'Height';

  @override
  String get height_hint => '0';

  @override
  String get congenital_disease => 'Congenital Disease';

  @override
  String get congenital_disease_hint => 'Diabetes, Asthma, ...';

  @override
  String get phone_number => 'Phone Number';

  @override
  String get license_plate => 'License Plate';

  @override
  String get license_plate_hint => 'Please enter numbers only';

  @override
  String get lock_weight => 'Lock Weight';

  @override
  String get allergy => 'Allergy';

  @override
  String get allergy_hint => 'Dust, Pollen, ...';

  @override
  String get bedrooms => 'Bedrooms';

  @override
  String get bathrooms => 'Bathrooms';

  @override
  String get area => 'Area';

  @override
  String get search_filter => 'Search Filter';

  @override
  String get amenities => 'Amenities';

  @override
  String get fireplace => 'Fireplace';

  @override
  String get swimming_pool => 'Swimming Pool';

  @override
  String get garage => 'Garage';

  @override
  String get garden => 'Garden';

  @override
  String get playground => 'Playground';

  @override
  String get search => 'Search';

  @override
  String get results_for => 'Matched results for';

  @override
  String get properties_found => 'properties found';

  @override
  String get compatibility_score => 'Compatibility Score';

  @override
  String get score_before_filters => 'Score before filtering';

  @override
  String get unit_sqm => 'sqm';

  @override
  String bath_count(Object count) {
    return '$count bath(s)';
  }

  @override
  String bed_count(Object count) {
    return '$count bed(s)';
  }

  @override
  String area_sqm(Object area) {
    return '$area sqm';
  }

  @override
  String floor_count(Object count) {
    return '$count floor(s)';
  }

  @override
  String price_per_sqm(Object price) {
    return '$price THB/sqm';
  }

  @override
  String get yourHomeAgent => 'YourHome Agent';

  @override
  String get viewHouse => 'View House';

  @override
  String get schedule_viewing => 'Schedule viewing';

  @override
  String people_interested(Object count) {
    return '$count people interested!';
  }

  @override
  String get inquire => 'Inquire';

  @override
  String get showFilterOnMap => 'Show filter on map';

  @override
  String get showOnMap => 'Show on map';

  @override
  String get list_view => 'List view';

  @override
  String get map_view => 'Map view';

  @override
  String get compatibility => 'Compatibility';

  @override
  String get register => 'Register';

  @override
  String get login => 'Login';

  @override
  String get no_locations_found => 'No properties match your current filters.';

  @override
  String get hero_search_prefix => 'Find the home you’ll';

  @override
  String get ticker_word_1 => 'Like';

  @override
  String get ticker_word_2 => 'Love';

  @override
  String get ticker_word_3 => 'Matched';

  @override
  String get login_agent_title => 'Login as Agent';

  @override
  String get login_agent_subtitle => 'Log in to your agent account';

  @override
  String get login_admin_title => 'Login as Admin';

  @override
  String get login_admin_subtitle => 'Log in to your admin account';

  @override
  String get login_agency_title => 'Login as Agency';

  @override
  String get login_agency_subtitle => 'Log in to your agency account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgot_password => 'Forgot your password?';

  @override
  String get remember_me => 'Remember me';

  @override
  String get login_button => 'LOG IN';

  @override
  String get sign_in_with_google => 'Google';

  @override
  String get sign_in_with_facebook => 'Facebook';

  @override
  String get or => 'or';

  @override
  String get don_t_have_account => 'Don\'t have an account?';

  @override
  String get register_now => 'Register now';

  @override
  String get already_have_account => 'Already have an account?';

  @override
  String get login_now => 'Log in';

  @override
  String get full_name => 'Name';

  @override
  String get full_name_hint => 'First name - Last name';

  @override
  String get confirm_password => 'Confirm Password';

  @override
  String get agent_license_number => 'License Number';

  @override
  String get agent_license_hint => 'License number';

  @override
  String get business_type => 'Business Type';

  @override
  String get business_type_hint => 'Please select';

  @override
  String get company_name => 'Company Name';

  @override
  String get company_name_hint => 'Company name';

  @override
  String get register_button => 'REGISTER';

  @override
  String get register_agent_title => 'Register as Agent';

  @override
  String get register_admin_title => 'Register as Admin';

  @override
  String get register_agency_title => 'Register as Agency';

  @override
  String get thb => 'THB';

  @override
  String get hero_slogan_part1 => 'A Good Life';

  @override
  String get hero_slogan_part2 => 'A Good House For You';

  @override
  String get hero_subtitle => 'Because we believe that a happy future starts with the right home';

  @override
  String get select_role_title => 'Select Your Role';

  @override
  String get select_role_subtitle => 'Choose how you want to access the platform';

  @override
  String get enter_email => 'Please enter your email';

  @override
  String get enter_valid_email => 'Please enter a valid email';

  @override
  String get enter_password => 'Please enter your password';

  @override
  String get password_length_error => 'Password must be at least 6 characters';

  @override
  String get sign_in_cancelled => 'Sign in cancelled';

  @override
  String get enter_name => 'Please enter your name';

  @override
  String get confirm_password_hint => 'Confirm your password';

  @override
  String get enter_confirm_password => 'Please confirm your password';

  @override
  String get passwords_do_not_match => 'Passwords do not match';

  @override
  String get select_business_type => 'Please select a business type';

  @override
  String get enter_license_number => 'Please enter your license number';

  @override
  String get enter_company_name => 'Please enter your company name';

  @override
  String get business_type_agency => 'Real Estate Agency';

  @override
  String get business_type_developer => 'Property Developer';

  @override
  String get business_type_independent => 'Independent Agent';

  @override
  String get business_type_brokerage => 'Brokerage Firm';

  @override
  String get role_agent => 'For Agent';

  @override
  String get role_agency => 'For Agency';

  @override
  String get role_admin => 'For Admin';

  @override
  String get create_property => 'Create Property';

  @override
  String get create_property_subtitle => 'Fill in the details below to create a new property listing';

  @override
  String get basic_information => 'Basic Information';

  @override
  String get specifications => 'Specifications';

  @override
  String get property_location => 'Location';

  @override
  String get photos => 'Photos';

  @override
  String get built_date => 'Built (YYYY-MM-DD)';

  @override
  String get type => 'Type';

  @override
  String get status => 'Status';

  @override
  String get bedrooms_label => 'Bedrooms';

  @override
  String get bathrooms_label => 'Bathrooms';

  @override
  String get garage_spaces => 'Garage Spaces';

  @override
  String get price_thb => 'Price (THB)';

  @override
  String get land_size => 'Land Size (sq.wa)';

  @override
  String get building_size => 'Building Size (sq.m)';

  @override
  String get house_color => 'House Color';

  @override
  String get available_from => 'Available From';

  @override
  String get description => 'Description';

  @override
  String get house_number => 'House Number';

  @override
  String get direction => 'Direction';

  @override
  String get select_direction => 'Select Direction (Optional)';

  @override
  String get city => 'City';

  @override
  String get state => 'State';

  @override
  String get country => 'Country';

  @override
  String get postal_code => 'Postal Code';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get address => 'Address';

  @override
  String get property_location_title => 'Property Location';

  @override
  String get property_location_subtitle => 'Click on the map or use your current location to set the property location.';

  @override
  String get use_current_location => 'Use Current Location';

  @override
  String get clear_location => 'Clear Location';

  @override
  String get set_by_map => 'Set by clicking on the map';

  @override
  String get click_to_upload => 'Click to upload';

  @override
  String get or_drag_drop => 'or drag and drop';

  @override
  String get image_format_note => 'JPEG/PNG/WebP up to 5MB each';

  @override
  String get take_photo => 'Take Photo';

  @override
  String get use_camera => 'Use your device camera to capture photos';

  @override
  String get selected_photos => 'Selected Photos';

  @override
  String photo_count(Object count) {
    return '$count photo(s) selected';
  }

  @override
  String get clear_all => 'Clear All';

  @override
  String get back => 'Back';

  @override
  String get create => 'Create Property';

  @override
  String get property_created_success => 'Property created successfully!';

  @override
  String get error_creating_property => 'Error creating property';

  @override
  String get error_picking_images => 'Error picking images';

  @override
  String get this_field_required => 'This field is required';

  @override
  String get please_enter_valid_number => 'Please enter a valid number';

  @override
  String get north => 'North';

  @override
  String get northeast => 'Northeast';

  @override
  String get east => 'East';

  @override
  String get southeast => 'Southeast';

  @override
  String get south => 'South';

  @override
  String get southwest => 'Southwest';

  @override
  String get west => 'West';

  @override
  String get northwest => 'Northwest';

  @override
  String get property_type_house => 'House';

  @override
  String get property_type_condominium => 'Condominium';

  @override
  String get property_type_townhouse => 'Townhouse';

  @override
  String get property_type_villa => 'Villa';

  @override
  String get property_type_duplex => 'Duplex';

  @override
  String get property_type_penthouse => 'Penthouse';

  @override
  String get property_type_studio => 'Studio';

  @override
  String get property_type_commercial => 'Commercial';

  @override
  String get property_type_land => 'Land';

  @override
  String get property_type_other => 'Other';

  @override
  String get status_available => 'Available';

  @override
  String get status_pending => 'Pending';

  @override
  String get status_sold => 'Sold';

  @override
  String get color_white => 'White';

  @override
  String get color_brown => 'Brown';

  @override
  String get color_gray => 'Gray';

  @override
  String get color_red => 'Red';

  @override
  String get color_orange => 'Orange';

  @override
  String get color_purple => 'Purple';

  @override
  String get color_gold => 'Gold';

  @override
  String get color_blue => 'Blue';

  @override
  String get color_black => 'Black';

  @override
  String get color_yellow => 'Yellow';

  @override
  String get color_green => 'Green';

  @override
  String get color_silver => 'Silver';

  @override
  String get edit_property => 'Edit Property';

  @override
  String get edit_property_subtitle => 'Update the details below to modify your property listing';

  @override
  String get current_photos => 'Current Photos';

  @override
  String get new_photos_to_add => 'New Photos to Add';

  @override
  String get save => 'Save';

  @override
  String get property_updated_success => 'Property updated successfully!';

  @override
  String get error_updating_property => 'Error updating property';

  @override
  String get add_available_time_slot => 'Add Available Time Slot';

  @override
  String get date => 'Date';

  @override
  String get start_time => 'Start Time';

  @override
  String get end_time => 'End Time';

  @override
  String get cancel => 'Cancel';

  @override
  String get end_time_must_be_after_start_time => 'End time must be after start time';

  @override
  String get availability_created_success => 'Available time created successfully!';

  @override
  String get error_creating_availability => 'Error creating available time';

  @override
  String get home_details_title => 'Home Details';

  @override
  String get furniture_status_label => 'Furniture Status';

  @override
  String get furniture_full => 'Fully furnished';

  @override
  String get furniture_full_subtitle => 'Fully decorated, ready to move in';

  @override
  String get sale_status_label => 'Sale Status';

  @override
  String get sale_ready => 'Ready to transfer';

  @override
  String get sale_ready_subtitle => 'Complete documents, ready to transfer immediately';

  @override
  String get area_label => 'Area';

  @override
  String get ownership_label => 'Ownership type';

  @override
  String get ownership_transfer => 'Freehold';

  @override
  String get direction_label => 'House direction';

  @override
  String get house_age_label => 'House age';

  @override
  String get not_specified => 'Not specified';

  @override
  String get feature_floors_label => 'Floors';

  @override
  String get feature_bedrooms_label => 'Bedrooms';

  @override
  String get feature_bathrooms_label => 'Bathrooms';

  @override
  String get feature_parking_label => 'Parking';

  @override
  String parking_count(Object count) {
    return '$count parking spot(s)';
  }

  @override
  String get more_details_title => 'Additional Details';

  @override
  String get more_details_description => 'Beautiful single house in a prime location, close to BTS, shopping malls, hospitals, and schools. Suitable for both living and investment.';

  @override
  String get show_more => 'See more';

  @override
  String get show_less => 'Show less';

  @override
  String get nearby_title => 'Nearby';

  @override
  String get nearby_travel => 'Transportation';

  @override
  String get nearby_shopping => 'Shopping & Retail';

  @override
  String get nearby_education => 'Education';

  @override
  String get nearby_item_bus_stop => 'Bus stop';

  @override
  String get nearby_item_bts_ari => 'BTS Ari';

  @override
  String get nearby_item_mrt_phahonyothin => 'MRT Phahon Yothin';

  @override
  String get nearby_item_7eleven => '7-Eleven';

  @override
  String get nearby_item_big_c_extra => 'Big C Extra';

  @override
  String get nearby_item_central_plaza => 'Central Plaza';

  @override
  String get nearby_item_demo_school => 'Demonstration School';

  @override
  String get sort_by_compatibility => 'Sort by compatibility high to low';

  @override
  String get sort_by_price_low_to_high => 'Sort by price low to high';

  @override
  String get sort_by_price_high_to_low => 'Sort by price high to low';

  @override
  String get sort_by_newest => 'Sort by newest listings';

  @override
  String get parking_spaces => 'Parking spaces';

  @override
  String get usable_area => 'Usable area';

  @override
  String get area_less_than_30 => 'Less than 30 sqm';

  @override
  String get area_30_50 => '30 - 50 sqm';

  @override
  String get area_50_100 => '50 - 100 sqm';

  @override
  String get area_100_1000 => '100 - 1,000 sqm';

  @override
  String get area_1000_5000 => '1,000 - 5,000 sqm';

  @override
  String get area_more_than_5000 => 'More than 5,000 sqm';

  @override
  String get five_or_more => '≥5';

  @override
  String get voice_location_prompt => 'Please say the location name you want to search, for example, Bangna';

  @override
  String get voice_budget_min_prompt => 'Please say the minimum budget, for example, 3 million or 3000000';

  @override
  String get voice_budget_max_prompt => 'Please say the maximum budget, for example, 5 million or 5000000';

  @override
  String get voice_property_type_prompt => 'Please say the property type, for example, house or condo';

  @override
  String get voice_member_name_prompt => 'What is your name?';

  @override
  String get voice_member_dob_prompt => 'When is your birthdate? Please say as day month year, for example, 01 01 1990';

  @override
  String get voice_member_gender_prompt => 'What is your gender? For example, male or female';

  @override
  String get voice_member_phone_prompt => 'What is your phone number? Please say as numbers';

  @override
  String get voice_member_car_plate_prompt => 'What is your license plate number? You can say as numbers';

  @override
  String get voice_member_weight_prompt => 'How important is this member? What percentage? For example, 50';

  @override
  String get voice_input_title => 'Voice Input';

  @override
  String get voice_listening => 'Listening...';

  @override
  String get voice_speaking => 'Speaking...';

  @override
  String get voice_listening_to_you => 'Listening to you...';

  @override
  String get voice_waiting_response => 'Waiting for response...';

  @override
  String get copyright => 'Copyright © 2025 youragent.site';

  @override
  String get terms_and_conditions => 'Terms and Conditions';

  @override
  String get privacy_policy => 'Privacy Policy';

  @override
  String get reserved_rights => 'Reserved Rights';

  @override
  String get logout_title => 'Logout';

  @override
  String get logout_message => 'Do you want to log out?';

  @override
  String get logout_button => 'Log out';

  @override
  String get cancel_button => 'Cancel';

  @override
  String get notifications_title => 'Notifications';

  @override
  String get read_all => 'Read All';

  @override
  String get no_notifications => 'No notifications';

  @override
  String get now => 'Now';

  @override
  String minutes_ago(Object count) {
    return '$count minutes ago';
  }

  @override
  String hours_ago(Object count) {
    return '$count hours ago';
  }

  @override
  String days_ago(Object count) {
    return '$count days ago';
  }

  @override
  String get unread => 'Unread';

  @override
  String get my_properties => 'My Properties';

  @override
  String get create_property_button => '+ Create Property';

  @override
  String get availability_calendar_view => 'Calendar View';

  @override
  String availability_count_available(Object count) {
    return '$count available times';
  }

  @override
  String get profile_bio => 'Bio';

  @override
  String get profile_languages => 'Languages';

  @override
  String get profile_experience => 'Years of Experience';

  @override
  String get profile_company => 'Company Name';

  @override
  String get profile_license => 'License Number';

  @override
  String get profile_radius => 'Service Radius';

  @override
  String get profile_service_area => 'Service Area Center';

  @override
  String get profile_not_set => 'Not Set';

  @override
  String get profile_agent_code => 'Agent Connection Code';

  @override
  String get profile_share_code_desc => 'Share this code with an agency so they can add you to their portfolio. This code can only be used once.';

  @override
  String get profile_copy => 'Copy';

  @override
  String get profile_professional_info => 'Professional Information';

  @override
  String get available_times_title => 'Available Times';

  @override
  String get available_times_subtitle => 'Manage your available time slots';

  @override
  String get calendar_view => 'Calendar View';

  @override
  String get add_time_slot => 'Add Time Slot';

  @override
  String get start_date => 'Start Date';

  @override
  String get end_date => 'End Date';

  @override
  String get filter => 'Filter';

  @override
  String get all => 'All';

  @override
  String get no_available_times => 'No available times';

  @override
  String get no_available_times_hint => 'Start by creating a new time slot';

  @override
  String get status_unavailable => 'Unavailable';

  @override
  String get back_to_availability => '← Back to Available Times';

  @override
  String get availability_tips_title => 'Tips for setting availability';

  @override
  String get tip_no_overlap => 'You cannot create overlapping time slots on the same day';

  @override
  String get tip_no_past_dates => 'Cannot set time slots for past dates';

  @override
  String get tip_end_after_start => 'End time must be after start time';

  @override
  String get tip_consider_schedule => 'Consider your schedule when setting availability';

  @override
  String get create_time_slot => 'Create Time Slot';

  @override
  String get delete_time_slot => 'Delete Time Slot';

  @override
  String get delete_time_slot_confirm => 'Are you sure you want to delete this time slot?';

  @override
  String get delete => 'Delete';

  @override
  String get time_slot_deleted => 'Time slot deleted successfully';

  @override
  String get list_view_button => 'List View';

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String get login_error => 'Login Error';

  @override
  String get confirm => 'Confirm';

  @override
  String get confirm_delete_property => 'Are you sure you want to delete this property?';

  @override
  String get confirm_create_property => 'Are you sure you want to create this property?';

  @override
  String get confirm_update_property => 'Are you sure you want to update this property?';

  @override
  String get confirm_delete_contract => 'Are you sure you want to delete this contract?';

  @override
  String get property_deleted_success => 'Property deleted successfully';

  @override
  String get error_deleting_property => 'Error deleting property';

  @override
  String get contract_deleted_success => 'Contract deleted successfully';

  @override
  String get error_deleting_contract => 'Error deleting contract';

  @override
  String get error_deleting => 'Error deleting';

  @override
  String get general_information => 'General Information';

  @override
  String get property_location_section => 'Property Location';

  @override
  String get property_details_section => 'Property Details';

  @override
  String get additional_details_section => 'Additional Details';

  @override
  String get property_images_section => 'Property Images';

  @override
  String get lessor_information => 'Lessor Information';

  @override
  String get lessee_information => 'Lessee Information';

  @override
  String get rental_property_information => 'Rental Property Information';

  @override
  String get lease_period => 'Lease Period';

  @override
  String get rental_fee_and_payment => 'Rental Fee and Payment';

  @override
  String get terms_and_conditions_section => 'Terms and Conditions';

  @override
  String get signature => 'Signature';

  @override
  String get create_rental_contract => 'Create Rental Contract';

  @override
  String get electrical_appliances_photos => 'Electrical Appliances Photos (Please specify)';

  @override
  String get furniture_photos => 'Furniture Photos (Please specify)';

  @override
  String get properties => 'Properties';

  @override
  String get appointments => 'Appointments';

  @override
  String get confirm_cancel => 'Are you sure you want to cancel? All unsaved changes will be lost.';

  @override
  String get confirm_cancel_create => 'Are you sure you want to cancel? All entered data will be lost.';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get confirmation_and_signature => 'Confirmation and Signature';

  @override
  String get contract_number => 'Contract Number';

  @override
  String get contract_type => 'Contract Type';

  @override
  String get rental_contract => 'Rental Contract';

  @override
  String get general_rental_contract => 'General Rental Contract';

  @override
  String get purchase_sale_contract => 'Purchase and Sale Contract';

  @override
  String get contract_date => 'Contract Date';

  @override
  String get create_new_account => 'Create New Account';

  @override
  String get individual => 'Individual';

  @override
  String get juristic_person => 'Juristic Person';

  @override
  String get full_name_or_company => 'Full Name / Company Name';

  @override
  String get enter_full_name => 'Enter full name';

  @override
  String get id_card_or_tax_id => 'ID Card / Tax ID';

  @override
  String get enter_id_card => 'Enter ID card number';

  @override
  String get authorized_signatory => 'Authorized Signatory';

  @override
  String get property_type_label => 'Property Type';

  @override
  String get select_property_type => 'Select property type';

  @override
  String get condominium => 'Condominium';

  @override
  String get single_house => 'Single House';

  @override
  String get project_name => 'Project Name';

  @override
  String get house_or_room_number => 'House/Room Number';

  @override
  String get floor_label => 'Floor';

  @override
  String get soi_alley_village => 'Soi/Alley/Village (if any)';

  @override
  String get road_if_any => 'Road (if any)';

  @override
  String get select_country => 'Select country';

  @override
  String get select_province => 'Select province';

  @override
  String get district => 'District';

  @override
  String get select_district => 'Select district';

  @override
  String get subdistrict => 'Sub-district';

  @override
  String get select_subdistrict => 'Select sub-district';

  @override
  String get quantity => 'Quantity';

  @override
  String get no_images => 'No images';

  @override
  String get add_item => 'Add Item';

  @override
  String get contract_start_date => 'Contract Start Date';

  @override
  String get select_date => 'Select date';

  @override
  String get contract_end_date => 'Contract End Date';

  @override
  String get lease_renewal_format => 'Lease Renewal Format';

  @override
  String get select_renewal_format => 'Select renewal format';

  @override
  String get renewal_conditions => 'Renewal Conditions';

  @override
  String get rental_fee => 'Rental Fee';

  @override
  String get common_fee => 'Common Fee';

  @override
  String get other_service_fee => 'Other Service Fee';

  @override
  String get total_monthly_payment => 'Total Monthly Payment';

  @override
  String get advance_rental => 'Advance Rental';

  @override
  String get damage_deposit => 'Damage Deposit';

  @override
  String get total_payment_before_move_in => 'Total Payment Before Move In';

  @override
  String get payment_due_date => 'Payment Due Date';

  @override
  String get of_every_month => 'of every month';

  @override
  String get water_fee => 'Water Fee';

  @override
  String get per_unit => 'per unit';

  @override
  String get payment_channel => 'Payment Channel';

  @override
  String get select_payment_channel => 'Select payment channel';

  @override
  String get branch => 'Branch';

  @override
  String get account_name => 'Account Name';

  @override
  String get account_number => 'Account Number';

  @override
  String get additional_conditions_optional => 'Additional Conditions (Optional)';

  @override
  String get additional_conditions => 'Additional conditions';

  @override
  String get lessee => 'Lessee';

  @override
  String get lessor => 'Lessor';

  @override
  String get test_system => 'Test System';

  @override
  String get property_owner => 'Property Owner';

  @override
  String get sq_wa => 'sq.wa';

  @override
  String get sq_m => 'sq.m';

  @override
  String get baht_per_month => 'THB/month';

  @override
  String get baht => 'THB';

  @override
  String get months => 'months';

  @override
  String get items_per_page => 'Items per page';

  @override
  String get dashboard_overview => 'Dashboard Overview';

  @override
  String get contracts => 'Contracts';

  @override
  String get availability => 'Availability';

  @override
  String get edit_profile => 'Edit Profile';

  @override
  String get legal_entity => 'Legal Entity';

  @override
  String get residential_lease => 'Residential Lease';

  @override
  String get commercial_lease => 'Commercial Lease';

  @override
  String get select_status => 'Select Status';

  @override
  String get select_color => 'Select Color';

  @override
  String get select_type => 'Select Type';

  @override
  String get upload_at_least_one_image => 'Please upload at least 1 image';

  @override
  String images_added(Object count) {
    return 'Added $count images';
  }

  @override
  String get select_file => 'Select Your File';

  @override
  String get retry => 'Retry';

  @override
  String get property_not_found => 'Property not found';

  @override
  String get no_profile_data => 'No profile data';

  @override
  String get new_ticket => 'New Ticket';

  @override
  String get send_reply => 'Send Reply';

  @override
  String get add_floor_plan => 'Add Floor Plan';

  @override
  String get view_floor_plan => 'View Floor Plan';

  @override
  String get back_to_login => 'Back to Login';

  @override
  String get bookings => 'Bookings';

  @override
  String get chats => 'Chats';

  @override
  String get time_slots => 'Time Slots';

  @override
  String get support => 'Support';

  @override
  String get profile => 'Profile';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get search_contract_number => 'Search contract number';

  @override
  String get search_property_name => 'Search property name';

  @override
  String get search_lessor => 'Search lessor';

  @override
  String get search_lessee => 'Search lessee';

  @override
  String get select_contract_status => 'Select contract status';

  @override
  String get select_property_type_contract => 'Select property type';

  @override
  String get contract_status_incomplete => 'Incomplete';

  @override
  String get contract_status_complete => 'Complete';

  @override
  String get month_january => 'January';

  @override
  String get month_february => 'February';

  @override
  String get month_march => 'March';

  @override
  String get month_april => 'April';

  @override
  String get month_may => 'May';

  @override
  String get month_june => 'June';

  @override
  String get month_july => 'July';

  @override
  String get month_august => 'August';

  @override
  String get month_september => 'September';

  @override
  String get month_october => 'October';

  @override
  String get month_november => 'November';

  @override
  String get month_december => 'December';

  @override
  String get email_not_verified => 'Not verified';

  @override
  String get full_name_label => 'Full Name';

  @override
  String get email_address => 'Email Address';

  @override
  String get mobile_number => 'Mobile Number';

  @override
  String get personal_info => 'Personal Information';

  @override
  String get account_info => 'Account Information';

  @override
  String get member_since => 'Member Since';

  @override
  String get last_updated => 'Last Updated';

  @override
  String get account_status_active => 'Active';

  @override
  String get account_status => 'Account Status';

  @override
  String get years_suffix => 'years';

  @override
  String get my_profile => 'My Profile';

  @override
  String get today => 'Today';

  @override
  String get day_sun => 'Sun';

  @override
  String get day_mon => 'Mon';

  @override
  String get day_tue => 'Tue';

  @override
  String get day_wed => 'Wed';

  @override
  String get day_thu => 'Thu';

  @override
  String get day_fri => 'Fri';

  @override
  String get day_sat => 'Sat';

  @override
  String get legend => 'Legend';

  @override
  String get error_occurred => 'An error occurred';

  @override
  String get agent_summary => 'Agent Summary';

  @override
  String get view_properties_list => 'View Properties List';

  @override
  String get i_have_read_and_accept => 'I have read and accept ';

  @override
  String get link_terms_and_conditions => 'Terms and Conditions';

  @override
  String get link_privacy_policy => 'Privacy Policy';

  @override
  String get please_enter => 'Please enter';

  @override
  String get please_select => 'Please select';

  @override
  String get field_required => 'This field is required';

  @override
  String get loading => 'Loading...';

  @override
  String get management => 'Management';

  @override
  String get no_data_found => 'No data found';

  @override
  String get people => 'people';

  @override
  String get property_types => 'Property Types';

  @override
  String get all_buyers_renters => 'All Buyers/Renters';

  @override
  String get all_buyers => 'All Buyers';

  @override
  String get all_renters => 'All Renters';

  @override
  String get help_center => 'Help Center';
}
