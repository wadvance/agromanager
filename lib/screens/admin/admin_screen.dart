import 'package:flutter/material.dart';
import '../../services/role_service.dart';
import '../../config/constants.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      _users = await RoleService.getAllUsers();
    } catch (e) {
      _error = 'Error al cargar usuarios: $e';
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Administración'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text(_error!),
                      SizedBox(height: 16),
                      FilledButton(
                          onPressed: _loadUsers,
                          child: Text('Reintentar')),
                    ],
                  ),
                )
              : _users.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No hay usuarios registrados'),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadUsers,
                      child: ListView.builder(
                        padding: EdgeInsets.all(12),
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          final role = user['role'] as String;
                          final email = user['email'] as String;
                          final name = user['name'] as String;

                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    _roleColor(role).withAlpha(30),
                                child: Icon(Icons.person,
                                    color: _roleColor(role)),
                              ),
                              title: Text(name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(email),
                              trailing: DropdownButton<String>(
                                value: role,
                                underline: SizedBox(),
                                items: RolePermissions.allRoles
                                    .map((r) => DropdownMenuItem(
                                          value: r,
                                          child: Row(
                                            mainAxisSize:
                                                MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration:
                                                    BoxDecoration(
                                                  color: _roleColor(r),
                                                  shape:
                                                      BoxShape.circle,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Text(RolePermissions
                                                  .getRoleName(r)),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (newRole) async {
                                  if (newRole == null) return;
                                  try {
                                    await RoleService.setUserRole(
                                        user['uid'], newRole);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                          'Rol actualizado a ${RolePermissions.getRoleName(newRole)}'),
                                    ));
                                    _loadUsers();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content:
                                          Text('Error: $e'),
                                    ));
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case AppConstants.roleSuperAdmin:
        return Colors.red;
      case AppConstants.roleAdmin:
        return Colors.orange;
      case AppConstants.roleCapataz:
        return Colors.blue;
      case AppConstants.roleUsuario:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
