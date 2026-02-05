import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';

class MoneyPropertyCard extends StatelessWidget {
  final String title;
  final String location;
  final String price;
  final String dueDate;
  final String? imageUrl;
  final VoidCallback onCall;

  const MoneyPropertyCard({
    super.key,
    required this.title,
    required this.location,
    required this.price,
    required this.dueDate,
    this.imageUrl,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          // Project Image
          Container(
            width: 95,
            height: double.infinity,
            color: AppColors.basePaleGrey,
            child: imageUrl != null
                ? Image.network(imageUrl!, fit: BoxFit.cover)
                : const Icon(Icons.image, color: AppColors.baseGrey),
          ),
          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.black,
                      fontFamily: 'Anuphan',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: AppColors.baseGrey,
                      fontFamily: 'Anuphan',
                    ),
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '฿$price',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE1393C),
                          fontFamily: 'Anuphan',
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '/ เดือน',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: AppColors.baseGrey,
                          fontFamily: 'Anuphan',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'กำหนดชำระ: $dueDate',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: AppColors.baseGrey,
                        fontFamily: 'Anuphan',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Call Button
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  onPressed: onCall,
                  iconSize: 13,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Color(0xFFF9F9F9)),
                    ),
                    elevation: 1,
                    shadowColor: const Color(0x1A0A0C12),
                  ),
                  icon: SvgPicture.asset(
                    'assets/icons/phone.svg',
                    width: 12,
                    height: 12,
                    colorFilter: const ColorFilter.mode(
                      AppColors.baseGrey,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
