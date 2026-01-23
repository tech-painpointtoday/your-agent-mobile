import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/widgets/custom_header.dart';
// import 'package:youragent/widgets/footer.dart';
import 'package:youragent/features/property/widgets/property_form.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/features/property/widgets/property_form_header.dart';
import 'package:youragent/widgets/app_sidebar.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/features/property/bloc/property_create_bloc.dart';
import 'package:youragent/features/property/bloc/property_create_event.dart';
import 'package:youragent/features/property/bloc/property_create_state.dart';
import 'package:youragent/features/property/bloc/property_form_bloc.dart';
import 'package:youragent/features/property/bloc/property_form_event.dart';
import 'package:youragent/services/api_response_service.dart';
import 'package:go_router/go_router.dart';

/// Property Create Screen - create new property using BLoC pattern
class PropertyCreateScreen extends StatelessWidget {
  final Function(Locale)? changeLocale;

  const PropertyCreateScreen({super.key, this.changeLocale});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PropertyCreateBloc>(
          create: (context) => PropertyCreateBloc(
            propertyApiService: DependencyInjection.propertyApiService,
          ),
        ),
        // Form BLoC for create mode.
        // We initialize it ONCE here with property: null so that
        // resizing the screen (LayoutBuilder rebuilds) does NOT recreate
        // or reset the form state.
        BlocProvider<PropertyFormBloc>(
          create: (context) => PropertyFormBloc()
            ..add(const PropertyFormInitialized(property: null)),
        ),
      ],
      child: _PropertyCreateView(changeLocale: changeLocale),
    );
  }
}

class _PropertyCreateView extends StatefulWidget {
  final Function(Locale)? changeLocale;

  const _PropertyCreateView({this.changeLocale});

  @override
  State<_PropertyCreateView> createState() => _PropertyCreateViewState();
}

class _PropertyCreateViewState extends State<_PropertyCreateView> {
  VoidCallback? _submitFormCallback;

  /// Safely navigate back - check if we can pop, otherwise go to properties list
  void _navigateBack() {
    final role =
        DependencyInjection.authRepository.currentRole ?? UserRole.agent;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/${role.name}/properties');
    }
  }

  Future<void> _handleSubmit(
    Map<String, dynamic> formData,
    List<XFile> photos,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<PropertyCreateBloc>();

    // Show confirmation dialog
    final confirmed = await StatusDialog.showConfirmation(
      context: context,
      title: l10n.confirm,
      message: l10n.confirm_create_property,
      confirmText: l10n.confirm,
      cancelText: l10n.cancel_button,
    );
    if (!confirmed || !mounted) return;

    // Validate required fields before dispatching
    final name = formData['name'] as String?;
    if (name == null || name.trim().isEmpty) {
      await StatusDialog.showError(
        context: context,
        title: l10n.error,
        message: 'The name field is required.',
      );
      return;
    }

    // Dispatch the submit event to BLoC
    try {
      bloc.add(PropertyCreateSubmitted(formData: formData, photos: photos));
    } catch (e) {
      // Handle any synchronous errors
      final userMessage = ApiResponseService.getErrorMessage(e.toString());
      await StatusDialog.showError(
        context: context,
        title: l10n.error,
        message: userMessage,
      );
    }
  }

  void _handleCreate() {
    debugPrint('PropertyCreateScreen: Create button pressed');
    debugPrint(
      'PropertyCreateScreen: _submitFormCallback is ${_submitFormCallback != null ? "set" : "null"}',
    );
    // Trigger form submission via callback
    _submitFormCallback?.call();
  }

  Future<void> _handleCancel() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await StatusDialog.showConfirmation(
      context: context,
      title: l10n.cancel_button,
      message: l10n.confirm_cancel_create,
      confirmText: l10n.yes,
      cancelText: l10n.no,
    );
    if (confirmed && mounted) {
      _navigateBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<PropertyCreateBloc, PropertyCreateState>(
      listener: (context, state) {
        if (state is PropertyCreateSuccess) {
          StatusDialog.showSuccess(
            context: context,
            title: l10n.success,
            message: l10n.property_created_success,
            onDismiss: () {
              final role =
                  DependencyInjection.authRepository.currentRole ??
                  UserRole.agent;
              // Return true to indicate successful create, then navigate
              // This allows the list screen to refresh
              if (context.canPop()) {
                context.pop(true);
              } else {
                context.go('/${role.name}/properties/${state.propertyId}');
              }
            },
          );
        } else if (state is PropertyCreateFailure) {
          // Parse error to get user-friendly message
          final userMessage = ApiResponseService.getErrorMessage(state.error);
          StatusDialog.showError(
            context: context,
            title: l10n.error,
            message: userMessage,
          ).then((_) {
            // Reset to initial state immediately after showing dialog
            // This prevents widget state from changing
            if (context.mounted) {
              context.read<PropertyCreateBloc>().add(PropertyCreateReset());
            }
          });
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;
          final scaffoldKey = GlobalKey<ScaffoldState>();
          final userRole =
              DependencyInjection.authRepository.currentRole ?? UserRole.agent;

          return Scaffold(
            key: scaffoldKey,
            backgroundColor: AppColors.wildSand,
            drawer: isMobile
                ? Drawer(
                    child: AppSidebar(
                      role: userRole,
                      currentRoute: '/agent/properties',
                    ),
                  )
                : null,
            body: SafeArea(
              child: Column(
                children: [
                  CustomHeader(
                    changeLocale: widget.changeLocale,
                    onMenuTap: isMobile
                        ? () => scaffoldKey.currentState?.openDrawer()
                        : null,
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sidebar (hidden on mobile, shown as drawer)
                        if (!isMobile)
                          AppSidebar(
                            role: userRole,
                            currentRoute: '/agent/properties',
                          ),
                        // Main Content - wrapped in white card
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Header inside the card
                                  BlocBuilder<
                                    PropertyCreateBloc,
                                    PropertyCreateState
                                  >(
                                    builder: (context, state) {
                                      return PropertyFormHeader(
                                        mode: PropertyFormMode.create,
                                        onPrimaryAction: _handleCreate,
                                        onSecondaryAction: _handleCancel,
                                        isLoading:
                                            state is PropertyCreateSubmitting,
                                      );
                                    },
                                  ),
                                  // Form content (has its own scrolling)
                                  Expanded(
                                    child: BlocBuilder<
                                      PropertyCreateBloc,
                                      PropertyCreateState
                                    >(
                                      builder: (context, state) {
                                        return PropertyForm(
                                          onSubmit: _handleSubmit,
                                          onFormReady: (submitCallback) {
                                            _submitFormCallback =
                                                submitCallback;
                                          },
                                          isSubmitting:
                                              state is PropertyCreateSubmitting,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // const Footer(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
