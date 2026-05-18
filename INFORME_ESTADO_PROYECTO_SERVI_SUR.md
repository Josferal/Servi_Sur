# Informe técnico del estado actual del proyecto Servi Sur

Proyecto inspeccionado: `C:\Users\UNA_COTO\Documents\Servi_Sur`

Este documento resume la arquitectura, funcionalidades, datos, riesgos y próximos pasos del proyecto Flutter sin incluir archivos completos ni logs extensos.

## 1. Resumen general del proyecto

Servi Sur es una aplicación Flutter tipo marketplace de servicios locales. El flujo móvil permite que un cliente explore categorías, revise servicios, contacte proveedores, cree solicitudes y consulte actividad/seguimiento. El proyecto también incluye un dashboard administrativo web-first bajo `lib/admin/` para monitorear usuarios, servicios, órdenes, reportes y configuración.

El problema que resuelve es conectar clientes con proveedores de servicios como limpieza, plomería, electricidad, jardinería o entregas, con una experiencia de solicitud similar a marketplaces modernos.

Roles actuales del sistema:

| Rol | Estado actual | Uso |
|---|---|---|
| Cliente | Mock funcional | Explora servicios, solicita servicios, ve perfil, actividad y tracking. |
| Proveedor | Mock/parcial | Tiene perfil y pantalla de panel de proveedor, pero sin operaciones reales de negocio. |
| Administrador | Mock funcional visual | Accede al dashboard administrativo, consulta métricas, tablas y exporta CSV en web. |

Plataformas presentes en el proyecto:

| Plataforma | Estado |
|---|---|
| Android | Carpeta `android/` presente. Permisos de ubicación configurados. No se pudo ejecutar `flutter run` en Android porque no había dispositivo Android conectado; sí existe un emulador `Pixel_8` disponible. |
| Web | Carpeta `web/` presente. `flutter build web` compila correctamente. Dashboard admin está orientado a web. |
| iOS | Carpeta `ios/` presente. Tiene permiso `NSLocationWhenInUseUsageDescription`. No fue validado en esta sesión. |
| Desktop | `flutter devices` detectó Windows, pero el repo no tiene carpetas desktop generadas (`windows/`, `macos/`, `linux/`). |

## 2. Arquitectura actual

Estructura principal dentro de `lib/`:

| Carpeta | Propósito |
|---|---|
| `lib/main.dart` | Punto de entrada, configura `MultiProvider`, tema y `MaterialApp.router`. |
| `lib/routes/` | Rutas globales con `go_router`. |
| `lib/models/` | Modelos compartidos del marketplace móvil y usados parcialmente por admin. |
| `lib/repositories/` | Contrato `MarketplaceRepository` y repositorio mock. |
| `lib/services/` | Servicios de plataforma o infraestructura móvil, actualmente ubicación y mocks. |
| `lib/providers/` | Estado global móvil: pestaña actual y carrito/solicitud activa. |
| `lib/screens/` | Pantallas móviles organizadas por dominio: auth, home, product, cart, activity, profile, provider. |
| `lib/widgets/` | Componentes reutilizables móviles: shell, inputs, botones, cards de servicio, navegación inferior. |
| `lib/admin/` | Módulo administrativo separado por core, models, providers, repositories, services, screens y widgets. |
| `lib/core/` | Tema, colores, navegación utilitaria, constantes y utilidades. |

Patrón usado:

| Capa | Implementación |
|---|---|
| Providers | `provider` / `ChangeNotifier`, con `MultiProvider`, `ProxyProvider` y `ChangeNotifierProxyProvider`. |
| Repositories | Contratos abstractos (`MarketplaceRepository`, `AdminRepository`) con implementaciones mock. |
| Services | Servicios concretos para geolocalización, sesión admin y exportación CSV. |
| Models | Clases Dart con `copyWith`, `fromMap` y `toMap` en los modelos principales. |
| Screens | Widgets de pantalla, varios con estado local para filtros/formularios. |
| Widgets | Componentes reutilizables móviles y admin. |

Separación móvil vs dashboard administrativo:

| Área | Ruta/carpeta | Características |
|---|---|---|
| App móvil | `lib/screens/`, `lib/widgets/`, `lib/providers/`, `lib/repositories/` | Tema oscuro, navegación inferior, flujos de cliente/proveedor, datos mock desde `MockMarketplaceRepository`. |
| Admin web | `lib/admin/` | Tema claro propio, sidebar/topbar responsive, tablas y gráficos, datos mock desde `MockAdminRepository`. |

Navegación:

El proyecto usa `go_router` en `lib/routes/app_router.dart`. Las rutas móviles están definidas como `GoRoute` simples. Las rutas admin usan `ShellRoute` con `AdminShell`, que incluye sidebar, topbar y layout responsive. La ruta inicial actual es `/login`.

Fragmento mínimo representativo:

```dart
MaterialApp.router(routerConfig: AppRouter.router)
```

## 3. Dependencias principales

Archivo: `pubspec.yaml`

| Paquete | Uso actual |
|---|---|
| `flutter` | SDK base de la app. |
| `cupertino_icons` | Iconos estilo iOS. Uso indirecto/disponible. |
| `geolocator` | Obtener coordenadas actuales en `LocationService`. |
| `go_router` | Navegación declarativa móvil y admin. |
| `google_fonts` | Tipografía del tema administrativo. |
| `intl` | Formateo de fechas y moneda. |
| `fl_chart` | Gráficos admin: línea, barras y pie/donut. |
| `data_table_2` | Tablas administrativas más flexibles. |
| `provider` | Inyección de dependencias y estado global. |
| `share_plus` | Compartir servicios desde detalle móvil. |
| `shared_preferences` | Sesión local del login admin. |
| `url_launcher` | Contactar proveedor por teléfono, correo o WhatsApp. |
| `flutter_lints` | Reglas de análisis estático. |

