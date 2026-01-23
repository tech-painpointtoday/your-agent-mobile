import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/widgets/custom_header.dart';
// import 'package:youragent/widgets/footer.dart';
import 'package:youragent/features/property/widgets/property_form.dart';
import 'package:youragent/features/property/widgets/property_form_header.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/widgets/app_loader.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/widgets/app_sidebar.dart';
import 'package:youragent/features/property/bloc/property_detail_bloc.dart';
import 'package:youragent/features/property/bloc/property_detail_event.dart';
import 'package:youragent/features/property/bloc/property_detail_state.dart';
import 'package:youragent/features/property/bloc/property_form_bloc.dart';
import 'package:youragent/features/property/bloc/property_form_event.dart';
import 'package:youragent/services/api_response_service.dart';
import 'package:go_router/go_router.dart';

/// Property Detail Screen - uses PropertyForm in read-only mode with BLoC pattern
class PropertyDetailScreen extends StatelessWidget {
  final Function(Locale) changeLocale;
  final int propertyId;

  const PropertyDetailScreen({
    super.key,
    required this.changeLocale,
    required this.propertyId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PropertyDetailBloc(
        propertyApiService: DependencyInjection.propertyApiService,
      )..add(PropertyDetailLoad(propertyId: propertyId)),
      child: _PropertyDetailView(
        changeLocale: changeLocale,
        propertyId: propertyId,
      ),
    );
  }
}

class _PropertyDetailView extends StatefulWidget {
  final Function(Locale) changeLocale;
  final int propertyId;

  const _PropertyDetailView({
    required this.changeLocale,
    required this.propertyId,
  });

  @override
  State<_PropertyDetailView> createState() => _PropertyDetailViewState();
}

class _PropertyDetailViewState extends State<_PropertyDetailView> {
  bool _hasInitialized = false;

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

  @override
  void didUpdateWidget(_PropertyDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload property if propertyId changed
    if (oldWidget.propertyId != widget.propertyId) {
      context.read<PropertyDetailBloc>().add(
            PropertyDetailLoad(propertyId: widget.propertyId),
          );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh property when screen comes back into view (after initial load)
    // This handles the case when returning from edit screen
    if (_hasInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final bloc = context.read<PropertyDetailBloc>();
          final currentState = bloc.state;
          // Only refresh if we have loaded data and not already loading
          if (currentState is PropertyDetailLoaded && mounted) {
            // Refresh to get latest data
            bloc.add(PropertyDetailLoad(propertyId: widget.propertyId));
          }
        }
      });
    } else {
      _hasInitialized = true;
    }
  }

  void _handleEdit() async {
    // Get property ID from current state
    final bloc = context.read<PropertyDetailBloc>();
    final currentState = bloc.state;
    int propertyId = widget.propertyId;
    if (currentState is PropertyDetailLoaded) {
      propertyId = currentState.property.id ?? widget.propertyId;
    }

    final role =
        DependencyInjection.authRepository.currentRole ?? UserRole.agent;
    debugPrint(
      'PropertyDetailScreen: Navigating to edit with property ID: $propertyId',
    );
    final result = await context.push('/${role.name}/properties/$propertyId/edit');
    // If edit was successful, refresh the property detail
    if (result == true && mounted) {
      bloc.add(PropertyDetailLoad(propertyId: widget.propertyId));
    }
  }

  Future<void> _handleDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<PropertyDetailBloc>();

    // Get property ID from current state
    final currentState = bloc.state;
    int propertyId = widget.propertyId;
    if (currentState is PropertyDetailLoaded) {
      propertyId = currentState.property.id ?? widget.propertyId;
    } else if (currentState is PropertyDetailDeleting) {
      propertyId = currentState.property.id ?? widget.propertyId;
    }

    final confirmed = await StatusDialog.showDestructive(
      context: context,
      title: l10n.confirm,
      message: l10n.confirm_delete_property,
      confirmText: l10n.delete,
      cancelText: l10n.cancel_button,
    );

    if (!confirmed || !mounted) return;

    // Dispatch the delete event to BLoC
    bloc.add(PropertyDetailDelete(propertyId: propertyId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PropertyDetailBloc, PropertyDetailState>(
      listener: (context, state) {
        if (state is PropertyDetailDeleted) {
          final l10n = AppLocalizations.of(context)!;
          StatusDialog.showSuccess(
            context: context,
            title: l10n.success,
            message: l10n.property_deleted_success,
          ).then((_) {
            if (mounted) {
              _navigateBack();
            }
          });
        } else if (state is PropertyDetailFailure) {
          final l10n = AppLocalizations.of(context)!;
          // Parse error to get user-friendly message
          final userMessage = ApiResponseService.getErrorMessage(state.error);
          StatusDialog.showError(
            context: context,
            title: l10n.error,
            message: userMessage,
          ).then((_) {
            // Reset to allow retry
            if (context.mounted) {
              context.read<PropertyDetailBloc>().add(PropertyDetailReset());
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
                        // Sidebar
                        if (!isMobile)
                          AppSidebar(
                            role: userRole,
                            currentRoute: '/agent/properties',
                          ),
                        // Main Content
                        Expanded(
                          child: BlocBuilder<
                            PropertyDetailBloc,
                            PropertyDetailState
                          >(
                            builder: (context, state) {
                              if (state is PropertyDetailLoading) {
                                return const AppLoader();
                              } else if (state is PropertyDetailFailure) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        state.error,
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: _navigateBack,
                                        child: const Text('Back'),
                                      ),
                                    ],
                                  ),
                                );
                              } else if (state is PropertyDetailLoaded) {
                                return Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.05,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        // Header inside the card
                                        BlocBuilder<
                                          PropertyDetailBloc,
                                          PropertyDetailState
                                        >(
                                          builder: (context, state) {
                                            return PropertyFormHeader(
                                              mode: PropertyFormMode.view,
                                              onPrimaryAction: _handleEdit,
                                              onSecondaryAction: _handleDelete,
                                              isLoading:
                                                  state is PropertyDetailDeleting,
                                            );
                                          },
                                        ),
                                        // Form content
                                        Expanded(
                                          child: BlocProvider(
                                            create: (context) => PropertyFormBloc()
                                              ..add(PropertyFormInitialized(property: state.property)),
                                            child: PropertyForm(
                                              property: state.property,
                                              isReadOnly: true,
                                              onSubmit: (_, __) {},
                                              isSubmitting: false,
                                            ),
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
