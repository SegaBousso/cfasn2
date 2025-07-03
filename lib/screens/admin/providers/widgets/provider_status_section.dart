import 'package:flutter/material.dart';
import '../../../../utils/responsive_helper.dart';

class ProviderStatusSection extends StatelessWidget {
  final bool isActive;
  final bool isAvailable;
  final bool isVerified;
  final Function(bool) onActiveChanged;
  final Function(bool) onAvailableChanged;
  final Function(bool) onVerifiedChanged;

  const ProviderStatusSection({
    super.key,
    required this.isActive,
    required this.isAvailable,
    required this.isVerified,
    required this.onActiveChanged,
    required this.onAvailableChanged,
    required this.onVerifiedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dimensions = ResponsiveHelper.getDimensions(context);

    return Card(
      child: Padding(
        padding: ResponsiveHelper.getScreenPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statuts',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveHelper.getFontSize(
                  context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
              ),
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
            if (dimensions.deviceType == DeviceType.mobile)
              _buildMobileLayout(context)
            else
              _buildDesktopLayout(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildStatusTile(
          context: context,
          title: 'Actif',
          subtitle: 'Le prestataire peut recevoir des demandes',
          value: isActive,
          onChanged: onActiveChanged,
          icon: Icons.power_settings_new,
          activeColor: Colors.green,
        ),
        _buildStatusTile(
          context: context,
          title: 'Disponible',
          subtitle: 'Actuellement disponible pour de nouveaux projets',
          value: isAvailable,
          onChanged: onAvailableChanged,
          icon: Icons.event_available,
          activeColor: Colors.blue,
        ),
        _buildStatusTile(
          context: context,
          title: 'Vérifié',
          subtitle: 'Profil vérifié par l\'administration',
          value: isVerified,
          onChanged: onVerifiedChanged,
          icon: Icons.verified,
          activeColor: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final spacing = ResponsiveHelper.getSpacing(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCompactStatusTile(
                context: context,
                title: 'Actif',
                value: isActive,
                onChanged: onActiveChanged,
                icon: Icons.power_settings_new,
                activeColor: Colors.green,
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: _buildCompactStatusTile(
                context: context,
                title: 'Disponible',
                value: isAvailable,
                onChanged: onAvailableChanged,
                icon: Icons.event_available,
                activeColor: Colors.blue,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing / 2),
        _buildCompactStatusTile(
          context: context,
          title: 'Vérifié par l\'administration',
          value: isVerified,
          onChanged: onVerifiedChanged,
          icon: Icons.verified,
          activeColor: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatusTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
    required Color activeColor,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context) / 2),
      color: value ? activeColor.withValues(alpha: 0.1) : null,
      child: SwitchListTile(
        title: Row(
          children: [
            Icon(
              icon,
              color: value ? activeColor : Colors.grey,
              size: ResponsiveHelper.getValue<double>(
                context,
                mobile: 20,
                tablet: 22,
                desktop: 24,
              ),
            ),
            SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context),
                fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                color: value ? activeColor : null,
              ),
            ),
          ],
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(
              context,
              mobile: 12,
              tablet: 13,
              desktop: 14,
            ),
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
      ),
    );
  }

  Widget _buildCompactStatusTile({
    required BuildContext context,
    required String title,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
    required Color activeColor,
  }) {
    return Container(
      padding: ResponsiveHelper.getScreenPadding(context) / 2,
      decoration: BoxDecoration(
        color: value ? activeColor.withValues(alpha: 0.1) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value
              ? activeColor.withValues(alpha: 0.3)
              : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: value ? activeColor : Colors.grey,
            size: ResponsiveHelper.getValue<double>(
              context,
              mobile: 18,
              tablet: 20,
              desktop: 22,
            ),
          ),
          SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context),
                fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                color: value ? activeColor : Colors.grey.shade700,
              ),
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: activeColor),
        ],
      ),
    );
  }
}