No hay dependencias de Firebase ni Google Maps en `pubspec.yaml`.

## 4. Rutas implementadas

| Ruta | Pantalla asociada | Plataforma principal | Estado | Descripción breve |
|---|---|---|---|---|
| `/login` | `LoginScreen` en `lib/screens/auth/login_screen.dart` | Mobile | Parcial/mock | Login visual. Navega a `/home`; no autentica contra backend. |
| `/register` | `RegisterScreen` en `lib/screens/auth/register_screen.dart` | Mobile | Parcial/mock | Registro visual. Navega a `/home`; no crea usuario real. |
| `/home` | `HomeScreen` en `lib/screens/home/home_screen.dart` | Mobile | Parcial con mock | Home con ubicación, búsqueda, categorías, filtros y cards de servicios. |
| `/services` | `ServicesListScreen` en `lib/screens/home/services_list_screen.dart` | Mobile | Parcial con mock | Lista todos los servicios desde repositorio mock. |
| `/service/:id` | `ServiceDetailScreen` en `lib/screens/product/service_detail_screen.dart` | Mobile | Parcial con mock | Detalle de servicio, proveedor, reviews, compartir, contacto externo y solicitud. |
| `/order-summary` | `OrderSummaryScreen` en `lib/screens/cart/order_summary_screen.dart` | Mobile | Parcial con mock | Formulario de solicitud, validación local y creación de orden mock. |
| `/activity` | `OrdersHistoryScreen` en `lib/screens/activity/orders_history_screen.dart` | Mobile | Parcial con mock | Historial y orden activa desde `CartProvider`/repositorio. |
| `/tracking` | `TrackingScreen` en `lib/screens/activity/tracking_screen.dart` | Mobile | Mock visual | Seguimiento con mapa dibujado, estado y datos de orden activa. |
| `/profile` | `ProfileScreen` en `lib/screens/profile/profile_screen.dart` | Mobile | Parcial/mock | Perfil del cliente, direcciones, pagos visuales, historial y acceso proveedor. |
| `/provider` | `ProviderDashboardScreen` en `lib/screens/provider/provider_dashboard_screen.dart` | Mobile | Mock visual | Panel básico de proveedor con métricas y servicios simulados. |
| `/admin/login` | `AdminLoginScreen` en `lib/admin/screens/admin_login_screen.dart` | Web/admin | Parcial/mock | Login admin con sesión local en `SharedPreferences`; no valida credenciales. |
| `/admin` | `AdminDashboardScreen` en `lib/admin/screens/admin_dashboard_screen.dart` | Web/admin | Parcial con mock | Métricas, acciones rápidas, actividad reciente y gráficos. |
| `/admin/users` | `AdminUsersScreen` en `lib/admin/screens/admin_users_screen.dart` | Web/admin | Parcial con mock | Tabla de usuarios con búsqueda y filtros. |
| `/admin/services` | `AdminServicesScreen` en `lib/admin/screens/admin_services_screen.dart` | Web/admin | Parcial con mock | Tabla de servicios con filtros por categoría/estado. |
| `/admin/orders` | `AdminOrdersScreen` en `lib/admin/screens/admin_orders_screen.dart` | Web/admin | Parcial con mock | Tabla de órdenes con búsqueda y filtros por estado. Botón exportar visual. |
| `/admin/reports` | `AdminReportsScreen` en `lib/admin/screens/admin_reports_screen.dart` | Web/admin | Parcial funcional con mock | Métricas, gráficos, tabla de ingresos y exportación CSV web. |
| `/admin/settings` | `AdminSettingsScreen` en `lib/admin/screens/admin_settings_screen.dart` | Web/admin | Parcial/mock | Preferencias, categorías y roles. Switches modifican estado local del provider. |

## 5. Funcionalidades móviles implementadas

### Login móvil

Archivo: `lib/screens/auth/login_screen.dart`

| Aspecto | Estado |
|---|---|
| Qué hace | Muestra formulario visual de inicio de sesión y acceso a registro. |
| Datos | No consume repositorio real. |
| Acciones funcionales | Botón principal navega a `/home`; enlace a registro navega a `/register`. |
| Acciones visuales | Campos de credenciales, recuperación/social si existen en UI. |
| Falta | Firebase/Auth real, validaciones, manejo de errores, roles y persistencia de sesión. |

### Registro móvil

Archivo: `lib/screens/auth/register_screen.dart`

| Aspecto | Estado |
|---|---|
| Qué hace | Muestra formulario de registro. |
| Datos | No crea usuario real. |
| Acciones funcionales | Navega a `/home`; permite regresar. |
| Acciones visuales | Campos y botones sociales. |
| Falta | Crear cuenta real, selección/verificación de rol, validación completa y términos. |

### Home

Archivo: `lib/screens/home/home_screen.dart`

| Aspecto | Estado |
|---|---|
| Qué hace | Lista categorías, servicios destacados y recomendados. Incluye búsqueda, filtros por ofertas/precio/distancia/experiencia y categoría seleccionada. |
| Datos | `MarketplaceRepository.getServices()`, `getCategories()`, `currentUser`, `defaultAddress`; implementación mock. |
| Acciones funcionales | Buscar, limpiar filtros, ordenar servicios, seleccionar categoría, abrir perfil, abrir detalle, pedir ubicación actual. |
| Acciones visuales/parciales | Ubicación solo muestra coordenadas o no disponible; no convierte a dirección. |
| Falta | Datos reales, paginación, geocoding, recomendaciones reales, búsqueda backend. |

### Lista de servicios

Archivo: `lib/screens/home/services_list_screen.dart`

