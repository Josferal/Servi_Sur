class AdminRoleConfig {
  const AdminRoleConfig({
    required this.name,
    required this.description,
    required this.users,
    required this.permissions,
  });

  final String name;
  final String description;
  final int users;
  final List<String> permissions;
}
