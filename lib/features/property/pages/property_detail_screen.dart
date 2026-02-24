import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/features/property/widgets/property_detail.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/l10n/app_localizations.dart';

class PropertyDetailScreen extends StatefulWidget {
  final int? propertyId;
  final Property? property; // Allow passing existing property object

  const PropertyDetailScreen({super.key, this.propertyId, this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  bool _isLoading = true;
  Property? _property;
  String? _error;
  final _propertyApiService = DependencyInjection.propertyApiService;

  @override
  void initState() {
    super.initState();
    // If property is passed, use it initially but still fetch fresh data
    if (widget.property != null) {
      _property = widget.property;
      _isLoading = false; // Show content immediately
    }

    if (widget.property != null || widget.propertyId != null) {
      _fetchPropertyDetail();
    }
  }

  Future<void> _fetchPropertyDetail() async {
    final propertyIdInt = widget.propertyId ?? _property?.id;

    // If we don't have property yet, show loading
    if (_property == null) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      if (propertyIdInt == null) throw Exception('Invalid property ID');

      final property = await _propertyApiService.getPropertyById(propertyIdInt);
      if (property != null) {
        setState(() {
          _property = property;
          _isLoading = false;
        });
      } else {
        throw Exception('Property not found');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        body: const Center(
          child: SpinKitFadingCircle(
            color: AppColors.primary,
            size: 32,
          ),
        ),
      );
    }

    if (_error != null && _property == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.supportRedDeep,
              ),
              const SizedBox(height: 16),
              Text(_error ?? 'Property not found', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              SizedBox(
                width: 200,
                child: AppButton(
                  text: AppLocalizations.of(context).retryButton,
                  style: AppButtonStyle.outline,
                  onPressed: _fetchPropertyDetail,
                  height: 40,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        height: double.infinity,
        child: Stack(
          children: [
            if (_property != null)
              RefreshIndicator(
                color: Colors.white,
                backgroundColor: AppColors.primary,
                onRefresh: _fetchPropertyDetail,
                child: PropertyDetail(
                  isFullScreen: true,
                  key: ObjectKey(_property!),
                  property: _property!,
                ),
              ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x145A5A5A),
              blurRadius: 24,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.baseLightGrey),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SvgPicture.asset(
                    'assets/icons/chevron-left.svg',
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      AppColors.baseDarkGrey,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppButton(
                text: _property?.isDraft == true
                    ? AppLocalizations.of(context).addInfo
                    : AppLocalizations.of(context).editDataTitle,
                style: AppButtonStyle.primary,
                onPressed: () {
                  if (_property != null) {
                    // Draft properties: route to create flow to resume at correct step
                    // Completed properties: route to edit menu
                    final route = _property!.isDraft
                        ? '/property/create'
                        : '/property/edit';
                    context
                        .push(route, extra: _property)
                        .then((_) => _fetchPropertyDetail());
                  }
                },
                height: 44,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
