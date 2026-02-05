import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/contract.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'contract_status_badge.dart';
import 'package:youragent/l10n/app_localizations.dart';

class ContractListItem extends StatefulWidget {
  final Contract contract;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onShare;

  const ContractListItem({
    super.key,
    required this.contract,
    this.onTap,
    this.onEdit,
    this.onShare,
  });

  @override
  State<ContractListItem> createState() => _ContractListItemState();
}

class _ContractListItemState extends State<ContractListItem> {
  bool _isExpanded = false;

  void _makeCall(String? phone) {
    if (phone == null || phone.isEmpty) return;
    // Note: Implementation of actual call requires url_launcher
    debugPrint('Calling $phone');
  }

  @override
  Widget build(BuildContext context) {
    final contract = widget.contract;
    int signedCount = 0;
    if (contract.sellerSignedAt != null) signedCount++;
    if (contract.buyerSignedAt != null) signedCount++;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Section: Badge and File Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ContractStatusBadge(
                        status: contract.status,
                        signedCount: signedCount,
                        totalCount: 2,
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F8FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/file-2.svg',
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                              AppColors.supportBlueDark,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Contract Number
                  Text(
                    'เลขที่สัญญา: ${contract.contractNumber}',
                    style: GoogleFonts.anuphan(
                      color: AppColors.baseGrey,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Property Name
                  Text(
                    contract.propertyName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.anuphan(
                      color: const Color(0xFF181D27),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1.0,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: _isExpanded
                    ? Column(
                        key: const ValueKey('expanded_content'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const Divider(
                            height: 1,
                            color: AppColors.baseLightGrey,
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Seller Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context).property,
                                        style: GoogleFonts.anuphan(
                                          color: AppColors.baseDarkGrey,
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        contract.owner?.name ?? contract.lessor,
                                        style: GoogleFonts.anuphan(
                                          color: AppColors.baseBlack,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      if (contract.sellerSignedAt != null)
                                        AppBadge(
                                          label: AppLocalizations.of(
                                            context,
                                          ).signed,
                                          color: BadgeColor.green,
                                          style: BadgeStyle.done,
                                        )
                                      else
                                        AppBadge(
                                          label: AppLocalizations.of(
                                            context,
                                          ).notSigned,
                                          color: BadgeColor.default_,
                                          style: BadgeStyle.plain,
                                        ),
                                    ],
                                  ),
                                ),
                                // Buyer Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context).buyer,
                                        style: GoogleFonts.anuphan(
                                          color: AppColors.baseDarkGrey,
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        contract.buyer?.name ?? contract.lessee,
                                        style: GoogleFonts.anuphan(
                                          color: AppColors.baseBlack,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      if (contract.buyerSignedAt != null)
                                        AppBadge(
                                          label: AppLocalizations.of(
                                            context,
                                          ).signed,
                                          color: BadgeColor.green,
                                          style: BadgeStyle.done,
                                        )
                                      else
                                        AppBadge(
                                          label: AppLocalizations.of(
                                            context,
                                          ).notSigned,
                                          color: BadgeColor.default_,
                                          style: BadgeStyle.plain,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(key: ValueKey('collapsed_content')),
              ),
            ),

            const SizedBox(height: 24),
            // Bottom Action Row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Expand/Collapse Button
                  _SmallActionButton(
                    iconPath: _isExpanded
                        ? 'assets/icons/chevron-up.svg'
                        : 'assets/icons/chevron-down.svg',
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                  ),
                  const SizedBox(width: 8),
                  // Phone Button with Pop-up Menu
                  Theme(
                    data: Theme.of(context).copyWith(
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                    child: PopupMenuButton<String>(
                      offset: const Offset(0, 40),
                      onSelected: _makeCall,
                      itemBuilder: (context) => [
                        if (contract.owner != null &&
                            contract.owner!.phone != null)
                          PopupMenuItem(
                            value: contract.owner!.phone,
                            child: Text(
                              'โทรหาเจ้าของทรัพย์: ${contract.owner!.phone}',
                              style: GoogleFonts.anuphan(fontSize: 14),
                            ),
                          ),
                        if (contract.buyer != null &&
                            contract.buyer!.phone != null)
                          PopupMenuItem(
                            value: contract.buyer!.phone,
                            child: Text(
                              'โทรหาผู้ซื้อ: ${contract.buyer!.phone}',
                              style: GoogleFonts.anuphan(fontSize: 14),
                            ),
                          ),
                        if ((contract.owner?.phone == null) &&
                            (contract.buyer?.phone == null))
                          PopupMenuItem(
                            enabled: false,
                            child: Text(
                              AppLocalizations.of(context).dataPhoneCall,
                              style: GoogleFonts.anuphan(fontSize: 14),
                            ),
                          ),
                      ],
                      child: const _SmallActionButton(
                        iconPath: 'assets/icons/phone.svg',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Share Button
                  Expanded(
                    child: AppButton(
                      padding: EdgeInsets.zero,
                      text: AppLocalizations.of(context).shareDocument,
                      style: AppButtonStyle.outline,
                      height: 32,
                      textStyle: GoogleFonts.anuphan(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.baseDarkGrey,
                      ),
                      onPressed: widget.onShare,
                      elevation: 0.1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Edit Button
                  Expanded(
                    child: AppButton(
                      text: AppLocalizations.of(context).edit,
                      style: AppButtonStyle.primary,
                      height: 32,
                      textStyle: GoogleFonts.anuphan(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.baseWhite,
                      ),
                      onPressed: widget.onEdit,
                      elevation: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback? onTap;

  const _SmallActionButton({required this.iconPath, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.baseWhite,
          border: Border.all(color: AppColors.baseLightGrey),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 2,
              offset: Offset(0, 1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: SvgPicture.asset(
              iconPath,
              key: ValueKey(iconPath),
              width: 12,
              height: 12,
              fit: BoxFit.scaleDown,
              colorFilter: const ColorFilter.mode(
                AppColors.baseDarkGrey,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
