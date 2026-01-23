import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/widgets/custom_header.dart';
// import 'package:youragent/widgets/footer.dart';
import 'package:youragent/features/property/widgets/property_form.dart';
import 'package:youragent/features/property/widgets/property_form_header.dart';
import 'package:youragent/widgets/app_sidebar.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/widgets/app_loader.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/features/property/bloc/property_edit_bloc.dart';
import 'package:youragent/features/property/bloc/property_edit_event.dart';
import 'package:youragent/features/property/bloc/property_edit_state.dart';
import 'package:youragent/features/property/bloc/property_form_bloc.dart';
import 'package:youragent/features/property/bloc/property_form_event.dart';
import 'package:youragent/features/property/bloc/property_form_state.dart';
import 'package:youragent/services/api_response_service.dart';
import 'package:go_router/go_router.dart';

/// Property Edit Screen - edit existing property using BLoC pattern
class PropertyEditScreen extends StatelessWidget {
  final Function(Locale) changeLocale;
  final int propertyId;

  const PropertyEditScreen({super.key, required this.changeLocale, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              PropertyEditBloc(propertyApiService: DependencyInjection.propertyApiService)
                ..add(PropertyEditLoad(propertyId: propertyId)),
        ),
        // PropertyFormBloc at this level to prevent recreation on state changes
        // This ensures form state persists across PropertyEditBloc state transitions
        BlocProvider(create: (context) => PropertyFormBloc()),
      ],
      child: _PropertyEditView(changeLocale: changeLocale, propertyId: propertyId),
    );
  }
}

class _PropertyEditView extends StatefulWidget {
  final Function(Locale) changeLocale;
  final int propertyId;

  const _PropertyEditView({required this.changeLocale, required this.propertyId});

  @override
  State<_PropertyEditView> createState() => _PropertyEditViewState();
}

class _PropertyEditViewState extends State<_PropertyEditView> {
  VoidCallback? _submitFormCallback;
  bool _hasInitializedForm = false; // Flag to prevent multiple initializations