| Aspecto | Estado |
|---|---|
| Qué hace | Muestra todos los servicios disponibles. |
| Datos | `MarketplaceRepository.getServices()`, mock. |
| Acciones funcionales | Abrir detalle de servicio con `/service/:id`. |
| Acciones visuales | Banners/cards y lista. |
| Falta | Filtros avanzados, búsqueda server-side, carga/empty/error states reales. |

### Detalle de servicio

Archivo: `lib/screens/product/service_detail_screen.dart`

| Aspecto | Estado |
|---|---|
| Qué hace | Presenta imagen, datos de servicio, proveedor, reseñas, popularidad y CTA para solicitar. |
| Datos | `findServiceById`, `getProviderForService`, `getReviewsForService`; mock derivado. |
| Acciones funcionales | Compartir con `share_plus`, contactar con `url_launcher`, abrir bottom sheet de reviews, seleccionar servicio y navegar a `/order-summary`. |
| Acciones visuales/parciales | Reviews y popularidad son mock; disponibilidad del proveedor no cambia en tiempo real. |
| Falta | Favoritos, reviews reales, disponibilidad real, agenda, precios dinámicos, manejo robusto de imágenes. |

### Confirmar solicitud

Archivo: `lib/screens/cart/order_summary_screen.dart`

| Aspecto | Estado |
|---|---|
| Qué hace | Formulario de fecha, franja horaria, dirección, descripción, emergencia y resumen de costo. |
| Datos | Servicio seleccionado en `CartProvider`, dirección default del repositorio mock. |
| Acciones funcionales | Valida campos, parsea fecha `mm/dd/yyyy`, crea `ServiceRequest` y `Order` mock con `createMockOrder`, navega a `/tracking`. |
| Acciones visuales/parciales | Adjuntar fotos es solo visual. Icono de ubicación no toma ubicación. |
| Falta | Calendario real, upload de fotos, pagos, confirmación backend, asignación de proveedor. |

### Actividad

Archivo: `lib/screens/activity/orders_history_screen.dart`

| Aspecto | Estado |
|---|---|
| Qué hace | Muestra orden activa e historial. |
| Datos | `CartProvider.orders`, que devuelve órdenes mock y las creadas en memoria. |
| Acciones funcionales | Abrir tracking; explorar servicios cuando no hay órdenes. |
| Acciones visuales/parciales | Estados no se actualizan por eventos reales. |
| Falta | Historial persistente por usuario, filtros, cancelación/reordenar, estados en tiempo real. |

### Tracking

Archivo: `lib/screens/activity/tracking_screen.dart`

| Aspecto | Estado |
|---|---|
| Qué hace | Muestra seguimiento de una orden activa con tarjeta de estado, timeline y mapa dibujado. |
| Datos | `CartProvider.activeOrder` o `MarketplaceRepository.getActiveOrder()`. |
| Acciones funcionales | Navegar a actividad. |
| Acciones visuales/parciales | Mapa es `CustomPainter`, no Google Maps. Ubicación del proveedor no es real. |
| Falta | GPS en tiempo real, mapa real, ETA real, chat/llamada real dentro del flujo. |

### Perfil

Archivo: `lib/screens/profile/profile_screen.dart`

| Aspecto | Estado |
|---|---|
| Qué hace | Perfil del cliente, direcciones, pagos, historial y acceso a proveedor. |
| Datos | `currentUser`, `currentClientProfile`, `orders`; mock. |
| Acciones funcionales | Ir a historial, salir a login, entrar al panel de proveedor. |
| Acciones visuales | Gestionar tarjetas/direcciones/configuración aparecen como UI sin persistencia real. |
| Falta | Edición de perfil, métodos de pago reales, cierre de sesión real, avatar/upload. |

### Panel proveedor móvil

Archivo: `lib/screens/provider/provider_dashboard_screen.dart`

| Aspecto | Estado |
|---|---|
| Qué hace | Muestra perfil proveedor, métricas, servicios y solicitudes. |
| Datos | `featuredProviderProfile`, servicios mock filtrados/derivados. |
| Acciones funcionales | Volver, abrir solicitud/orden summary desde botón. |
| Acciones visuales | Métricas, servicios y solicitudes son simulados. |
| Falta | Gestión real de disponibilidad, aceptar/rechazar órdenes, edición de servicios, calendario. |

## 6. Funcionalidades del dashboard administrativo

### Login administrativo

| Aspecto | Estado |
|---|---|
| Archivo | `lib/admin/screens/admin_login_screen.dart` |
| Estado actual | Parcial/mock. |
| Datos mostrados | Email/password precargados: `admin@servimarket.com` y `admin123`. |
| Widgets usados | `TextField`, `CheckboxListTile`, `FilledButton`, layout responsive. |
| Funciones reales | Guarda sesión booleana con `AdminSessionService`/`SharedPreferences`. |
| Funciones mock | No valida credenciales; cualquier submit entra. |
| Pendiente | Firebase Auth/admin claims, guard de rutas, logout visible, errores y MFA. |

### Dashboard principal

| Aspecto | Estado |
|---|---|
| Archivo | `lib/admin/screens/admin_dashboard_screen.dart` |
| Estado actual | Parcial con mock. |
| Datos mostrados | Métricas de usuarios, proveedores, servicios, órdenes, ingresos simulados y actividad reciente. |
| Widgets usados | `AdminStatCard`, `AdminDataTable`, `AdminChartCard`, quick actions. |
| Gráficos | Línea/barras para ingresos y segmentos para estados/roles. |
| Tablas | Actividad reciente. |
| Filtros | No tiene filtros principales. |
| Funciones reales | Navegación a módulos, exportación CSV desde topbar. |
| Funciones mock | Métricas y actividad. |
| Pendiente | Métricas backend, periodos, refresh, permisos por rol. |

### Gestión de usuarios

