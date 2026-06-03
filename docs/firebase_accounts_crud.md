# Firebase Accounts CRUD

## Colecciones

### `users/{uid}`

Documento base:

```json
{
  "uid": "firebase-auth-uid",
  "id": "firebase-auth-uid",
  "name": "Nombre visible",
  "fullName": "Nombre visible",
  "email": "usuario@example.com",
  "phone": "+506 8888 0000",
  "avatarUrl": "https://...",
  "role": "client",
  "status": "active",
  "createdAt": "serverTimestamp",
  "updatedAt": "serverTimestamp",
  "lastLoginAt": "serverTimestamp"
}
```

Roles validos: `client`, `provider`, `admin`.

Estados validos: `active`, `inactive`, `suspended`, `deleted`.

### `adminActivity/{activityId}`

Registra acciones administrativas:

```json
{
  "adminId": "uid-admin",
  "targetUserId": "uid-afectado",
  "action": "user_updated",
  "previousValue": "opcional",
  "newValue": "opcional",
  "createdAt": "serverTimestamp"
}
```

Acciones usadas: `user_updated`, `user_blocked`, `user_unblocked`, `user_role_changed`, `user_activated`, `user_deactivated`, `user_deleted`.

## Campos Editables

Usuario autenticado:

- `name`
- `fullName`
- `phone`
- `avatarUrl`
- `updatedAt`
- `lastLoginAt`

El usuario normal no puede editar `role` ni `status`.

Administrador:

- `name`
- `fullName`
- `phone`
- `role`
- `status`
- `updatedAt`

## Implementacion Flutter

- `lib/shared/data/datasources/account_service.dart` centraliza lectura/listado/actualizacion de usuarios, cambio de contrasena y auditoria.
- `lib/features/admin/data/repositories/firebase_admin_repository.dart` implementa `AdminRepository` usando `users/{uid}` para cuentas reales.
- `MockAdminRepository` sigue disponible para fallback y pruebas.
- `lib/admin/repositories/firebase_admin_repository.dart` exporta el repositorio real para compatibilidad con la ruta solicitada.
- `ProfileScreen` permite editar nombre/telefono, cambiar contrasena con Firebase Auth y cerrar sesion.
- `AdminUsersScreen` lista usuarios, busca por nombre/correo/rol, filtra por rol/estado, muestra detalle, edita, bloquea/desbloquea y deja la creacion de cuentas como accion pendiente de Cloud Functions/Admin SDK.

## Reglas de Seguridad

`firestore.rules` mantiene acceso conservador:

- Nadie sin autenticar puede leer `users`.
- El dueno solo puede leer su documento.
- El dueno solo puede actualizar campos seguros y no puede cambiar `role` ni `status`.
- Admin activo puede listar, crear y actualizar usuarios.
- `adminActivity` solo puede leerse y crearse por admins activos.
- Las reglas existentes de `categories`, `services`, `serviceRequests` y `orders` se mantienen.

## Acciones Que Requieren Cloud Functions/Admin SDK

Estas acciones no deben implementarse directamente en Flutter para produccion:

- Crear usuarios admin sin iniciar sesion como la cuenta nueva.
- Eliminar usuarios de Firebase Auth.
- Deshabilitar usuarios en Firebase Auth.
- Asignar custom claims.
- Sincronizar `role` de Firestore con custom claims.

Estado actual: no existe carpeta `functions/`, asi que esta fase deja el flujo preparado desde Flutter/Firestore y documenta la necesidad de Functions para endurecimiento.

## Como Probar

1. Iniciar sesion con una cuenta cuyo `users/{uid}.role` sea `admin` y `status` sea `active`.
2. Abrir `/admin/users`.
3. Verificar listado desde Firestore.
4. Buscar por nombre, correo o rol.
5. Filtrar por rol y estado.
6. Editar nombre, telefono, rol y estado de un usuario.
7. Bloquear/desbloquear usando las acciones de la tabla.
8. Probar "Nuevo usuario" y confirmar que muestra la limitacion de Cloud Functions/Admin SDK.
9. Revisar que se escriban documentos en `adminActivity`.
10. Entrar como usuario normal a `/profile` y editar nombre/telefono.
11. Confirmar que el usuario normal no tiene controles para editar `role` o `status`.

## Limitaciones Actuales

- La creacion basica desde admin no se ejecuta en Flutter; debe moverse a Cloud Functions para no cambiar la sesion del administrador.
- El bloqueo actual cambia `users/{uid}.status`; deshabilitar Firebase Auth requiere Admin SDK.
- Eliminacion real de Auth no esta implementada en Flutter por seguridad.
- Avatar queda limitado a guardar `avatarUrl`; subida/seleccion de archivo queda pendiente aunque `firebase_storage` existe en dependencias.
- Custom claims quedan pendientes para produccion.
