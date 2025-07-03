import 'package:flutter/material.dart';
import '../../../../utils/responsive_helper.dart';
import '../../../../widgets/overflow_safe_widgets.dart';
import 'form_sections/form_sections.dart';

class ServiceBody extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const ServiceBody({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return OverflowSafeArea(
      child: ResponsiveHelper.getDeviceType(context) == DeviceType.mobile
          ? _buildMobileLayout()
          : _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ServiceBasicInfoSection(),
            SizedBox(height: 24),
            ServiceImageSection(),
            SizedBox(height: 24),
            ServiceCategorySection(),
            SizedBox(height: 24),
            ServicePriceSection(),
            SizedBox(height: 24),
            ServiceTagsSection(),
            SizedBox(height: 24),
            ServiceStatusSection(),
            SizedBox(height: 32),
            ServiceActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Form(
            key: formKey,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          ServiceBasicInfoSection(),
                          SizedBox(height: 24),
                          ServiceCategorySection(),
                          SizedBox(height: 24),
                          ServicePriceSection(),
                          SizedBox(height: 24),
                          ServiceTagsSection(),
                        ],
                      ),
                    ),
                    SizedBox(width: 32),
                    Expanded(
                      child: Column(
                        children: [
                          ServiceImageSection(),
                          SizedBox(height: 24),
                          ServiceStatusSection(),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),
                ServiceActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