| Aspecto | Estado |
|---|---|
| Archivo | `lib/admin/screens/admin_users_screen.dart` |
| Estado actual | Parcial con mock. |
| Datos mostrados | Usuarios cliente/proveedor/admin desde `MockAdminRepository`. |
| Widgets usados | `AdminPageHeader`, `AdminFilterBar`, `AdminSearchField`, `AdminFilterChip`, `AdminDataTable`, `AdminStatusChip`. |
| Tablas | Nombre, email, rol, estado, fecha y acciones. |
| Filtros | Búsqueda por texto, rol y estado. |
| Funciones reales | Filtro local en `AdminDashboardProvider`. |
| Funciones mock | Acciones de tabla y usuarios. |
| Pendiente | CRUD, bloqueo/suspensión real, detalle de usuario, auditoría. |

### Gestión de servicios

| Aspecto | Estado |
|---|---|
| Archivo | `lib/admin/screens/admin_services_screen.dart` |
| Estado actual | Parcial con mock. |
| Datos mostrados | Servicios base del marketplace más servicios admin agregados. |
| Widgets usados | `AdminFilterBar`, `AdminSearchField`, `AdminSelectFilter`, `AdminDataTable`, `AdminStatusChip`. |
| Tablas | Servicio, categoría, proveedor, precio, rating, estado, acciones. |
| Filtros | Búsqueda, categoría y estado. |
| Funciones reales | Filtro local. |
| Funciones mock | Aprobar/editar/acciones no conectadas. |
| Pendiente | Moderación real, aprobación de servicios, edición, baja, validación de proveedor. |

### Gestión de órdenes

| Aspecto | Estado |
|---|---|
| Archivo | `lib/admin/screens/admin_orders_screen.dart` |
| Estado actual | Parcial con mock. |
| Datos mostrados | Órdenes mock y órdenes derivadas del repositorio móvil. |
| Widgets usados | `AdminPageHeader`, `AdminFilterBar`, `AdminSearchField`, `AdminFilterChip`, `AdminDataTable`. |
| Tablas | ID, cliente, proveedor, servicio, fecha, total, estado, acciones. |
| Filtros | Búsqueda y estado. |
| Funciones reales | Filtro local. |
| Funciones mock | Botón de exportar en header no tiene acción; acciones de tabla visuales. |
| Pendiente | Estados reales, reasignación, cancelación/reembolso, detalle, exportación específica. |

### Reportes

| Aspecto | Estado |
|---|---|
| Archivo | `lib/admin/screens/admin_reports_screen.dart` |
| Estado actual | Parcial funcional con mock. |
| Datos mostrados | Métricas, ingresos simulados, órdenes recientes. |
| Widgets usados | `AdminStatCard`, `AdminFilterBar`, `AdminChartCard`, `AdminDataTable`. |
| Gráficos | Línea/barras de ingresos actuales vs previos, pie/donut de segmentos. |
| Tablas | Ingresos recientes/órdenes. |
| Filtros | Chips visuales `Ingresos`, `Usuarios`, `Ordenes`; no cambian dataset. |
| Funciones reales | Descarga CSV en web por `AdminExportService` y `admin_csv_downloader_web.dart`. Stub retorna `false` fuera de web. |
| Funciones mock | Datos y periodos. |
| Pendiente | Reportes por rango, backend seguro, PDF/Excel, permisos y auditoría. |

### Configuración

| Aspecto | Estado |
|---|---|
| Archivo | `lib/admin/screens/admin_settings_screen.dart` |
| Estado actual | Parcial/mock. |
| Datos mostrados | `AdminSettings`, categorías y roles. |
| Widgets usados | Cards internas, `SwitchListTile`, listas de categorías/roles. |
| Funciones reales | Switches actualizan `AdminSettings` local en `AdminDashboardProvider`. |
| Funciones mock | No persiste cambios. Roles/categorías son estáticos. |
| Pendiente | Persistencia, gestión de roles/permisos, configuración fiscal, feature flags. |

## 7. Modelos de datos

