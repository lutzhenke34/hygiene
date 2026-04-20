class RolePermission {
  final String roleName;
  final bool canManageMitarbeiter;
  final bool canManageGeraete;
  final bool canManageKuehlgeraete;
  final bool canCreateHygieneAufgaben;
  final bool canCreateAufgaben;
  final bool canManageSchichten;
  final bool canSeeAllProtokolle;
  final bool canEditProtokolle;

  RolePermission({
    required this.roleName,
    required this.canManageMitarbeiter,
    required this.canManageGeraete,
    required this.canManageKuehlgeraete,
    required this.canCreateHygieneAufgaben,
    required this.canCreateAufgaben,
    required this.canManageSchichten,
    required this.canSeeAllProtokolle,
    required this.canEditProtokolle,
  });

  factory RolePermission.fromJson(Map<String, dynamic> json) {
    return RolePermission(
      roleName: json['role_name'] ?? '',
      canManageMitarbeiter: json['can_manage_mitarbeiter'] ?? false,
      canManageGeraete: json['can_manage_geraete'] ?? false,
      canManageKuehlgeraete: json['can_manage_kuehlgeraete'] ?? false,
      canCreateHygieneAufgaben: json['can_create_hygiene_aufgaben'] ?? false,
      canCreateAufgaben: json['can_create_aufgaben'] ?? false,
      canManageSchichten: json['can_manage_schichten'] ?? false,
      canSeeAllProtokolle: json['can_see_all_protokolle'] ?? true,
      canEditProtokolle: json['can_edit_protokolle'] ?? false,
    );
  }

  // Hilfsfunktionen
  bool get isAdmin => roleName.toLowerCase() == 'admin';
  bool get isLeadership => ['admin', 'betriebsleiter', 'kuechenchef'].contains(roleName.toLowerCase());
}