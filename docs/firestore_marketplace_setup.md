# Firestore Marketplace Setup

Esta fase conecta categorias y servicios reales con Cloud Firestore. Ordenes, solicitudes, tracking, mapas, Storage, pagos y notificaciones siguen pendientes.

## Colecciones

### `categories/{categoryId}`

Campos esperados:

- `id`: string
- `name`: string
- `description`: string
- `subtitle`: string opcional para UI
- `iconName` o `iconKey`: string
- `imageUrl`: string opcional
- `isActive`: boolean
- `sortOrder`: number
- `createdAt`: timestamp
- `updatedAt`: timestamp

### `services/{serviceId}`

Campos esperados:

- `id`: string
- `title`: string
- `description`: string
- `categoryId`: string
- `categoryName`: string
- `providerId`: string
- `providerName`: string
- `price`: number
- `priceType` o `pricingType`: `fixed`, `hourly`, `visit` o `project`
- `rating`: number
- `reviewsCount` o `reviewCount`: number
- `imageUrl`: string opcional
- `locationText`: string opcional
- `distance`: string opcional para UI actual
- `duration`: string opcional
- `tags`: array de strings opcional
- `isActive`: boolean
- `status`: `active`, `paused`, `draft` o `archived`
- `createdAt`: timestamp
- `updatedAt`: timestamp

## Crear datos manualmente

1. Abrir Firebase Console.
2. Ir a Firestore Database.
3. Crear una coleccion `categories`.
4. Crear documentos con ids estables, por ejemplo `cleaning`, `plumbers`, `electricians`.
5. Crear una coleccion `services`.
6. Crear servicios con `categoryId` apuntando a un documento de `categories`.
7. Para que aparezcan en la app, usar `isActive: true` y `status: active`.

## Seed inicial desde mocks

El proyecto incluye un script para sembrar categorias y servicios desde los datos mock actuales:

```powershell
flutter pub run tool/seed_firestore.dart
```

El seed no duplica documentos existentes. Para sobrescribirlos:

```powershell
flutter pub run tool/seed_firestore.dart --overwrite
```

Si el entorno local no permite ejecutar el script, copia manualmente la estructura anterior en Firebase Console.

## Probar `/home`

1. Iniciar sesion con un usuario activo.
2. Ir a `/home`.
3. Confirmar que se muestran categorias y servicios.
4. Si Firestore esta vacio, la app muestra datos temporales de fallback.
5. Probar busqueda por texto y filtros visuales.

## Probar `/services`

1. Ir a `/services`.
2. Confirmar que lista servicios activos.
3. Tocar una tarjeta y verificar que navega a `/service/:id`.
4. Si Firestore falla o esta vacio, debe mostrarse un aviso y datos temporales.

## Probar `/service/:id`

1. Desde `/home` o `/services`, abrir un servicio.
2. Confirmar titulo, descripcion, categoria, proveedor, precio e imagen.
3. Abrir directamente una URL con un id inexistente y confirmar mensaje amigable.

## Pendiente

- Ordenes y solicitudes reales en Firestore.
- Datos reales de proveedores.
- Storage para imagenes administradas.
- Tracking/mapas reales.
- Reglas mas estrictas por estado, rol y ownership.
- Cloud Functions y custom claims para administracion productiva.
