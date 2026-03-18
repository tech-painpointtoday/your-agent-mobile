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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('th'),
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

  /// No description provided for @bathrooms.
  ///
  /// In en, this message translates to:
  /// **'Bathrooms'**
  String get bathrooms;

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

  /// No description provided for @yourHomeSeller.
  ///
  /// In en, this message translates to:
  /// **'YourHome Seller'**
  String get yourHomeSeller;

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
  /// **'Password must be at least 8 characters'**
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

  /// No description provided for @confirm_register.
  ///
  /// In en, this message translates to:
  /// **'Confirm Registration'**
  String get confirm_register;

  /// No description provided for @confirm_register_description.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to register?'**
  String get confirm_register_description;

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
  /// **'Agent'**
  String get role_agent;

  /// No description provided for @role_agency.
  ///
  /// In en, this message translates to:
  /// **'Agency'**
  String get role_agency;

  /// No description provided for @role_seller.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get role_seller;

  /// No description provided for @role_admin.
  ///
  /// In en, this message translates to:
  /// **'For Admin'**
  String get role_admin;

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

  /// No description provided for @agent_license_number.
  ///
  /// In en, this message translates to:
  /// **'License Number'**
  String get agent_license_number;

  /// No description provided for @agent_license_hint.
  ///
  /// In en, this message translates to:
  /// **'License Number'**
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
  /// **'Company Name'**
  String get company_name_hint;

  /// No description provided for @register_button.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register_button;

  /// No description provided for @register_success.
  ///
  /// In en, this message translates to:
  /// **'Registration Successful'**
  String get register_success;

  /// No description provided for @register_success_message.
  ///
  /// In en, this message translates to:
  /// **'Your account has been created successfully. Please check your email for verification.'**
  String get register_success_message;

  /// No description provided for @register_error.
  ///
  /// In en, this message translates to:
  /// **'Registration Failed'**
  String get register_error;

  /// No description provided for @emailAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This email has already been registered.'**
  String get emailAlreadyRegistered;

  /// No description provided for @useThisEmailToContinue.
  ///
  /// In en, this message translates to:
  /// **'Use this email to continue the contract'**
  String get useThisEmailToContinue;

  /// No description provided for @registrationNote.
  ///
  /// In en, this message translates to:
  /// **'Data will not be updated if it already exists.'**
  String get registrationNote;

  /// No description provided for @social_login_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Do you want to continue with {provider}?'**
  String social_login_confirmation(String provider);

  /// No description provided for @hero_subtitle.
  ///
  /// In en, this message translates to:
  /// **'The right home for a better life'**
  String get hero_subtitle;

  /// No description provided for @create_property_title.
  ///
  /// In en, this message translates to:
  /// **'Create New Property'**
  String get create_property_title;

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

  /// No description provided for @permission_generic_title.
  ///
  /// In en, this message translates to:
  /// **'Permission required'**
  String get permission_generic_title;

  /// No description provided for @permission_generic_denied_settings.
  ///
  /// In en, this message translates to:
  /// **'Please enable permission in Settings.'**
  String get permission_generic_denied_settings;

  /// No description provided for @permission_generic_warning_title.
  ///
  /// In en, this message translates to:
  /// **'Permission not granted'**
  String get permission_generic_warning_title;

  /// No description provided for @permission_generic_warning_message.
  ///
  /// In en, this message translates to:
  /// **'Please allow access to use this feature.'**
  String get permission_generic_warning_message;

  /// No description provided for @permission_button_open_settings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get permission_button_open_settings;

  /// No description provided for @permission_button_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get permission_button_cancel;

  /// No description provided for @permission_location_title.
  ///
  /// In en, this message translates to:
  /// **'Access location'**
  String get permission_location_title;

  /// No description provided for @permission_location_message.
  ///
  /// In en, this message translates to:
  /// **'Please allow access to your location to detect where you are.'**
  String get permission_location_message;

  /// No description provided for @permission_location_denied_forever.
  ///
  /// In en, this message translates to:
  /// **'You have permanently disabled location permission. Please go to Settings to enable location access.'**
  String get permission_location_denied_forever;

  /// No description provided for @permission_camera_title.
  ///
  /// In en, this message translates to:
  /// **'Access camera'**
  String get permission_camera_title;

  /// No description provided for @permission_camera_message.
  ///
  /// In en, this message translates to:
  /// **'Please allow access to the camera to take photos.'**
  String get permission_camera_message;

  /// No description provided for @permission_camera_denied_forever.
  ///
  /// In en, this message translates to:
  /// **'You have permanently disabled camera access. Please go to Settings to enable camera permission.'**
  String get permission_camera_denied_forever;

  /// No description provided for @permission_photos_title.
  ///
  /// In en, this message translates to:
  /// **'Access photos'**
  String get permission_photos_title;

  /// No description provided for @permission_photos_message.
  ///
  /// In en, this message translates to:
  /// **'Please allow access to your photos to select from the album.'**
  String get permission_photos_message;

  /// No description provided for @permission_photos_denied_forever.
  ///
  /// In en, this message translates to:
  /// **'You have permanently disabled photo access. Please go to Settings to enable photo permission.'**
  String get permission_photos_denied_forever;

  /// No description provided for @permission_files_title.
  ///
  /// In en, this message translates to:
  /// **'Access files'**
  String get permission_files_title;

  /// No description provided for @permission_files_message.
  ///
  /// In en, this message translates to:
  /// **'Please allow access to your files to pick documents.'**
  String get permission_files_message;

  /// No description provided for @permission_files_denied_forever.
  ///
  /// In en, this message translates to:
  /// **'You have permanently disabled file access. Please go to Settings to enable file permission.'**
  String get permission_files_denied_forever;

  /// No description provided for @permission_notification_title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get permission_notification_title;

  /// No description provided for @permission_notification_message.
  ///
  /// In en, this message translates to:
  /// **'Please allow notifications to receive updates and new messages.'**
  String get permission_notification_message;

  /// No description provided for @permission_notification_denied_forever.
  ///
  /// In en, this message translates to:
  /// **'You have permanently disabled notifications. Please go to Settings to enable notifications.'**
  String get permission_notification_denied_forever;

  /// No description provided for @permission_location_error_title.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get permission_location_error_title;

  /// No description provided for @permission_location_error_message.
  ///
  /// In en, this message translates to:
  /// **'Unable to get current location.'**
  String get permission_location_error_message;

  /// No description provided for @permission_notification_turn_off_title.
  ///
  /// In en, this message translates to:
  /// **'Turn off notifications?'**
  String get permission_notification_turn_off_title;

  /// No description provided for @permission_notification_turn_off_message.
  ///
  /// In en, this message translates to:
  /// **'If you want to turn off notifications, please go to Settings and disable notifications for this app.'**
  String get permission_notification_turn_off_message;

  /// No description provided for @chat_filter_booking.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get chat_filter_booking;

  /// No description provided for @chat_filter_inquiry.
  ///
  /// In en, this message translates to:
  /// **'Inquiries'**
  String get chat_filter_inquiry;

  /// No description provided for @chat_type_booking.
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get chat_type_booking;

  /// No description provided for @chat_type_inquiry.
  ///
  /// In en, this message translates to:
  /// **'Inquiry'**
  String get chat_type_inquiry;

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
  /// **'Copyright © 2025 yourhome.co.th'**
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

  /// No description provided for @workInfo.
  ///
  /// In en, this message translates to:
  /// **'Work Information'**
  String get workInfo;

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

  /// No description provided for @kmUnit.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get kmUnit;

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

  /// No description provided for @signing_place.
  ///
  /// In en, this message translates to:
  /// **'Signing Place'**
  String get signing_place;

  /// No description provided for @enter_signing_place.
  ///
  /// In en, this message translates to:
  /// **'Enter signing place'**
  String get enter_signing_place;

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
  /// **'Bank'**
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

  /// No description provided for @properties.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get properties;

  /// No description provided for @contracts.
  ///
  /// In en, this message translates to:
  /// **'Contracts'**
  String get contracts;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get availability;

  /// No description provided for @edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit_profile;

  /// No description provided for @create_new_account.
  ///
  /// In en, this message translates to:
  /// **'Create New Account'**
  String get create_new_account;

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

  /// No description provided for @select_file.
  ///
  /// In en, this message translates to:
  /// **'Select Your File'**
  String get select_file;

  /// No description provided for @take_photo.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get take_photo;

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

  /// No description provided for @create_property.
  ///
  /// In en, this message translates to:
  /// **'Create Property'**
  String get create_property;

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

  /// No description provided for @calendar_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get calendar_all;

  /// No description provided for @calendar_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get calendar_today;

  /// No description provided for @calendar_tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get calendar_tomorrow;

  /// No description provided for @calendar_this_week.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get calendar_this_week;

  /// No description provided for @calendar_appointments_title.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get calendar_appointments_title;

  /// No description provided for @calendar_total_appointments.
  ///
  /// In en, this message translates to:
  /// **'Total appointments {count} items'**
  String calendar_total_appointments(int count);

  /// No description provided for @calendar_no_appointments.
  ///
  /// In en, this message translates to:
  /// **'No appointments'**
  String get calendar_no_appointments;

  /// No description provided for @calendar_history_title.
  ///
  /// In en, this message translates to:
  /// **'Appointment History'**
  String get calendar_history_title;

  /// No description provided for @calendar_total_history.
  ///
  /// In en, this message translates to:
  /// **'Total past appointments {count} items'**
  String calendar_total_history(int count);

  /// No description provided for @calendar_history_personal_note.
  ///
  /// In en, this message translates to:
  /// **'Personal Note: {note}'**
  String calendar_history_personal_note(String note);

  /// No description provided for @calendar_history_expired_desc.
  ///
  /// In en, this message translates to:
  /// **'This appointment has expired without updates'**
  String get calendar_history_expired_desc;

  /// No description provided for @calendar_history_reason.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String calendar_history_reason(String reason);

  /// No description provided for @calendar_history_no_show.
  ///
  /// In en, this message translates to:
  /// **'The visitor did not show up'**
  String get calendar_history_no_show;

  /// No description provided for @calendar_history_contact_button.
  ///
  /// In en, this message translates to:
  /// **'Contact Visitor'**
  String get calendar_history_contact_button;

  /// No description provided for @calendar_history_reject.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get calendar_history_reject;

  /// No description provided for @calendar_sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get calendar_sun;

  /// No description provided for @calendar_mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get calendar_mon;

  /// No description provided for @calendar_tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get calendar_tue;

  /// No description provided for @calendar_wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get calendar_wed;

  /// No description provided for @calendar_thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get calendar_thu;

  /// No description provided for @calendar_fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get calendar_fri;

  /// No description provided for @calendar_sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get calendar_sat;

  /// No description provided for @calendar_select_month.
  ///
  /// In en, this message translates to:
  /// **'Select Month'**
  String get calendar_select_month;

  /// No description provided for @calendar_visitor_label.
  ///
  /// In en, this message translates to:
  /// **'Visitor'**
  String get calendar_visitor_label;

  /// No description provided for @calendar_datetime_label.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get calendar_datetime_label;

  /// No description provided for @calendar_co_agent_required.
  ///
  /// In en, this message translates to:
  /// **'Co-agent Required'**
  String get calendar_co_agent_required;

  /// No description provided for @calendar_pending_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Pending Confirmation'**
  String get calendar_pending_confirmation;

  /// No description provided for @calendar_arriving_status.
  ///
  /// In en, this message translates to:
  /// **'Arriving at {time}'**
  String calendar_arriving_status(String time);

  /// No description provided for @not_yet_appointment_day.
  ///
  /// In en, this message translates to:
  /// **'Not yet appointment day'**
  String get not_yet_appointment_day;

  /// No description provided for @calendar_not_started_status.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get calendar_not_started_status;

  /// No description provided for @calendar_tab_appointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get calendar_tab_appointments;

  /// No description provided for @calendar_tab_history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get calendar_tab_history;

  /// No description provided for @calendar_tab_availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get calendar_tab_availability;

  /// No description provided for @availability_delete_success.
  ///
  /// In en, this message translates to:
  /// **'Availability deleted successfully'**
  String get availability_delete_success;

  /// No description provided for @availability_create_success.
  ///
  /// In en, this message translates to:
  /// **'Availability added successfully'**
  String get availability_create_success;

  /// No description provided for @availability_update_success.
  ///
  /// In en, this message translates to:
  /// **'Availability updated successfully'**
  String get availability_update_success;

  /// No description provided for @availability_success_description.
  ///
  /// In en, this message translates to:
  /// **'Availability saved successfully'**
  String get availability_success_description;

  /// No description provided for @availability_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during the transaction'**
  String get availability_error;

  /// No description provided for @availability_title.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get availability_title;

  /// No description provided for @availability_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your available time slots'**
  String get availability_subtitle;

  /// No description provided for @availability_view_list.
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get availability_view_list;

  /// No description provided for @availability_view_calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar View'**
  String get availability_view_calendar;

  /// No description provided for @availability_empty_day.
  ///
  /// In en, this message translates to:
  /// **'No availability for the selected date'**
  String get availability_empty_day;

  /// No description provided for @availability_empty_list.
  ///
  /// In en, this message translates to:
  /// **'No availability'**
  String get availability_empty_list;

  /// No description provided for @availability_confirm_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Availability?'**
  String get availability_confirm_delete_title;

  /// No description provided for @availability_confirm_delete_desc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this availability?'**
  String get availability_confirm_delete_desc;

  /// No description provided for @availability_status_available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get availability_status_available;

  /// No description provided for @availability_status_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get availability_status_unavailable;

  /// No description provided for @availability_edit_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Availability'**
  String get availability_edit_title;

  /// No description provided for @availability_add_title.
  ///
  /// In en, this message translates to:
  /// **'Add Availability'**
  String get availability_add_title;

  /// No description provided for @availability_instruction.
  ///
  /// In en, this message translates to:
  /// **'Please check your schedule first to prevent double-booking the same day.'**
  String get availability_instruction;

  /// No description provided for @availability_date_label.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get availability_date_label;

  /// No description provided for @availability_start_time_label.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get availability_start_time_label;

  /// No description provided for @availability_end_time_label.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get availability_end_time_label;

  /// No description provided for @availability_status_label.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get availability_status_label;

  /// No description provided for @availability_cancel_button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get availability_cancel_button;

  /// No description provided for @availability_save_button.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get availability_save_button;

  /// No description provided for @availability_add_button.
  ///
  /// In en, this message translates to:
  /// **'Add Now'**
  String get availability_add_button;

  /// No description provided for @availability_invalid_time_title.
  ///
  /// In en, this message translates to:
  /// **'Invalid Time'**
  String get availability_invalid_time_title;

  /// No description provided for @availability_past_time_error.
  ///
  /// In en, this message translates to:
  /// **'Cannot select time in the past'**
  String get availability_past_time_error;

  /// No description provided for @availability_end_before_start_error.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time'**
  String get availability_end_before_start_error;

  /// No description provided for @availability_confirm_edit_title.
  ///
  /// In en, this message translates to:
  /// **'Confirm editing availability?'**
  String get availability_confirm_edit_title;

  /// No description provided for @availability_confirm_edit_desc.
  ///
  /// In en, this message translates to:
  /// **'Do you want to save the changes?'**
  String get availability_confirm_edit_desc;

  /// No description provided for @availability_confirm_add_title.
  ///
  /// In en, this message translates to:
  /// **'Confirm adding availability?'**
  String get availability_confirm_add_title;

  /// No description provided for @availability_confirm_add_desc.
  ///
  /// In en, this message translates to:
  /// **'Do you want to add this availability?'**
  String get availability_confirm_add_desc;

  /// No description provided for @availability_delete_label.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get availability_delete_label;

  /// No description provided for @availability_confirm_add_label.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get availability_confirm_add_label;

  /// No description provided for @availability_input_slot_mode.
  ///
  /// In en, this message translates to:
  /// **'Slot Time'**
  String get availability_input_slot_mode;

  /// No description provided for @availability_input_custom_mode.
  ///
  /// In en, this message translates to:
  /// **'Custom Time'**
  String get availability_input_custom_mode;

  /// No description provided for @availability_slot_instruction_add.
  ///
  /// In en, this message translates to:
  /// **'Select one or more 1-hour slots between 08:00 and 19:00'**
  String get availability_slot_instruction_add;

  /// No description provided for @availability_slot_instruction_edit.
  ///
  /// In en, this message translates to:
  /// **'Select one 1-hour slot between 08:00 and 19:00'**
  String get availability_slot_instruction_edit;

  /// No description provided for @availability_select_slot_error.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one time slot'**
  String get availability_select_slot_error;

  /// No description provided for @availability_select_month.
  ///
  /// In en, this message translates to:
  /// **'Select Month'**
  String get availability_select_month;

  /// No description provided for @calendar_success_update.
  ///
  /// In en, this message translates to:
  /// **'Status updated successfully'**
  String get calendar_success_update;

  /// No description provided for @calendar_error_update.
  ///
  /// In en, this message translates to:
  /// **'Failed to update status'**
  String get calendar_error_update;

  /// No description provided for @calendar_unspecified_name.
  ///
  /// In en, this message translates to:
  /// **'Unspecified Name'**
  String get calendar_unspecified_name;

  /// No description provided for @calendar_unspecified_location.
  ///
  /// In en, this message translates to:
  /// **'Unspecified Location'**
  String get calendar_unspecified_location;

  /// No description provided for @calendar_confirm_cancel_title.
  ///
  /// In en, this message translates to:
  /// **'Cancel Appointment?'**
  String get calendar_confirm_cancel_title;

  /// No description provided for @calendar_confirm_cancel_desc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this appointment?'**
  String get calendar_confirm_cancel_desc;

  /// No description provided for @calendar_confirm_label.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get calendar_confirm_label;

  /// No description provided for @calendar_cancel_label.
  ///
  /// In en, this message translates to:
  /// **'Cancel Appointment'**
  String get calendar_cancel_label;

  /// No description provided for @calendar_status_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get calendar_status_confirmed;

  /// No description provided for @calendar_status_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get calendar_status_cancelled;

  /// No description provided for @calendar_status_finished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get calendar_status_finished;

  /// No description provided for @calendar_status_traveling.
  ///
  /// In en, this message translates to:
  /// **'Traveling'**
  String get calendar_status_traveling;

  /// No description provided for @calendar_status_arrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get calendar_status_arrived;

  /// No description provided for @calendar_status_offer.
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get calendar_status_offer;

  /// No description provided for @calendar_status_contract.
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get calendar_status_contract;

  /// No description provided for @calendar_status_closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get calendar_status_closed;

  /// No description provided for @calendar_status_expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get calendar_status_expired;

  /// No description provided for @calendar_cancel_success.
  ///
  /// In en, this message translates to:
  /// **'Appointment cancelled successfully'**
  String get calendar_cancel_success;

  /// No description provided for @calendar_cancel_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel appointment'**
  String get calendar_cancel_error;

  /// No description provided for @calendar_unconfirmed_on_date.
  ///
  /// In en, this message translates to:
  /// **'Unconfirmed on date'**
  String get calendar_unconfirmed_on_date;

  /// No description provided for @notifications_mark_all_read.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notifications_mark_all_read;

  /// No description provided for @notifications_confirm_mark_all_read_title.
  ///
  /// In en, this message translates to:
  /// **'Mark All as Read?'**
  String get notifications_confirm_mark_all_read_title;

  /// No description provided for @notifications_confirm_mark_all_read_desc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to mark all notifications as read?'**
  String get notifications_confirm_mark_all_read_desc;

  /// No description provided for @notifications_filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notifications_filter_all;

  /// No description provided for @notifications_filter_unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get notifications_filter_unread;

  /// No description provided for @notifications_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {message}'**
  String notifications_error(String message);

  /// No description provided for @notifications_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notifications_empty_title;

  /// No description provided for @notifications_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'We will update you here when there are notifications'**
  String get notifications_empty_subtitle;

  /// No description provided for @notifications_not_found.
  ///
  /// In en, this message translates to:
  /// **'Notification not found'**
  String get notifications_not_found;

  /// No description provided for @notifications_now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get notifications_now;

  /// No description provided for @notifications_minutes_ago.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String notifications_minutes_ago(int count);

  /// No description provided for @notifications_hours_ago.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String notifications_hours_ago(int count);

  /// No description provided for @notifications_days_ago.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String notifications_days_ago(int count);

  /// No description provided for @notifications_archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get notifications_archive;

  /// No description provided for @notifications_unarchive.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get notifications_unarchive;

  /// No description provided for @notifications_delete_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Delete notification?'**
  String get notifications_delete_confirm_title;

  /// No description provided for @notifications_delete_confirm_desc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this notification? This action cannot be undone.'**
  String get notifications_delete_confirm_desc;

  /// No description provided for @notifications_delete_label.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get notifications_delete_label;

  /// No description provided for @notifications_cancel_label.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get notifications_cancel_label;

  /// No description provided for @calendar_delay_warning.
  ///
  /// In en, this message translates to:
  /// **'You may be arriving {minutes} minutes late'**
  String calendar_delay_warning(int minutes);

  /// No description provided for @booking_detail_title.
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get booking_detail_title;

  /// No description provided for @booking_date.
  ///
  /// In en, this message translates to:
  /// **'Booking Date'**
  String get booking_date;

  /// No description provided for @booking_time.
  ///
  /// In en, this message translates to:
  /// **'Booking Time'**
  String get booking_time;

  /// No description provided for @booking_location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get booking_location;

  /// No description provided for @booking_property_info.
  ///
  /// In en, this message translates to:
  /// **'Property Information'**
  String get booking_property_info;

  /// No description provided for @booking_client.
  ///
  /// In en, this message translates to:
  /// **'Booking Client'**
  String get booking_client;

  /// No description provided for @booking_not_found.
  ///
  /// In en, this message translates to:
  /// **'Booking information not found'**
  String get booking_not_found;

  /// No description provided for @booking_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get booking_retry;

  /// No description provided for @booking_status_pending_client.
  ///
  /// In en, this message translates to:
  /// **'Waiting for client confirmation'**
  String get booking_status_pending_client;

  /// No description provided for @booking_status_traveling_client.
  ///
  /// In en, this message translates to:
  /// **'Client is traveling'**
  String get booking_status_traveling_client;

  /// No description provided for @booking_status_arrived_client.
  ///
  /// In en, this message translates to:
  /// **'Arrived at destination'**
  String get booking_status_arrived_client;

  /// No description provided for @booking_confirm_booking.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get booking_confirm_booking;

  /// No description provided for @booking_confirm_booking_title.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking?'**
  String get booking_confirm_booking_title;

  /// No description provided for @booking_confirm_booking_desc.
  ///
  /// In en, this message translates to:
  /// **'Do you want to confirm this booking?'**
  String get booking_confirm_booking_desc;

  /// No description provided for @booking_start_traveling.
  ///
  /// In en, this message translates to:
  /// **'Start Traveling'**
  String get booking_start_traveling;

  /// No description provided for @booking_confirm_traveling_title.
  ///
  /// In en, this message translates to:
  /// **'Start Traveling?'**
  String get booking_confirm_traveling_title;

  /// No description provided for @booking_confirm_traveling_desc.
  ///
  /// In en, this message translates to:
  /// **'Are you starting your journey to the client?'**
  String get booking_confirm_traveling_desc;

  /// No description provided for @booking_confirm_arrived_title.
  ///
  /// In en, this message translates to:
  /// **'Arrived at Destination?'**
  String get booking_confirm_arrived_title;

  /// No description provided for @booking_confirm_arrived_desc.
  ///
  /// In en, this message translates to:
  /// **'Have you arrived at the destination?'**
  String get booking_confirm_arrived_desc;

  /// No description provided for @booking_finish_work.
  ///
  /// In en, this message translates to:
  /// **'Finish Work'**
  String get booking_finish_work;

  /// No description provided for @booking_confirm_finish_title.
  ///
  /// In en, this message translates to:
  /// **'Finish Work?'**
  String get booking_confirm_finish_title;

  /// No description provided for @booking_confirm_finish_desc.
  ///
  /// In en, this message translates to:
  /// **'Have you finished the property viewing?'**
  String get booking_confirm_finish_desc;

  /// No description provided for @booking_unspecified_property.
  ///
  /// In en, this message translates to:
  /// **'Unspecified Property'**
  String get booking_unspecified_property;

  /// No description provided for @booking_status_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown Status'**
  String get booking_status_unknown;

  /// No description provided for @not_specified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get not_specified;

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

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated successfully'**
  String get profilePhotoUpdated;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @emailVerified.
  ///
  /// In en, this message translates to:
  /// **'Email Verified'**
  String get emailVerified;

  /// No description provided for @profileCompleteness.
  ///
  /// In en, this message translates to:
  /// **'Profile Completeness'**
  String get profileCompleteness;

  /// No description provided for @connectionCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Connection code copied to clipboard'**
  String get connectionCodeCopied;

  /// No description provided for @notConnectedAgency.
  ///
  /// In en, this message translates to:
  /// **'Not connected to any agency'**
  String get notConnectedAgency;

  /// No description provided for @addInfo.
  ///
  /// In en, this message translates to:
  /// **'Add Information'**
  String get addInfo;

  /// No description provided for @socialLinks.
  ///
  /// In en, this message translates to:
  /// **'Social Links'**
  String get socialLinks;

  /// No description provided for @editInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit Information'**
  String get editInfo;

  /// No description provided for @generalInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Property name and address'**
  String get generalInfoSubtitle;

  /// No description provided for @propertyDetailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Room details, size, and price'**
  String get propertyDetailSubtitle;

  /// No description provided for @additionalInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Decor style, highlights, and amenities'**
  String get additionalInfoSubtitle;

  /// No description provided for @propertyImagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload at least 1 images'**
  String get propertyImagesSubtitle;

  /// No description provided for @propertyIdPrefix.
  ///
  /// In en, this message translates to:
  /// **'Code: '**
  String get propertyIdPrefix;

  /// No description provided for @confirmInfo.
  ///
  /// In en, this message translates to:
  /// **'Confirm Information'**
  String get confirmInfo;

  /// No description provided for @deleteConfirmationWarning.
  ///
  /// In en, this message translates to:
  /// **'Once deleted, it cannot be undone.'**
  String get deleteConfirmationWarning;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @propertyCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Property Created Successfully'**
  String get propertyCreatedSuccess;

  /// No description provided for @propertyCreatedErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to create property. Please try again.'**
  String get propertyCreatedErrorMessage;

  /// No description provided for @errorWithPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get errorWithPrefix;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @createPropertyConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Do you want to create this property listing?'**
  String get createPropertyConfirmation;

  /// No description provided for @draftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft Saved'**
  String get draftSaved;

  /// No description provided for @styleColonial.
  ///
  /// In en, this message translates to:
  /// **'Colonial'**
  String get styleColonial;

  /// No description provided for @styleContemporary.
  ///
  /// In en, this message translates to:
  /// **'Contemporary'**
  String get styleContemporary;

  /// No description provided for @styleLoft.
  ///
  /// In en, this message translates to:
  /// **'Loft'**
  String get styleLoft;

  /// No description provided for @styleMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get styleMinimal;

  /// No description provided for @styleNatural.
  ///
  /// In en, this message translates to:
  /// **'Natural'**
  String get styleNatural;

  /// No description provided for @styleNordic.
  ///
  /// In en, this message translates to:
  /// **'Nordic'**
  String get styleNordic;

  /// No description provided for @styleThaiContemporary.
  ///
  /// In en, this message translates to:
  /// **'Thai Contemporary'**
  String get styleThaiContemporary;

  /// No description provided for @styleVintage.
  ///
  /// In en, this message translates to:
  /// **'Vintage'**
  String get styleVintage;

  /// No description provided for @styleOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get styleOther;

  /// No description provided for @petFriendly.
  ///
  /// In en, this message translates to:
  /// **'Pet Friendly'**
  String get petFriendly;

  /// No description provided for @elderlyFriendly.
  ///
  /// In en, this message translates to:
  /// **'Elderly Friendly'**
  String get elderlyFriendly;

  /// No description provided for @fitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get fitness;

  /// No description provided for @swimmingPool.
  ///
  /// In en, this message translates to:
  /// **'Swimming Pool'**
  String get swimmingPool;

  /// No description provided for @garden.
  ///
  /// In en, this message translates to:
  /// **'Garden'**
  String get garden;

  /// No description provided for @coWorkingSpace.
  ///
  /// In en, this message translates to:
  /// **'Co-Working Space'**
  String get coWorkingSpace;

  /// No description provided for @sportsField.
  ///
  /// In en, this message translates to:
  /// **'Sports Field'**
  String get sportsField;

  /// No description provided for @cctv.
  ///
  /// In en, this message translates to:
  /// **'CCTV'**
  String get cctv;

  /// No description provided for @evCharger.
  ///
  /// In en, this message translates to:
  /// **'EV Charger'**
  String get evCharger;

  /// No description provided for @smartHome.
  ///
  /// In en, this message translates to:
  /// **'Smart Home'**
  String get smartHome;

  /// No description provided for @park.
  ///
  /// In en, this message translates to:
  /// **'Park'**
  String get park;

  /// No description provided for @houseType.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get houseType;

  /// No description provided for @condoType.
  ///
  /// In en, this message translates to:
  /// **'Condo'**
  String get condoType;

  /// No description provided for @townhomeType.
  ///
  /// In en, this message translates to:
  /// **'Townhome'**
  String get townhomeType;

  /// No description provided for @apartmentType.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get apartmentType;

  /// No description provided for @homeOfficeType.
  ///
  /// In en, this message translates to:
  /// **'Home Office'**
  String get homeOfficeType;

  /// No description provided for @poolVillaType.
  ///
  /// In en, this message translates to:
  /// **'Pool Villa'**
  String get poolVillaType;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @continueAddingInfo.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAddingInfo;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending Approval'**
  String get statusPending;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @colorWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get colorWhite;

  /// No description provided for @colorCream.
  ///
  /// In en, this message translates to:
  /// **'Cream'**
  String get colorCream;

  /// No description provided for @colorGrey.
  ///
  /// In en, this message translates to:
  /// **'Grey'**
  String get colorGrey;

  /// No description provided for @colorBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get colorBlack;

  /// No description provided for @colorBrown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get colorBrown;

  /// No description provided for @colorRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colorRed;

  /// No description provided for @colorYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get colorYellow;

  /// No description provided for @colorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// No description provided for @colorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorBlue;

  /// No description provided for @colorPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get colorPink;

  /// No description provided for @colorPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get colorPurple;

  /// No description provided for @colorOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get colorOrange;

  /// No description provided for @dirNorth.
  ///
  /// In en, this message translates to:
  /// **'North'**
  String get dirNorth;

  /// No description provided for @dirSouth.
  ///
  /// In en, this message translates to:
  /// **'South'**
  String get dirSouth;

  /// No description provided for @dirEast.
  ///
  /// In en, this message translates to:
  /// **'East'**
  String get dirEast;

  /// No description provided for @dirWest.
  ///
  /// In en, this message translates to:
  /// **'West'**
  String get dirWest;

  /// No description provided for @dirNorthEast.
  ///
  /// In en, this message translates to:
  /// **'North East'**
  String get dirNorthEast;

  /// No description provided for @dirSouthEast.
  ///
  /// In en, this message translates to:
  /// **'South East'**
  String get dirSouthEast;

  /// No description provided for @dirNorthWest.
  ///
  /// In en, this message translates to:
  /// **'North West'**
  String get dirNorthWest;

  /// No description provided for @dirSouthWest.
  ///
  /// In en, this message translates to:
  /// **'South West'**
  String get dirSouthWest;

  /// No description provided for @additional_info_section.
  ///
  /// In en, this message translates to:
  /// **'Additional Info'**
  String get additional_info_section;

  /// No description provided for @propertyNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Property Name'**
  String get propertyNameLabel;

  /// No description provided for @propertyNameHint.
  ///
  /// In en, this message translates to:
  /// **'Property Name'**
  String get propertyNameHint;

  /// No description provided for @propertyNameDescription.
  ///
  /// In en, this message translates to:
  /// **'This name will appear as the title of your listing.'**
  String get propertyNameDescription;

  /// No description provided for @developerLabel.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developerLabel;

  /// No description provided for @developerHint.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developerHint;

  /// No description provided for @addDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Add Developer'**
  String get addDeveloper;

  /// No description provided for @projectNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Project Name'**
  String get projectNameLabel;

  /// No description provided for @addProject.
  ///
  /// In en, this message translates to:
  /// **'Add Project'**
  String get addProject;

  /// No description provided for @searchDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Search Developer'**
  String get searchDeveloper;

  /// No description provided for @searchDeveloperDescription.
  ///
  /// In en, this message translates to:
  /// **'Search for the property developer'**
  String get searchDeveloperDescription;

  /// No description provided for @searchProjectDescription.
  ///
  /// In en, this message translates to:
  /// **'Search for the property project name'**
  String get searchProjectDescription;

  /// No description provided for @buildingLabel.
  ///
  /// In en, this message translates to:
  /// **'Building'**
  String get buildingLabel;

  /// No description provided for @buildingHint.
  ///
  /// In en, this message translates to:
  /// **'Building'**
  String get buildingHint;

  /// No description provided for @floorLabel.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get floorLabel;

  /// No description provided for @floorHint.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get floorHint;

  /// No description provided for @roomNoLabel.
  ///
  /// In en, this message translates to:
  /// **'Room Number'**
  String get roomNoLabel;

  /// No description provided for @roomNoHint.
  ///
  /// In en, this message translates to:
  /// **'Room Number'**
  String get roomNoHint;

  /// No description provided for @houseNoLabel.
  ///
  /// In en, this message translates to:
  /// **'House Number'**
  String get houseNoLabel;

  /// No description provided for @houseNoHint.
  ///
  /// In en, this message translates to:
  /// **'House Number'**
  String get houseNoHint;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @locationHint.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationHint;

  /// No description provided for @locationDescription.
  ///
  /// In en, this message translates to:
  /// **'Select a location on the map or use your current location to set the property location'**
  String get locationDescription;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use Current Location'**
  String get useCurrentLocation;

  /// No description provided for @clearLocation.
  ///
  /// In en, this message translates to:
  /// **'Clear Location'**
  String get clearLocation;

  /// No description provided for @listingTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Listing Type'**
  String get listingTypeLabel;

  /// No description provided for @listingSale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get listingSale;

  /// No description provided for @listingRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get listingRent;

  /// No description provided for @listingSaleRent.
  ///
  /// In en, this message translates to:
  /// **'Sale & Rent'**
  String get listingSaleRent;

  /// No description provided for @occupancyStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get occupancyStatusLabel;

  /// No description provided for @occupancyAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get occupancyAvailable;

  /// No description provided for @propertyDirectionHint.
  ///
  /// In en, this message translates to:
  /// **'Select property direction'**
  String get propertyDirectionHint;

  /// No description provided for @floorUnit.
  ///
  /// In en, this message translates to:
  /// **'Floor No.'**
  String get floorUnit;

  /// No description provided for @roomUnit.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get roomUnit;

  /// No description provided for @roomUnitTooltip.
  ///
  /// In en, this message translates to:
  /// **'Your room\'s number'**
  String get roomUnitTooltip;

  /// No description provided for @parkingUnit.
  ///
  /// In en, this message translates to:
  /// **'Spaces'**
  String get parkingUnit;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @propertiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get propertiesTitle;

  /// No description provided for @myProperties.
  ///
  /// In en, this message translates to:
  /// **'My Properties'**
  String get myProperties;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noPropertiesFoundSearch.
  ///
  /// In en, this message translates to:
  /// **'No properties found for your search'**
  String get noPropertiesFoundSearch;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noPropertiesInSystem.
  ///
  /// In en, this message translates to:
  /// **'Currently there are no properties in the system'**
  String get noPropertiesInSystem;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @save_draft.
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get save_draft;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchHint;

  /// No description provided for @labelCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get labelCode;

  /// No description provided for @searchFilter.
  ///
  /// In en, this message translates to:
  /// **'Search Filter'**
  String get searchFilter;

  /// No description provided for @approvalStatus.
  ///
  /// In en, this message translates to:
  /// **'Approval Status'**
  String get approvalStatus;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @pendingAt.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingAt;

  /// No description provided for @approvedAt.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approvedAt;

  /// No description provided for @disapprovedAt.
  ///
  /// In en, this message translates to:
  /// **'Disapproved'**
  String get disapprovedAt;

  /// No description provided for @minPrice.
  ///
  /// In en, this message translates to:
  /// **'Min Price'**
  String get minPrice;

  /// No description provided for @maxPrice.
  ///
  /// In en, this message translates to:
  /// **'Max Price'**
  String get maxPrice;

  /// No description provided for @propertyHighlights.
  ///
  /// In en, this message translates to:
  /// **'Property Highlights'**
  String get propertyHighlights;

  /// No description provided for @commonFacilities.
  ///
  /// In en, this message translates to:
  /// **'Common Facilities'**
  String get commonFacilities;

  /// No description provided for @nearExpressway.
  ///
  /// In en, this message translates to:
  /// **'Near Expressway'**
  String get nearExpressway;

  /// No description provided for @nearStation.
  ///
  /// In en, this message translates to:
  /// **'Near Station'**
  String get nearStation;

  /// No description provided for @nearHospital.
  ///
  /// In en, this message translates to:
  /// **'Near Hospital'**
  String get nearHospital;

  /// No description provided for @newProject.
  ///
  /// In en, this message translates to:
  /// **'New Project'**
  String get newProject;

  /// No description provided for @securityGuard.
  ///
  /// In en, this message translates to:
  /// **'Security Guard'**
  String get securityGuard;

  /// No description provided for @ownerOccupied.
  ///
  /// In en, this message translates to:
  /// **'Owner Occupied'**
  String get ownerOccupied;

  /// No description provided for @roomTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Room Type'**
  String get roomTypeLabel;

  /// No description provided for @baht.
  ///
  /// In en, this message translates to:
  /// **'Baht'**
  String get baht;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @luxury.
  ///
  /// In en, this message translates to:
  /// **'Luxury'**
  String get luxury;

  /// No description provided for @classic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get classic;

  /// No description provided for @modern.
  ///
  /// In en, this message translates to:
  /// **'Modern'**
  String get modern;

  /// No description provided for @natural.
  ///
  /// In en, this message translates to:
  /// **'Natural'**
  String get natural;

  /// No description provided for @loft.
  ///
  /// In en, this message translates to:
  /// **'Loft'**
  String get loft;

  /// No description provided for @occupancyStatusVacancy.
  ///
  /// In en, this message translates to:
  /// **'Vacant'**
  String get occupancyStatusVacancy;

  /// No description provided for @occupancyStatusOccupied.
  ///
  /// In en, this message translates to:
  /// **'Occupied'**
  String get occupancyStatusOccupied;

  /// No description provided for @propertyColor.
  ///
  /// In en, this message translates to:
  /// **'Property Color'**
  String get propertyColor;

  /// No description provided for @colorCyan.
  ///
  /// In en, this message translates to:
  /// **'Cyan'**
  String get colorCyan;

  /// No description provided for @totalFloorsLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Floors'**
  String get totalFloorsLabel;

  /// No description provided for @bedroomsLabel.
  ///
  /// In en, this message translates to:
  /// **'Bedrooms'**
  String get bedroomsLabel;

  /// No description provided for @bathroomsLabel.
  ///
  /// In en, this message translates to:
  /// **'Bathrooms'**
  String get bathroomsLabel;

  /// No description provided for @parkingLabel.
  ///
  /// In en, this message translates to:
  /// **'Parking Spaces'**
  String get parkingLabel;

  /// No description provided for @landSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Land Size'**
  String get landSizeLabel;

  /// No description provided for @usableAreaLabel.
  ///
  /// In en, this message translates to:
  /// **'Usable Area'**
  String get usableAreaLabel;

  /// No description provided for @propertyStyleLabel.
  ///
  /// In en, this message translates to:
  /// **'Property Style'**
  String get propertyStyleLabel;

  /// No description provided for @minimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get minimal;

  /// No description provided for @vintage.
  ///
  /// In en, this message translates to:
  /// **'Vintage'**
  String get vintage;

  /// No description provided for @contemporary.
  ///
  /// In en, this message translates to:
  /// **'Contemporary'**
  String get contemporary;

  /// No description provided for @colonialStyle.
  ///
  /// In en, this message translates to:
  /// **'Colonial'**
  String get colonialStyle;

  /// No description provided for @nordicStyle.
  ///
  /// In en, this message translates to:
  /// **'Nordic'**
  String get nordicStyle;

  /// No description provided for @thaiContemporary.
  ///
  /// In en, this message translates to:
  /// **'Thai Contemporary'**
  String get thaiContemporary;

  /// No description provided for @builtLabel.
  ///
  /// In en, this message translates to:
  /// **'Property Built Date'**
  String get builtLabel;

  /// No description provided for @builtHint.
  ///
  /// In en, this message translates to:
  /// **'Select property built date'**
  String get builtHint;

  /// No description provided for @builtTooltip.
  ///
  /// In en, this message translates to:
  /// **'When was the property built?'**
  String get builtTooltip;

  /// No description provided for @directionTooltip.
  ///
  /// In en, this message translates to:
  /// **'More accurate analysis for compatibility'**
  String get directionTooltip;

  /// No description provided for @propertyColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Property Color'**
  String get propertyColorLabel;

  /// No description provided for @propertyColorHint.
  ///
  /// In en, this message translates to:
  /// **'Select property color'**
  String get propertyColorHint;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @monthlyRentalPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly Rental Price'**
  String get monthlyRentalPriceLabel;

  /// No description provided for @currencyUnit.
  ///
  /// In en, this message translates to:
  /// **'THB'**
  String get currencyUnit;

  /// No description provided for @sqWahUnit.
  ///
  /// In en, this message translates to:
  /// **'sq.wa'**
  String get sqWahUnit;

  /// No description provided for @sqmUnit.
  ///
  /// In en, this message translates to:
  /// **'sq.m'**
  String get sqmUnit;

  /// No description provided for @propertyDirectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Property Direction'**
  String get propertyDirectionLabel;

  /// No description provided for @propertyTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Property Type'**
  String get propertyTypeTitle;

  /// No description provided for @studio.
  ///
  /// In en, this message translates to:
  /// **'Studio'**
  String get studio;

  /// No description provided for @project_name.
  ///
  /// In en, this message translates to:
  /// **'Project Name'**
  String get project_name;

  /// No description provided for @projectNameHint.
  ///
  /// In en, this message translates to:
  /// **'Project Name'**
  String get projectNameHint;

  /// No description provided for @occupancyOccupied.
  ///
  /// In en, this message translates to:
  /// **'Occupied'**
  String get occupancyOccupied;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @garage.
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get garage;

  /// No description provided for @swimming_pool.
  ///
  /// In en, this message translates to:
  /// **'Swimming Pool'**
  String get swimming_pool;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @accountManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Management'**
  String get accountManagementTitle;

  /// No description provided for @changeLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguageLabel;

  /// No description provided for @notificationSettingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettingsLabel;

  /// No description provided for @notificationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettingsTitle;

  /// No description provided for @connectLineAccount.
  ///
  /// In en, this message translates to:
  /// **'Connect Line Account'**
  String get connectLineAccount;

  /// No description provided for @lineNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not Connected'**
  String get lineNotConnected;

  /// No description provided for @lineNotifications.
  ///
  /// In en, this message translates to:
  /// **'Line Notifications'**
  String get lineNotifications;

  /// No description provided for @lineNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications conveniently and easily'**
  String get lineNotificationsSubtitle;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// No description provided for @emailNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive security alerts and important news'**
  String get emailNotificationsSubtitle;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Go to settings on your device to enable/disable notifications'**
  String get pushNotificationsSubtitle;

  /// No description provided for @connectButton.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connectButton;

  /// No description provided for @matchingSettingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Matching System Settings'**
  String get matchingSettingsLabel;

  /// No description provided for @matchingSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Matching System Settings'**
  String get matchingSettingsTitle;

  /// No description provided for @matchingSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Minimum compatibility required for your property to appear in results'**
  String get matchingSettingsSubtitle;

  /// No description provided for @minimumScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum Score'**
  String get minimumScoreLabel;

  /// No description provided for @scorePercentSuffix.
  ///
  /// In en, this message translates to:
  /// **'% or more'**
  String get scorePercentSuffix;

  /// No description provided for @termsLabel.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsLabel;

  /// No description provided for @privacyLabel.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyLabel;

  /// No description provided for @contactUsLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUsLabel;

  /// No description provided for @contactInfoLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInfoLabel;

  /// No description provided for @companyAddressValue.
  ///
  /// In en, this message translates to:
  /// **'No. 51 Punnawithi 33, Bang Chak, Phra Khanong, Bangkok 10260'**
  String get companyAddressValue;

  /// No description provided for @companyEmailValue.
  ///
  /// In en, this message translates to:
  /// **'yourhome@example.com'**
  String get companyEmailValue;

  /// No description provided for @companyPhoneValue.
  ///
  /// In en, this message translates to:
  /// **'02-123-4567'**
  String get companyPhoneValue;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmMessage;

  /// No description provided for @logoutConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Yes, Logout'**
  String get logoutConfirmButton;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// No description provided for @requestChangeEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Request Change Email'**
  String get requestChangeEmailLabel;

  /// No description provided for @requestChangePhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Request Change Phone Number'**
  String get requestChangePhoneLabel;

  /// No description provided for @deleteAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountLabel;

  /// No description provided for @personalInfoLabel.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfoLabel;

  /// No description provided for @editPersonalInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Personal Information'**
  String get editPersonalInfoTitle;

  /// No description provided for @savePersonalInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Save Personal Information?'**
  String get savePersonalInfoTitle;

  /// No description provided for @savePersonalInfoMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to save changes to personal information?'**
  String get savePersonalInfoMessage;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @nameHintText.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get nameHintText;

  /// No description provided for @mobileHintText.
  ///
  /// In en, this message translates to:
  /// **'0xx-xxx-xxxx'**
  String get mobileHintText;

  /// No description provided for @bioLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bioLabel;

  /// No description provided for @bioHintText.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself...'**
  String get bioHintText;

  /// No description provided for @nationalIdLabel.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get nationalIdLabel;

  /// No description provided for @nationalIdHintText.
  ///
  /// In en, this message translates to:
  /// **'Enter National ID'**
  String get nationalIdHintText;

  /// No description provided for @addressHintText.
  ///
  /// In en, this message translates to:
  /// **'Enter address'**
  String get addressHintText;

  /// No description provided for @workInfoLabel.
  ///
  /// In en, this message translates to:
  /// **'Work Information'**
  String get workInfoLabel;

  /// No description provided for @addWorkInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Work Information'**
  String get addWorkInfoTitle;

  /// No description provided for @saveWorkInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Save Work Information?'**
  String get saveWorkInfoTitle;

  /// No description provided for @saveWorkInfoMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to save this work information?'**
  String get saveWorkInfoMessage;

  /// No description provided for @companyNameHint.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyNameHint;

  /// No description provided for @licenseNumberHint.
  ///
  /// In en, this message translates to:
  /// **'License Number'**
  String get licenseNumberHint;

  /// No description provided for @yearsOfExperienceLabel.
  ///
  /// In en, this message translates to:
  /// **'Years of Experience'**
  String get yearsOfExperienceLabel;

  /// No description provided for @yearsOfExperienceHint.
  ///
  /// In en, this message translates to:
  /// **'0'**
  String get yearsOfExperienceHint;

  /// No description provided for @languageProficiencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Language Proficiency'**
  String get languageProficiencyLabel;

  /// No description provided for @addLabel.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addLabel;

  /// No description provided for @linkOrIdHint.
  ///
  /// In en, this message translates to:
  /// **'Link or ID'**
  String get linkOrIdHint;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPasswordLabel;

  /// No description provided for @currentPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter current password'**
  String get currentPasswordHint;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordLabel;

  /// No description provided for @newPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get newPasswordHint;

  /// No description provided for @confirmNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPasswordLabel;

  /// No description provided for @confirmNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Please confirm new password'**
  String get confirmNewPasswordHint;

  /// No description provided for @passwordMismatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Passwords Do Not Match'**
  String get passwordMismatchTitle;

  /// No description provided for @passwordMismatchMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your new password and confirmation'**
  String get passwordMismatchMessage;

  /// No description provided for @passwordChangeSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Password Changed Successfully'**
  String get passwordChangeSuccessTitle;

  /// No description provided for @passwordChangeSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your password has been changed successfully'**
  String get passwordChangeSuccessMessage;

  /// No description provided for @thaiLanguage.
  ///
  /// In en, this message translates to:
  /// **'Thai'**
  String get thaiLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// No description provided for @serviceAreaLabel.
  ///
  /// In en, this message translates to:
  /// **'Service Area'**
  String get serviceAreaLabel;

  /// No description provided for @serviceAreaHint.
  ///
  /// In en, this message translates to:
  /// **'Service Area'**
  String get serviceAreaHint;

  /// No description provided for @serviceAreaDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a location on the map or use your current location to define your service area'**
  String get serviceAreaDescription;

  /// No description provided for @useCurrentLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Use Current Location'**
  String get useCurrentLocationLabel;

  /// No description provided for @clearLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear Location'**
  String get clearLocationLabel;

  /// No description provided for @serviceRadiusLabel.
  ///
  /// In en, this message translates to:
  /// **'Service Radius'**
  String get serviceRadiusLabel;

  /// No description provided for @serviceRadiusHint.
  ///
  /// In en, this message translates to:
  /// **'Service Radius'**
  String get serviceRadiusHint;

  /// No description provided for @serviceRadiusUnit.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get serviceRadiusUnit;

  /// No description provided for @saveServiceAreaTitle.
  ///
  /// In en, this message translates to:
  /// **'Save Service Area?'**
  String get saveServiceAreaTitle;

  /// No description provided for @saveServiceAreaMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to save this service area information?'**
  String get saveServiceAreaMessage;

  /// No description provided for @addServiceAreaTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Service Area Information'**
  String get addServiceAreaTitle;

  /// No description provided for @specifyLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Specify Location'**
  String get specifyLocationTitle;

  /// No description provided for @specifyLocationMessage.
  ///
  /// In en, this message translates to:
  /// **'Please select a service area center location on the map'**
  String get specifyLocationMessage;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Your password must be at least 8 characters and contain both letters and numbers'**
  String get changePasswordDescription;

  /// No description provided for @changePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordButton;

  /// No description provided for @change_language.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get change_language;

  /// No description provided for @select_language.
  ///
  /// In en, this message translates to:
  /// **'Select System Language'**
  String get select_language;

  /// No description provided for @addDeveloperTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Project Developer'**
  String get addDeveloperTitle;

  /// No description provided for @developerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Developer Name'**
  String get developerNameLabel;

  /// No description provided for @developerNameHint.
  ///
  /// In en, this message translates to:
  /// **'Developer Name'**
  String get developerNameHint;

  /// No description provided for @addProjectNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Project Name'**
  String get addProjectNameTitle;

  /// No description provided for @locationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationTitle;

  /// No description provided for @searchLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Search Location'**
  String get searchLocationHint;

  /// No description provided for @confirmLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm This Location'**
  String get confirmLocationButton;

  /// No description provided for @propertyTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Property Type'**
  String get propertyTypeLabel;

  /// No description provided for @propertyImagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Property Images'**
  String get propertyImagesLabel;

  /// No description provided for @uploadImagesButton.
  ///
  /// In en, this message translates to:
  /// **'Upload Images'**
  String get uploadImagesButton;

  /// No description provided for @imageSampleLabel.
  ///
  /// In en, this message translates to:
  /// **'Image Samples'**
  String get imageSampleLabel;

  /// No description provided for @deleteAllImagesButton.
  ///
  /// In en, this message translates to:
  /// **'Delete All Images'**
  String get deleteAllImagesButton;

  /// No description provided for @takePhotoButton.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhotoButton;

  /// No description provided for @selectFromAlbumButton.
  ///
  /// In en, this message translates to:
  /// **'Select from Album'**
  String get selectFromAlbumButton;

  /// No description provided for @deleteImagesConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Image?'**
  String get deleteImagesConfirmTitle;

  /// No description provided for @deleteImagesConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this image?'**
  String get deleteImagesConfirmMessage;

  /// No description provided for @deleteConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteConfirmLabel;

  /// No description provided for @deleteAllConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAllConfirmLabel;

  /// No description provided for @showLessButton.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLessButton;

  /// No description provided for @showMoreButton.
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get showMoreButton;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @editDataButton.
  ///
  /// In en, this message translates to:
  /// **'Edit Data'**
  String get editDataButton;

  /// No description provided for @cannotCreateContractTitle.
  ///
  /// In en, this message translates to:
  /// **'Cannot create contract'**
  String get cannotCreateContractTitle;

  /// No description provided for @cannotCreateContractMessage.
  ///
  /// In en, this message translates to:
  /// **'You must have an approved property in the system before you can create a contract document.'**
  String get cannotCreateContractMessage;

  /// No description provided for @itemNumber.
  ///
  /// In en, this message translates to:
  /// **'Item {index}'**
  String itemNumber(int index);

  /// No description provided for @uploadImageHint.
  ///
  /// In en, this message translates to:
  /// **'Upload at least 1 image (JPEG, PNG, WebP)'**
  String get uploadImageHint;

  /// No description provided for @contractImageName.
  ///
  /// In en, this message translates to:
  /// **'Contract Image'**
  String get contractImageName;

  /// No description provided for @paymentMethodCreditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get paymentMethodCreditCard;

  /// No description provided for @paymentMethodPromptPay.
  ///
  /// In en, this message translates to:
  /// **'PromptPay'**
  String get paymentMethodPromptPay;

  /// No description provided for @paymentMethodBankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get paymentMethodBankTransfer;

  /// No description provided for @deleteAllImagesConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete All Images?'**
  String get deleteAllImagesConfirmTitle;

  /// No description provided for @deleteAllImagesConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all images? This action cannot be undone.'**
  String get deleteAllImagesConfirmMessage;

  /// No description provided for @imagesDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Images deleted successfully'**
  String get imagesDeletedMessage;

  /// No description provided for @deleteItemQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete Item?'**
  String get deleteItemQuestion;

  /// No description provided for @furnitureTitle.
  ///
  /// In en, this message translates to:
  /// **'Furniture'**
  String get furnitureTitle;

  /// No description provided for @furnitureExampleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Sofa, Bed'**
  String get furnitureExampleHint;

  /// No description provided for @furnitureDescExampleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Brand, Color, Condition'**
  String get furnitureDescExampleHint;

  /// No description provided for @selectImageFromProperty.
  ///
  /// In en, this message translates to:
  /// **'Select from Property Images'**
  String get selectImageFromProperty;

  /// No description provided for @sellingPrice.
  ///
  /// In en, this message translates to:
  /// **'Selling Price'**
  String get sellingPrice;

  /// No description provided for @rentalPrice.
  ///
  /// In en, this message translates to:
  /// **'Rental Price'**
  String get rentalPrice;

  /// No description provided for @latePaymentPenalty.
  ///
  /// In en, this message translates to:
  /// **'Late Payment Penalty'**
  String get latePaymentPenalty;

  /// No description provided for @bahtPerDay.
  ///
  /// In en, this message translates to:
  /// **'Baht/Day'**
  String get bahtPerDay;

  /// No description provided for @enterDateRangeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1-5'**
  String get enterDateRangeHint;

  /// No description provided for @enterBranchHint.
  ///
  /// In en, this message translates to:
  /// **'Enter branch'**
  String get enterBranchHint;

  /// No description provided for @enterAccountNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter account name'**
  String get enterAccountNameHint;

  /// No description provided for @enterAccountNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter account number'**
  String get enterAccountNumberHint;

  /// No description provided for @nameFile.
  ///
  /// In en, this message translates to:
  /// **'File Name'**
  String get nameFile;

  /// No description provided for @fileNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter file name'**
  String get fileNameHint;

  /// No description provided for @uploadFile.
  ///
  /// In en, this message translates to:
  /// **'Upload File'**
  String get uploadFile;

  /// No description provided for @allPropertiesCount.
  ///
  /// In en, this message translates to:
  /// **'All property types total {count} items'**
  String allPropertiesCount(int count);

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemCount(int count);

  /// No description provided for @unknownStep.
  ///
  /// In en, this message translates to:
  /// **'Step {step} Unknown'**
  String unknownStep(int step);

  /// No description provided for @emailHintJuristic.
  ///
  /// In en, this message translates to:
  /// **'juristic@example.com'**
  String get emailHintJuristic;

  /// No description provided for @selectLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Location'**
  String get selectLocationTitle;

  /// No description provided for @selectLocationMessage.
  ///
  /// In en, this message translates to:
  /// **'Please select a location on the map or search for a place'**
  String get selectLocationMessage;

  /// No description provided for @mapAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address from Map'**
  String get mapAddressLabel;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @editDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Data'**
  String get editDataTitle;

  /// No description provided for @successTitle.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get successTitle;

  /// No description provided for @changesSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Changes saved successfully'**
  String get changesSavedMessage;

  /// No description provided for @saveChangesConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Do you want to save these changes?'**
  String get saveChangesConfirmation;

  /// No description provided for @confirmSaveLabel.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get confirmSaveLabel;

  /// No description provided for @cancelSaveLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelSaveLabel;

  /// No description provided for @pleaseFillAllFieldsError.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields'**
  String get pleaseFillAllFieldsError;

  /// No description provided for @listingTypeValueSale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get listingTypeValueSale;

  /// No description provided for @listingTypeValueRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get listingTypeValueRent;

  /// No description provided for @listingTypeValueSaleAndRent.
  ///
  /// In en, this message translates to:
  /// **'Sale and Rent'**
  String get listingTypeValueSaleAndRent;

  /// No description provided for @statusValueAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get statusValueAvailable;

  /// No description provided for @statusValueNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not Available'**
  String get statusValueNotAvailable;

  /// No description provided for @propertyDetailFallback.
  ///
  /// In en, this message translates to:
  /// **'Property Details'**
  String get propertyDetailFallback;

  /// No description provided for @addDeveloperDescription.
  ///
  /// In en, this message translates to:
  /// **'If you add a new project developer, the system will save the information and you can easily search for it next time.'**
  String get addDeveloperDescription;

  /// No description provided for @addProjectNameDescription.
  ///
  /// In en, this message translates to:
  /// **'If you add a new project name, the system will save the information and you can easily search for it next time.'**
  String get addProjectNameDescription;

  /// No description provided for @addNowButton.
  ///
  /// In en, this message translates to:
  /// **'Add Now'**
  String get addNowButton;

  /// No description provided for @juristicContactPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Juristic Contact Phone'**
  String get juristicContactPhoneLabel;

  /// No description provided for @furnitureAndAppliance.
  ///
  /// In en, this message translates to:
  /// **'Furniture and Appliance'**
  String get furnitureAndAppliance;

  /// No description provided for @noFurniture.
  ///
  /// In en, this message translates to:
  /// **'No furniture items'**
  String get noFurniture;

  /// No description provided for @noAppliance.
  ///
  /// In en, this message translates to:
  /// **'No appliance items'**
  String get noAppliance;

  /// No description provided for @deleteItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Item?'**
  String get deleteItemTitle;

  /// No description provided for @deleteItemMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get deleteItemMessage;

  /// No description provided for @addFurniture.
  ///
  /// In en, this message translates to:
  /// **'Add Furniture'**
  String get addFurniture;

  /// No description provided for @appliance.
  ///
  /// In en, this message translates to:
  /// **'Appliance'**
  String get appliance;

  /// No description provided for @additionalConditionsHint.
  ///
  /// In en, this message translates to:
  /// **'Enter additional conditions...'**
  String get additionalConditionsHint;

  /// No description provided for @juristicContactEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Juristic Contact Email'**
  String get juristicContactEmailLabel;

  /// No description provided for @discardConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardConfirmTitle;

  /// No description provided for @discardAllPropertyConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard All Property Information Changes?'**
  String get discardAllPropertyConfirmTitle;

  /// No description provided for @discardAllPropertyConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Once you discard, it cannot be undone'**
  String get discardAllPropertyConfirmMessage;

  /// No description provided for @imageDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Image deleted successfully'**
  String get imageDeletedMessage;

  /// No description provided for @searchFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Search Filter'**
  String get searchFilterLabel;

  /// No description provided for @approvalStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Approval Status'**
  String get approvalStatusTitle;

  /// No description provided for @statusIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Pending Signature'**
  String get statusIncomplete;

  /// No description provided for @statusSigned.
  ///
  /// In en, this message translates to:
  /// **'Signed'**
  String get statusSigned;

  /// No description provided for @statusComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get statusComplete;

  /// No description provided for @contractTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Contract Type'**
  String get contractTypeTitle;

  /// No description provided for @saleContractType.
  ///
  /// In en, this message translates to:
  /// **'Sale Contract'**
  String get saleContractType;

  /// No description provided for @rentContractType.
  ///
  /// In en, this message translates to:
  /// **'Rent Contract'**
  String get rentContractType;

  /// No description provided for @clearFiltersButton.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearFiltersButton;

  /// No description provided for @showResultsButton.
  ///
  /// In en, this message translates to:
  /// **'Show Results'**
  String get showResultsButton;

  /// No description provided for @confirmCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Cancel'**
  String get confirmCancelTitle;

  /// No description provided for @confirmCancelMessage.
  ///
  /// In en, this message translates to:
  /// **'Your entered data will be lost. Do you want to cancel?'**
  String get confirmCancelMessage;

  /// No description provided for @confirmCancelLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Cancel'**
  String get confirmCancelLabel;

  /// No description provided for @continueEditingLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue Editing'**
  String get continueEditingLabel;

  /// No description provided for @createContractTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Contract'**
  String get createContractTitle;

  /// No description provided for @saveDraftButton.
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get saveDraftButton;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @createContractButton.
  ///
  /// In en, this message translates to:
  /// **'Create Contract'**
  String get createContractButton;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// No description provided for @statusPendingSignature.
  ///
  /// In en, this message translates to:
  /// **'Pending Signature'**
  String get statusPendingSignature;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @registrationSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Registration Successful'**
  String get registrationSuccessTitle;

  /// No description provided for @accountCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get accountCreatedMessage;

  /// No description provided for @errorOccurredTitle.
  ///
  /// In en, this message translates to:
  /// **'An Error Occurred'**
  String get errorOccurredTitle;

  /// No description provided for @createNewAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Account'**
  String get createNewAccountTitle;

  /// No description provided for @sentToOwnerMessage.
  ///
  /// In en, this message translates to:
  /// **'Document sent to property owner successfully'**
  String get sentToOwnerMessage;

  /// No description provided for @sentToBuyerMessage.
  ///
  /// In en, this message translates to:
  /// **'Document sent to buyer successfully'**
  String get sentToBuyerMessage;

  /// No description provided for @changeEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Change Email'**
  String get changeEmailTitle;

  /// No description provided for @changeEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the new email you want to change to. Once you confirm, we will check and inform you immediately.'**
  String get changeEmailSubtitle;

  /// No description provided for @requestChangeButton.
  ///
  /// In en, this message translates to:
  /// **'Request Change'**
  String get requestChangeButton;

  /// No description provided for @newEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'New Email'**
  String get newEmailLabel;

  /// No description provided for @changePhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Change Phone Number'**
  String get changePhoneTitle;

  /// No description provided for @changePhoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the new phone number you want to change to. Once you confirm, we will check and inform you immediately.'**
  String get changePhoneSubtitle;

  /// No description provided for @newPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'New Phone Number'**
  String get newPhoneLabel;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountConfirmPrompt.
  ///
  /// In en, this message translates to:
  /// **'If you want to delete your account, please type '**
  String get deleteAccountConfirmPrompt;

  /// No description provided for @deleteAccountConfirmSuffix.
  ///
  /// In en, this message translates to:
  /// **' to confirm account deletion'**
  String get deleteAccountConfirmSuffix;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'Once your account is deleted, all your data will be permanently removed and cannot be recovered.'**
  String get deleteAccountWarning;

  /// No description provided for @reasonForDeleting.
  ///
  /// In en, this message translates to:
  /// **'Reason for deleting'**
  String get reasonForDeleting;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @typeToDeleteHint.
  ///
  /// In en, this message translates to:
  /// **'Type message here...'**
  String get typeToDeleteHint;

  /// No description provided for @yesDeleteImmediately.
  ///
  /// In en, this message translates to:
  /// **'Yes, delete immediately'**
  String get yesDeleteImmediately;

  /// No description provided for @unexpectedErrorTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error occurred. Please try again.'**
  String get unexpectedErrorTryAgain;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @agencyUnknown.
  ///
  /// In en, this message translates to:
  /// **'Agency Unknown'**
  String get agencyUnknown;

  /// No description provided for @searchProperty.
  ///
  /// In en, this message translates to:
  /// **'Search property'**
  String get searchProperty;

  /// No description provided for @propertySearchRecentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get propertySearchRecentSearches;

  /// No description provided for @propertySearchClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get propertySearchClear;

  /// No description provided for @propertySearchClearRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear recent searches?'**
  String get propertySearchClearRecentTitle;

  /// No description provided for @propertySearchClearRecentDesc.
  ///
  /// In en, this message translates to:
  /// **'This will remove all recent search history.'**
  String get propertySearchClearRecentDesc;

  /// No description provided for @propertySearchNoRecent.
  ///
  /// In en, this message translates to:
  /// **'No recent searches'**
  String get propertySearchNoRecent;

  /// No description provided for @propertySearchEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Try searching your property\nby name, location, or keywords.'**
  String get propertySearchEmptyHint;

  /// No description provided for @finance.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get finance;

  /// No description provided for @contactListLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact List'**
  String get contactListLabel;

  /// No description provided for @coAgent.
  ///
  /// In en, this message translates to:
  /// **'Co-Agent'**
  String get coAgent;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @recommendedForYou.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get recommendedForYou;

  /// No description provided for @curatedForYou.
  ///
  /// In en, this message translates to:
  /// **'Specially curated just for you'**
  String get curatedForYou;

  /// No description provided for @sample.
  ///
  /// In en, this message translates to:
  /// **'Sample'**
  String get sample;

  /// No description provided for @activityDemoUser12Min.
  ///
  /// In en, this message translates to:
  /// **'Kongkiat Labusinesslert • 12 mins'**
  String get activityDemoUser12Min;

  /// No description provided for @dateDemoDec24.
  ///
  /// In en, this message translates to:
  /// **'Dec 24, 2025, 12:00 PM'**
  String get dateDemoDec24;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activities;

  /// No description provided for @activitiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Aggregation of interesting activities, news, and PR'**
  String get activitiesSubtitle;

  /// No description provided for @contract.
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get contract;

  /// No description provided for @signedByBoth.
  ///
  /// In en, this message translates to:
  /// **'Signed by both parties'**
  String get signedByBoth;

  /// No description provided for @signedByLessor.
  ///
  /// In en, this message translates to:
  /// **'Signed by lessor'**
  String get signedByLessor;

  /// No description provided for @signedByLessee.
  ///
  /// In en, this message translates to:
  /// **'Signed by lessee'**
  String get signedByLessee;

  /// No description provided for @notSignedYet.
  ///
  /// In en, this message translates to:
  /// **'No signers yet'**
  String get notSignedYet;

  /// No description provided for @downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get downloadPdf;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get pleaseWait;

  /// No description provided for @document.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get document;

  /// No description provided for @property.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get property;

  /// No description provided for @file.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get file;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @submitDocument.
  ///
  /// In en, this message translates to:
  /// **'Submit document'**
  String get submitDocument;

  /// No description provided for @loadingPdf.
  ///
  /// In en, this message translates to:
  /// **'Loading PDF...'**
  String get loadingPdf;

  /// No description provided for @preparingPdf.
  ///
  /// In en, this message translates to:
  /// **'Preparing PDF...'**
  String get preparingPdf;

  /// No description provided for @editContract.
  ///
  /// In en, this message translates to:
  /// **'Edit contract'**
  String get editContract;

  /// No description provided for @deleteContract.
  ///
  /// In en, this message translates to:
  /// **'Delete contract'**
  String get deleteContract;

  /// No description provided for @deleteBackContract.
  ///
  /// In en, this message translates to:
  /// **'Delete back contract'**
  String get deleteBackContract;

  /// No description provided for @contractDocumentNotFound.
  ///
  /// In en, this message translates to:
  /// **'Contract document'**
  String get contractDocumentNotFound;

  /// No description provided for @dataContract.
  ///
  /// In en, this message translates to:
  /// **'Data contract'**
  String get dataContract;

  /// No description provided for @errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorLabel;

  /// No description provided for @saveDataSuccess.
  ///
  /// In en, this message translates to:
  /// **'Save data success'**
  String get saveDataSuccess;

  /// No description provided for @saveChangesQuestion.
  ///
  /// In en, this message translates to:
  /// **'Save changes?'**
  String get saveChangesQuestion;

  /// No description provided for @dataProperty.
  ///
  /// In en, this message translates to:
  /// **'Data property'**
  String get dataProperty;

  /// No description provided for @dataAddress.
  ///
  /// In en, this message translates to:
  /// **'Data address'**
  String get dataAddress;

  /// No description provided for @addDetails.
  ///
  /// In en, this message translates to:
  /// **'Add details'**
  String get addDetails;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @addContractConditionsAdditional.
  ///
  /// In en, this message translates to:
  /// **'Add contract conditions'**
  String get addContractConditionsAdditional;

  /// No description provided for @contractFile.
  ///
  /// In en, this message translates to:
  /// **'Contract file'**
  String get contractFile;

  /// No description provided for @editAddContractFile.
  ///
  /// In en, this message translates to:
  /// **'Edit add contract file'**
  String get editAddContractFile;

  /// No description provided for @conditions.
  ///
  /// In en, this message translates to:
  /// **'Conditions'**
  String get conditions;

  /// No description provided for @personTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Person Type'**
  String get personTypeLabel;

  /// No description provided for @searchDataNameProperty.
  ///
  /// In en, this message translates to:
  /// **'Search data name property'**
  String get searchDataNameProperty;

  /// No description provided for @currentAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Address'**
  String get currentAddressLabel;

  /// No description provided for @paymentDueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Due Date'**
  String get paymentDueDateLabel;

  /// No description provided for @propertyPhotos.
  ///
  /// In en, this message translates to:
  /// **'Property Photos'**
  String get propertyPhotos;

  /// No description provided for @searchDataName.
  ///
  /// In en, this message translates to:
  /// **'Search data name'**
  String get searchDataName;

  /// No description provided for @contractSelect.
  ///
  /// In en, this message translates to:
  /// **'Contract select'**
  String get contractSelect;

  /// No description provided for @totalLeasePeriod.
  ///
  /// In en, this message translates to:
  /// **'Total Lease Period'**
  String get totalLeasePeriod;

  /// No description provided for @applianceExampleHint.
  ///
  /// In en, this message translates to:
  /// **'Example: refrigerator, fan'**
  String get applianceExampleHint;

  /// No description provided for @applianceDescExampleHint.
  ///
  /// In en, this message translates to:
  /// **'Example: new black three-door refrigerator'**
  String get applianceDescExampleHint;

  /// No description provided for @signed.
  ///
  /// In en, this message translates to:
  /// **'Signed'**
  String get signed;

  /// No description provided for @notSigned.
  ///
  /// In en, this message translates to:
  /// **'Not signed'**
  String get notSigned;

  /// No description provided for @buyer.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get buyer;

  /// No description provided for @callProperty.
  ///
  /// In en, this message translates to:
  /// **'Call property'**
  String get callProperty;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @dataPhoneCall.
  ///
  /// In en, this message translates to:
  /// **'Data phone'**
  String get dataPhoneCall;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @townhouse.
  ///
  /// In en, this message translates to:
  /// **'Townhouse'**
  String get townhouse;

  /// No description provided for @showresults.
  ///
  /// In en, this message translates to:
  /// **'Showresults'**
  String get showresults;

  /// No description provided for @dataPropertyContract.
  ///
  /// In en, this message translates to:
  /// **'Data property contract'**
  String get dataPropertyContract;

  /// No description provided for @registering.
  ///
  /// In en, this message translates to:
  /// **'Registering...'**
  String get registering;

  /// No description provided for @registerMember.
  ///
  /// In en, this message translates to:
  /// **'Register Member'**
  String get registerMember;

  /// No description provided for @demoNameSomchai.
  ///
  /// In en, this message translates to:
  /// **'Somchai Jaidee'**
  String get demoNameSomchai;

  /// No description provided for @demoAddress1.
  ///
  /// In en, this message translates to:
  /// **'123/456 Bangkok'**
  String get demoAddress1;

  /// No description provided for @demoNameJaidee.
  ///
  /// In en, this message translates to:
  /// **'Jaidee Meesuk'**
  String get demoNameJaidee;

  /// No description provided for @demoAddress2.
  ///
  /// In en, this message translates to:
  /// **'456/789 Bangkok'**
  String get demoAddress2;

  /// No description provided for @registerToStart.
  ///
  /// In en, this message translates to:
  /// **'Register to start using the system'**
  String get registerToStart;

  /// No description provided for @forAgent.
  ///
  /// In en, this message translates to:
  /// **'For Agent'**
  String get forAgent;

  /// No description provided for @forAgency.
  ///
  /// In en, this message translates to:
  /// **'For Agency'**
  String get forAgency;

  /// No description provided for @submitEmailSuccess.
  ///
  /// In en, this message translates to:
  /// **'Submit email success'**
  String get submitEmailSuccess;

  /// No description provided for @emailPassword.
  ///
  /// In en, this message translates to:
  /// **'Email password'**
  String get emailPassword;

  /// No description provided for @submitEmail.
  ///
  /// In en, this message translates to:
  /// **'Submit email'**
  String get submitEmail;

  /// No description provided for @welcomeSellerManual.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the new seller manual'**
  String get welcomeSellerManual;

  /// No description provided for @submitPassword.
  ///
  /// In en, this message translates to:
  /// **'Submit password'**
  String get submitPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordUseQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to use this password?'**
  String get confirmPasswordUseQuestion;

  /// No description provided for @passwordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password success'**
  String get passwordSuccess;

  /// No description provided for @confirmEmail.
  ///
  /// In en, this message translates to:
  /// **'Confirm email'**
  String get confirmEmail;

  /// No description provided for @confirmSubmitEmail.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a confirmation link to {email}. Please check your inbox.'**
  String confirmSubmitEmail(Object email);

  /// No description provided for @locationProperty.
  ///
  /// In en, this message translates to:
  /// **'Location property'**
  String get locationProperty;

  /// No description provided for @saveLocation.
  ///
  /// In en, this message translates to:
  /// **'Save location'**
  String get saveLocation;

  /// No description provided for @confirmLocationPropertySelect.
  ///
  /// In en, this message translates to:
  /// **'Confirm location property select'**
  String get confirmLocationPropertySelect;

  /// No description provided for @searchAddress.
  ///
  /// In en, this message translates to:
  /// **'Search address'**
  String get searchAddress;

  /// No description provided for @confirmThisLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm this location'**
  String get confirmThisLocation;

  /// No description provided for @noDataFound.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get noDataFound;

  /// Standard date format
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String dateFormat(DateTime date);

  /// No description provided for @demoCompanyName.
  ///
  /// In en, this message translates to:
  /// **'YourHome Platform Co., Ltd.'**
  String get demoCompanyName;

  /// No description provided for @lastUpdateDemo.
  ///
  /// In en, this message translates to:
  /// **'Last updated Dec 24, 2025, 12:00 PM'**
  String get lastUpdateDemo;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @userAllDocumentConditions.
  ///
  /// In en, this message translates to:
  /// **'User all document conditions'**
  String get userAllDocumentConditions;

  /// No description provided for @cancelDeleteEditUserConditions.
  ///
  /// In en, this message translates to:
  /// **'Cancel delete edit user conditions'**
  String get cancelDeleteEditUserConditions;

  /// No description provided for @dataUser.
  ///
  /// In en, this message translates to:
  /// **'Data user'**
  String get dataUser;

  /// No description provided for @submitDataUser.
  ///
  /// In en, this message translates to:
  /// **'Submit data user'**
  String get submitDataUser;

  /// No description provided for @cancelUserConditions.
  ///
  /// In en, this message translates to:
  /// **'Cancel user conditions'**
  String get cancelUserConditions;

  /// No description provided for @closeDataUser.
  ///
  /// In en, this message translates to:
  /// **'Close data user'**
  String get closeDataUser;

  /// No description provided for @dataNameEmailCallAddressUser.
  ///
  /// In en, this message translates to:
  /// **'Data name email call address user'**
  String get dataNameEmailCallAddressUser;

  /// No description provided for @submitData.
  ///
  /// In en, this message translates to:
  /// **'Submit data'**
  String get submitData;

  /// No description provided for @closeDataImageUser.
  ///
  /// In en, this message translates to:
  /// **'Close data image user'**
  String get closeDataImageUser;

  /// No description provided for @deleteEditDataUser.
  ///
  /// In en, this message translates to:
  /// **'Delete edit data user'**
  String get deleteEditDataUser;

  /// No description provided for @dataAll.
  ///
  /// In en, this message translates to:
  /// **'Data all'**
  String get dataAll;

  /// No description provided for @disclaimerExcerpt.
  ///
  /// In en, this message translates to:
  /// **'The company is not responsible for any damages...'**
  String get disclaimerExcerpt;

  /// No description provided for @cancelEdit.
  ///
  /// In en, this message translates to:
  /// **'Cancel edit'**
  String get cancelEdit;

  /// No description provided for @activityDemoUser15Min.
  ///
  /// In en, this message translates to:
  /// **'Kongkiat Labusinesslert • 15 mins'**
  String get activityDemoUser15Min;

  /// No description provided for @dateDemoDec25.
  ///
  /// In en, this message translates to:
  /// **'Dec 25, 2025, 2:00 PM'**
  String get dateDemoDec25;

  /// No description provided for @newBooking.
  ///
  /// In en, this message translates to:
  /// **'New Booking'**
  String get newBooking;

  /// No description provided for @alert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get alert;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @deleteAlert.
  ///
  /// In en, this message translates to:
  /// **'Delete alert'**
  String get deleteAlert;

  /// No description provided for @deleteBackAlert.
  ///
  /// In en, this message translates to:
  /// **'Delete back alert'**
  String get deleteBackAlert;

  /// No description provided for @closeLocation.
  ///
  /// In en, this message translates to:
  /// **'Close location'**
  String get closeLocation;

  /// No description provided for @notAuthorized.
  ///
  /// In en, this message translates to:
  /// **'Not authorized'**
  String get notAuthorized;

  /// No description provided for @locationPermissionPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please allow location access to use this feature'**
  String get locationPermissionPrompt;

  /// No description provided for @goToSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get goToSettings;

  /// No description provided for @propertyHouse.
  ///
  /// In en, this message translates to:
  /// **'Property house'**
  String get propertyHouse;

  /// No description provided for @demoPropertyPunnawithi1_Title.
  ///
  /// In en, this message translates to:
  /// **'Cheap rental house Punnawithi near BTS'**
  String get demoPropertyPunnawithi1_Title;

  /// No description provided for @demoLocationPunnawithi.
  ///
  /// In en, this message translates to:
  /// **'Punnawithi, Bangkok'**
  String get demoLocationPunnawithi;

  /// No description provided for @condoNearBts.
  ///
  /// In en, this message translates to:
  /// **'Condo near BTS'**
  String get condoNearBts;

  /// No description provided for @demoLocationSukhumvit.
  ///
  /// In en, this message translates to:
  /// **'Sukhumvit, Bangkok'**
  String get demoLocationSukhumvit;

  /// No description provided for @townhome3Floors.
  ///
  /// In en, this message translates to:
  /// **'3-Story Townhome'**
  String get townhome3Floors;

  /// No description provided for @demoLocationLadprao.
  ///
  /// In en, this message translates to:
  /// **'Ladprao, Bangkok'**
  String get demoLocationLadprao;

  /// No description provided for @demoLocationRamkhamhaeng.
  ///
  /// In en, this message translates to:
  /// **'Ramkhamhaeng, Bangkok'**
  String get demoLocationRamkhamhaeng;

  /// No description provided for @demoLocationSathon.
  ///
  /// In en, this message translates to:
  /// **'Sathon, Bangkok'**
  String get demoLocationSathon;

  /// No description provided for @demoLocationBangna.
  ///
  /// In en, this message translates to:
  /// **'Bangna, Bangkok'**
  String get demoLocationBangna;

  /// No description provided for @townhouseTownhome.
  ///
  /// In en, this message translates to:
  /// **'Townhouse/Townhome'**
  String get townhouseTownhome;

  /// No description provided for @pleaseLoginAgain.
  ///
  /// In en, this message translates to:
  /// **'Please log in again'**
  String get pleaseLoginAgain;

  /// No description provided for @systemErrorTryAgain.
  ///
  /// In en, this message translates to:
  /// **'System error. Please try again.'**
  String get systemErrorTryAgain;

  /// No description provided for @errorTryAgain.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get errorTryAgain;

  /// No description provided for @subdistrictLabel.
  ///
  /// In en, this message translates to:
  /// **'Sub-district'**
  String get subdistrictLabel;

  /// No description provided for @districtLabel.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get districtLabel;

  /// No description provided for @subdistrictThaiLabel.
  ///
  /// In en, this message translates to:
  /// **'Tambon'**
  String get subdistrictThaiLabel;

  /// No description provided for @districtThaiLabel.
  ///
  /// In en, this message translates to:
  /// **'Amphoe'**
  String get districtThaiLabel;

  /// No description provided for @soiLabel.
  ///
  /// In en, this message translates to:
  /// **'Soi'**
  String get soiLabel;

  /// No description provided for @noAttachedPhotos.
  ///
  /// In en, this message translates to:
  /// **'No attached photos'**
  String get noAttachedPhotos;

  /// No description provided for @searchSuccess.
  ///
  /// In en, this message translates to:
  /// **'Search success'**
  String get searchSuccess;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @demoNews1.
  ///
  /// In en, this message translates to:
  /// **'Sample News'**
  String get demoNews1;

  /// No description provided for @shareDocument.
  ///
  /// In en, this message translates to:
  /// **'Share Document'**
  String get shareDocument;

  /// No description provided for @submitDocumentQuestion.
  ///
  /// In en, this message translates to:
  /// **'Submit document?'**
  String get submitDocumentQuestion;

  /// No description provided for @buyerInfo.
  ///
  /// In en, this message translates to:
  /// **'Buyer Information'**
  String get buyerInfo;

  /// No description provided for @renterInfo.
  ///
  /// In en, this message translates to:
  /// **'Renter Information'**
  String get renterInfo;

  /// No description provided for @addFurnitureDetails.
  ///
  /// In en, this message translates to:
  /// **'Add furniture items and details'**
  String get addFurnitureDetails;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Cost and payment methods'**
  String get paymentMethods;

  /// No description provided for @additionalContractConditions.
  ///
  /// In en, this message translates to:
  /// **'Additional contract conditions'**
  String get additionalContractConditions;

  /// No description provided for @propertyOwnerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Property owner data not found'**
  String get propertyOwnerNotFound;

  /// No description provided for @connectPropertyOwnerEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Please specify the property owner\'s email to connect information'**
  String get connectPropertyOwnerEmailHint;

  /// No description provided for @contractFormat.
  ///
  /// In en, this message translates to:
  /// **'Contract format'**
  String get contractFormat;

  /// No description provided for @selectContractStartDate.
  ///
  /// In en, this message translates to:
  /// **'Select contract start date'**
  String get selectContractStartDate;

  /// No description provided for @registerBuyerToContract.
  ///
  /// In en, this message translates to:
  /// **'Register buyer info to make contract'**
  String get registerBuyerToContract;

  /// No description provided for @enterRegisteredEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter registered email for reset link'**
  String get enterRegisteredEmailHint;

  /// No description provided for @sendResetPasswordLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset password link'**
  String get sendResetPasswordLink;

  /// No description provided for @resetPasswordFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to set new password'**
  String get resetPasswordFailed;

  /// No description provided for @emailSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Email sent successfully'**
  String get emailSentSuccessfully;

  /// No description provided for @propertyNotFound.
  ///
  /// In en, this message translates to:
  /// **'Property not found'**
  String get propertyNotFound;

  /// No description provided for @propertyLocationOnMap.
  ///
  /// In en, this message translates to:
  /// **'Property location on map'**
  String get propertyLocationOnMap;

  /// No description provided for @createLabel.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createLabel;

  /// No description provided for @selectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select location'**
  String get selectLocation;

  /// No description provided for @usableAreaSize.
  ///
  /// In en, this message translates to:
  /// **'Usable area size'**
  String get usableAreaSize;

  /// No description provided for @startingPrice.
  ///
  /// In en, this message translates to:
  /// **'Starting price'**
  String get startingPrice;

  /// No description provided for @classicStyle.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get classicStyle;

  /// No description provided for @securityGuardLabel.
  ///
  /// In en, this message translates to:
  /// **'Security Guard'**
  String get securityGuardLabel;

  /// No description provided for @showresults1.
  ///
  /// In en, this message translates to:
  /// **'Showresults'**
  String get showresults1;

  /// No description provided for @draftLabel.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draftLabel;

  /// No description provided for @termsGovernanceDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'These terms are governed by Thai law. Disputes go to Bangkok court.'**
  String get termsGovernanceDisclaimer;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @emailNotVerifiedYet.
  ///
  /// In en, this message translates to:
  /// **'Email not verified yet'**
  String get emailNotVerifiedYet;

  /// No description provided for @yourProfile.
  ///
  /// In en, this message translates to:
  /// **'Your Profile'**
  String get yourProfile;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @languageProficiency.
  ///
  /// In en, this message translates to:
  /// **'Language Proficiency'**
  String get languageProficiency;

  /// No description provided for @addressNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Address not specified'**
  String get addressNotSpecified;

  /// No description provided for @noNotificationsFound.
  ///
  /// In en, this message translates to:
  /// **'No notifications found'**
  String get noNotificationsFound;

  /// No description provided for @enableLocationServicesPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please enable location services for current location'**
  String get enableLocationServicesPrompt;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission required'**
  String get locationPermissionRequired;

  /// No description provided for @demoPropertyPunnawithi1.
  ///
  /// In en, this message translates to:
  /// **'Property 2: Cheap house Punnawithi near BTS'**
  String get demoPropertyPunnawithi1;

  /// No description provided for @cheapRentalHouse.
  ///
  /// In en, this message translates to:
  /// **'Cheap rental house'**
  String get cheapRentalHouse;

  /// No description provided for @luxuryRiversideCondo.
  ///
  /// In en, this message translates to:
  /// **'Luxury riverside condo'**
  String get luxuryRiversideCondo;

  /// No description provided for @dragAndDropHint.
  ///
  /// In en, this message translates to:
  /// **'Or drag and drop files here. Supports JPG, PNG, WebP up to 5MB.'**
  String get dragAndDropHint;

  /// No description provided for @demoActivity.
  ///
  /// In en, this message translates to:
  /// **'Sample Activity'**
  String get demoActivity;

  /// No description provided for @electrical_appliances_photos.
  ///
  /// In en, this message translates to:
  /// **'Appliances Photos'**
  String get electrical_appliances_photos;

  /// No description provided for @furniture_photos.
  ///
  /// In en, this message translates to:
  /// **'Furniture Photos'**
  String get furniture_photos;

  /// No description provided for @buyerDataNotFound.
  ///
  /// In en, this message translates to:
  /// **'Buyer data not found'**
  String get buyerDataNotFound;

  /// No description provided for @sixMonthLeaseContract.
  ///
  /// In en, this message translates to:
  /// **'6-month lease contract'**
  String get sixMonthLeaseContract;

  /// No description provided for @selectContractEndDate.
  ///
  /// In en, this message translates to:
  /// **'Select contract end date'**
  String get selectContractEndDate;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @resendLink.
  ///
  /// In en, this message translates to:
  /// **'Resend link'**
  String get resendLink;

  /// No description provided for @createPropertyLabel.
  ///
  /// In en, this message translates to:
  /// **'Create Property'**
  String get createPropertyLabel;

  /// No description provided for @noNotificationsNow.
  ///
  /// In en, this message translates to:
  /// **'No notifications at this time.'**
  String get noNotificationsNow;

  /// No description provided for @locationPermissionDeniedPermanently.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied permanently. Please enable in settings.'**
  String get locationPermissionDeniedPermanently;

  /// No description provided for @cannotGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Cannot get current location'**
  String get cannotGetLocation;

  /// No description provided for @demoPropertyPunnawithi2.
  ///
  /// In en, this message translates to:
  /// **'Property 3: Cheap house Punnawithi near BTS'**
  String get demoPropertyPunnawithi2;

  /// No description provided for @twoStoryHouse.
  ///
  /// In en, this message translates to:
  /// **'2-Story House'**
  String get twoStoryHouse;

  /// No description provided for @propertyDataNotFound.
  ///
  /// In en, this message translates to:
  /// **'Property data not found'**
  String get propertyDataNotFound;

  /// No description provided for @twelveMonthLeaseContract.
  ///
  /// In en, this message translates to:
  /// **'12-month lease contract'**
  String get twelveMonthLeaseContract;

  /// No description provided for @setNewPasswordPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please set your new password'**
  String get setNewPasswordPrompt;

  /// No description provided for @propertyHighlightsLabel.
  ///
  /// In en, this message translates to:
  /// **'Property Highlights'**
  String get propertyHighlightsLabel;

  /// No description provided for @externalLinksDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Links to other sites are for convenience only. We are not responsible for their content.'**
  String get externalLinksDisclaimer;

  /// No description provided for @demoPR2.
  ///
  /// In en, this message translates to:
  /// **'Sample PR 2'**
  String get demoPR2;

  /// No description provided for @houseWithGarden.
  ///
  /// In en, this message translates to:
  /// **'House with garden'**
  String get houseWithGarden;

  /// No description provided for @enterNewPasswordPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please enter new password'**
  String get enterNewPasswordPrompt;

  /// No description provided for @demoNews2.
  ///
  /// In en, this message translates to:
  /// **'Sample News 2'**
  String get demoNews2;

  /// No description provided for @demoProperty4.
  ///
  /// In en, this message translates to:
  /// **'Property 4'**
  String get demoProperty4;

  /// No description provided for @checkInternetConnectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection'**
  String get checkInternetConnectionLabel;

  /// No description provided for @invalidDataCheckAndTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Invalid data. Please check and try again.'**
  String get invalidDataCheckAndTryAgain;

  /// No description provided for @passwordRequirementNote.
  ///
  /// In en, this message translates to:
  /// **'Your password must be at least 8 characters with letters and numbers.'**
  String get passwordRequirementNote;

  /// No description provided for @demoActivity2.
  ///
  /// In en, this message translates to:
  /// **'Sample Activity 2'**
  String get demoActivity2;

  /// No description provided for @demoProperty5.
  ///
  /// In en, this message translates to:
  /// **'Property 5'**
  String get demoProperty5;

  /// No description provided for @cannotConnectToServer.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to server. Please check internet.'**
  String get cannotConnectToServer;

  /// No description provided for @noProfileAccess.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to access this data.'**
  String get noProfileAccess;

  /// No description provided for @draftSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Draft saved successfully'**
  String get draftSavedMessage;

  /// No description provided for @draftSaveErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to save draft. Please try again.'**
  String get draftSaveErrorMessage;

  /// No description provided for @propertyPublishedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Property published successfully'**
  String get propertyPublishedSuccess;

  /// No description provided for @publishButton.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publishButton;

  /// No description provided for @publishPropertyConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to publish this property?'**
  String get publishPropertyConfirmation;

  /// No description provided for @noApprovedPropertiesTitle.
  ///
  /// In en, this message translates to:
  /// **'No Approved Properties'**
  String get noApprovedPropertiesTitle;

  /// No description provided for @noApprovedPropertiesMessage.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any approved properties in your list. Please complete property information and wait for approval before creating a contract.'**
  String get noApprovedPropertiesMessage;

  /// No description provided for @invalidThaiIdError.
  ///
  /// In en, this message translates to:
  /// **'Invalid Thai National ID'**
  String get invalidThaiIdError;

  /// No description provided for @contractCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Contract Created Successfully'**
  String get contractCreatedSuccess;

  /// No description provided for @contractPublishedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Contract Published Successfully'**
  String get contractPublishedSuccess;

  /// No description provided for @empty_chat_message.
  ///
  /// In en, this message translates to:
  /// **'No messages yet.\nOnce you start a conversation, it will appear here.'**
  String get empty_chat_message;

  /// No description provided for @empty_chat_message_unread.
  ///
  /// In en, this message translates to:
  /// **'No unread messages'**
  String get empty_chat_message_unread;

  /// No description provided for @recent_search.
  ///
  /// In en, this message translates to:
  /// **'Recent Search'**
  String get recent_search;

  /// No description provided for @type_message_hint.
  ///
  /// In en, this message translates to:
  /// **'Type a message here...'**
  String get type_message_hint;

  /// No description provided for @read_status.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get read_status;

  /// No description provided for @message_sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get message_sent;

  /// No description provided for @conversation_title.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get conversation_title;

  /// No description provided for @search_messages_hint.
  ///
  /// In en, this message translates to:
  /// **'Search messages...'**
  String get search_messages_hint;

  /// No description provided for @no_conversations_found.
  ///
  /// In en, this message translates to:
  /// **'No conversations found'**
  String get no_conversations_found;

  /// No description provided for @no_messages.
  ///
  /// In en, this message translates to:
  /// **'No messages'**
  String get no_messages;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @time_unit_th.
  ///
  /// In en, this message translates to:
  /// **''**
  String get time_unit_th;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @applianceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appliance'**
  String get applianceTitle;

  /// No description provided for @add_developer_success.
  ///
  /// In en, this message translates to:
  /// **'Developer added successfully'**
  String get add_developer_success;

  /// No description provided for @add_project_success.
  ///
  /// In en, this message translates to:
  /// **'Project added successfully'**
  String get add_project_success;

  /// No description provided for @ownerLabel.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get ownerLabel;

  /// No description provided for @buyerLabel.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get buyerLabel;

  /// No description provided for @signedSuffix.
  ///
  /// In en, this message translates to:
  /// **'Signed'**
  String get signedSuffix;

  /// No description provided for @sendDocumentTo.
  ///
  /// In en, this message translates to:
  /// **'Send document to {label}'**
  String sendDocumentTo(String label);

  /// No description provided for @resendDocumentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to resend the document to {label} ({email}) again?'**
  String resendDocumentConfirm(String label, String email);

  /// No description provided for @sendDocumentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to send the document to {label} ({email})?'**
  String sendDocumentConfirm(String label, String email);

  /// No description provided for @sendToLessorSuccess.
  ///
  /// In en, this message translates to:
  /// **'Document sent to lessor successfully'**
  String get sendToLessorSuccess;

  /// No description provided for @sendToLesseeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Document sent to lessee successfully'**
  String get sendToLesseeSuccess;

  /// No description provided for @invalidPhoneNumberFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhoneNumberFormat;

  /// No description provided for @invalidEmailFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get invalidEmailFormat;

  /// No description provided for @passwordMinLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLengthError;

  /// No description provided for @passwordMismatchError.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatchError;

  /// No description provided for @addAppliance.
  ///
  /// In en, this message translates to:
  /// **'Add Appliance'**
  String get addAppliance;

  /// No description provided for @addApplianceAndDetails.
  ///
  /// In en, this message translates to:
  /// **'Add appliance items and details'**
  String get addApplianceAndDetails;

  /// No description provided for @furnitureConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Furniture'**
  String get furnitureConfirm;

  /// No description provided for @allowAgentRepresentationLabel.
  ///
  /// In en, this message translates to:
  /// **'Allow Agent'**
  String get allowAgentRepresentationLabel;

  /// No description provided for @renterOrBuyer.
  ///
  /// In en, this message translates to:
  /// **'Renter/Buyer Info'**
  String get renterOrBuyer;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @navProperty.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get navProperty;

  /// No description provided for @navContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get navContact;

  /// No description provided for @navMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get navMoney;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @licenseNumberWithPrefix.
  ///
  /// In en, this message translates to:
  /// **'License Number {number}'**
  String licenseNumberWithPrefix(String number);

  /// No description provided for @experienceYears.
  ///
  /// In en, this message translates to:
  /// **'{years} years experience'**
  String experienceYears(int years);

  /// No description provided for @serviceRadiusWithPrefix.
  ///
  /// In en, this message translates to:
  /// **'Service Radius {radius} km'**
  String serviceRadiusWithPrefix(String radius);

  /// No description provided for @profileLevel.
  ///
  /// In en, this message translates to:
  /// **'Lv. {level}'**
  String profileLevel(int level);

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields'**
  String get pleaseFillAllFields;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'th':
      return AppLocalizationsTh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
