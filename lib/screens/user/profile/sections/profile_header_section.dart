import 'package:flutter/material.dart';
import '../../../../models/models.dart';
import '../../../../utils/responsive_helper.dart';
import '../../../../widgets/overflow_safe_widgets.dart';
import '../widgets/profile_widgets.dart';

/// Section d'en-tête du profil utilisateur
class ProfileHeaderSection extends StatelessWidget {
  final UserModel user;
  final VoidCallback onChangeProfilePicture;

  const ProfileHeaderSection({
    super.key,
    required this.user,
    required this.onChangeProfilePicture,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveContainer(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          _buildProfileAvatar(context),
          const SizedBox(height: 16),
          _buildUserName(),
          const SizedBox(height: 8),
          VerificationBadge(isVerified: user.isVerified),
          const SizedBox(height: 16),
          _buildContactInfo(),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: user.photoURL != null
              ? NetworkImage(user.photoURL!)
              : null,
          child: user.photoURL == null
              ? Text(
                  user.displayName.isNotEmpty
                      ? user.displayName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.camera_alt,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: onChangeProfilePicture,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserName() {
    return AdaptiveText(
      user.displayName,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      maxLines: 1,
    );
  }

  Widget _buildContactInfo() {
    return Column(
      children: [
        _buildInfoRow(Icons.email, user.email),
        if (user.phoneNumber != null) ...[
          const SizedBox(height: 8),
          _buildInfoRow(Icons.phone, user.phoneNumber!),
        ],
        if (user.address != null) ...[
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on, user.address!, maxLines: 2),
        ],
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {int maxLines = 1}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: AdaptiveText(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            maxLines: maxLines,
          ),
        ),
      ],
    );
  }
}
