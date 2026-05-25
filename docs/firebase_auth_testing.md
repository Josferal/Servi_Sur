# Pruebas manuales de Firebase Auth y roles

Esta guia valida la Fase 1.5: autenticacion real, perfil base en Firestore, guards de rutas y acceso por rol. Los servicios, ordenes, mapas, Storage y notificaciones siguen fuera de alcance por ahora.

## Preparacion

1. Ejecutar la app web:

   ```powershell
   flutter run -d edge
   ```

2. Confirmar en Firebase Console que el proyecto tiene habilitado el proveedor Email/Password en Authentication.
3. Abrir Firestore Database y ubicar la coleccion `users`.

## Cliente

1. Ir a `/register`.
2. Registrar un usuario con nombre, correo real de prueba y contrasena elegida localmente para la prueba.
3. Confirmar que la app redirige a `/home`.
4. En Firestore, verificar que exista `users/{uid}` con:
   - `uid`
   - `name`
   - `email`
   - `role: client`
   - `status: active`
   - `createdAt`
   - `updatedAt`
5. Ir a `/profile` y confirmar que se muestran `name`, `email`, `role` y `status`.
6. Cerrar sesion desde `/profile`.
7. Volver a `/login` e iniciar sesion con el mismo usuario cliente.
8. Intentar abrir `/admin`; debe redirigir a `/home`.
9. Intentar abrir `/provider`; debe redirigir a `/home`.

## Admin

1. Crear otro usuario desde `/register` o desde Firebase Authentication.
2. En Firestore, abrir `users/{uid}` de ese usuario.
3. Cambiar manualmente `role` a `admin`.
4. Mantener `status` como `active`.
5. Cerrar sesion si habia otra cuenta activa.
6. Iniciar sesion con ese usuario desde `/login` o `/admin/login`.
7. Confirmar que la app redirige a `/admin`.
8. Intentar abrir rutas de cliente como `/home` o `/profile`; debe volver a `/admin`.

## Provider

1. Crear otro usuario desde `/register` o desde Firebase Authentication.
2. En Firestore, abrir `users/{uid}` de ese usuario.
3. Cambiar manualmente `role` a `provider`.
4. Mantener `status` como `active`.
5. Cerrar sesion si habia otra cuenta activa.
6. Iniciar sesion con ese usuario desde `/login`.
7. Confirmar que la app redirige a `/provider`.
8. Intentar abrir `/admin`; debe volver a `/provider`.

## Usuarios inactivos o bloqueados

1. En Firestore, cambiar `status` a `inactive`, `blocked` o `suspended` para un usuario de prueba.
2. Intentar iniciar sesion.
3. La app debe cerrar la sesion y mostrar un error de cuenta inactiva o bloqueada.
4. Restaurar `status: active` para seguir probando.

## Usuarios sin documento Firestore

1. Crear un usuario directamente en Firebase Authentication sin crear documento en `users`.
2. Iniciar sesion con ese usuario.
3. La app debe crear un perfil base seguro en `users/{uid}` con `role: client` y `status: active`.
4. Confirmar que no hay crash y que el usuario entra como cliente.

## Notas de seguridad

- Para pruebas iniciales, el rol `admin` se puede asignar manualmente en Firestore.
- En produccion, el rol `admin` debe moverse a custom claims o manejarse con Cloud Functions.
- Nunca se deben guardar contrasenas ni credenciales admin en el codigo.
- Las reglas de Firestore son la barrera de seguridad; los guards del frontend solo mejoran la experiencia de usuario.