| Modelo | Archivo | Campos principales | Para qué se usa | Estado |
|---|---|---|---|---|
| `UserModel` | `lib/models/user_model.dart` | `id`, `fullName`, `email`, `phone`, `role`, `avatarUrl`, `createdAt`, `status`, `isClient/isProvider/isAdmin` | Usuario cliente/proveedor/admin. | Parcial; listo para Firestore básico, falta auth UID/claims y dirección relacional. |
| `ServiceItem` | `lib/models/service_item.dart` | `id`, `providerId`, `categoryId`, `title`, `description`, `imageUrl`, `price`, `pricingType`, `rating`, `reviewCount`, `distance`, `duration`, `badge`, `tags`, `status` | Servicios del marketplace y tablas admin. | Parcial; requiere disponibilidad, ubicación real, cobertura, reglas de precio. |
| `Order` | `lib/models/order.dart` | `id`, `requestId`, `clientId`, `providerId`, `serviceId`, `title`, `providerName`, `scheduledAt`, `address`, `subtotal`, `platformFee`, `total`, `status` | Órdenes móviles y base para admin. | Parcial; falta pagos, timestamps de estado, tracking, cancelación/reembolso. |
| `ServiceRequest` | `lib/models/service_request.dart` | `id`, `clientId`, `serviceId`, `providerId`, `address`, `preferredDate`, `timeSlot`, `problemDescription`, `estimatedTotal`, `status`, `photoUrls`, `isEmergency` | Solicitud previa/relacionada a orden. | Parcial; falta asignación, cotización, workflow de aceptación real. |
| `ProviderProfile` | `lib/models/provider_profile.dart` | `id`, `userId`, `displayName`, `businessName`, `specialty`, `email`, `phone`, `address`, `serviceCategoryIds`, `rating`, `isVerified`, `availability`, `portfolioImageUrls` | Perfil proveedor y detalle de servicio. | Parcial; buen punto de partida, falta documentación, verificación, horarios y zona. |
| `ServiceCategory` | `lib/models/service_category.dart` | `id`, `name`, `subtitle`, `iconKey`, `color`, `isActive`, `sortOrder` | Categorías móviles y admin settings. | Parcial; requiere CRUD/persistencia e iconos normalizados. |
| `Review` | `lib/models/review.dart` | `id`, `orderId`, `serviceId`, `providerId`, `clientId`, `clientName`, `rating`, `comment`, `createdAt`, `isPublic` | Reseñas en detalle de servicio. | Parcial; falta moderación, respuesta de proveedor y fotos. |
| `Address` | `lib/models/address.dart` | `id`, `label`, `fullAddress`, `city`, `country`, `latitude`, `longitude`, `isDefault` | Direcciones de usuario, orden y solicitud. | Parcial; falta validación/geocoding. |
| `ClientProfile` | `lib/models/client_profile.dart` | `id`, `userId`, `defaultAddressId`, `addresses`, `favoriteServiceIds`, `paymentMethodIds` | Perfil cliente. | Parcial; falta métodos de pago reales y preferencias. |
| `AdminOrderRecord` | `lib/admin/models/admin_order_record.dart` | `id`, `clientName`, `providerName`, `serviceName`, `category`, `date`, `status`, `total`, `currency` | Vista resumida de órdenes admin. | Parcial; modelo de vista, no entidad backend. |
| `AdminMetric` | `lib/admin/models/admin_metric.dart` | `label`, `value`, `icon`, `delta`, `color` | Métricas dashboard/reportes. | Completo para UI mock; requiere fuente real. |
| `AdminReportPoint` | `lib/admin/models/admin_report_point.dart` | `label`, `current`, `previous` | Gráficos de ingresos. | Parcial/mock. |
| `AdminChartSegment` | `lib/admin/models/admin_chart_segment.dart` | `label`, `value`, `color` | Gráficos pie/donut. | Parcial/mock. |
| `AdminActivity` | `lib/admin/models/admin_activity.dart` | `time`, `user`, `action`, `status` | Tabla de actividad reciente. | Parcial; debería ser auditoría real con timestamps. |
| `AdminSettings` | `lib/admin/models/admin_settings.dart` | `platformName`, `supportEmail`, `maintenanceMode`, `notificationsEnabled`, `manualProviderApproval`, `twoFactorRequired`, `taxRate` | Configuración admin local. | Parcial; falta persistencia y validación. |
| `AdminRoleConfig` | `lib/admin/models/admin_role_config.dart` | `name`, `description`, `users`, `permissions` | Roles visibles en configuración. | Mock; debería conectarse a claims/reglas. |

## 8. Repositorios y servicios

| Servicio/repositorio | Archivo | Métodos principales | Datos que devuelve | Mock o real | Conectar luego a Firebase/backend |
|---|---|---|---|---|---|
| `MarketplaceRepository` | `lib/repositories/marketplace_repository.dart` | `getServices`, `getCategories`, `findServiceById`, `getOrders`, `getActiveOrder`, `getReviewsForService`, `createMockOrder` | Contrato del marketplace móvil. | Contrato | Implementar con Firestore/Auth/Storage/Functions. |
| `MockMarketplaceRepository` | `lib/repositories/mock_marketplace_repository.dart` | Implementa contrato y crea órdenes en memoria. | Usuarios, perfil cliente, proveedor, servicios, categorías, órdenes, reviews. | Mock | Sustituir por repositorio real. |
| `MockMarketplaceService` | `lib/services/mock_marketplace_service.dart` | Datos estáticos del marketplace. | Datasets iniciales mock. | Mock | Migrar a seed data o Firestore. |
| `LocationService` | `lib/services/location_service.dart` | `getCurrentLocationLabel()` | String con coordenadas lat/lng o `null`. | Real parcial | Integrar geocoding, permisos robustos, persistencia de dirección. |
| `AdminRepository` | `lib/admin/repositories/admin_repository.dart` | `getUsers`, `getServices`, `getOrders`, `getCategories`, `getRevenueReport`, `getRoles` | Contrato admin. | Contrato | Firebase Auth, Firestore y Cloud Functions. |
| `MockAdminRepository` | `lib/admin/repositories/mock_admin_repository.dart` | Implementa contrato admin usando marketplace + datos adicionales. | Usuarios, servicios, órdenes, actividad, reportes y roles. | Mock | Reemplazar por consultas reales y agregaciones seguras. |
| `AdminSessionService` | `lib/admin/services/admin_session_service.dart` | `isSignedIn`, `signIn`, `signOut` | Booleano de sesión local. | Real local/mock auth | Reemplazar por Firebase Auth y custom claims. |
| `AdminExportService` | `lib/admin/services/admin_export_service.dart` | `buildAdminReportCsv`, `downloadAdminReportCsv`, `ordersToCsv` | CSV generado localmente. | Real local con datos mock | Exportaciones backend, firmas, permisos y auditoría. |
| `admin_csv_downloader_web` | `lib/admin/services/admin_csv_downloader_web.dart` | `downloadCsv` | Descarga browser con `dart:html`. | Real web | Mantener o migrar a URLs seguras. |
| `admin_csv_downloader_stub` | `lib/admin/services/admin_csv_downloader_stub.dart` | `downloadCsv` | `false` fuera de web. | Stub | Implementar descarga móvil/desktop si se requiere. |

## 9. Providers / Controllers