  /// Safely navigate back - check if we can pop, otherwise go to properties list
  void _navigateBack() {
    final role = DependencyInjection.authRepository.currentRole ?? UserRole.agent;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/${role.name}/properties');
    }
  }

  @override
  void didUpdateWidget(_PropertyEditView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload property if propertyId changed
    if (oldWidget.propertyId != widget.propertyId) {
      _hasInitializedForm = false; // Reset flag for new property
      context.read<PropertyEditBloc>().add(PropertyEditLoad(propertyId: widget.propertyId));
    }
  }

  Future<void> _handleSubmit(Map<String, dynamic> formData, List<XFile> photos) async {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<PropertyEditBloc>();

    // Show confirmation dialog
    final confirmed = await StatusDialog.showConfirmation(
      context: context,
      title: l10n.confirm,
      message: l10n.confirm_update_property,
      confirmText: l10n.confirm,
      cancelText: l10n.cancel_button,
    );
    if (!confirmed || !mounted) return;

    // Validate required fields before dispatching
    final name = formData['name'] as String?;
    if (name == null || name.trim().isEmpty) {
      await StatusDialog.showError(context: context, title: l10n.error, message: 'The name field is required.');
      return;
    }

    // Get property ID from current state
    final currentState = bloc.state;
    int propertyId = widget.propertyId;
    if (currentState is PropertyEditLoaded) {
      propertyId = currentState.property.id ?? widget.propertyId;
    } else if (currentState is PropertyEditSubmitting) {
      propertyId = currentState.property.id ?? widget.propertyId;
    }

    // Dispatch the submit event to BLoC
    bloc.add(PropertyEditSubmitted(propertyId: propertyId, formData: formData, photos: photos));
  }

  void _handleSave() {
    debugPrint('PropertyEditScreen: Save button pressed');
    debugPrint('PropertyEditScreen: _submitFormCallback is ${_submitFormCallback != null ? "set" : "null"}');
    // Trigger form submission via callback
    _submitFormCallback?.call();
  }

  Future<void> _handleCancel() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await StatusDialog.showConfirmation(
      context: context,
      title: l10n.cancel_button,
      message: l10n.confirm_cancel,
      confirmText: l10n.yes,
      cancelText: l10n.no,
    );
    if (confirmed && mounted) {
      _navigateBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PropertyEditBloc, PropertyEditState>(
      listener: (context, state) {
        if (state is PropertyEditSuccess) {
          final l10n = AppLocalizations.of(context)!;
          StatusDialog.showSuccess(
            context: context,
            title: l10n.success,
            message: l10n.property_updated_success,
            onDismiss: () {
              if (mounted) {
                // Always navigate to detail screen after successful save
                final role = DependencyInjection.authRepository.currentRole ?? UserRole.agent;
                context.go('/${role.name}/properties/${state.propertyId}');
              }
            },
          );
        } else if (state is PropertyEditFailure) {
          final l10n = AppLocalizations.of(context)!;
          // Parse error to get user-friendly message
          final userMessage = ApiResponseService.getErrorMessage(state.error);
          StatusDialog.showError(context: context, title: l10n.error, message: userMessage).then((_) {
            // Reset to loaded state immediately after showing dialog
            // This prevents widget state from changing
            if (context.mounted) {
              // Reload property to restore loaded state
              context.read<PropertyEditBloc>().add(PropertyEditLoad(propertyId: widget.propertyId));
            }
          });
        } else if (state is PropertyEditLoaded) {
          // Initialize PropertyFormBloc with loaded property data
          // Only do this once when property is first loaded
          if (!_hasInitializedForm) {
            _hasInitializedForm = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.read<PropertyFormBloc>().add(PropertyFormInitialized(property: state.property));
              }
            });
          }
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;
          final scaffoldKey = GlobalKey<ScaffoldState>();
          final userRole = DependencyInjection.authRepository.currentRole ?? UserRole.agent;

          return Scaffold(
            key: scaffoldKey,
            backgroundColor: AppColors.wildSand,
            drawer: isMobile
                ? Drawer(
                    child: AppSidebar(role: userRole, currentRoute: '/agent/properties'),
                  )
                : null,
            body: SafeArea(
              child: Column(
                children: [
                  CustomHeader(
                    changeLocale: widget.changeLocale,
                    onMenuTap: isMobile ? () => scaffoldKey.currentState?.openDrawer() : null,
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sidebar
                        if (!isMobile) AppSidebar(role: userRole, currentRoute: '/agent/properties'),
                        // Main Content
                        Expanded(
                          child: BlocBuilder<PropertyEditBloc, PropertyEditState>(
                            builder: (context, state) {
                              if (state is PropertyEditLoading) {
                                return const AppLoader();
                              } else if (state is PropertyEditFailure) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Error loading property: ${state.error}',
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(onPressed: _navigateBack, child: const Text('Back')),
                                    ],
                                  ),
                                );
                              } else if (state is PropertyEditLoaded) {
                                return Padding(
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
                                        BlocBuilder<PropertyEditBloc, PropertyEditState>(
                                          builder: (context, state) {
                                            return PropertyFormHeader(
                                              mode: PropertyFormMode.edit,
                                              onPrimaryAction: _handleSave,
                                              onSecondaryAction: _handleCancel,
                                              isLoading: state is PropertyEditSubmitting,
                                            );
                                          },
                                        ),
                                        // Form content (has its own scrolling)
                                        Expanded(
                                          child: BlocBuilder<PropertyEditBloc, PropertyEditState>(
                                            builder: (context, editState) {
                                              if (editState is PropertyEditLoaded) {
                                                // Wait for PropertyFormBloc to be initialized
                                                return BlocBuilder<PropertyFormBloc, PropertyFormState>(
                                                  builder: (context, formState) {
                                                    // Only render form when PropertyFormData is ready
                                                    if (formState is PropertyFormData) {
                                                      return PropertyForm(
                                                        property: editState.property,
                                                        onSubmit: _handleSubmit,
                                                        onFormReady: (submitCallback) {
                                                          _submitFormCallback = submitCallback;
                                                        },
                                                        isSubmitting: editState is PropertyEditSubmitting,
                                                      );
                                                    }
                                                    // Show loader while waiting for form initialization
                                                    return const Center(
                                                      child: SizedBox(
                                                        width: 24,
                                                        height: 24,
                                                        child: CircularProgressIndicator(strokeWidth: 2),
                                                      ),
                                                    );
                                                  },
                                                );
                                              }
                                              return const SizedBox.shrink();
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              // Initial state or other states
                              return const AppLoader();
                            },
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
