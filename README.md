# Servi Sur

Servi Sur es una aplicación Flutter tipo marketplace de servicios locales. Incluye una experiencia móvil para clientes y proveedores, además de un dashboard administrativo web para monitorear usuarios, servicios, órdenes, reportes y configuración del sistema.

## Tecnologías Utilizadas

| Tecnología | Uso |
|---|---|
| Flutter / Dart | Desarrollo multiplataforma móvil y web. |
| Provider | Gestión de estado e inyección de repositorios. |
| GoRouter | Navegación declarativa por rutas. |
| fl_chart | Gráficas del dashboard administrativo. |
| data_table_2 | Tablas administrativas responsivas. |
| shared_preferences | Sesión local mock del administrador. |
| geolocator | Obtención parcial de ubicación en móvil. |
| url_launcher / share_plus | Contacto externo y compartir servicios. |

## Arquitectura General

El proyecto está organizado por capas y separa el flujo móvil del módulo administrativo:

| Área | Ubicación | Descripción |
|---|---|---|
| App móvil | `lib/screens`, `lib/widgets`, `lib/providers` | Login, home, servicios, solicitud, tracking, actividad y perfil. |
| Dashboard web | `lib/admin` | Panel administrativo con módulos, tablas, métricas y reportes. |
| Modelos | `lib/models`, `lib/admin/models` | Entidades de usuario, servicio, orden, reportes y configuración. |
| Repositorios | `lib/repositories`, `lib/admin/repositories` | Contratos e implementaciones mock. |
| Tema y core | `lib/core`, `lib/admin/core` | Colores, rutas, tema y utilidades compartidas. |

## Ejecución

Instalar dependencias:

```bash
flutter pub get
```

Ejecutar app móvil:

```bash
flutter run
```

Ejecutar app móvil y dejar el dashboard disponible en el puerto fijo `5764`:

```powershell
.\run_app_with_dashboard.bat
```

Ejecutar solo el dashboard web en `http://127.0.0.1:5764/admin`:

```powershell
.\run_dashboard_web.bat -OpenDashboard
```

Ejecutar dashboard web:

```bash
flutter run -d chrome --web-port 5764
```

Compilar versión web:

```bash
flutter build web
```

## Credenciales Admin Mock

| Campo | Valor |
|---|---|
| URL | `/admin/login` |
| Email | `admin@servimarket.com` |
| Contraseña | `admin123` |

## Rutas Principales

| Ruta | Módulo |
|---|---|
| `/login` | Inicio de sesión móvil. |
| `/register` | Registro móvil. |
| `/home` | Pantalla principal de servicios. |
| `/services` | Lista de servicios. |
| `/service/:id` | Detalle de servicio. |
| `/order-summary` | Confirmación de solicitud. |
| `/activity` | Historial de actividad. |
| `/tracking` | Seguimiento de orden. |
| `/profile` | Perfil del cliente. |
| `/provider` | Panel mock del proveedor. |
| `/admin` | Dashboard administrativo. |
| `/admin/users` | Gestión de usuarios. |
| `/admin/services` | Gestión de servicios. |
| `/admin/orders` | Gestión de órdenes. |
| `/admin/reports` | Reportes y estadísticas. |
| `/admin/settings` | Configuración. |

## Características Principales

- Marketplace móvil con categorías, servicios destacados, detalle de proveedor y solicitud de servicio.
- Flujo de orden mock con resumen, actividad e interfaz de tracking.
- Dashboard administrativo web con sidebar, topbar, métricas, gráficas y tablas.
- Filtros locales para usuarios, servicios y órdenes.
- Exportación CSV en entorno web.
- Arquitectura preparada para reemplazar mocks por Firebase o backend propio.

## Estructura Básica

```text
lib/
  admin/
    core/
    models/
    providers/
    repositories/
    screens/
    services/
    widgets/
  core/
  models/
  providers/
  repositories/
  routes/
  screens/
  services/
  widgets/
test/
web/
android/
ios/
```

## Estado Actual

El proyecto se encuentra en estado de prototipo avanzado para entrega académica. La navegación, UI, datos mock, dashboard web y exportación CSV están implementados. Las acciones administrativas críticas, autenticación real, persistencia de datos, pagos, mapas reales y reportes avanzados quedan pendientes para una versión productiva.