| Provider/controller | Archivo | Estado que maneja | Pantallas que lo consumen | Problemas o mejoras pendientes |
|---|---|---|---|---|
| `AppProvider` | `lib/providers/app_provider.dart` | Índice de tab inferior. | `BottomNav`/shell móvil si se usa desde componentes comunes. | Persistir ruta/tab, sincronizar con `go_router`. |
| `CartProvider` | `lib/providers/cart_provider.dart` | Servicio seleccionado, solicitud actual, orden activa, lista de órdenes. | Detalle servicio, resumen de orden, tracking, actividad. | El nombre "cart" no representa todo el flujo; usa creación mock en memoria. |
| `AdminDashboardProvider` | `lib/admin/providers/admin_dashboard_provider.dart` | Settings admin, filtros de usuarios/servicios/órdenes, métricas, CSV, formatos. | Todas las pantallas admin principales. | Mezcla lógica de filtros, métricas y exportación; separar cuando haya backend real. |

## 10. Estado de datos reales vs mock

Datos reales o derivados del proyecto:

| Dato | Fuente | Comentario |
|---|---|---|
| Coordenadas actuales | `LocationService` con `geolocator` | Real parcial; solo coordenadas, no dirección. |
| Sesión admin local | `SharedPreferences` | Real local, pero no autenticación segura. |
| Exportación CSV web | `AdminExportService` + `dart:html` | Real como mecanismo de descarga; datos son mock. |
| Navegación/rutas | `go_router` | Funcional. |
| Filtros locales | Providers/pantallas | Funcionales sobre listas mock. |

Datos mock temporales:

| Dato | Fuente |
|---|---|
| Usuario cliente actual | `MockMarketplaceService.clientUser` |
| Perfil cliente | `MockMarketplaceService.clientProfile` |
| Proveedor destacado | `MockMarketplaceService.profile` |
| Servicios/categorías/reviews/órdenes | `MockMarketplaceService` |
| Usuarios admin | `MockAdminRepository.getUsers()` |
| Servicios adicionales admin | `MockAdminRepository.getServices()` |
| Órdenes admin adicionales | `MockAdminRepository.getOrders()` |
| Actividad reciente | `MockAdminRepository.getRecentActivity()` |
| Reporte de ingresos | `MockAdminRepository.getRevenueReport()` |
| Roles admin | `MockAdminRepository.getRoles()` |

Datos quemados directamente en UI o provider:

| Dato | Ubicación |
|---|---|
| Credenciales admin precargadas | `AdminLoginScreen` |
| Opciones de filtros admin | `AdminDashboardProvider` |
| Textos de estados admin | `AdminDashboardProvider` y pantallas admin |
| Tarifa plataforma `$3` | `OrderSummaryScreen` y `MockMarketplaceRepository.createMockOrder()` |
| Periodos y mensajes de tracking | `TrackingScreen` |
| Métricas/deltas como `+8.2%`, `Atencion` | `AdminDashboardProvider` |

Datos que deberían migrarse a Firebase:

Usuarios, perfiles cliente/proveedor, categorías, servicios, solicitudes, órdenes, reseñas, direcciones, pagos, sesiones, roles/permisos, configuración admin, auditoría, reportes agregados, archivos/fotos y eventos de tracking.

## 11. Firebase / backend

Firebase no está configurado actualmente.

Evidencia:

| Revisión | Resultado |
|---|---|
| Dependencias Firebase en `pubspec.yaml` | No existen. |
| Archivos `firebase_options.dart` | No encontrados. |
| Referencias a Firebase | Solo comentarios TODO en admin repository/export. |
| Configuración nativa Firebase | No se identificaron `google-services.json` ni `GoogleService-Info.plist` en la lista de archivos. |

Funcionalidades que deberían conectarse primero:

| Prioridad | Funcionalidad |
|---|---|
| 1 | Autenticación por roles: cliente, proveedor, admin. |
| 2 | Servicios/categorías desde Firestore. |
| 3 | Solicitudes y órdenes persistentes. |
| 4 | Perfil cliente/proveedor y direcciones. |
| 5 | Dashboard admin con consultas reales y reglas de seguridad. |
| 6 | Storage para fotos de solicitudes, servicios y perfiles. |
| 7 | Cloud Functions para reportes, asignación, notificaciones y exportaciones. |

Colecciones sugeridas:

| Colección | Uso |
|---|---|
| `users` | Datos base de usuario y rol. |
| `client_profiles` | Direcciones, favoritos y preferencias. |
| `provider_profiles` | Perfil profesional, disponibilidad, verificación. |
| `categories` | Categorías de servicios. |
| `services` | Servicios publicados por proveedores. |
| `service_requests` | Solicitudes creadas por clientes. |
| `orders` | Órdenes aceptadas/en proceso/completadas. |
| `reviews` | Reseñas por servicio/orden. |
| `admin_settings` | Configuración de plataforma. |
| `audit_logs` | Acciones administrativas. |
| `reports_cache` | Agregados calculados por Cloud Functions. |
| `notifications` | Notificaciones para clientes/proveedores/admin. |

Autenticación necesaria por roles:

| Rol | Necesidad |
|---|---|
| Cliente | Crear solicitudes, ver sus órdenes, editar perfil/direcciones. |
| Proveedor | Gestionar servicios, aceptar/rechazar órdenes asignadas, actualizar disponibilidad. |
| Admin | Ver/moderar todo, gestionar usuarios/servicios, acceder reportes/configuración. |

## 12. Google Maps / Geolocalización

Estado actual:

| Elemento | Estado |
|---|---|
| `geolocator` | Instalado y usado por `LocationService`. |
| Permisos Android | `ACCESS_COARSE_LOCATION` y `ACCESS_FINE_LOCATION` en `android/app/src/main/AndroidManifest.xml`. |
| Permiso iOS | `NSLocationWhenInUseUsageDescription` en `ios/Runner/Info.plist`. |
| Google Maps | No está instalado `google_maps_flutter`; no hay API key configurada. |
| Mapa tracking | Simulado con `CustomPainter` en `TrackingScreen`. |

Qué funciona:

