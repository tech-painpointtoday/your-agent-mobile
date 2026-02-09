import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/badges/app_badge.dart';

class MoneyPropertyCard extends StatelessWidget {
  final String? installment;
  final String? tenantName;
  final String title;
  final String? location;
  final String price;
  final String dueDate;
  final String? imageUrl;
  final VoidCallback onCall;
  final VoidCallback? onTap;

  final String? fineAmount;
  final String? overdueStatus;
  final bool isOverdue;
  final bool isPaid;
  final String? paidDate;

  const MoneyPropertyCard({
    super.key,
    this.installment,
    this.tenantName,
    required this.title,
    this.location,
    required this.price,
    required this.dueDate,
    this.imageUrl,
    required this.onCall,
    this.fineAmount,
    this.overdueStatus,
    this.isOverdue = false,
    this.isPaid = false,
    this.paidDate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 1, color: const Color(0xFFFAFAFA)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Image
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: AppColors.basePaleGrey,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x28000000),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: imageUrl == null
                        ? const Icon(Icons.image, color: AppColors.baseGrey)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  // Property Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (installment != null)
                                    Text(
                                      installment!,
                                      style: const TextStyle(
                                        color: AppColors.baseDarkGrey,
                                        fontSize: 10,
                                        fontFamily: 'Anuphan',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  if (tenantName != null)
                                    Text(
                                      'ผู้เช่า: $tenantName',
                                      style: const TextStyle(
                                        color: AppColors.baseDarkGrey,
                                        fontSize: 10,
                                        fontFamily: 'Anuphan',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Call Button
                            GestureDetector(
                              onTap: onCall,
                              child: SvgPicture.asset(
                                'assets/icons/phone.svg',
                                width: 24,
                                height: 24,
                                fit: BoxFit.scaleDown,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.baseGrey,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.baseBlack,
                            fontSize: 14,
                            fontFamily: 'Anuphan',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Separator
            Divider(color: AppColors.basePaleGrey),
            const SizedBox(height: 16),
            // Price and Due Date Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '฿$price',
                            style: const TextStyle(
                              color: Color(0xFFF04437),
                              fontSize: 18,
                              fontFamily: 'Anuphan',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '/ เดือน',
                            style: TextStyle(
                              color: Color(0xFF717680),
                              fontSize: 12,
                              fontFamily: 'Anuphan',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      if (isOverdue && fineAmount != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '+ ค่าปรับ $fineAmount บาท',
                          style: const TextStyle(
                            color: Color(0xFFF04437),
                            fontSize: 12,
                            fontFamily: 'Anuphan',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                  AppBadge(
                    label: isPaid
                        ? (paidDate ?? '')
                        : (isOverdue
                              ? (overdueStatus ?? '')
                              : 'กำหนดชำระ : $dueDate'),
                    color: isPaid
                        ? BadgeColor.green
                        : (isOverdue
                              ? BadgeColor.red
                              : (dueDate.contains('วันนี้')
                                    ? BadgeColor.blue
                                    : BadgeColor.default_)),
                    style: isPaid ? BadgeStyle.done : BadgeStyle.plain,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    fontSize: 12,
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
