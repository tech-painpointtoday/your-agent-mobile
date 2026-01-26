import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_th.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('th')
  ];

  /// No description provided for @app_title.
  ///
  /// In en, this message translates to:
  /// **'Home for you'**
  String get app_title;

  /// No description provided for @family_members.
  ///
  /// In en, this message translates to:
  /// **'Family Members'**
  String get family_members;

  /// No description provided for @family_members_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in member details to find homes that fit everyone in the family'**
  String get family_members_subtitle;

  /// No description provided for @real_estate.
  ///
  /// In en, this message translates to:
  /// **'Real Estate'**
  String get real_estate;

  /// No description provided for @real_estate_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in details to find the most suitable home'**
  String get real_estate_subtitle;

  /// No description provided for @add_member.
  ///
  /// In en, this message translates to:
  /// **'Add Member'**
  String get add_member;

  /// No description provided for @clear_data.
  ///
  /// In en, this message translates to:
  /// **'Clear Data'**
  String get clear_data;

  /// No description provided for @search_homes.
  ///
  /// In en, this message translates to:
  /// **'Search Homes'**
  String get search_homes;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @location_hint.
  ///
  /// In en, this message translates to:
  /// **'Sukhumvit, Silom, Bangkok, ...'**
  String get location_hint;

  /// No description provided for @property_type.
  ///
  /// In en, this message translates to:
  /// **'Property Type'**
  String get property_type;

  /// No description provided for @property_type_hint.
  ///
  /// In en, this message translates to:
  /// **'Please select'**
  String get property_type_hint;

  /// No description provided for @budget_range.
  ///
  /// In en, this message translates to:
  /// **'Budget Range'**
  String get budget_range;

  /// No description provided for @budget_hint.
  ///
  /// In en, this message translates to:
  /// **'0'**
  String get budget_hint;

  /// No description provided for @budget_note.
  ///
  /// In en, this message translates to:
  /// **'You can specify only one field'**
  String get budget_note;

  /// No description provided for @condo.
  ///
  /// In en, this message translates to:
  /// **'Condo'**
  String get condo;

  /// No description provided for @house.
  ///
  /// In en, this message translates to:
  /// **'Single House'**
  String get house;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @name_hint.
  ///
  /// In en, this message translates to:
  /// **'First name Last name'**
  String get name_hint;

  /// No description provided for @birthdate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthdate;

  /// No description provided for @birthdate_hint.
  ///
  /// In en, this message translates to:
  /// **'DD/MM/YYYY'**
  String get birthdate_hint;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @gender_male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get gender_male;

  /// No description provided for @gender_female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get gender_female;

  /// No description provided for @gender_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get gender_other;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @weight_hint.
  ///
  /// In en, this message translates to:
  /// **'0'**
  String get weight_hint;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @height_hint.
  ///
  /// In en, this message translates to:
  /// **'0'**
  String get height_hint;

  /// No description provided for @congenital_disease.
  ///
  /// In en, this message translates to:
  /// **'Congenital Disease'**
  String get congenital_disease;

  /// No description provided for @congenital_disease_hint.
  ///
  /// In en, this message translates to:
  /// **'Diabetes, Asthma, ...'**
  String get congenital_disease_hint;

  /// No description provided for @phone_number.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone_number;

  /// No description provided for @license_plate.
  ///
  /// In en, this message translates to:
  /// **'License Plate'**
  String get license_plate;

  /// No description provided for @license_plate_hint.
  ///
  /// In en, this message translates to:
  /// **'Please enter numbers only'**
  String get license_plate_hint;

  /// No description provided for @lock_weight.
  ///
  /// In en, this message translates to:
  /// **'Lock Weight'**
  String get lock_weight;

  /// No description provided for @allergy.
  ///
  /// In en, this message translates to:
  /// **'Allergy'**
  String get allergy;

  /// No description provided for @allergy_hint.
  ///
  /// In en, this message translates to:
  /// **'Dust, Pollen, ...'**
  String get allergy_hint;

  /// No description provided for @bedrooms.
  ///
  /// In en, this message translates to:
  /// **'Bedrooms'**
  String get bedrooms;

  /// No description provided for @bathrooms.
  ///
  /// In en, this message translates to:
  /// **'Bathrooms'**
  String get bathrooms;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// No description provided for @search_filter.
  ///
  /// In en, this message translates to:
  /// **'Search Filter'**
  String get search_filter;

  /// No description provided for @amenities.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get amenities;

  /// No description provided for @fireplace.
  ///
  /// In en, this message translates to:
  /// **'Fireplace'**
  String get fireplace;

  /// No description provided for @swimming_pool.
  ///
  /// In en, this message translates to:
  /// **'Swimming Pool'**
  String get swimming_pool;

  /// No description provided for @garage.
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get garage;

  /// No description provided for @garden.
  ///
  /// In en, this message translates to:
  /// **'Garden'**
  String get garden;

  /// No description provided for @playground.
  ///
  /// In en, this message translates to:
  /// **'Playground'**
  String get playground;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @results_for.
  ///
  /// In en, this message translates to:
  /// **'Matched results for'**
  String get results_for;

  /// No description provided for @properties_found.
  ///
  /// In en, this message translates to:
  /// **'properties found'**
  String get properties_found;

  /// No description provided for @compatibility_score.
  ///
  /// In en, this message translates to:
  /// **'Compatibility Score'**
  String get compatibility_score;

  /// No description provided for @score_before_filters.
  ///
  /// In en, this message translates to:
  /// **'Score before filtering'**
  String get score_before_filters;

  /// No description provided for @unit_sqm.
  ///
  /// In en, this message translates to:
  /// **'sqm'**
  String get unit_sqm;

  /// No description provided for @bath_count.
  ///
  /// In en, this message translates to:
  /// **'{count} bath(s)'**
  String bath_count(Object count);

  /// No description provided for @bed_count.
  ///
  /// In en, this message translates to:
  /// **'{count} bed(s)'**
  String bed_count(Object count);

  /// No description provided for @area_sqm.
  ///
  /// In en, this message translates to:
  /// **'{area} sqm'**
  String area_sqm(Object area);

  /// No description provided for @floor_count.
  ///
  /// In en, this message translates to:
  /// **'{count} floor(s)'**
  String floor_count(Object count);

  /// No description provided for @price_per_sqm.
  ///
  /// In en, this message translates to:
  /// **'{price} THB/sqm'**
  String price_per_sqm(Object price);

  /// No description provided for @yourHomeAgent.
  ///
  /// In en, this message translates to:
  /// **'YourHome Agent'**
  String get yourHomeAgent;

  /// No description provided for @viewHouse.
  ///
  /// In en, this message translates to:
  /// **'View House'**
  String get viewHouse;

  /// No description provided for @schedule_viewing.
  ///
  /// In en, this message translates to:
  /// **'Schedule viewing'**
  String get schedule_viewing;

  /// No description provided for @people_interested.
  ///
  /// In en, this message translates to:
  /// **'{count} people interested!'**
  String people_interested(Object count);

  /// No description provided for @inquire.
  ///
  /// In en, this message translates to:
  /// **'Inquire'**
  String get inquire;

  /// No description provided for @showFilterOnMap.
  ///
  /// In en, this message translates to:
  /// **'Show filter on map'**
  String get showFilterOnMap;

  /// No description provided for @showOnMap.
  ///
  /// In en, this message translates to:
  /// **'Show on map'**
  String get showOnMap;

  /// No description provided for @list_view.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get list_view;

  /// No description provided for @map_view.
  ///
  /// In en, this message translates to:
  /// **'Map view'**
  String get map_view;

  /// No description provided for @compatibility.
  ///
  /// In en, this message translates to:
  /// **'Compatibility'**
  String get compatibility;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @no_locations_found.
  ///
  /// In en, this message translates to:
  /// **'No properties match your current filters.'**
  String get no_locations_found;

  /// No description provided for @hero_search_prefix.
  ///
  /// In en, this message translates to:
  /// **'Find the home you’ll'**
  String get hero_search_prefix;

  /// No description provided for @ticker_word_1.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get ticker_word_1;

  /// No description provided for @ticker_word_2.
  ///
  /// In en, this message translates to:
  /// **'Love'**
  String get ticker_word_2;

  /// No description provided for @ticker_word_3.
  ///
  /// In en, this message translates to:
  /// **'Matched'**
  String get ticker_word_3;

  /// No description provided for @login_agent_title.
  ///
  /// In en, this message translates to:
  /// **'Login as Agent'**
  String get login_agent_title;

  /// No description provided for @login_agent_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to your agent account'**
  String get login_agent_subtitle;

  /// No description provided for @login_admin_title.
  ///
  /// In en, this message translates to:
  /// **'Login as Admin'**
  String get login_admin_title;

  /// No description provided for @login_admin_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to your admin account'**
  String get login_admin_subtitle;

  /// No description provided for @login_agency_title.
  ///
  /// In en, this message translates to:
  /// **'Login as Agency'**
  String get login_agency_title;

  /// No description provided for @login_agency_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to your agency account'**
  String get login_agency_subtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgot_password;

  /// No description provided for @remember_me.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get remember_me;

  /// No description provided for @login_button.
  ///
  /// In en, this message translates to:
  /// **'LOG IN'**
  String get login_button;

  /// No description provided for @sign_in_with_google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get sign_in_with_google;

  /// No description provided for @sign_in_with_facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get sign_in_with_facebook;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @don_t_have_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get don_t_have_account;

  /// No description provided for @register_now.
  ///
  /// In en, this message translates to:
  /// **'Register now'**
  String get register_now;

  /// No description provided for @already_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get already_have_account;

  /// No description provided for @login_now.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login_now;

  /// No description provided for @full_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get full_name;

  /// No description provided for @full_name_hint.
  ///
  /// In en, this message translates to:
  /// **'First name - Last name'**
  String get full_name_hint;

  /// No description provided for @confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirm_password;

  /// No description provided for @agent_license_number.
  ///
  /// In en, this message translates to:
  /// **'License Number'**
  String get agent_license_number;

  /// No description provided for @agent_license_hint.
  ///
  /// In en, this message translates to:
  /// **'License number'**
  String get agent_license_hint;

  /// No description provided for @business_type.
  ///
  /// In en, this message translates to:
  /// **'Business Type'**
  String get business_type;

  /// No description provided for @business_type_hint.
  ///
  /// In en, this message translates to:
  /// **'Please select'**
  String get business_type_hint;

  /// No description provided for @company_name.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get company_name;

  /// No description provided for @company_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get company_name_hint;

  /// No description provided for @register_button.
  ///
  /// In en, this message translates to:
  /// **'REGISTER'**
  String get register_button;

  /// No description provided for @register_agent_title.
  ///
  /// In en, this message translates to:
  /// **'Register as Agent'**
  String get register_agent_title;

  /// No description provided for @register_admin_title.
  ///
  /// In en, this message translates to:
  /// **'Register as Admin'**
  String get register_admin_title;

  /// No description provided for @register_agency_title.
  ///
  /// In en, this message translates to:
  /// **'Register as Agency'**
  String get register_agency_title;

  /// No description provided for @thb.
  ///
  /// In en, this message translates to:
  /// **'THB'**
  String get thb;

  /// No description provided for @hero_slogan_part1.
  ///
  /// In en, this message translates to:
  /// **'A Good Life'**
  String get hero_slogan_part1;

  /// No description provided for @hero_slogan_part2.
  ///
  /// In en, this message translates to:
  /// **'A Good House For You'**
  String get hero_slogan_part2;

  /// No description provided for @hero_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Because we believe that a happy future starts with the right home'**
  String get hero_subtitle;

  /// No description provided for @select_role_title.
  ///
  /// In en, this message translates to:
  /// **'Select Your Role'**
  String get select_role_title;

  /// No description provided for @select_role_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to access the platform'**
  String get select_role_subtitle;

  /// No description provided for @enter_email.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get enter_email;

  /// No description provided for @enter_valid_email.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get enter_valid_email;

  /// No description provided for @enter_password.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get enter_password;

  /// No description provided for @password_length_error.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get password_length_error;

  /// No description provided for @sign_in_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Sign in cancelled'**
  String get sign_in_cancelled;

  /// No description provided for @enter_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get enter_name;

  /// No description provided for @confirm_password_hint.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirm_password_hint;

  /// No description provided for @enter_confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get enter_confirm_password;

  /// No description provided for @passwords_do_not_match.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwords_do_not_match;

  /// No description provided for @select_business_type.
  ///
  /// In en, this message translates to:
  /// **'Please select a business type'**
  String get select_business_type;

  /// No description provided for @enter_license_number.
  ///
  /// In en, this message translates to:
  /// **'Please enter your license number'**
  String get enter_license_number;

  /// No description provided for @enter_company_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter your company name'**
  String get enter_company_name;

  /// No description provided for @business_type_agency.
  ///
  /// In en, this message translates to:
  /// **'Real Estate Agency'**
  String get business_type_agency;

  /// No description provided for @business_type_developer.
  ///
  /// In en, this message translates to:
  /// **'Property Developer'**
  String get business_type_developer;

  /// No description provided for @business_type_independent.
  ///
  /// In en, this message translates to:
  /// **'Independent Agent'**
  String get business_type_independent;

  /// No description provided for @business_type_brokerage.
  ///
  /// In en, this message translates to:
  /// **'Brokerage Firm'**
  String get business_type_brokerage;

  /// No description provided for @role_agent.
  ///
  /// In en, this message translates to:
  /// **'For Agent'**
  String get role_agent;

  /// No description provided for @role_agency.
  ///
  /// In en, this message translates to:
  /// **'For Agency'**
  String get role_agency;

  /// No description provided for @role_admin.
  ///
  /// In en, this message translates to:
  /// **'For Admin'**
  String get role_admin;

  /// No description provided for @create_property.
  ///
  /// In en, this message translates to:
  /// **'Create Property'**
  String get create_property;

  /// No description provided for @create_property_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in the details below to create a new property listing'**
  String get create_property_subtitle;

  /// No description provided for @basic_information.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basic_information;

  /// No description provided for @specifications.
  ///
  /// In en, this message translates to:
  /// **'Specifications'**
  String get specifications;

  /// No description provided for @property_location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get property_location;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @built_date.
  ///
  /// In en, this message translates to:
  /// **'Built (YYYY-MM-DD)'**
  String get built_date;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @bedrooms_label.
  ///
  /// In en, this message translates to:
  /// **'Bedrooms'**
  String get bedrooms_label;

  /// No description provided for @bathrooms_label.
  ///
  /// In en, this message translates to:
  /// **'Bathrooms'**
  String get bathrooms_label;

  /// No description provided for @garage_spaces.
  ///
  /// In en, this message translates to:
  /// **'Garage Spaces'**
  String get garage_spaces;

  /// No description provided for @price_thb.
  ///
  /// In en, this message translates to:
  /// **'Price (THB)'**
  String get price_thb;

  /// No description provided for @land_size.
  ///
  /// In en, this message translates to:
  /// **'Land Size (sq.wa)'**
  String get land_size;

  /// No description provided for @building_size.
  ///
  /// In en, this message translates to:
  /// **'Building Size (sq.m)'**
  String get building_size;

  /// No description provided for @house_color.
  ///
  /// In en, this message translates to:
  /// **'House Color'**
  String get house_color;

  /// No description provided for @available_from.
  ///
  /// In en, this message translates to:
  /// **'Available From'**
  String get available_from;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @house_number.
  ///
  /// In en, this message translates to:
  /// **'House Number'**
  String get house_number;

  /// No description provided for @direction.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get direction;

  /// No description provided for @select_direction.
  ///
  /// In en, this message translates to:
  /// **'Select Direction (Optional)'**
  String get select_direction;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @postal_code.
  ///
  /// In en, this message translates to:
  /// **'Postal Code'**
  String get postal_code;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @property_location_title.
  ///
  /// In en, this message translates to:
  /// **'Property Location'**
  String get property_location_title;

  /// No description provided for @property_location_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Click on the map or use your current location to set the property location.'**
  String get property_location_subtitle;

  /// No description provided for @use_current_location.
  ///
  /// In en, this message translates to:
  /// **'Use Current Location'**
  String get use_current_location;

  /// No description provided for @clear_location.
  ///
  /// In en, this message translates to:
  /// **'Clear Location'**
  String get clear_location;

  /// No description provided for @set_by_map.
  ///
  /// In en, this message translates to:
  /// **'Set by clicking on the map'**
  String get set_by_map;

  /// No description provided for @click_to_upload.
  ///
  /// In en, this message translates to:
  /// **'Click to upload'**
  String get click_to_upload;

  /// No description provided for @or_drag_drop.
  ///
  /// In en, this message translates to:
  /// **'or drag and drop'**
  String get or_drag_drop;

  /// No description provided for @image_format_note.
  ///
  /// In en, this message translates to:
  /// **'JPEG/PNG/WebP up to 5MB each'**
  String get image_format_note;

  /// No description provided for @take_photo.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get take_photo;

  /// No description provided for @use_camera.
  ///
  /// In en, this message translates to:
  /// **'Use your device camera to capture photos'**
  String get use_camera;

  /// No description provided for @selected_photos.
  ///
  /// In en, this message translates to:
  /// **'Selected Photos'**
  String get selected_photos;

  /// No description provided for @photo_count.
  ///
  /// In en, this message translates to:
  /// **'{count} photo(s) selected'**
  String photo_count(Object count);

  /// No description provided for @clear_all.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clear_all;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create Property'**
  String get create;

  /// No description provided for @property_created_success.
  ///
  /// In en, this message translates to:
  /// **'Property created successfully!'**
  String get property_created_success;

  /// No description provided for @error_creating_property.
  ///
  /// In en, this message translates to:
  /// **'Error creating property'**
  String get error_creating_property;

  /// No description provided for @error_picking_images.
  ///
  /// In en, this message translates to:
  /// **'Error picking images'**
  String get error_picking_images;

  /// No description provided for @this_field_required.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get this_field_required;

  /// No description provided for @please_enter_valid_number.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get please_enter_valid_number;

  /// No description provided for @north.
  ///
  /// In en, this message translates to:
  /// **'North'**
  String get north;

  /// No description provided for @northeast.
  ///
  /// In en, this message translates to:
  /// **'Northeast'**
  String get northeast;

  /// No description provided for @east.
  ///
  /// In en, this message translates to:
  /// **'East'**
  String get east;

  /// No description provided for @southeast.
  ///
  /// In en, this message translates to:
  /// **'Southeast'**
  String get southeast;

  /// No description provided for @south.
  ///
  /// In en, this message translates to:
  /// **'South'**
  String get south;

  /// No description provided for @southwest.
  ///
  /// In en, this message translates to:
  /// **'Southwest'**
  String get southwest;

  /// No description provided for @west.
  ///
  /// In en, this message translates to:
  /// **'West'**
  String get west;

  /// No description provided for @northwest.
  ///
  /// In en, this message translates to:
  /// **'Northwest'**
  String get northwest;

  /// No description provided for @property_type_house.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get property_type_house;

  /// No description provided for @property_type_condominium.
  ///
  /// In en, this message translates to:
  /// **'Condominium'**
  String get property_type_condominium;

  /// No description provided for @property_type_townhouse.
  ///
  /// In en, this message translates to:
  /// **'Townhouse'**
  String get property_type_townhouse;

  /// No description provided for @property_type_villa.
  ///
  /// In en, this message translates to:
  /// **'Villa'**
  String get property_type_villa;

  /// No description provided for @property_type_duplex.
  ///
  /// In en, this message translates to:
  /// **'Duplex'**
  String get property_type_duplex;

  /// No description provided for @property_type_penthouse.
  ///
  /// In en, this message translates to:
  /// **'Penthouse'**
  String get property_type_penthouse;

  /// No description provided for @property_type_studio.
  ///
  /// In en, this message translates to:
  /// **'Studio'**
  String get property_type_studio;

  /// No description provided for @property_type_commercial.
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get property_type_commercial;

  /// No description provided for @property_type_land.
  ///
  /// In en, this message translates to:
  /// **'Land'**
  String get property_type_land;

  /// No description provided for @property_type_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get property_type_other;

  /// No description provided for @status_available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get status_available;

  /// No description provided for @status_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get status_pending;

  /// No description provided for @status_sold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get status_sold;

  /// No description provided for @color_white.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get color_white;

  /// No description provided for @color_brown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get color_brown;

  /// No description provided for @color_gray.
  ///
  /// In en, this message translates to:
  /// **'Gray'**
  String get color_gray;

  /// No description provided for @color_red.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get color_red;

  /// No description provided for @color_orange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get color_orange;

  /// No description provided for @color_purple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get color_purple;

  /// No description provided for @color_gold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get color_gold;

  /// No description provided for @color_blue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get color_blue;

  /// No description provided for @color_black.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get color_black;

  /// No description provided for @color_yellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get color_yellow;

  /// No description provided for @color_green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get color_green;

  /// No description provided for @color_silver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get color_silver;

  /// No description provided for @edit_property.
  ///
  /// In en, this message translates to:
  /// **'Edit Property'**
  String get edit_property;

  /// No description provided for @edit_property_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Update the details below to modify your property listing'**
  String get edit_property_subtitle;

  /// No description provided for @current_photos.
  ///
  /// In en, this message translates to:
  /// **'Current Photos'**
  String get current_photos;

  /// No description provided for @new_photos_to_add.
  ///
  /// In en, this message translates to:
  /// **'New Photos to Add'**
  String get new_photos_to_add;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @property_updated_success.
  ///
  /// In en, this message translates to:
  /// **'Property updated successfully!'**
  String get property_updated_success;

  /// No description provided for @error_updating_property.
  ///
  /// In en, this message translates to:
  /// **'Error updating property'**
  String get error_updating_property;

  /// No description provided for @add_available_time_slot.
  ///
  /// In en, this message translates to:
  /// **'Add Available Time Slot'**
  String get add_available_time_slot;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @start_time.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get start_time;

  /// No description provided for @end_time.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get end_time;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @end_time_must_be_after_start_time.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time'**
  String get end_time_must_be_after_start_time;

  /// No description provided for @availability_created_success.
  ///
  /// In en, this message translates to:
  /// **'Available time created successfully!'**
  String get availability_created_success;

  /// No description provided for @error_creating_availability.
  ///
  /// In en, this message translates to:
  /// **'Error creating available time'**
  String get error_creating_availability;

  /// No description provided for @home_details_title.
  ///
  /// In en, this message translates to:
  /// **'Home Details'**
  String get home_details_title;

  /// No description provided for @furniture_status_label.
  ///
  /// In en, this message translates to:
  /// **'Furniture Status'**
  String get furniture_status_label;

  /// No description provided for @furniture_full.
  ///
  /// In en, this message translates to:
  /// **'Fully furnished'**
  String get furniture_full;

  /// No description provided for @furniture_full_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Fully decorated, ready to move in'**
  String get furniture_full_subtitle;

  /// No description provided for @sale_status_label.
  ///
  /// In en, this message translates to:
  /// **'Sale Status'**
  String get sale_status_label;

  /// No description provided for @sale_ready.
  ///
  /// In en, this message translates to:
  /// **'Ready to transfer'**
  String get sale_ready;

  /// No description provided for @sale_ready_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete documents, ready to transfer immediately'**
  String get sale_ready_subtitle;

  /// No description provided for @area_label.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area_label;

  /// No description provided for @ownership_label.
  ///
  /// In en, this message translates to:
  /// **'Ownership type'**
  String get ownership_label;

  /// No description provided for @ownership_transfer.
  ///
  /// In en, this message translates to:
  /// **'Freehold'**
  String get ownership_transfer;

  /// No description provided for @direction_label.
  ///
  /// In en, this message translates to:
  /// **'House direction'**
  String get direction_label;

  /// No description provided for @house_age_label.
  ///
  /// In en, this message translates to:
  /// **'House age'**
  String get house_age_label;

  /// No description provided for @not_specified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get not_specified;

  /// No description provided for @feature_floors_label.
  ///
  /// In en, this message translates to:
  /// **'Floors'**
  String get feature_floors_label;

  /// No description provided for @feature_bedrooms_label.
  ///
  /// In en, this message translates to:
  /// **'Bedrooms'**
  String get feature_bedrooms_label;

  /// No description provided for @feature_bathrooms_label.
  ///
  /// In en, this message translates to:
  /// **'Bathrooms'**
  String get feature_bathrooms_label;

  /// No description provided for @feature_parking_label.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get feature_parking_label;

  /// No description provided for @parking_count.
  ///
  /// In en, this message translates to:
  /// **'{count} parking spot(s)'**
  String parking_count(Object count);

  /// No description provided for @more_details_title.
  ///
  /// In en, this message translates to:
  /// **'Additional Details'**
  String get more_details_title;

  /// No description provided for @more_details_description.
  ///
  /// In en, this message translates to:
  /// **'Beautiful single house in a prime location, close to BTS, shopping malls, hospitals, and schools. Suitable for both living and investment.'**
  String get more_details_description;

  /// No description provided for @show_more.
  ///
  /// In en, this message translates to:
  /// **'See more'**
  String get show_more;

  /// No description provided for @show_less.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get show_less;

  /// No description provided for @nearby_title.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get nearby_title;

  /// No description provided for @nearby_travel.
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get nearby_travel;

  /// No description provided for @nearby_shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping & Retail'**
  String get nearby_shopping;

  /// No description provided for @nearby_education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get nearby_education;

  /// No description provided for @nearby_item_bus_stop.
  ///
  /// In en, this message translates to:
  /// **'Bus stop'**
  String get nearby_item_bus_stop;

  /// No description provided for @nearby_item_bts_ari.
  ///
  /// In en, this message translates to:
  /// **'BTS Ari'**
  String get nearby_item_bts_ari;

  /// No description provided for @nearby_item_mrt_phahonyothin.
  ///
  /// In en, this message translates to:
  /// **'MRT Phahon Yothin'**
  String get nearby_item_mrt_phahonyothin;

  /// No description provided for @nearby_item_7eleven.
  ///
  /// In en, this message translates to:
  /// **'7-Eleven'**
  String get nearby_item_7eleven;

  /// No description provided for @nearby_item_big_c_extra.
  ///
  /// In en, this message translates to:
  /// **'Big C Extra'**
  String get nearby_item_big_c_extra;

  /// No description provided for @nearby_item_central_plaza.
  ///
  /// In en, this message translates to:
  /// **'Central Plaza'**
  String get nearby_item_central_plaza;

  /// No description provided for @nearby_item_demo_school.
  ///
  /// In en, this message translates to:
  /// **'Demonstration School'**
  String get nearby_item_demo_school;

  /// No description provided for @sort_by_compatibility.
  ///
  /// In en, this message translates to:
  /// **'Sort by compatibility high to low'**
  String get sort_by_compatibility;

  /// No description provided for @sort_by_price_low_to_high.
  ///
  /// In en, this message translates to:
  /// **'Sort by price low to high'**
  String get sort_by_price_low_to_high;

  /// No description provided for @sort_by_price_high_to_low.
  ///
  /// In en, this message translates to:
  /// **'Sort by price high to low'**
  String get sort_by_price_high_to_low;

  /// No description provided for @sort_by_newest.
  ///
  /// In en, this message translates to:
  /// **'Sort by newest listings'**
  String get sort_by_newest;

  /// No description provided for @parking_spaces.
  ///
  /// In en, this message translates to:
  /// **'Parking spaces'**
  String get parking_spaces;

  /// No description provided for @usable_area.
  ///
  /// In en, this message translates to:
  /// **'Usable area'**
  String get usable_area;

  /// No description provided for @area_less_than_30.
  ///
  /// In en, this message translates to:
  /// **'Less than 30 sqm'**
  String get area_less_than_30;

  /// No description provided for @area_30_50.
  ///
  /// In en, this message translates to:
  /// **'30 - 50 sqm'**
  String get area_30_50;

  /// No description provided for @area_50_100.
  ///
  /// In en, this message translates to:
  /// **'50 - 100 sqm'**
  String get area_50_100;

  /// No description provided for @area_100_1000.
  ///
  /// In en, this message translates to:
  /// **'100 - 1,000 sqm'**
  String get area_100_1000;

  /// No description provided for @area_1000_5000.
  ///
  /// In en, this message translates to:
  /// **'1,000 - 5,000 sqm'**
  String get area_1000_5000;

  /// No description provided for @area_more_than_5000.
  ///
  /// In en, this message translates to:
  /// **'More than 5,000 sqm'**
  String get area_more_than_5000;

  /// No description provided for @five_or_more.
  ///
  /// In en, this message translates to:
  /// **'≥5'**
  String get five_or_more;

  /// No description provided for @voice_location_prompt.
  ///
  /// In en, this message translates to:
  /// **'Please say the location name you want to search, for example, Bangna'**
  String get voice_location_prompt;

  /// No description provided for @voice_budget_min_prompt.
  ///
  /// In en, this message translates to:
  /// **'Please say the minimum budget, for example, 3 million or 3000000'**
  String get voice_budget_min_prompt;

  /// No description provided for @voice_budget_max_prompt.
  ///
  /// In en, this message translates to:
  /// **'Please say the maximum budget, for example, 5 million or 5000000'**
  String get voice_budget_max_prompt;

  /// No description provided for @voice_property_type_prompt.
  ///
  /// In en, this message translates to:
  /// **'Please say the property type, for example, house or condo'**
  String get voice_property_type_prompt;

  /// No description provided for @voice_member_name_prompt.
  ///
  /// In en, this message translates to:
  /// **'What is your name?'**
  String get voice_member_name_prompt;

  /// No description provided for @voice_member_dob_prompt.
  ///
  /// In en, this message translates to:
  /// **'When is your birthdate? Please say as day month year, for example, 01 01 1990'**
  String get voice_member_dob_prompt;

  /// No description provided for @voice_member_gender_prompt.
  ///
  /// In en, this message translates to:
  /// **'What is your gender? For example, male or female'**
  String get voice_member_gender_prompt;

  /// No description provided for @voice_member_phone_prompt.
  ///
  /// In en, this message translates to:
  /// **'What is your phone number? Please say as numbers'**
  String get voice_member_phone_prompt;

  /// No description provided for @voice_member_car_plate_prompt.
  ///
  /// In en, this message translates to:
  /// **'What is your license plate number? You can say as numbers'**
  String get voice_member_car_plate_prompt;

  /// No description provided for @voice_member_weight_prompt.
  ///
  /// In en, this message translates to:
  /// **'How important is this member? What percentage? For example, 50'**
  String get voice_member_weight_prompt;

  /// No description provided for @voice_input_title.
  ///
  /// In en, this message translates to:
  /// **'Voice Input'**
  String get voice_input_title;

  /// No description provided for @voice_listening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get voice_listening;

  /// No description provided for @voice_speaking.
  ///
  /// In en, this message translates to:
  /// **'Speaking...'**
  String get voice_speaking;

  /// No description provided for @voice_listening_to_you.
  ///
  /// In en, this message translates to:
  /// **'Listening to you...'**
  String get voice_listening_to_you;

  /// No description provided for @voice_waiting_response.
  ///
  /// In en, this message translates to:
  /// **'Waiting for response...'**
  String get voice_waiting_response;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'Copyright © 2025 youragent.site'**
  String get copyright;

  /// No description provided for @terms_and_conditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get terms_and_conditions;

  /// No description provided for @privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy;

  /// No description provided for @reserved_rights.
  ///
  /// In en, this message translates to:
  /// **'Reserved Rights'**
  String get reserved_rights;

  /// No description provided for @logout_title.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout_title;

  /// No description provided for @logout_message.
  ///
  /// In en, this message translates to:
  /// **'Do you want to log out?'**
  String get logout_message;

  /// No description provided for @logout_button.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout_button;

  /// No description provided for @cancel_button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel_button;

  /// No description provided for @notifications_title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications_title;

  /// No description provided for @read_all.
  ///
  /// In en, this message translates to:
  /// **'Read All'**
  String get read_all;

  /// No description provided for @no_notifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get no_notifications;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @minutes_ago.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String minutes_ago(Object count);

  /// No description provided for @hours_ago.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String hours_ago(Object count);

  /// No description provided for @days_ago.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String days_ago(Object count);

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @my_properties.
  ///
  /// In en, this message translates to:
  /// **'My Properties'**
  String get my_properties;

  /// No description provided for @create_property_button.
  ///
  /// In en, this message translates to:
  /// **'+ Create Property'**
  String get create_property_button;

  /// No description provided for @availability_calendar_view.
  ///
  /// In en, this message translates to:
  /// **'Calendar View'**
  String get availability_calendar_view;

  /// No description provided for @availability_count_available.
  ///
  /// In en, this message translates to:
  /// **'{count} available times'**
  String availability_count_available(Object count);

  /// No description provided for @profile_bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get profile_bio;

  /// No description provided for @profile_languages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get profile_languages;

  /// No description provided for @profile_experience.
  ///
  /// In en, this message translates to:
  /// **'Years of Experience'**
  String get profile_experience;

  /// No description provided for @profile_company.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get profile_company;

  /// No description provided for @profile_license.
  ///
  /// In en, this message translates to:
  /// **'License Number'**
  String get profile_license;

  /// No description provided for @profile_radius.
  ///
  /// In en, this message translates to:
  /// **'Service Radius'**
  String get profile_radius;

  /// No description provided for @profile_service_area.
  ///
  /// In en, this message translates to:
  /// **'Service Area Center'**
  String get profile_service_area;

  /// No description provided for @profile_not_set.
  ///
  /// In en, this message translates to:
  /// **'Not Set'**
  String get profile_not_set;

  /// No description provided for @profile_agent_code.
  ///
  /// In en, this message translates to:
  /// **'Agent Connection Code'**
  String get profile_agent_code;

  /// No description provided for @profile_share_code_desc.
  ///
  /// In en, this message translates to:
  /// **'Share this code with an agency so they can add you to their portfolio. This code can only be used once.'**
  String get profile_share_code_desc;

  /// No description provided for @profile_copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get profile_copy;

  /// No description provided for @profile_professional_info.
  ///
  /// In en, this message translates to:
  /// **'Professional Information'**
  String get profile_professional_info;

  /// No description provided for @available_times_title.
  ///
  /// In en, this message translates to:
  /// **'Available Times'**
  String get available_times_title;

  /// No description provided for @available_times_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your available time slots'**
  String get available_times_subtitle;

  /// No description provided for @calendar_view.
  ///
  /// In en, this message translates to:
  /// **'Calendar View'**
  String get calendar_view;

  /// No description provided for @add_time_slot.
  ///
  /// In en, this message translates to:
  /// **'Add Time Slot'**
  String get add_time_slot;

  /// No description provided for @start_date.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get start_date;

  /// No description provided for @end_date.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get end_date;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @no_available_times.
  ///
  /// In en, this message translates to:
  /// **'No available times'**
  String get no_available_times;

  /// No description provided for @no_available_times_hint.
  ///
  /// In en, this message translates to:
  /// **'Start by creating a new time slot'**
  String get no_available_times_hint;

  /// No description provided for @status_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get status_unavailable;

  /// No description provided for @back_to_availability.
  ///
  /// In en, this message translates to:
  /// **'← Back to Available Times'**
  String get back_to_availability;

  /// No description provided for @availability_tips_title.
  ///
  /// In en, this message translates to:
  /// **'Tips for setting availability'**
  String get availability_tips_title;

  /// No description provided for @tip_no_overlap.
  ///
  /// In en, this message translates to:
  /// **'You cannot create overlapping time slots on the same day'**
  String get tip_no_overlap;

  /// No description provided for @tip_no_past_dates.
  ///
  /// In en, this message translates to:
  /// **'Cannot set time slots for past dates'**
  String get tip_no_past_dates;

  /// No description provided for @tip_end_after_start.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time'**
  String get tip_end_after_start;

  /// No description provided for @tip_consider_schedule.
  ///
  /// In en, this message translates to:
  /// **'Consider your schedule when setting availability'**
  String get tip_consider_schedule;

  /// No description provided for @create_time_slot.
  ///
  /// In en, this message translates to:
  /// **'Create Time Slot'**
  String get create_time_slot;

  /// No description provided for @delete_time_slot.
  ///
  /// In en, this message translates to:
  /// **'Delete Time Slot'**
  String get delete_time_slot;

  /// No description provided for @delete_time_slot_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this time slot?'**
  String get delete_time_slot_confirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @time_slot_deleted.
  ///
  /// In en, this message translates to:
  /// **'Time slot deleted successfully'**
  String get time_slot_deleted;

  /// No description provided for @list_view_button.
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get list_view_button;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @login_error.
  ///
  /// In en, this message translates to:
  /// **'Login Error'**
  String get login_error;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @confirm_delete_property.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this property?'**
  String get confirm_delete_property;

  /// No description provided for @confirm_create_property.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to create this property?'**
  String get confirm_create_property;

  /// No description provided for @confirm_update_property.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to update this property?'**
  String get confirm_update_property;

  /// No description provided for @confirm_delete_contract.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this contract?'**
  String get confirm_delete_contract;

  /// No description provided for @property_deleted_success.
  ///
  /// In en, this message translates to:
  /// **'Property deleted successfully'**
  String get property_deleted_success;

  /// No description provided for @error_deleting_property.
  ///
  /// In en, this message translates to:
  /// **'Error deleting property'**
  String get error_deleting_property;

  /// No description provided for @contract_deleted_success.
  ///
  /// In en, this message translates to:
  /// **'Contract deleted successfully'**
  String get contract_deleted_success;

  /// No description provided for @error_deleting_contract.
  ///
  /// In en, this message translates to:
  /// **'Error deleting contract'**
  String get error_deleting_contract;

  /// No description provided for @error_deleting.
  ///
  /// In en, this message translates to:
  /// **'Error deleting'**
  String get error_deleting;

  /// No description provided for @general_information.
  ///
  /// In en, this message translates to:
  /// **'General Information'**
  String get general_information;

  /// No description provided for @property_location_section.
  ///
  /// In en, this message translates to:
  /// **'Property Location'**
  String get property_location_section;

  /// No description provided for @property_details_section.
  ///
  /// In en, this message translates to:
  /// **'Property Details'**
  String get property_details_section;

  /// No description provided for @additional_details_section.
  ///
  /// In en, this message translates to:
  /// **'Additional Details'**
  String get additional_details_section;

  /// No description provided for @property_images_section.
  ///
  /// In en, this message translates to:
  /// **'Property Images'**
  String get property_images_section;

  /// No description provided for @lessor_information.
  ///
  /// In en, this message translates to:
  /// **'Lessor Information'**
  String get lessor_information;

  /// No description provided for @lessee_information.
  ///
  /// In en, this message translates to:
  /// **'Lessee Information'**
  String get lessee_information;

  /// No description provided for @rental_property_information.
  ///
  /// In en, this message translates to:
  /// **'Rental Property Information'**
  String get rental_property_information;

  /// No description provided for @lease_period.
  ///
  /// In en, this message translates to:
  /// **'Lease Period'**
  String get lease_period;

  /// No description provided for @rental_fee_and_payment.
  ///
  /// In en, this message translates to:
  /// **'Rental Fee and Payment'**
  String get rental_fee_and_payment;

  /// No description provided for @terms_and_conditions_section.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get terms_and_conditions_section;

  /// No description provided for @signature.
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get signature;

  /// No description provided for @create_rental_contract.
  ///
  /// In en, this message translates to:
  /// **'Create Rental Contract'**
  String get create_rental_contract;

  /// No description provided for @electrical_appliances_photos.
  ///
  /// In en, this message translates to:
  /// **'Electrical Appliances Photos (Please specify)'**
  String get electrical_appliances_photos;

  /// No description provided for @furniture_photos.
  ///
  /// In en, this message translates to:
  /// **'Furniture Photos (Please specify)'**
  String get furniture_photos;

  /// No description provided for @properties.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get properties;

  /// No description provided for @appointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointments;

  /// No description provided for @confirm_cancel.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel? All unsaved changes will be lost.'**
  String get confirm_cancel;

  /// No description provided for @confirm_cancel_create.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel? All entered data will be lost.'**
  String get confirm_cancel_create;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @confirmation_and_signature.
  ///
  /// In en, this message translates to:
  /// **'Confirmation and Signature'**
  String get confirmation_and_signature;

  /// No description provided for @contract_number.
  ///
  /// In en, this message translates to:
  /// **'Contract Number'**
  String get contract_number;

  /// No description provided for @contract_type.
  ///
  /// In en, this message translates to:
  /// **'Contract Type'**
  String get contract_type;

  /// No description provided for @rental_contract.
  ///
  /// In en, this message translates to:
  /// **'Rental Contract'**
  String get rental_contract;

  /// No description provided for @general_rental_contract.
  ///
  /// In en, this message translates to:
  /// **'General Rental Contract'**
  String get general_rental_contract;

  /// No description provided for @purchase_sale_contract.
  ///
  /// In en, this message translates to:
  /// **'Purchase and Sale Contract'**
  String get purchase_sale_contract;

  /// No description provided for @contract_date.
  ///
  /// In en, this message translates to:
  /// **'Contract Date'**
  String get contract_date;

  /// No description provided for @create_new_account.
  ///
  /// In en, this message translates to:
  /// **'Create New Account'**
  String get create_new_account;

  /// No description provided for @individual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get individual;

  /// No description provided for @juristic_person.
  ///
  /// In en, this message translates to:
  /// **'Juristic Person'**
  String get juristic_person;

  /// No description provided for @full_name_or_company.
  ///
  /// In en, this message translates to:
  /// **'Full Name / Company Name'**
  String get full_name_or_company;

  /// No description provided for @enter_full_name.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get enter_full_name;

  /// No description provided for @id_card_or_tax_id.
  ///
  /// In en, this message translates to:
  /// **'ID Card / Tax ID'**
  String get id_card_or_tax_id;

  /// No description provided for @enter_id_card.
  ///
  /// In en, this message translates to:
  /// **'Enter ID card number'**
  String get enter_id_card;

  /// No description provided for @authorized_signatory.
  ///
  /// In en, this message translates to:
  /// **'Authorized Signatory'**
  String get authorized_signatory;

  /// No description provided for @property_type_label.
  ///
  /// In en, this message translates to:
  /// **'Property Type'**
  String get property_type_label;

  /// No description provided for @select_property_type.
  ///
  /// In en, this message translates to:
  /// **'Select property type'**
  String get select_property_type;

  /// No description provided for @condominium.
  ///
  /// In en, this message translates to:
  /// **'Condominium'**
  String get condominium;

  /// No description provided for @single_house.
  ///
  /// In en, this message translates to:
  /// **'Single House'**
  String get single_house;

  /// No description provided for @project_name.
  ///
  /// In en, this message translates to:
  /// **'Project Name'**
  String get project_name;

  /// No description provided for @house_or_room_number.
  ///
  /// In en, this message translates to:
  /// **'House/Room Number'**
  String get house_or_room_number;

  /// No description provided for @floor_label.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get floor_label;

  /// No description provided for @soi_alley_village.
  ///
  /// In en, this message translates to:
  /// **'Soi/Alley/Village (if any)'**
  String get soi_alley_village;

  /// No description provided for @road_if_any.
  ///
  /// In en, this message translates to:
  /// **'Road (if any)'**
  String get road_if_any;

  /// No description provided for @select_country.
  ///
  /// In en, this message translates to:
  /// **'Select country'**
  String get select_country;

  /// No description provided for @select_province.
  ///
  /// In en, this message translates to:
  /// **'Select province'**
  String get select_province;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @select_district.
  ///
  /// In en, this message translates to:
  /// **'Select district'**
  String get select_district;

  /// No description provided for @subdistrict.
  ///
  /// In en, this message translates to:
  /// **'Sub-district'**
  String get subdistrict;

  /// No description provided for @select_subdistrict.
  ///
  /// In en, this message translates to:
  /// **'Select sub-district'**
  String get select_subdistrict;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @no_images.
  ///
  /// In en, this message translates to:
  /// **'No images'**
  String get no_images;

  /// No description provided for @add_item.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get add_item;

  /// No description provided for @contract_start_date.
  ///
  /// In en, this message translates to:
  /// **'Contract Start Date'**
  String get contract_start_date;

  /// No description provided for @select_date.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get select_date;

  /// No description provided for @contract_end_date.
  ///
  /// In en, this message translates to:
  /// **'Contract End Date'**
  String get contract_end_date;

  /// No description provided for @lease_renewal_format.
  ///
  /// In en, this message translates to:
  /// **'Lease Renewal Format'**
  String get lease_renewal_format;

  /// No description provided for @select_renewal_format.
  ///
  /// In en, this message translates to:
  /// **'Select renewal format'**
  String get select_renewal_format;

  /// No description provided for @renewal_conditions.
  ///
  /// In en, this message translates to:
  /// **'Renewal Conditions'**
  String get renewal_conditions;

  /// No description provided for @rental_fee.
  ///
  /// In en, this message translates to:
  /// **'Rental Fee'**
  String get rental_fee;

  /// No description provided for @common_fee.
  ///
  /// In en, this message translates to:
  /// **'Common Fee'**
  String get common_fee;

  /// No description provided for @other_service_fee.
  ///
  /// In en, this message translates to:
  /// **'Other Service Fee'**
  String get other_service_fee;

  /// No description provided for @total_monthly_payment.
  ///
  /// In en, this message translates to:
  /// **'Total Monthly Payment'**
  String get total_monthly_payment;

  /// No description provided for @advance_rental.
  ///
  /// In en, this message translates to:
  /// **'Advance Rental'**
  String get advance_rental;

  /// No description provided for @damage_deposit.
  ///
  /// In en, this message translates to:
  /// **'Damage Deposit'**
  String get damage_deposit;

  /// No description provided for @total_payment_before_move_in.
  ///
  /// In en, this message translates to:
  /// **'Total Payment Before Move In'**
  String get total_payment_before_move_in;

  /// No description provided for @payment_due_date.
  ///
  /// In en, this message translates to:
  /// **'Payment Due Date'**
  String get payment_due_date;

  /// No description provided for @of_every_month.
  ///
  /// In en, this message translates to:
  /// **'of every month'**
  String get of_every_month;

  /// No description provided for @water_fee.
  ///
  /// In en, this message translates to:
  /// **'Water Fee'**
  String get water_fee;

  /// No description provided for @per_unit.
  ///
  /// In en, this message translates to:
  /// **'per unit'**
  String get per_unit;

  /// No description provided for @payment_channel.
  ///
  /// In en, this message translates to:
  /// **'Payment Channel'**
  String get payment_channel;

  /// No description provided for @select_payment_channel.
  ///
  /// In en, this message translates to:
  /// **'Select payment channel'**
  String get select_payment_channel;

  /// No description provided for @branch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get branch;

  /// No description provided for @account_name.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get account_name;

  /// No description provided for @account_number.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get account_number;

  /// No description provided for @additional_conditions_optional.
  ///
  /// In en, this message translates to:
  /// **'Additional Conditions (Optional)'**
  String get additional_conditions_optional;

  /// No description provided for @additional_conditions.
  ///
  /// In en, this message translates to:
  /// **'Additional conditions'**
  String get additional_conditions;

  /// No description provided for @lessee.
  ///
  /// In en, this message translates to:
  /// **'Lessee'**
  String get lessee;

  /// No description provided for @lessor.
  ///
  /// In en, this message translates to:
  /// **'Lessor'**
  String get lessor;

  /// No description provided for @test_system.
  ///
  /// In en, this message translates to:
  /// **'Test System'**
  String get test_system;

  /// No description provided for @property_owner.
  ///
  /// In en, this message translates to:
  /// **'Property Owner'**
  String get property_owner;

  /// No description provided for @sq_wa.
  ///
  /// In en, this message translates to:
  /// **'sq.wa'**
  String get sq_wa;

  /// No description provided for @sq_m.
  ///
  /// In en, this message translates to:
  /// **'sq.m'**
  String get sq_m;

  /// No description provided for @baht_per_month.
  ///
  /// In en, this message translates to:
  /// **'THB/month'**
  String get baht_per_month;

  /// No description provided for @baht.
  ///
  /// In en, this message translates to:
  /// **'THB'**
  String get baht;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get months;

  /// No description provided for @items_per_page.
  ///
  /// In en, this message translates to:
  /// **'Items per page'**
  String get items_per_page;

  /// No description provided for @dashboard_overview.
  ///
  /// In en, this message translates to:
  /// **'Dashboard Overview'**
  String get dashboard_overview;

  /// No description provided for @contracts.
  ///
  /// In en, this message translates to:
  /// **'Contracts'**
  String get contracts;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit_profile;

  /// No description provided for @legal_entity.
  ///
  /// In en, this message translates to:
  /// **'Legal Entity'**
  String get legal_entity;

  /// No description provided for @residential_lease.
  ///
  /// In en, this message translates to:
  /// **'Residential Lease'**
  String get residential_lease;

  /// No description provided for @commercial_lease.
  ///
  /// In en, this message translates to:
  /// **'Commercial Lease'**
  String get commercial_lease;

  /// No description provided for @select_status.
  ///
  /// In en, this message translates to:
  /// **'Select Status'**
  String get select_status;

  /// No description provided for @select_color.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get select_color;

  /// No description provided for @select_type.
  ///
  /// In en, this message translates to:
  /// **'Select Type'**
  String get select_type;

  /// No description provided for @upload_at_least_one_image.
  ///
  /// In en, this message translates to:
  /// **'Please upload at least 1 image'**
  String get upload_at_least_one_image;

  /// No description provided for @images_added.
  ///
  /// In en, this message translates to:
  /// **'Added {count} images'**
  String images_added(Object count);

  /// No description provided for @select_file.
  ///
  /// In en, this message translates to:
  /// **'Select Your File'**
  String get select_file;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @property_not_found.
  ///
  /// In en, this message translates to:
  /// **'Property not found'**
  String get property_not_found;

  /// No description provided for @no_profile_data.
  ///
  /// In en, this message translates to:
  /// **'No profile data'**
  String get no_profile_data;

  /// No description provided for @new_ticket.
  ///
  /// In en, this message translates to:
  /// **'New Ticket'**
  String get new_ticket;

  /// No description provided for @send_reply.
  ///
  /// In en, this message translates to:
  /// **'Send Reply'**
  String get send_reply;

  /// No description provided for @add_floor_plan.
  ///
  /// In en, this message translates to:
  /// **'Add Floor Plan'**
  String get add_floor_plan;

  /// No description provided for @view_floor_plan.
  ///
  /// In en, this message translates to:
  /// **'View Floor Plan'**
  String get view_floor_plan;

  /// No description provided for @back_to_login.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get back_to_login;

  /// No description provided for @bookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookings;

  /// No description provided for @chats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chats;

  /// No description provided for @time_slots.
  ///
  /// In en, this message translates to:
  /// **'Time Slots'**
  String get time_slots;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @search_contract_number.
  ///
  /// In en, this message translates to:
  /// **'Search contract number'**
  String get search_contract_number;

  /// No description provided for @search_property_name.
  ///
  /// In en, this message translates to:
  /// **'Search property name'**
  String get search_property_name;

  /// No description provided for @search_lessor.
  ///
  /// In en, this message translates to:
  /// **'Search lessor'**
  String get search_lessor;

  /// No description provided for @search_lessee.
  ///
  /// In en, this message translates to:
  /// **'Search lessee'**
  String get search_lessee;

  /// No description provided for @select_contract_status.
  ///
  /// In en, this message translates to:
  /// **'Select contract status'**
  String get select_contract_status;

  /// No description provided for @select_property_type_contract.
  ///
  /// In en, this message translates to:
  /// **'Select property type'**
  String get select_property_type_contract;

  /// No description provided for @contract_status_incomplete.
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get contract_status_incomplete;

  /// No description provided for @contract_status_complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get contract_status_complete;

  /// No description provided for @month_january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get month_january;

  /// No description provided for @month_february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get month_february;

  /// No description provided for @month_march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get month_march;

  /// No description provided for @month_april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get month_april;

  /// No description provided for @month_may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get month_may;

  /// No description provided for @month_june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get month_june;

  /// No description provided for @month_july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get month_july;

  /// No description provided for @month_august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get month_august;

  /// No description provided for @month_september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get month_september;

  /// No description provided for @month_october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get month_october;

  /// No description provided for @month_november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get month_november;

  /// No description provided for @month_december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get month_december;

  /// No description provided for @email_not_verified.
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get email_not_verified;

  /// No description provided for @full_name_label.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get full_name_label;

  /// No description provided for @email_address.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get email_address;

  /// No description provided for @mobile_number.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobile_number;

  /// No description provided for @personal_info.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personal_info;

  /// No description provided for @account_info.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get account_info;

  /// No description provided for @member_since.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get member_since;

  /// No description provided for @last_updated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get last_updated;

  /// No description provided for @account_status_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get account_status_active;

  /// No description provided for @account_status.
  ///
  /// In en, this message translates to:
  /// **'Account Status'**
  String get account_status;

  /// No description provided for @years_suffix.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years_suffix;

  /// No description provided for @my_profile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get my_profile;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @day_sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get day_sun;

  /// No description provided for @day_mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get day_mon;

  /// No description provided for @day_tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get day_tue;

  /// No description provided for @day_wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get day_wed;

  /// No description provided for @day_thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get day_thu;

  /// No description provided for @day_fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get day_fri;

  /// No description provided for @day_sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get day_sat;

  /// No description provided for @legend.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get legend;

  /// No description provided for @error_occurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get error_occurred;

  /// No description provided for @agent_summary.
  ///
  /// In en, this message translates to:
  /// **'Agent Summary'**
  String get agent_summary;

  /// No description provided for @view_properties_list.
  ///
  /// In en, this message translates to:
  /// **'View Properties List'**
  String get view_properties_list;

  /// No description provided for @i_have_read_and_accept.
  ///
  /// In en, this message translates to:
  /// **'I have read and accept '**
  String get i_have_read_and_accept;

  /// No description provided for @link_terms_and_conditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get link_terms_and_conditions;

  /// No description provided for @link_privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get link_privacy_policy;

  /// No description provided for @please_enter.
  ///
  /// In en, this message translates to:
  /// **'Please enter'**
  String get please_enter;

  /// No description provided for @please_select.
  ///
  /// In en, this message translates to:
  /// **'Please select'**
  String get please_select;

  /// No description provided for @field_required.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get field_required;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @management.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get management;

  /// No description provided for @no_data_found.
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get no_data_found;

  /// No description provided for @people.
  ///
  /// In en, this message translates to:
  /// **'people'**
  String get people;

  /// No description provided for @property_types.
  ///
  /// In en, this message translates to:
  /// **'Property Types'**
  String get property_types;

  /// No description provided for @all_buyers_renters.
  ///
  /// In en, this message translates to:
  /// **'All Buyers/Renters'**
  String get all_buyers_renters;

  /// No description provided for @all_buyers.
  ///
  /// In en, this message translates to:
  /// **'All Buyers'**
  String get all_buyers;

  /// No description provided for @all_renters.
  ///
  /// In en, this message translates to:
  /// **'All Renters'**
  String get all_renters;

  /// No description provided for @help_center.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get help_center;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'th': return AppLocalizationsTh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
