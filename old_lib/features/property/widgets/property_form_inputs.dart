// Export general form components for backward compatibility
export 'package:youragent/widgets/form_fields/app_form_number_field.dart';
export 'package:youragent/widgets/form_fields/app_form_dropdown_field.dart';
export 'package:youragent/widgets/form_fields/app_form_section.dart';

// Legacy aliases for backward compatibility
import 'package:youragent/widgets/form_fields/app_form_number_field.dart';
import 'package:youragent/widgets/form_fields/app_form_dropdown_field.dart';
import 'package:youragent/widgets/form_fields/app_form_section.dart';

/// @deprecated Use AppFormNumberField instead
typedef PropertyNumberField = AppFormNumberField;

/// @deprecated Use AppFormDropdownField instead
typedef PropertyDropdownField<T> = AppFormDropdownField<T>;

/// @deprecated Use AppFormSection instead
typedef PropertyFormSection = AppFormSection;
