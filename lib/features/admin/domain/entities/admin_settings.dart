class AdminSettings {
  const AdminSettings({
    required this.platformName,
    required this.supportEmail,
    required this.maintenanceMode,
    required this.notificationsEnabled,
    required this.manualProviderApproval,
    required this.twoFactorRequired,
    required this.taxRate,
  });

  final String platformName;
  final String supportEmail;
  final bool maintenanceMode;
  final bool notificationsEnabled;
  final bool manualProviderApproval;
  final bool twoFactorRequired;
  final double taxRate;

  AdminSettings copyWith({
    String? platformName,
    String? supportEmail,
    bool? maintenanceMode,
    bool? notificationsEnabled,
    bool? manualProviderApproval,
    bool? twoFactorRequired,
    double? taxRate,
  }) {
    return AdminSettings(
      platformName: platformName ?? this.platformName,
      supportEmail: supportEmail ?? this.supportEmail,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      manualProviderApproval:
          manualProviderApproval ?? this.manualProviderApproval,
      twoFactorRequired: twoFactorRequired ?? this.twoFactorRequired,
      taxRate: taxRate ?? this.taxRate,
    );
  }
}
