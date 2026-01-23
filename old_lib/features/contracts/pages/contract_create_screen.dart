import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/data/models/contract_create_data_model.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/features/contracts/bloc/form/contract_form_bloc.dart';
import 'package:youragent/features/contracts/bloc/form/contract_form_event.dart';
import 'package:youragent/features/contracts/bloc/form/contract_form_state.dart';
import 'package:youragent/features/contracts/widgets/contract_form.dart';
import 'package:youragent/features/auth/bloc/auth_bloc.dart';
import 'package:youragent/features/auth/bloc/auth_state.dart';
import 'package:youragent/widgets/app_sidebar.dart';
import 'package:youragent/widgets/custom_header.dart';
import 'package:youragent/features/contracts/widgets/contract_form_header.dart';

class ContractCreateScreen extends StatefulWidget {
  final String? propertyId;

  const ContractCreateScreen({super.key, this.propertyId});

  @override
  State<ContractCreateScreen> createState() => _ContractCreateScreenState();
}

class _ContractCreateScreenState extends State<ContractCreateScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  VoidCallback? _submitFormCallback;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.path;
    final authState = context.watch<AuthBloc>().state;
    final role = authState is Authenticated
        ? authState.user.role
        : UserRole.agent;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.wildSand,
          drawer: isMobile
              ? Drawer(
                  child: AppSidebar(role: role, currentRoute: currentRoute),
                )
              : null,
          body: SafeArea(
            child: Column(
              children: [
                CustomHeader(
                  changeLocale: (locale) {
                    // TODO: Implement locale change if needed
                  },
                  onMenuTap: isMobile
                      ? () => _scaffoldKey.currentState?.openDrawer()
                      : null,
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sidebar (hidden on mobile, shown as drawer)
                      if (!isMobile)
                        AppSidebar(role: role, currentRoute: currentRoute),
                      // Main Content - wrapped in white card
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: BlocProvider(
                            create: (context) {
                              final bloc = ContractFormBloc();
                              final propertyId = int.tryParse(widget.propertyId ?? '');
                              bloc.add(
                                ContractFormInitializeCreate(propertyId: propertyId),
                              );
                              return bloc;
                            },
                            child: BlocConsumer<ContractFormBloc, ContractFormState>(
                              listener: (context, state) {
                                if (state is! ContractFormData) return;
                                if (state.submitSuccess) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('บันทึกข้อมูลสำเร็จ'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  context.pop();
                                } else if (state.submitErrorMessage != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(state.submitErrorMessage!),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              builder: (context, state) {
                                final formState = state is ContractFormData ? state : null;

                                final ContractCreateData? createData = formState == null
                                    ? null
                                    : ContractCreateData(
                                        property: formState.sourceProperty,
                                        banks: formState.banks,
                                        accountTypes: formState.accountTypes,
                                      );

                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
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
                                      ContractFormHeader(
                                        mode: ContractFormMode.create,
                                        title: AppLocalizations.of(context)!.create_rental_contract,
                                        subtitle: formState?.sourceProperty != null
                                            ? 'สำหรับ: ${formState!.sourceProperty!.name}'
                                            : null,
                                        onPrimaryAction: formState?.isSubmitting == true
                                            ? null
                                            : () => _submitFormCallback?.call(),
                                        onSecondaryAction: () => context.pop(),
                                        isLoading: formState?.isSubmitting == true,
                                      ),
                                      Expanded(
                                        child: (formState == null || formState.isLoading)
                                            ? const Center(child: CircularProgressIndicator())
                                            : formState.errorMessage != null
                                                ? Center(
                                                    child: Text(
                                                      formState.errorMessage!,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.copyWith(color: Colors.red),
                                                    ),
                                                  )
                                                : ContractForm(
                                                    initialData: formState,
                                                    isReadOnly: false,
                                                    property: formState.sourceProperty,
                                                    contractCreateData: createData,
                                                    onSubmit: (formData) {
                                                      context.read<ContractFormBloc>().add(
                                                            ContractFormSubmitted(formData: formData),
                                                          );
                                                    },
                                                    onFormReady: (submitCallback) {
                                                      _submitFormCallback = submitCallback;
                                                    },
                                                  ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
