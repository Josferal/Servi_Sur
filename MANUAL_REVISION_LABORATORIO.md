# Manual de Revisión para Laboratorio - Servi Sur

Proyecto: `Servi Sur`  
Ruta local: `C:\Users\UNA_COTO\Documents\Servi_Sur`  
Tipo de entrega: Aplicación Flutter móvil con dashboard administrativo web.

## 1. Objetivo del Manual

Este manual guía la revisión técnica y académica del proyecto Servi Sur. Su propósito es mostrar cómo ejecutar el sistema, qué módulos revisar, qué funcionalidades están implementadas y qué partes corresponden a datos mock o prototipo.

## 2. Resumen del Proyecto

Servi Sur es un marketplace de servicios locales. La app móvil permite al cliente explorar categorías, revisar servicios, solicitar atención, consultar actividad y ver seguimiento de una orden. El proyecto también incluye un dashboard administrativo web bajo `/admin`, diseñado para gestionar usuarios, servicios, órdenes, reportes y configuración.

| Rol | Estado | Alcance |
|---|---|---|
| Cliente | Mock funcional | Explora servicios, solicita, consulta tracking y actividad. |
| Proveedor | Mock parcial | Visualiza panel básico con métricas y servicios simulados. |
| Administrador | Mock funcional visual | Accede al dashboard, tablas, métricas, reportes y configuración. |

## 3. Tecnologías y Dependencias

| Tecnología | Uso en el proyecto |
|---|---|
| Flutter | Desarrollo móvil y web. |
| Dart | Lenguaje principal. |
| Provider | Estado global y conexión con repositorios. |
| GoRouter | Definición de rutas móviles y administrativas. |
| fl_chart | Gráficas de líneas, barras y circular. |
| data_table_2 | Tablas administrativas con mejor manejo de ancho. |
| Google Fonts | Tipografía del dashboard administrativo. |
| shared_preferences | Sesión local mock del administrador. |
| geolocator | Ubicación parcial en la app móvil. |
| url_launcher | Contacto externo con proveedor. |
| share_plus | Compartir información de servicios. |

## 4. Preparación del Entorno

1. Abrir una terminal en la carpeta del proyecto:

```bash
cd C:\Users\UNA_COTO\Documents\Servi_Sur
```

2. Instalar dependencias:

```bash
flutter pub get
```

3. Verificar dispositivos disponibles:

```bash
flutter devices
```

4. Ejecutar análisis estático:

```bash
flutter analyze
```

5. Ejecutar pruebas:

```bash
flutter test
```

## 5. Cómo Ejecutar la App Móvil

Para ejecutar en un emulador o dispositivo móvil:

```bash
flutter run
```

Rutas recomendadas para revisión móvil:

| Ruta | Qué revisar |
|---|---|
| `/login` | Pantalla de inicio de sesión móvil. |
| `/register` | Pantalla de registro. |
| `/home` | Categorías, servicios destacados, búsqueda y filtros. |
| `/services` | Lista general de servicios. |
| `/service/:id` | Detalle, proveedor, reseñas y contacto. |
| `/order-summary` | Confirmación de solicitud. |
| `/tracking` | Seguimiento visual de orden. |
| `/activity` | Historial y orden activa. |
| `/profile` | Perfil, direcciones, pagos visuales y acceso proveedor. |
| `/provider` | Panel mock del proveedor. |

## 6. Cómo Ejecutar el Dashboard Web

Para ejecutar en navegador:

```bash
flutter run -d chrome
```

Para generar build web:

```bash
flutter build web
```

Rutas administrativas:

| Ruta | Módulo |
|---|---|
| `/admin/login` | Login administrativo mock. |
| `/admin` | Dashboard principal. |
| `/admin/users` | Gestión de usuarios. |
| `/admin/services` | Gestión de servicios. |
| `/admin/orders` | Gestión de órdenes. |
| `/admin/reports` | Reportes y estadísticas. |
| `/admin/settings` | Configuración del sistema. |

## 7. Credenciales Administrativas Mock

| Campo | Valor |
|---|---|
| Email | `admin@servimarket.com` |
| Contraseña | `admin123` |
| Ruta | `/admin/login` |

La sesión administrativa utiliza `SharedPreferences`. Es una autenticación local de demostración, no un mecanismo de seguridad real para producción.

## 8. Arquitectura del Proyecto

La arquitectura está dividida por dominio y responsabilidad:

