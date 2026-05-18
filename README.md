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

Ejecutar dashboard web:

```bash
flutter run -d chrome
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

## Capturas

![Dashboard](docs/screenshots/dashboard.png)
![Login administrativo](docs/screenshots/admin-login.png)
![Home móvil](docs/screenshots/mobile-home.png)
![Detalle de servicio](docs/screenshots/service-detail.png)

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

## Video Demostrativo

Agregar aquí el enlace del video de demostración:

```text
https://...
```

## Integrantes

Completar con los integrantes del equipo:

| Nombre | Rol |
|---|---|
| Integrante 1 | Desarrollo / documentación |
| Integrante 2 | Desarrollo / pruebas |
