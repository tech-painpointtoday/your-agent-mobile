import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/theme/app_colors.dart';

class MoneyPropertyCard extends StatelessWidget {
  final String? installment;
  final String? tenantName;
  final String title;
  final String? location;
  final String price;
  final String dueDate;
  final String? imageUrl;
  final VoidCallback onCall;

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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          Row(
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
                                    color: Color(0xFF717680),
                                    fontSize: 10,
                                    fontFamily: 'Anuphan',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              if (tenantName != null)
                                Text(
                                  'ผู้เช่า: $tenantName',
                                  style: const TextStyle(
                                    color: Color(0xFF717680),
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
                        color: Color(0xFF181D27),
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
          const SizedBox(height: 16),
          // Separator
          Container(
            width: double.infinity,
            height: 1,
            color: const Color(0xFFF5F5F5),
          ),
          const SizedBox(height: 16),
          // Price and Due Date Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: dueDate.contains('วันนี้')
                      ? const Color(0xFFEFF8FF)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'กำหนดชำระ : $dueDate',
                  style: TextStyle(
                    color: dueDate.contains('วันนี้')
                        ? const Color(0xFF175CD3)
                        : const Color(0xFF717680),
                    fontSize: 12,
                    fontFamily: 'Anuphan',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
