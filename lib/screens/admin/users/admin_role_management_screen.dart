import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:service/models/user_model.dart';
import 'package:service/utils/responsive_helper.dart';
import 'package:service/widgets/overflow_safe_widgets.dart';

class AdminRoleManagementScreen extends StatefulWidget {
  const AdminRoleManagementScreen({super.key});

  @override
  State<AdminRoleManagementScreen> createState() =>
      _AdminRoleManagementScreenState();
}

class _AdminRoleManagementScreenState extends State<AdminRoleManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<UserModel> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      final users = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    }
  }

  Future<void> _updateUserRole(UserModel user, UserRole newRole) async {
    try {
      await _firestore.collection('users').doc(user.uid).update({
        'role': newRole.name,
        'isAdmin': newRole == UserRole.admin,
      });

      setState(() {
        final index = _users.indexWhere((u) => u.uid == user.uid);
        if (index != -1) {
          _users[index] = user.copyWith(
            role: newRole,
            isAdmin: newRole == UserRole.admin,
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rôle mis à jour pour ${user.displayName}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    }
  }

  List<UserModel> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    return _users
        .where(
          (user) =>
              user.displayName.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              user.email.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des rôles utilisateurs'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ResponsiveBuilder(
        builder: (context, dimensions) {
          return OverflowSafeArea(
            child: Column(
              children: [
                // Barre de recherche
                Padding(
                  padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Rechercher un utilisateur...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),

                // Liste des utilisateurs
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return _buildUserCard(user);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getSpacing(context),
        vertical: ResponsiveHelper.getSpacing(context) * 0.5,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.photoURL != null
              ? NetworkImage(user.photoURL!)
              : null,
          child: user.photoURL == null
              ? Text(
                  user.displayName.isNotEmpty
                      ? user.displayName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
              : null,
        ),
        title: Text(
          user.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getRoleColor(user.role).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.role.label,
                style: TextStyle(
                  color: _getRoleColor(user.role),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<UserRole>(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => UserRole.values
              .map(
                (role) => PopupMenuItem(
                  value: role,
                  child: Row(
                    children: [
                      Icon(
                        _getRoleIcon(role),
                        color: _getRoleColor(role),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(role.label),
                      if (role == user.role) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.check, size: 16, color: Colors.green),
                      ],
                    ],
                  ),
                  enabled: role != user.role,
                ),
              )
              .toList(),
          onSelected: (UserRole newRole) {
            _showRoleChangeDialog(user, newRole);
          },
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.client:
        return Colors.blue;
      case UserRole.provider:
        return Colors.green;
      case UserRole.admin:
        return Colors.red;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.client:
        return Icons.person;
      case UserRole.provider:
        return Icons.work;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }

  void _showRoleChangeDialog(UserModel user, UserRole newRole) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer le rôle'),
        content: Text(
          'Voulez-vous vraiment changer le rôle de ${user.displayName} '
          'de "${user.role.label}" vers "${newRole.label}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateUserRole(user, newRole);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getRoleColor(newRole),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}