`HomeScreen` intenta obtener ubicación actual y muestra coordenadas formateadas si hay permiso/servicio activo.

Qué está pendiente:

Geocoding inverso, selección manual de ubicación, Google Maps real, rutas/ETA, tracking de proveedor en vivo, manejo de permisos denegados con UI, ubicación por servicio y zona de cobertura.

Pantallas que deberían usar ubicación:

| Pantalla | Uso recomendado |
|---|---|
| `HomeScreen` | Servicios cercanos y dirección legible. |
| `ServicesListScreen` | Ordenar/filtrar por distancia real. |
| `OrderSummaryScreen` | Selección de dirección en mapa. |
| `TrackingScreen` | Mapa, ETA y ubicación proveedor/cliente. |
| `ProviderDashboardScreen` | Zona de cobertura y desplazamientos. |

## 13. Estado responsive y multiplataforma

Android:

Funcionalmente el código debería compilar para Android porque el proyecto tiene carpeta Android y permisos de ubicación. No se ejecutó `flutter run` en Android porque `flutter devices` no detectó dispositivo Android conectado. `flutter emulators` muestra un emulador disponible: `Pixel_8`.

Web:

`flutter build web` compila correctamente. El dashboard admin está claramente diseñado como web-first con `AdminShell`, sidebar, topbar y tablas.

Rutas web-first:

`/admin/login`, `/admin`, `/admin/users`, `/admin/services`, `/admin/orders`, `/admin/reports`, `/admin/settings`.

Rutas mobile-first:

`/login`, `/register`, `/home`, `/services`, `/service/:id`, `/order-summary`, `/activity`, `/tracking`, `/profile`, `/provider`.

Problemas o riesgos responsive:

| Riesgo | Detalle |
|---|---|
| App móvil en web | Las rutas móviles están diseñadas con tema oscuro y layout mobile; pueden verse estrechas o no optimizadas en desktop. |
| Admin en móvil | `AdminShell` tiene drawer/tablet mode, pero tablas densas pueden requerir scroll horizontal. |
| Textos largos | Hay varios textos con acentos corruptos por encoding en archivos fuente, por ejemplo cadenas tipo `ubicaciÃ³n`. Esto impacta UI visual. |
| Imágenes remotas | Servicios usan `NetworkImage`; requiere conexión y fallback robusto. |

Soluciones ya aplicadas:

| Solución | Ubicación |
|---|---|
| `LayoutBuilder` admin para sidebar compacto/drawer | `AdminShell` |
| Topbar admin oculta fecha/texto según ancho | `AdminTopBar` |
| Tablas con `data_table_2` y `minWidth` | `AdminDataTable` |
| Shell móvil con navegación inferior | `AppShell` / `BottomNav` |

## 14. Reportería y exportación

Reportes existentes:

| Reporte | Estado |
|---|---|
| Dashboard de métricas admin | Mock calculado localmente. |
| Reportes de ingresos | Mock con puntos `current` vs `previous`. |
| Segmentos por estado de orden | Calculados desde órdenes mock. |
| Segmentos por rol de usuario | Calculados desde usuarios mock. |
| Tabla de ingresos/órdenes recientes | Mock. |

Gráficos existentes:

| Gráfico | Widget |
|---|---|
| Línea | `AdminChartCard` con `AdminChartType.line` usando `fl_chart`. |
| Barras | `AdminChartCard` con `AdminChartType.bar`. |
| Pie/donut | `AdminChartCard` con `AdminChartType.pie`. |

Exportación:

| Formato | Estado |
|---|---|
| CSV | Implementado en web con `AdminExportService` y `admin_csv_downloader_web.dart`. |
| PDF | No implementado. |
| Excel | No implementado. |

Qué está simulado:

Todos los datos exportados son mock o derivados de listas mock. Los periodos/filtros del reporte son visuales o fijos.

Qué falta para entorno real:

Consultas por rango, agregaciones backend, exportación segura por Cloud Functions, permisos por rol, auditoría de descargas, PDF/Excel si el negocio lo requiere.

## 15. UI/UX

Evaluación:

| Área | Estado |
|---|---|
| Consistencia visual móvil | Buena base: tema oscuro, cards, botones, inputs y navegación inferior consistentes. |
| Consistencia admin | Buena separación: tema claro admin, sidebar, topbar, tablas y cards coherentes. |
| Colores | Móvil usa paleta oscura con naranja/azul. Admin usa verde/neutral claro. La diferencia ayuda a separar contextos. |
| Tipografía | Admin usa `google_fonts`; móvil depende del tema `AppTheme`. |
| Componentes reutilizables | Hay widgets móviles (`PrimaryButton`, `DarkInput`, `ServiceCard`) y admin (`AdminDataTable`, `AdminChartCard`, `AdminStatCard`). |
| Diferencias app/admin | Correctamente marcadas: móvil marketplace vs admin operativo. |

Problemas visuales pendientes:

| Problema | Impacto |
|---|---|
| Textos con encoding corrupto | Varias cadenas muestran `Ã³`, `Ã±`, `Â¿`, etc. Debe corregirse antes de QA visual. |
| Acciones visuales sin feedback | Botones de ayuda, algunas acciones de tabla, gestionar tarjetas y adjuntar fotos no hacen nada. |
| Mapa simulado | Puede parecer funcional aunque no haya tracking real. |
| Login admin sin validación | Riesgo UX/seguridad: cualquier credencial ingresa. |

## 16. Pruebas y validación

Tests existentes:

| Archivo | Estado |
|---|---|
| `test/widget_test.dart` | Test básico que verifica textos del login. |

Resultados ejecutados en esta sesión:

