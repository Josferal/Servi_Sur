# Firestore Orders Setup

Esta fase conecta solicitudes y ordenes reales con Cloud Firestore. Storage para adjuntos ya existe; mapas reales, notificaciones, pagos, Cloud Functions y custom claims siguen pendientes.

## Colecciones

### `serviceRequests/{requestId}`

Campos esperados:

- `id`
- `clientId`
- `clientName`
- `clientEmail`
- `serviceId`
- `serviceTitle`
- `categoryId`
- `categoryName`
- `providerId`
- `providerName`
- `description`
- `addressText`
- `scheduledDate`
- `scheduledTime`
- `estimatedPrice`
- `status`
- `createdAt`
- `updatedAt`

Estados: `pending`, `accepted`, `rejected`, `cancelled`, `convertedToOrder`.

### `orders/{orderId}`

Campos esperados:

- `id`
- `requestId`
- `clientId`
- `clientName`
- `clientEmail`
- `serviceId`
- `serviceTitle`
- `categoryId`
- `categoryName`
- `providerId`
- `providerName`
- `description`
- `addressText`
- `scheduledDate`
- `scheduledTime`
- `totalAmount`
- `status`
- `trackingStatus`
- `imageUrls`
- `imagePaths`
- `attachments`
- `createdAt`
- `updatedAt`

Estados de orden: `pending`, `accepted`, `inProgress`, `completed`, `cancelled`.

Nota de compatibilidad: el modelo Dart todavia acepta `active` para leer ordenes mock o datos antiguos, pero las ordenes nuevas de Firestore se crean como `pending`.

Estados de tracking: `requested`, `assigned`, `onTheWay`, `arrived`, `working`, `completed`.

## Crear una orden desde la app

1. Iniciar sesion con un usuario cliente activo.
2. Abrir `/home` o `/services`.
3. Entrar a un servicio.
4. Tocar `SOLICITAR SERVICIO`.
5. Completar fecha, horario, direccion y descripcion.
6. Confirmar solicitud.
7. La app crea un documento en `serviceRequests`, lo marca como `convertedToOrder` y crea un documento en `orders`.
8. Al finalizar navega a `/tracking?orderId={orderId}`.

## Probar `/order-summary`

1. Seleccionar un servicio.
2. Completar campos requeridos.
3. Confirmar.
4. Validar en Firestore que existan documentos en `serviceRequests` y `orders`.
5. Si Firestore falla, la UI muestra un error amigable.

## Probar `/activity`

1. Crear una orden desde la app.
2. Abrir `/activity`.
3. El cliente debe ver sus ordenes por `clientId`.
4. Un proveedor debe ver ordenes donde `providerId` coincida con su uid.
5. Un admin es redirigido al dashboard admin.

## Probar `/tracking`

1. Abrir tracking desde la confirmacion o desde `/activity`.
2. Confirmar que carga servicio, proveedor, direccion, estado y trackingStatus.
3. Cambiar manualmente `trackingStatus` en Firestore y verificar que la pantalla se actualiza.
4. Abrir `/tracking` sin `orderId` y confirmar que muestra un mensaje amigable.
5. Abrir `/tracking?orderId=no-existe` y confirmar que informa que la orden no existe.

## Checklist de pruebas manuales

- Registrar o iniciar sesion con un cliente activo.
- Entrar a `/service/:id` desde `/home` o `/services`.
- Confirmar que `SOLICITAR SERVICIO` exige sesion activa.
- Completar `/order-summary` con fecha, horario, direccion y descripcion.
- Confirmar que se crea un documento en `serviceRequests`.
- Confirmar que la solicitud queda con `status: convertedToOrder`.
- Confirmar que se crea un documento en `orders`.
- Confirmar que la navegacion termina en `/tracking?orderId={orderId}`.
- Abrir `/activity` y verificar que el cliente ve solo sus ordenes.
- Cambiar el usuario a provider y verificar que solo ve ordenes donde `providerId` coincide con su uid.
- Cambiar el usuario a admin y verificar que `/activity` redirige a `/admin`.
- Cambiar manualmente `trackingStatus` y confirmar que `/tracking` se actualiza.

## Casos de error esperados

- Usuario sin sesion en `/order-summary`: redireccion a `/login`.
- Servicio no seleccionado o inexistente: mensaje amigable en la pantalla.
- Campos requeridos vacios: validacion local del formulario.
- Error de Firestore al crear orden: mensaje amigable y sin pantalla en blanco.
- Error de Firestore en `/activity`: fallback temporal a mocks con aviso visible.
- `/tracking` sin `orderId`: mensaje para volver a actividad.
- `/tracking` con `orderId` inexistente: mensaje de orden no encontrada.

## Limitaciones

- El mapa sigue siendo visual temporal.
- Las fotos se suben a Firebase Storage y en Firestore solo se guardan URLs, paths y metadata.
- No hay notificaciones push.
- No hay pagos reales.
- No hay asignacion automatica avanzada de proveedor.
- No hay Google Maps real ni tracking GPS real.
- No hay Cloud Functions ni custom claims para automatizar asignaciones.
- No hay chat en tiempo real.
