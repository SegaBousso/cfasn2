import 'package:flutter/material.dart';
import 'admin_user_manager.dart';
import '../../../models/user_model.dart';
import 'widgets/user_card.dart';
import 'widgets/user_filters.dart';
import 'widgets/user_form_dialog.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AdminUserManager _userManager = AdminUserManager();
  String _selectedFilter = 'Tous';
  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = true;
  final Set<String> _selectedUsers = {};

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final users = await _userManager.allUsers;
      if (mounted) {
        setState(() {
          _users = users;
          _filteredUsers = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des utilisateurs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterUsers() {
    setState(() {
      _filteredUsers = _users.where((user) {
        final matchesSearch =
            user.displayName.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ) ||
            user.email.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );

        final matchesFilter =
            _selectedFilter == 'Tous' ||
            (_selectedFilter == 'Actifs' && user.isVerified) ||
            (_selectedFilter == 'Inactifs' && !user.isVerified) ||
            (_selectedFilter == 'Clients' && user.role == UserRole.client) ||
            (_selectedFilter == 'Prestataires' &&
                user.role == UserRole.provider) ||
            (_selectedFilter == 'Admins' && user.role == UserRole.admin);

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => UserFormDialog(
        onUserSaved: (user) async {
          try {
            await _userManager.addUser(user);
            _loadUsers();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Utilisateur créé avec succès'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erreur lors de la création: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _editUser(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => UserFormDialog(
        user: user,
        onUserSaved: (updatedUser) async {
          try {
            await _userManager.updateUser(updatedUser);
            _loadUsers();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Utilisateur modifié avec succès'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erreur lors de la modification: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _deleteUser(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Voulez-vous vraiment supprimer l\'utilisateur "${user.displayName}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _userManager.deleteUser(user.uid);
                _loadUsers();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Utilisateur supprimé avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la suppression: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _selectAllUsers() {
    setState(() {
      if (_selectedUsers.length == _filteredUsers.length) {
        _selectedUsers.clear();
      } else {
        _selectedUsers.clear();
        _selectedUsers.addAll(_filteredUsers.map((u) => u.uid));
      }
    });
  }

  void _deleteSelectedUsers() {
    if (_selectedUsers.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Voulez-vous vraiment supprimer ${_selectedUsers.length} utilisateur(s) ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _userManager.deleteMultipleUsers(_selectedUsers.toList());
                setState(() => _selectedUsers.clear());
                _loadUsers();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Utilisateurs supprimés avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la suppression: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Utilisateurs'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading:
            false, // Empêche l'affichage de l'icône de retour
        actions: [
          if (_selectedUsers.isNotEmpty) ...[
            IconButton(
              onPressed: _deleteSelectedUsers,
              icon: const Icon(Icons.delete),
              tooltip: 'Supprimer la sélection',
            ),
            IconButton(
              onPressed: _selectAllUsers,
              icon: Icon(
                _selectedUsers.length == _filteredUsers.length
                    ? Icons.deselect
                    : Icons.select_all,
              ),
              tooltip: _selectedUsers.length == _filteredUsers.length
                  ? 'Tout désélectionner'
                  : 'Tout sélectionner',
            ),
          ],
          IconButton(
            onPressed: _loadUsers,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche et filtres
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Barre de recherche
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un utilisateur...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                // Filtres
                UserFilters(
                  selectedFilter: _selectedFilter,
                  onFilterChanged: (filter) {
                    setState(() => _selectedFilter = filter);
                    _filterUsers();
                  },
                ),
              ],
            ),
          ),
          // Stats rapides
          if (!_isLoading) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildStatChip(
                    'Total',
                    _users.length.toString(),
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    'Actifs',
                    _users.where((u) => u.isVerified).length.toString(),
                    Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    'Prestataires',
                    _users
                        .where((u) => u.role == UserRole.provider)
                        .length
                        .toString(),
                    Colors.orange,
                  ),
                  if (_selectedUsers.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _buildStatChip(
                      'Sélectionnés',
                      _selectedUsers.length.toString(),
                      Colors.purple,
                    ),
                  ],
                ],
              ),
            ),
          ],
          // Liste des utilisateurs
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Aucun utilisateur trouvé',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return UserCard(
                        user: user,
                        isSelected: _selectedUsers.contains(user.uid),
                        onSelectionChanged: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedUsers.add(user.uid);
                            } else {
                              _selectedUsers.remove(user.uid);
                            }
                          });
                        },
                        onEdit: () => _editUser(user),
                        onDelete: () => _deleteUser(user),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "users_management_fab",
        onPressed: _showAddUserDialog,
        tooltip: 'Ajouter un utilisateur',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Chip(
      label: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }
}