| Carpeta | Propósito |
|---|---|
| `lib/main.dart` | Punto de entrada, providers globales y `MaterialApp.router`. |
| `lib/routes` | Rutas generales con `go_router`. |
| `lib/models` | Modelos del marketplace móvil. |
| `lib/repositories` | Contratos y repositorios mock del marketplace. |
| `lib/providers` | Estado de app móvil y flujo de solicitudes. |
| `lib/screens` | Pantallas móviles por dominio. |
| `lib/widgets` | Componentes reutilizables móviles. |
| `lib/admin` | Dashboard administrativo completo. |
| `lib/core` | Tema, colores, navegación y utilidades. |
| `test` | Pruebas automatizadas. |

### Separación Móvil y Admin

| Área | Características |
|---|---|
| App móvil | Tema oscuro, navegación mobile-first, servicios, solicitudes, perfil y tracking. |
| Admin web | Tema claro, sidebar, topbar, tablas, métricas, gráficos y reportes. |

## 9. Flujo Recomendado de Revisión

1. Ejecutar `flutter analyze` y confirmar que no existan errores.
2. Ejecutar `flutter test` para validar pruebas existentes.
3. Abrir la app móvil e ingresar desde `/login`.
4. Revisar `/home`, filtros, lista de servicios y detalle.
5. Crear una solicitud desde el detalle de un servicio.
6. Revisar `/order-summary`, `/tracking` y `/activity`.
7. Abrir `/admin/login` en navegador.
8. Ingresar con las credenciales mock.
9. Revisar dashboard, usuarios, servicios, órdenes, reportes y configuración.
10. Verificar comportamiento responsive cambiando el ancho del navegador.
11. Mostrar la exportación CSV desde el módulo de reportes o topbar si aplica.

## 10. Módulos Móviles

### Login y Registro

| Pantalla | Estado | Observación |
|---|---|---|
| Login | Mock visual | Navega al home; no autentica con backend real. |
| Registro | Mock visual | Permite simular entrada al flujo principal. |

### Home y Servicios

| Funcionalidad | Estado |
|---|---|
| Categorías | Implementado con datos mock. |
| Servicios destacados | Implementado con repositorio mock. |
| Búsqueda y filtros | Funcional localmente. |
| Ubicación | Parcial con coordenadas; no hay geocoding. |

### Detalle y Solicitud

| Funcionalidad | Estado |
|---|---|
| Detalle de servicio | Implementado. |
| Datos de proveedor | Mock. |
| Reseñas | Mock. |
| Compartir servicio | Implementado con `share_plus`. |
| Contacto externo | Implementado con `url_launcher`. |
| Confirmación de solicitud | Implementada con validación local. |

### Actividad y Tracking

| Funcionalidad | Estado |
|---|---|
| Orden activa | Mock/en memoria. |
| Historial | Mock y órdenes creadas en la sesión. |
| Tracking visual | Simulado con interfaz propia; no usa mapa real. |

### Perfil y Proveedor

| Funcionalidad | Estado |
|---|---|
| Perfil cliente | Mock visual. |
| Direcciones y pagos | Visual, sin persistencia real. |
| Panel proveedor | Mock parcial con métricas y servicios simulados. |

## 11. Módulos Administrativos

### Dashboard Principal

Incluye métricas, acciones rápidas, actividad reciente y gráficas. Es el punto central de revisión del laboratorio.

| Elemento | Estado |
|---|---|
| Cards estadísticas | Implementadas. |
| Actividad reciente | Mock. |
| Gráficas | Implementadas con `fl_chart`. |
| Acciones rápidas | Visuales/parciales. |

### Gestión de Usuarios

| Elemento | Estado |
|---|---|
| Tabla de usuarios | Implementada. |
| Búsqueda | Funcional local. |
| Filtros por rol y estado | Funcionales localmente. |
| Acciones de tabla | Principalmente visuales. |

### Gestión de Servicios

| Elemento | Estado |
|---|---|
| Tabla de servicios | Implementada. |
| Filtros por categoría y estado | Funcionales localmente. |
| Información de proveedor y precio | Mock. |
| Acciones administrativas | Visuales/parciales. |

### Gestión de Órdenes

| Elemento | Estado |
|---|---|
| Tabla de órdenes | Implementada. |
| Filtros por estado | Funcionales localmente. |
| Datos de cliente/proveedor/servicio | Mock. |
| Cambio de estado/cancelación | Pendiente de persistencia real. |

### Reportes y Estadísticas

| Elemento | Estado |
|---|---|
| Gráfico de líneas | Implementado. |
| Gráfico de barras | Implementado. |
| Gráfico circular | Implementado. |
| Exportación CSV | Implementada en web. |
| PDF/Excel | No implementado; pueden mostrarse como mejora futura. |

