import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../home/pages/home_screen.dart';

class AllActivitiesScreen extends StatelessWidget {
  const AllActivitiesScreen({super.key});

  static const List<ActivityItem> _allActivities = [
    ActivityItem(
      title: 'ตัวอย่างประชาสัมพันธ์',
      description:
          'Figma Ipsum Component Variant Main Layer. Edit Effect Pencil Draft Pixel Underline. Scale Figma Draft Rotate Invite Figma Italic Compo...',
      imageUrl:
          'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=200&h=200&fit=crop',
      type: ActivityType.publicRelations,
    ),
    ActivityItem(
      title: 'ตัวอย่างข่าวสาร',
      description:
          'Figma Ipsum Component Variant Main Layer. Edit Effect Pencil Draft Pixel Underline. Scale...',
      imageUrl:
          'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=200&h=200&fit=crop',
      type: ActivityType.news,
      metadata: 'ก้องเกียร การธุรกิจเลิศ • 12 นาที',
    ),
    ActivityItem(
      title: 'ตัวอย่างกิจกรรม',
      description:
          'Figma Ipsum Component Variant Main Layer. Edit Effect Pencil Draft Pixel Underline. Scale...',
      imageUrl:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=200&h=200&fit=crop',
      type: ActivityType.activity,
      metadata: '24 ธ.ค. 2568, 12:00 น.',
    ),
    ActivityItem(
      title: 'ตัวอย่างประชาสัมพันธ์ 2',
      description:
          'Figma Ipsum Component Variant Main Layer. Edit Effect Pencil Draft Pixel Underline. Scale Figma Draft Rotate Invite Figma Italic Compo...',
      imageUrl:
          'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=200&h=200&fit=crop',
      type: ActivityType.publicRelations,
    ),
    ActivityItem(
      title: 'ตัวอย่างข่าวสาร 2',
      description:
          'Figma Ipsum Component Variant Main Layer. Edit Effect Pencil Draft Pixel Underline. Scale...',
      imageUrl:
          'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=200&h=200&fit=crop',
      type: ActivityType.news,
      metadata: 'ก้องเกียร การธุรกิจเลิศ • 15 นาที',
    ),
    ActivityItem(
      title: 'ตัวอย่างกิจกรรม 2',
      description:
          'Figma Ipsum Component Variant Main Layer. Edit Effect Pencil Draft Pixel Underline. Scale...',
      imageUrl:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=200&h=200&fit=crop',
      type: ActivityType.activity,
      metadata: '25 ธ.ค. 2568, 14:00 น.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('กิจกรรม'),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.baseDarkGrey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'รวมกิจกรรม ข่าวสาร และประชาสัมพันธ์ที่น่าสนใจ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.baseDarkGrey,
              ),
            ),
            const SizedBox(height: 16),
            ..._allActivities.map(
              (activity) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ActivityCard(activity: activity),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final ActivityItem activity;
  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.baseDarkGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.baseDarkGrey,
                    height: 1.35,
                  ),
                ),
                if (activity.metadata != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (activity.type == ActivityType.activity)
                        SvgPicture.asset(
                          'assets/icons/calendar.svg',
                          width: 10,
                          height: 10,
                          colorFilter: const ColorFilter.mode(
                            AppColors.baseDarkGrey,
                            BlendMode.srcIn,
                          ),
                        ),
                      if (activity.type == ActivityType.activity)
                        const SizedBox(width: 4),
                      if (activity.type == ActivityType.news)
                        SvgPicture.asset(
                          'assets/icons/clock.svg',
                          width: 10,
                          height: 10,
                          colorFilter: const ColorFilter.mode(
                            AppColors.baseDarkGrey,
                            BlendMode.srcIn,
                          ),
                        ),
                      if (activity.type == ActivityType.news)
                        const SizedBox(width: 4),
                      Text(
                        activity.metadata!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.baseDarkGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: activity.imageUrl,
              width: 76,
              height: 76,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 76,
                height: 76,
                color: AppColors.basePaleGrey,
              ),
              errorWidget: (context, url, error) => Container(
                width: 76,
                height: 76,
                color: AppColors.basePaleGrey,
                child: const Icon(
                  Icons.error_outline,
                  color: AppColors.baseGrey,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
