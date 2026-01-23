import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/features/contracts/bloc/form/contract_form_bloc.dart';
import 'package:youragent/features/contracts/bloc/form/contract_form_event.dart';
import 'package:youragent/features/contracts/bloc/form/contract_form_state.dart';
import 'package:youragent/features/contracts/bloc/pdf/contract_pdf_bloc.dart';
import 'package:youragent/features/contracts/bloc/pdf/contract_pdf_event.dart';
import 'package:youragent/features/contracts/bloc/pdf/contract_pdf_state.dart';
import 'package:youragent/features/contracts/widgets/contract_form.dart';
import 'package:youragent/features/contracts/widgets/contract_form_header.dart';
import 'package:youragent/features/contracts/widgets/contract_pdf_viewer.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/widgets/app_sidebar.dart';
import 'package:youragent/widgets/custom_header.dart';

/// Contract Detail/View Screen - displays contract information in read-only mode
class ContractDetailScreen extends StatefulWidget {
  final String contractId;

  const ContractDetailScreen({super.key, required this.contractId});

  @override
  State<ContractDetailScreen> createState() => _ContractDetailScreenState();
}

class _ContractDetailScreenState extends State<ContractDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showPdf = false;
  ContractPdfBloc? _pdfBloc;

  @override
  void dispose() {
    _pdfBloc?.close();
    super.dispose();
  }

  Future<void> _handleDelete() async {
    final contractId = int.tryParse(widget.contractId);
    if (contractId == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.delete),
        content: Text('คุณต้องการลบสัญญานี้หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DependencyInjection.contractApiService.deleteContract(
          contractId: contractId,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('ลบสัญญาสำเร็จ'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.path;
    final role =
        DependencyInjection.authRepository.currentRole ?? UserRole.agent;
    // final l10n = AppLocalizations.of(context)!;

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
                  changeLocale: (locale) {},
                  onMenuTap: isMobile
                      ? () => _scaffoldKey.currentState?.openDrawer()
                      : null,
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isMobile == false)
                        AppSidebar(role: role, currentRoute: currentRoute),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Container(
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
                                  mode: ContractFormMode.view,
                                  title: 'ข้อมูลเอกสารสัญญา',
                                  extraLeadingAction: TextButton.icon(
                                    onPressed: () {
                                      final contractId = int.tryParse(
                                        widget.contractId,
                                      );
                                      if (contractId != null) {
                                        setState(() {
                                          _showPdf = true;
                                          // Create bloc and start loading PDF
                                          _pdfBloc = ContractPdfBloc();
                                          _pdfBloc!.add(
                                            ContractPdfLoad(contractId),
                                          );
                                        });
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.picture_as_pdf,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'ดู PDF',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: TextButton.styleFrom(
                                      backgroundColor: AppColors.ruby500,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  onPrimaryAction: () {
                                    context.push(
                                      '/agent/contracts/${widget.contractId}/edit',
                                    );
                                  },
                                  onSecondaryAction: _handleDelete,
                                ),
                                Expanded(
                                  child: BlocProvider(
                                    create: (context) {
                                      final bloc = ContractFormBloc();
                                      final contractId = int.tryParse(
                                        widget.contractId,
                                      );
                                      if (contractId != null) {
                                        bloc.add(
                                          ContractFormInitializeDetail(
                                            contractId: contractId,
                                          ),
                                        );
                                      }
                                      return bloc;
                                    },
                                    child: BlocBuilder<ContractFormBloc, ContractFormState>(
                                      builder: (context, state) {
                                        final formState =
                                            state is ContractFormData
                                            ? state
                                            : null;

                                        if (formState == null ||
                                            formState.isLoading) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }

                                        if (formState.errorMessage != null) {
                                          return Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Error loading contract',
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.titleLarge,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  formState.errorMessage!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: Colors.red,
                                                      ),
                                                ),
                                                const SizedBox(height: 16),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    final contractId =
                                                        int.tryParse(
                                                          widget.contractId,
                                                        );
                                                    if (contractId != null) {
                                                      context
                                                          .read<
                                                            ContractFormBloc
                                                          >()
                                                          .add(
                                                            ContractFormInitializeDetail(
                                                              contractId:
                                                                  contractId,
                                                            ),
                                                          );
                                                    }
                                                  },
                                                  child: const Text('Retry'),
                                                ),
                                              ],
                                            ),
                                          );
                                        }

                                        if (_showPdf) {
                                          final contractId = int.tryParse(
                                            widget.contractId,
                                          );
                                          if (contractId == null) {
                                            return const SizedBox.shrink();
                                          }

                                          // Create bloc if not exists
                                          if (_pdfBloc == null) {
                                            _pdfBloc = ContractPdfBloc();
                                            _pdfBloc!.add(
                                              ContractPdfLoad(contractId),
                                            );
                                          }

                                          return BlocProvider.value(
                                            value: _pdfBloc!,
                                            child: BlocBuilder<ContractPdfBloc, ContractPdfState>(
                                              builder: (context, pdfState) {
                                                // Show loading while PDF is loading
                                                if (pdfState.isLoading ||
                                                    pdfState.pdfBytes == null) {
                                                  return const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                }

                                                // Show error if loading failed
                                                if (pdfState.errorMessage !=
                                                    null) {
                                                  return Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          'ไม่สามารถโหลดไฟล์ PDF ได้',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .titleLarge,
                                                        ),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        Text(
                                                          pdfState
                                                              .errorMessage!,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.copyWith(
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        const SizedBox(
                                                          height: 16,
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            _pdfBloc?.add(
                                                              ContractPdfLoad(
                                                                contractId,
                                                              ),
                                                            );
                                                          },
                                                          child: const Text(
                                                            'ลองอีกครั้ง',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }

                                                // Show PDF viewer when loaded
                                                return ContractPdfViewer(
                                                  contractId: contractId,
                                                  contract: formState.contract,
                                                );
                                              },
                                            ),
                                          );
                                        }

                                        return ContractForm(
                                          initialData: formState,
                                          isReadOnly: true,
                                        );
                                      },
                                    ),
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
              ],
            ),
          ),
        );
      },
    );
  }
}