### Configuración

| Elemento | Estado |
|---|---|
| Preferencias del sistema | Estado local mock. |
| Categorías | Visual/mock. |
| Roles | Visual/mock. |
| Persistencia | Pendiente para backend real. |

## 12. Responsive

El dashboard administrativo está diseñado como web-first:

| Tamaño | Comportamiento esperado |
|---|---|
| Desktop | Sidebar fijo, tablas amplias, métricas en grilla. |
| Laptop | Layout conserva estructura principal. |
| Tablet | Sidebar cambia a modo compacto/drawer. |
| Móvil | No es el foco principal del dashboard; las tablas pueden requerir scroll. |

Durante la presentación conviene mostrar al menos dos anchos de navegador para evidenciar la adaptación del dashboard.

## 13. Capturas

Agregar capturas reales antes de la entrega final:

![Dashboard](docs/screenshots/dashboard.png)
![Usuarios](docs/screenshots/admin-users.png)
![Reportes](docs/screenshots/admin-reports.png)
![Configuración](docs/screenshots/admin-settings.png)
![Home móvil](docs/screenshots/mobile-home.png)
![Tracking móvil](docs/screenshots/mobile-tracking.png)

## 14. Estado de Cumplimiento del Laboratorio

| Requisito | Estado |
|---|---|
| Dashboard administrativo web | Cumple. |
| Sidebar y topbar | Cumple. |
| Navegación modular | Cumple. |
| Cards estadísticas | Cumple. |
| Gráficas de barras, líneas y circular | Cumple. |
| Módulos de usuarios, servicios, órdenes, reportes y configuración | Cumple parcialmente con datos mock. |
| Responsive para web/tablet | Cumple en estructura general. |
| Arquitectura organizada | Cumple. |
| Manual técnico | Cumple con este documento. |
| Video demostrativo | Pendiente de agregar enlace. |

## 15. Funcionalidades Mock y Pendientes

| Área | Estado actual | Pendiente productivo |
|---|---|---|
| Autenticación | Sesión local mock. | Firebase Auth o backend propio con roles. |
| Datos | Repositorios mock. | Persistencia real en base de datos. |
| Órdenes | En memoria/mock. | Estados reales y trazabilidad. |
| Admin actions | Varias acciones visuales. | CRUD y permisos reales. |
| Reportes | Datos mock y CSV web. | Filtros por rango, PDF/Excel y backend. |
| Tracking | Simulado. | Mapa real, ETA y ubicación en vivo. |
| Pagos | Visual/no implementado. | Pasarela de pago. |

## 16. Detalles Administrativos para Defensa

Puntos fuertes para explicar durante la revisión:

- El dashboard está separado del flujo móvil bajo `lib/admin`.
- Las rutas admin usan `ShellRoute` para compartir sidebar y topbar.
- Los datos mock están encapsulados en repositorios, lo que facilita reemplazarlos por Firebase o API.
- Las gráficas cumplen los tipos solicitados: líneas, barras y circular.
- La exportación CSV ya funciona en entorno web.
- La UI administrativa tiene tema, componentes y estructura propios.

Limitaciones que deben explicarse con claridad:

- No existe backend real en esta versión.
- La autenticación admin es mock.
- Algunas acciones de tabla son demostrativas.
- El tracking y los reportes se basan en datos simulados.

## 17. Video Demostrativo

Duración sugerida: 5 a 10 minutos.

Guion recomendado:

1. Presentar objetivo del proyecto.
2. Mostrar estructura general de carpetas.
3. Ejecutar app móvil y recorrer login, home, detalle y solicitud.
4. Mostrar actividad y tracking.
5. Abrir dashboard web en `/admin/login`.
6. Ingresar con credenciales mock.
7. Revisar dashboard, usuarios, servicios, órdenes, reportes y configuración.
8. Mostrar responsive cambiando el ancho del navegador.
9. Explicar mocks, arquitectura y futuras integraciones.

Enlace del video:

```text
https://...
```

## 18. Recomendaciones Finales para Entrega

1. Agregar capturas reales en `docs/screenshots`.
2. Completar el enlace del video en README y en este manual.
3. Incluir nombres reales de integrantes.
4. Validar `flutter analyze`, `flutter test` y `flutter build web` antes de comprimir.
5. Explicar en la defensa que el proyecto es un prototipo avanzado con arquitectura lista para backend.
6. Si hay tiempo, priorizar acciones mock visibles: logout, bloqueo de usuario, cambio de estado de orden o filtro real por fecha.
