import 'package:flutter/material.dart';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/overflow_safe_widgets.dart';

/// Header card widget for the complete profile screen
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            const AdaptiveText(
              'Bienvenue !',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const AdaptiveText(
              'Pour finaliser votre inscription, veuillez compléter les informations suivantes :',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
