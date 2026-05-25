# Firebase Storage para fotos adjuntas

Esta fase permite adjuntar fotos desde `/order-summary`, subirlas a Firebase Storage y guardar sus referencias en Firestore para mostrarlas en `/tracking` y marcar la orden en `/activity`.

## Dependencias

- `firebase_storage`
- `image_picker`

`image_picker` se usa porque funciona en Flutter web y movil. No se guardan imagenes como base64 en Firestore.

## Ruta de Storage

Las fotos se guardan en:

```text
request_images/{uid}/{orderId}/{fileName}
```

- `uid`: usuario autenticado que crea la orden.
- `orderId`: orden real creada en Firestore.
- `fileName`: nombre seguro generado con timestamp.

## Campos en Firestore

En `serviceRequests/{requestId}` y `orders/{orderId}` se guardan:

- `imageUrls`: lista de URLs de descarga.
- `imagePaths`: lista de paths internos en Storage.
- `attachments`: lista de metadatos `{ url, path, fileName, contentType, sizeBytes }`.
- `photoUrls`: se mantiene en `serviceRequests` por compatibilidad con fases anteriores.

Los modelos toleran documentos sin estos campos y usan listas vacias.

## Como probar `/order-summary` con fotos

1. Iniciar sesion como cliente.
2. Abrir un servicio desde `/services` o `/home`.
3. Continuar hacia `/order-summary`.
4. Completar fecha, horario, direccion y descripcion.
5. Tocar `Adjuntar Fotos`.
6. Seleccionar hasta 3 imagenes de 5 MB o menos.
7. Confirmar la solicitud.
8. Verificar en Firebase Console:
   - Archivo en `Storage/request_images/{uid}/{orderId}/...`.
   - Campos `imageUrls`, `imagePaths` y `attachments` en `orders/{orderId}`.
   - Campos equivalentes en `serviceRequests/{requestId}`.

Si una foto falla al subir, la orden se mantiene creada y la app informa el problema. Las fotos que si subieron quedan asociadas.

## Como probar `/tracking` con fotos

1. Crear una orden con fotos.
2. Confirmar que la app navega a `/tracking?orderId={orderId}`.
3. Verificar que aparece la seccion `Fotos adjuntas`.
4. Abrir `/activity` y confirmar que la orden indica que tiene fotos.
5. Abrir la orden desde actividad y confirmar que las fotos siguen visibles.

## Reglas de seguridad

`storage.rules` permite:

- Usuario autenticado sube solo a `request_images/{suUid}/{orderId}/{fileName}`.
- Maximo 5 MB por archivo.
- Solo `contentType image/*`.
- Lectura y borrado solo por el mismo usuario dueño de la ruta.
- No hay lectura ni escritura publica.

`firestore.rules` permite al cliente dueño agregar `imageUrls`, `imagePaths`, `attachments` y `photoUrls` a sus propias solicitudes y ordenes. Proveedores y admins conservan las reglas de la fase de ordenes.

## Limitaciones actuales

- El proveedor asignado y el admin no leen imagenes desde Storage si no son dueños de la ruta. Esto queda documentado para endurecer luego con reglas cruzadas de Firestore, custom claims o Cloud Functions.
- No hay compresion avanzada ni editor de imagenes.
- No hay Storage para perfiles, servicios o evidencias del proveedor.
- No hay mapas reales, notificaciones, pagos, chat ni Cloud Functions.

## Pendiente para proveedor/admin

- Permitir lectura segura al proveedor asignado.
- Permitir lectura/admin segura con custom claims.
- Agregar acciones de moderacion o eliminacion desde panel admin.
- Considerar Cloud Functions para validar metadatos y limpiar archivos huerfanos.