| Comando | Resultado |
|---|---|
| `flutter analyze` | Exitoso. Sin issues. |
| `flutter test` | Exitoso. 1 test aprobado. |
| `flutter build web` | Exitoso. Generó `build\web`. Incluyó aviso de dry run Wasm exitoso. |
| `flutter devices` | Detectó Windows desktop y Edge web; no detectó Android conectado. |
| `flutter emulators` | Detectó emulador Android disponible `Pixel_8`. |
| `flutter run` en Android | No ejecutado por no haber dispositivo Android conectado al momento de validar. |

Errores actuales:

No hay errores de análisis, test o build web. El mayor problema visible detectado no es compilación, sino texto con encoding corrupto en varias cadenas de UI.

## 17. Problemas técnicos pendientes

Críticos:

| Prioridad | Problema |
|---|---|
| C1 | No existe autenticación real ni control de roles. |
| C2 | No hay backend/Firebase; los datos principales son mock o memoria local. |
| C3 | Login admin acepta cualquier entrada y solo guarda un booleano local. |
| C4 | Solicitudes/órdenes no persisten al reiniciar app. |

Importantes:

| Prioridad | Problema |
|---|---|
| I1 | Textos con encoding corrupto en UI. |
| I2 | Acciones admin de tabla no ejecutan operaciones reales. |
| I3 | Tracking y mapa son simulados. |
| I4 | Adjuntar fotos y pagos no existen. |
| I5 | Exportación CSV solo es real en web; en no-web retorna `false`. |
| I6 | No hay guards de rutas admin ni móvil. |

Mejoras:

| Prioridad | Problema |
|---|---|
| M1 | Separar métricas/exportación/filtros del `AdminDashboardProvider` cuando crezca. |
| M2 | Agregar tests por rutas, providers y repositorios. |
| M3 | Implementar estados loading/error/empty reales en repositorios async. |
| M4 | Normalizar moneda, país, impuestos y tarifas de plataforma. |
| M5 | Fortalecer fallback de imágenes remotas. |

Extras:

| Prioridad | Problema |
|---|---|
| E1 | PDF/Excel para reportes. |
| E2 | Notificaciones push. |
| E3 | Chat cliente-proveedor. |
| E4 | Sistema de cupones/promociones. |

## 18. Recomendación de próximos pasos

| Prioridad | Tarea | Módulo afectado | Impacto | Dificultad | Dependencias | Prompt sugerido para Codex |
|---|---|---|---|---|---|---|
| 1 | Corregir encoding de textos visibles | Toda la UI | Alto: mejora inmediata de calidad visual | Baja | Ninguna | "Corrige los textos con mojibake en los archivos Dart sin cambiar lógica ni estilos." |
| 2 | Implementar Firebase base | Auth/backend | Alto: habilita datos reales | Media | Crear proyecto Firebase | "Integra Firebase en Flutter con firebase_core, firebase_auth y cloud_firestore, dejando repositorios reales detrás de interfaces existentes." |
| 3 | Autenticación por roles | Login móvil/admin | Crítico: seguridad y navegación real | Media | Firebase Auth, claims/roles | "Implementa login/register reales con Firebase Auth y control de rutas por roles cliente/proveedor/admin usando go_router." |
| 4 | Persistir servicios/categorías | Marketplace | Alto: reemplaza mocks principales | Media | Firestore, reglas | "Crea FirestoreMarketplaceRepository para leer categorías y servicios reales manteniendo la interfaz MarketplaceRepository." |
| 5 | Persistir solicitudes y órdenes | Cart/activity/tracking/admin orders | Alto: core del negocio | Media/Alta | Auth, Firestore | "Conecta createOrder/createServiceRequest a Firestore y actualiza actividad, tracking y admin orders con datos reales." |
| 6 | Guard de rutas admin | Admin | Alto: seguridad | Baja/Media | Auth real | "Agrega redirect/guards en go_router para proteger /admin y redirigir según sesión y rol." |
| 7 | CRUD admin de usuarios/servicios | Admin users/services | Alto operativo | Alta | Firestore, roles | "Implementa acciones reales de suspender usuario, aprobar/pausar servicio y editar registros desde el dashboard admin." |
| 8 | Google Maps y ubicación | Home/order/tracking | Medio/alto: experiencia real | Alta | API key, google_maps_flutter | "Integra google_maps_flutter para selección de ubicación en solicitud y tracking visual de orden." |
| 9 | Upload de fotos | Order summary/services | Medio | Media | Firebase Storage | "Implementa adjuntar fotos en solicitudes usando image_picker y Firebase Storage." |
| 10 | Reportes backend | Admin reports | Medio/alto | Alta | Cloud Functions/Firestore agregados | "Reemplaza reportes mock por agregaciones reales y exportación CSV segura desde backend." |
| 11 | Tests ampliados | Todo | Medio | Media | Base estable | "Agrega pruebas unitarias para providers/repositorios y widget tests de rutas críticas móvil/admin." |
| 12 | Pagos | Order summary | Alto para producción | Alta | Pasarela local/regional | "Diseña e integra flujo de pago para órdenes, separando modelo Payment y estados de pago." |

## 19. Resumen ejecutivo final

El proyecto ya tiene una base Flutter sólida: navegación completa, separación clara entre app móvil y dashboard admin, providers/repositorios, modelos de dominio, UI consistente y build web funcional. La app móvil permite explorar servicios y crear órdenes mock; el admin permite visualizar métricas, tablas, filtros y exportar CSV en web.

Lo que falta para pasar de demo a producto real es principalmente backend: autenticación por roles, persistencia de usuarios/servicios/órdenes, reglas de seguridad, reportes reales, tracking real y carga de archivos. Antes de eso conviene corregir el encoding de textos, porque afecta directamente la percepción visual.

Lo más recomendable ahora es: corregir textos, integrar Firebase/Auth, reemplazar progresivamente los repositorios mock y proteger rutas admin. Conviene dejar para después pagos avanzados, reportes PDF/Excel, chat y notificaciones push.
