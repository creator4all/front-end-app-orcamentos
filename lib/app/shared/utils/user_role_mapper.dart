import '../widgets/budget_card_widget.dart';

/// Converte a string da role do usuário para o enum UserRole
/// Suporta roles em português (administrador, gestor, vendedor)
/// e em inglês (admin, manager, seller)
UserRole mapStringToUserRole(String? roleName) {
  if (roleName == null) return UserRole.seller;

  switch (roleName.toLowerCase()) {
    case 'administrador':
    case 'admin':
      return UserRole.admin;
    case 'gestor':
    case 'manager':
      return UserRole.manager;
    case 'vendedor':
    case 'seller':
    default:
      return UserRole.seller;
  }
}

/// Retorna o ID numérico da role baseado no nome
/// Administrador: 1, Gestor: 2, Vendedor: 3
int getRoleIdFromName(String? roleName) {
  if (roleName == null) return 3; // Default: Vendedor

  switch (roleName.toLowerCase()) {
    case 'administrador':
    case 'admin':
      return 1;
    case 'gestor':
    case 'manager':
      return 2;
    case 'vendedor':
    case 'seller':
    default:
      return 3;
  }
}

/// Verifica se um usuário com roleId `currentRoleId` pode editar
/// um usuário com roleId `targetRoleId`
/// Hierarquia: Admin (1) > Gestor (2) > Vendedor (3)
/// Um usuário pode editar outro se seu roleId é MENOR ou IGUAL ao do alvo
bool canEditUserWithRole(int currentRoleId, int targetRoleId) {
  return currentRoleId <= targetRoleId;
}
