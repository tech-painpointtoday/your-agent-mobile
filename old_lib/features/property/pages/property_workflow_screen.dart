import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/widgets/custom_header.dart';
// import 'package:youragent/widgets/footer.dart';

/// Property Workflow Screen - shows property approval workflow
class PropertyWorkflowScreen extends StatelessWidget {
  final Function(Locale) changeLocale;

  const PropertyWorkflowScreen({super.key, required this.changeLocale});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.wildSand,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(changeLocale: changeLocale),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Property Workflow',
                      style: GoogleFonts.anuphan(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.baseDarkGrey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.bonJour,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Workflow steps
                          _buildWorkflowStep('1', 'Submitted', true),
                          _buildWorkflowStep('2', 'Under Review', true),
                          _buildWorkflowStep('3', 'Approved', false),
                          _buildWorkflowStep('4', 'Published', false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflowStep(String step, String label, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.jungleGreen
                  : AppColors.shadyLady.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: AppColors.white, size: 20)
                  : Text(
                      step,
                      style: GoogleFonts.anuphan(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.shadyLady,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.anuphan(
                fontSize: 16,
                fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                color: isCompleted
                    ? AppColors.baseDarkGrey
                    : AppColors.shadyLady,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
