import 'package:flutter/material.dart';

/// Action button for completing the profile
class ProfileActionButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const ProfileActionButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Finaliser mon profil',
                style: TextStyle(fontSize: 16),
              ),
      ),
    );
  }
}
