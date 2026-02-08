import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';
import '../../core/constants/app_colors.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.user;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchAllUsers();
    });
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("Create New User", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email Address",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Secure Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<UserRole>(
                initialValue: _selectedRole,
                items: UserRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role == UserRole.admin ? "Administrator" : "Standard User"),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedRole = val!),
                decoration: InputDecoration(
                  labelText: "Access Level",
                  fillColor: AppColors.primaryGreen.withOpacity(0.05),
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.isNotEmpty && 
                  _emailController.text.isNotEmpty && 
                  _phoneController.text.isNotEmpty && 
                  _passwordController.text.isNotEmpty) {
                
                final success = await Provider.of<UserProvider>(context, listen: false).addUser(
                  _nameController.text,
                  _emailController.text,
                  _phoneController.text,
                  _passwordController.text,
                  _selectedRole,
                );

                if (success && mounted) {
                  _nameController.clear();
                  _emailController.clear();
                  _phoneController.clear();
                  _passwordController.clear();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User created successfully")));
                } else if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to create user. Ensure all fields are valid.")));
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("All fields are required!")));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              minimumSize: const Size(100, 45),
            ),
            child: const Text("Create User"),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(User user) {
    _nameController.text = user.name;
    _emailController.text = user.email;
    _selectedRole = user.role;
    final phoneController = TextEditingController(text: user.phone ?? "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text("Edit User: ${user.name}", style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email Address",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<UserRole>(
                initialValue: _selectedRole,
                items: UserRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role == UserRole.admin ? "Administrator" : "Standard User"),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedRole = val!),
                decoration: InputDecoration(
                  labelText: "Access Level",
                  fillColor: AppColors.primaryGreen.withOpacity(0.05),
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 15),
              const Text("Password and Created At are non-editable.", style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.isNotEmpty && _emailController.text.isNotEmpty) {
                final success = await Provider.of<UserProvider>(context, listen: false).updateUser(
                  user.id,
                  {
                    'name': _nameController.text,
                    'email': _emailController.text,
                    'phone': phoneController.text,
                    'role': _selectedRole == UserRole.admin ? 'admin' : 'user',
                  },
                );
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User updated successfully")));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              minimumSize: const Size(100, 45),
            ),
            child: const Text("Save Changes"),
          ),
        ],
      ),
    );
  }

  String _maskPassword(String password) {
    if (password.isEmpty) return "N/A";
    return "*" * 8;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primaryGreen,
            expandedHeight: 120,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text("User Management", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              centerTitle: false,
              titlePadding: EdgeInsets.only(left: 60, bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Consumer<UserProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(100.0),
                      child: CircularProgressIndicator(color: AppColors.primaryGreen),
                    ),
                  );
                }

                if (provider.users.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(50.0),
                      child: Column(
                        children: [
                          Icon(Icons.people_outline, size: 60, color: Colors.grey),
                          SizedBox(height: 10),
                          Text("No users found", style: TextStyle(color: Colors.grey, fontSize: 16)),
                        ],
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(AppColors.primaryGreen.withOpacity(0.1)),
                      columnSpacing: 25,
                      columns: const [
                        DataColumn(label: Text("Name", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Email", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Phone", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Password", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Role", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Created At", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: provider.users.map((user) {
                        final isAdmin = user.role == UserRole.admin;
                        return DataRow(cells: [
                          DataCell(Text(user.name)),
                          DataCell(Text(user.email)),
                          DataCell(Text(user.phone ?? "N/A")),
                          DataCell(Text(_maskPassword(user.hashedPassword))),
                          DataCell(Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (isAdmin ? AppColors.primaryPeach : AppColors.primaryGreen).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isAdmin ? "ADMIN" : "USER",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isAdmin ? AppColors.primaryPeach : AppColors.primaryGreen),
                            ),
                          )),
                          DataCell(Text(user.createdAt.split(' ')[0])), // Show date only for brevity
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                                onPressed: () => _showEditUserDialog(user),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade300, size: 20),
                                onPressed: () => provider.deleteUser(user.id),
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddUserDialog,
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text("New User", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
