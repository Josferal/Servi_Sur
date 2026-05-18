# Evaluacion de cumplimiento - Laboratorio Dashboard Administrativo Web

Proyecto evaluado: `C:\Users\UNA_COTO\Documents\Servi_Sur`  
Documento base: `C:\Users\UNA_COTO\Downloads\Laboratorio_dashboard_web.pdf`  
Fecha de revision: 2026-05-17

## 1. Resumen ejecutivo

El proyecto Servi Sur cumple de forma solida con el objetivo central del laboratorio: incluye un dashboard administrativo web bajo `/admin`, separado del flujo movil, con navegacion modular, sidebar, topbar, metricas, graficas, tablas, filtros, reportes, configuracion y arquitectura organizada.

La implementacion se ve cercana a un producto SaaS administrativo real en lo visual y estructural. La principal limitacion es que muchas acciones son todavia visuales o mock: autenticacion admin, botones de editar/bloquear/cambiar estado, filtros de fecha, PDF/Excel, notificaciones y datos en tiempo real. Para efectos academicos, esto no impide aprobar, pero si puede limitar la nota maxima en los rubros de integracion, reportería y extras premium.

Estimacion global de cumplimiento: **84 %**  
Nota estimada: **84 / 100**  
Rango probable si se presenta bien con video/manual: **82 - 88**

## 2. Requisitos oficiales extraidos del laboratorio

El PDF solicita construir un **Centro Administrativo Web del Proyecto** en Flutter Web que permita:

| Area | Requisito oficial |
|---|---|
| Objetivo general | Gestionar, visualizar y monitorear informacion principal del sistema mediante dashboard profesional en Flutter Web. |
| Dashboard principal | Sidebar administrativo, navegacion modular, pantalla dashboard, cards estadisticas, topbar administrativa y navegacion web. |
| Sidebar profesional | Iconos, modulos organizados, seleccion activa, navegacion clara, diseno consistente. |
| Topbar administrativa | Usuario logueado, rol, notificaciones, fecha/hora y acciones rapidas. |
| Visualizacion de datos | Minimo grafico de barras, grafico circular y grafico de lineas. |
| Modulos administrativos | Usuarios, reportes, datos principales, estadisticas, configuracion y panel administrativo. |
| UI/UX | Calidad visual, distribucion, colores, organizacion, experiencia de usuario y apariencia profesional. |
| Responsive design | Pantallas grandes, laptops, tablets y navegadores modernos. |
| Arquitectura recomendada | Separacion en core, models, services/controllers, screens, widgets, dashboard y reports. |
| Tecnologias sugeridas | Flutter Web, provider, go_router, fl_chart, data_table_2, responsive_framework, flutter_animate, google_fonts. |
| Extras premium | Dark mode, tiempo real, Firebase, exportacion PDF/Excel, mapas, notificaciones, roles, animaciones avanzadas. |
| Entregables | Codigo fuente comprimido, manual tecnico con arquitectura/capturas/navegacion y video demostrativo de 5 a 10 minutos. |

## 3. Evidencia general del proyecto actual

| Elemento revisado | Evidencia |
|---|---|
| Modulo admin separado | `lib/admin/` contiene `core`, `models`, `providers`, `repositories`, `screens`, `services`, `widgets`. |
| Rutas admin | `lib/admin/core/admin_routes.dart` define `/admin/login`, `/admin`, `/admin/users`, `/admin/services`, `/admin/orders`, `/admin/reports`, `/admin/settings`. |
| Integracion con router global | `lib/routes/app_router.dart` agrega rutas moviles y rutas admin con `ShellRoute`. |
| Flujo movil conservado | `lib/routes/app_router.dart` mantiene `/login`, `/register`, `/home`, `/services`, `/service/:id`, `/order-summary`, `/activity`, `/tracking`, `/profile`, `/provider`. |
| Providers | `lib/main.dart` registra `MarketplaceRepository`, `AdminRepository`, `CartProvider` y `AdminDashboardProvider`. |
| Repositorios | `lib/admin/repositories/admin_repository.dart` define contrato admin; `mock_admin_repository.dart` implementa datos mock y reutiliza `MarketplaceRepository`. |
| Graficas | `lib/admin/widgets/admin_chart_card.dart` usa `fl_chart` para line, bar y pie. |
| Tablas | `lib/admin/widgets/admin_data_table.dart` usa `DataTable2` y empty state. |
| Exportacion | `lib/admin/services/admin_export_service.dart` genera CSV; `admin_csv_downloader.dart` usa import/export condicional para Web. |
| Responsive | `AdminShell`, pantallas y graficas usan `LayoutBuilder`, drawer en tablet y grids adaptativos. |
| Tema admin | `lib/admin/core/admin_theme.dart` aplica `GoogleFonts.interTextTheme`, Material 3, paleta clara, botones, inputs, tooltips y switches. |
| Validacion tecnica | `flutter analyze` sin issues; `flutter test` pasa; `flutter build web` exitoso. |

## 4. Comparacion requisito por requisito

| Requisito del laboratorio | Estado | Evidencia encontrada | Nivel de cumplimiento | Que falta |
|---|---|---|---|---|
| Dashboard administrativo web en Flutter Web | Cumple | `lib/admin/`, rutas `/admin`, `flutter build web` exitoso. | Alto | Validar visualmente en navegador durante la defensa. |
| Sidebar administrativo | Cumple | `AdminSidebar` con ancho normal/compacto, iconos, rutas y marca activa. | Alto | Agregar logo/branding definitivo si se quiere mas acabado. |
| Navegacion modular | Cumple | `ShellRoute` en `app_router.dart`; items a dashboard, usuarios, servicios, ordenes, reportes y configuracion. | Alto | Ninguno critico. |
| Pantalla principal tipo dashboard | Cumple | `AdminDashboardScreen` con metricas, accesos rapidos, graficas y actividad reciente. | Alto | Algunas acciones del header son visuales. |
| Cards estadisticas | Cumple | `AdminStatCard` y `dashboardMetrics` calculados desde provider. | Alto | Deltas son simulados, no calculados historicamente. |
| Topbar administrativa | Cumple | `AdminTopBar` muestra busqueda, fecha/hora, notificaciones, exportacion, ayuda y usuario. | Alto | Notificaciones y ayuda no tienen funcionalidad real. |
| Sistema de navegacion web | Cumple | `go_router` y rutas admin dedicadas. | Alto | En hosting real se debe configurar fallback a `index.html` para refresh directo. |
| Sidebar con iconos | Cumple | `AdminSidebar` usa iconos Material por modulo. | Alto | Ninguno critico. |
| Sidebar con seleccion activa | Cumple | Seleccion por `GoRouterState.of(context).uri.path`. | Alto | Ninguno critico. |
| Sidebar con diseno consistente | Cumple | Paleta oscura, spacing y estados visuales definidos en admin widgets. | Alto | Ninguno critico. |
| Usuario logueado en topbar | Cumple | `currentAdmin` desde `AdminDashboardProvider` y `MockAdminRepository`. | Medio-Alto | Autenticacion no valida credenciales reales. |
| Rol del usuario | Cumple | Topbar muestra `Superuser`; repositorio usa `UserRole.admin`. | Medio | Rol visible pero no controla permisos reales. |
| Notificaciones | Cumple parcialmente | Icono de notificaciones en `AdminTopBar`. | Medio | No hay contador, lista ni datos reales. |
| Fecha u hora | Cumple | `DateFormat('dd MMM yyyy, HH:mm')` en `AdminTopBar`. | Alto | Ninguno critico. |
| Acciones rapidas | Cumple | Exportacion en topbar y quick actions en dashboard. | Medio-Alto | Algunas acciones no ejecutan operaciones reales. |
| Grafico de barras | Cumple | `AdminChartType.bar` en `AdminChartCard`, usado en dashboard y reportes. | Alto | Datos semanales son mock. |
| Grafico circular | Cumple | `AdminChartType.pie` para estados de ordenes y usuarios por rol. | Alto | Datos calculados sobre mocks. |
| Grafico de lineas | Cumple | `AdminChartType.line` para crecimiento/ingresos semanales. | Alto | Datos historicos son mock. |
| Gestion de usuarios | Cumple parcialmente | `AdminUsersScreen` con tabla, busqueda, filtros por rol/estado y acciones visuales. | Medio-Alto | Acciones ver/editar/bloquear no modifican datos. |
| Gestion de servicios | Cumple parcialmente | `AdminServicesScreen` con busqueda, filtros, proveedor, precio, rating, estado y acciones. | Medio-Alto | Acciones ver/editar/pausar/eliminar son visuales. |
| Gestion de ordenes | Cumple parcialmente | `AdminOrdersScreen` con busqueda, chips por estado, tabla, cliente/proveedor/servicio/fecha/monto. | Medio-Alto | Cambiar estado/cancelar/ver detalle no persisten. |
| Reportes y estadisticas | Cumple parcialmente | `AdminReportsScreen` con metricas, graficas, tabla, filtros visuales y CSV. | Medio-Alto | PDF/Excel y filtros de fecha no son funcionales. |
| Configuracion | Cumple parcialmente | `AdminSettingsScreen` con preferencias, categorias, roles y switches. | Medio-Alto | Guardar cambios no persiste; campos de texto no actualizan repositorio. |
| Administrar usuarios o elementos criticos | Cumple parcialmente | Tablas y acciones visuales para usuarios, servicios y ordenes. | Medio | Falta CRUD real o cambios en provider/repository. |
| Generar reportes y metricas | Cumple parcialmente | CSV real para Web y metricas calculadas. | Medio-Alto | Falta PDF/Excel real y filtros funcionales. |
| Monitorear operaciones | Cumple | Actividad reciente y tabla de operaciones en dashboard. | Medio-Alto | Actividad es mock, no eventos reales. |
| Calidad visual | Cumple | Tema admin, cards blancas, sidebar oscuro, chips, tablas y graficas coherentes. | Alto | Revisar capturas finales para evitar overflows puntuales. |
| Uso correcto de colores | Cumple | `AdminColors` define paleta clara, sidebar oscuro y estados. | Alto | No hay modo oscuro admin. |
| Organizacion visual | Cumple | Headers, filtros, grids, tablas y graficas ordenadas. | Alto | Ninguno critico. |
| Experiencia de usuario | Cumple parcialmente | Navegacion clara, filtros y busquedas. | Medio-Alto | Botones sin efecto pueden sentirse incompletos si el profesor los prueba. |
| Responsive en pantallas grandes | Cumple | Max width, grids de 4 columnas y layout con sidebar fijo. | Alto | Validar con screenshot de escritorio. |
| Responsive en laptops | Cumple | Breakpoints en shell, metricas y charts. | Alto | Validar visualmente en 1366px. |
| Responsive en tablets | Cumple | `AdminShell` cambia a drawer bajo 820px; tablas tienen minWidth. | Medio-Alto | No se prioriza movil; tablas pueden requerir scroll segun ancho. |
| Navegadores modernos | Cumple | Build web exitoso. | Alto | Probar en Chrome durante presentacion si esta disponible. |
| Arquitectura recomendada | Cumple | Separacion por capas en `lib/admin`; provider/repository/services/models/widgets/screens. | Alto | No existe carpeta `controllers`, pero `providers` cumple esa funcion. |
| Paquetes recomendados | Cumple parcialmente | Tiene `provider`, `go_router`, `fl_chart`, `data_table_2`, `google_fonts`. | Medio-Alto | No usa `responsive_framework` ni `flutter_animate`. |
| Manual tecnico | Cumple parcialmente | Existe `INFORME_ESTADO_PROYECTO_SERVI_SUR.md` y este informe complementa. | Medio-Alto | Agregar capturas reales del dashboard y seccion de instalacion/ejecucion. |
| Video demostrativo | No cumple | No se encontro archivo o entregable de video en el proyecto. | Bajo | Grabar video de 5 a 10 minutos mostrando dashboard, responsive y funcionalidades. |
| Entrega comprimida | No cumple | No se encontro `GrupoX_DashboardAdministrativo.zip`. | Bajo | Crear ZIP final del proyecto cuando este listo. |

## 5. Evaluacion especifica por area

### 5.1 Dashboard principal

| Elemento | Estado | Evidencia | Observacion |
|---|---|---|---|
| Sidebar | Cumple | `AdminSidebar` | Profesional, oscuro, con iconos y estado activo. |
| Topbar | Cumple | `AdminTopBar` | Incluye busqueda, fecha, usuario, rol visual, notificaciones y exportacion. |
| Estadisticas | Cumple | `dashboardMetrics` en `AdminDashboardProvider` | Calculadas desde usuarios, servicios y ordenes mock/reutilizadas. |
| Navegacion | Cumple | `go_router`, `ShellRoute` | Bien separada del flujo movil. |
| Cards | Cumple | `AdminStatCard`, `AdminChartCard` | Visualmente consistentes. |
| UX | Cumple parcialmente | Accesos rapidos y filtros | Se ve real, pero varios botones no ejecutan logica. |

### 5.2 Visualizacion de datos

| Grafico | Estado | Evidencia | Observacion |
|---|---|---|---|
| Barras | Cumple | `AdminChartType.bar` | Usado para ordenes/ingresos por dia. |
| Circular | Cumple | `AdminChartType.pie` | Usado para estados y roles. |
| Lineas | Cumple | `AdminChartType.line` | Usado para crecimiento/ingresos semanales. |

La visualizacion cumple claramente el minimo del PDF. La debilidad es que los puntos historicos se originan en `MockAdminRepository.getRevenueReport()`.

### 5.3 Responsive design

| Dispositivo | Estado | Evidencia | Riesgo |
|---|---|---|---|
| Desktop grande | Cumple | Sidebar fijo, maxWidth 1640, grids de 4 columnas. | Bajo. |
| Laptop | Cumple | Breakpoints de 980, 1040, 1100, 1180, 1200. | Bajo. |
| Tablet | Cumple parcialmente | Drawer bajo 820px y layout apilado. | Medio si el profesor prueba tablas muy estrechas. |
| Movil | No requerido | Dashboard no prioriza movil. | Bajo porque el PDF solicita tablets, no moviles. |

### 5.4 Arquitectura

| Aspecto | Estado | Evidencia | Observacion |
|---|---|---|---|
| Separacion admin/movil | Cumple | `lib/admin/` y rutas `/admin` separadas. | Muy buen punto para la rubrica. |
| Providers | Cumple | `AdminDashboardProvider` | Centraliza filtros, metricas y acceso a repositorio. |
| Repositories | Cumple | `AdminRepository`, `MockAdminRepository` | Preparado para Firebase. |
| Services | Cumple | `AdminExportService`, `AdminSessionService`, CSV downloader condicional. | Bien separado de pantallas. |
| Widgets reutilizables | Cumple | Shell, sidebar, topbar, cards, tablas, filtros, chips. | Alta reutilizacion. |
| Modelos | Cumple | Modelos admin + modelos compartidos. | Correcto. |
| Limpieza tecnica | Cumple | `flutter analyze` sin issues. | Excelente para entrega. |

### 5.5 Integracion con el proyecto

| Punto | Estado | Evidencia | Observacion |
|---|---|---|---|
| Reutiliza repositorio principal | Cumple | `MockAdminRepository(this._marketplace)` | Buen alineamiento con la app existente. |
| Reutiliza modelos moviles | Cumple | `UserModel`, `ServiceItem`, `ServiceCategory`, `OrderStatus`. | Evita duplicacion. |
| Mantiene flujo movil | Cumple | Rutas moviles intactas en `app_router.dart`. | No rompe mobile. |
| Datos reales | Cumple parcialmente | Usa datos del mock marketplace y datos admin agregados. | No hay backend ni Firebase. |
| Autenticacion | Cumple parcialmente | `AdminSessionService` con `SharedPreferences`. | No valida credenciales reales. |

### 5.6 Diseno UI/UX

| Criterio | Estado | Observacion |
|---|---|---|
| Profesionalismo | Alto | Estetica limpia tipo SaaS, sidebar oscuro, cards blancas, tabla y graficas coherentes. |
| Consistencia | Alto | `AdminTheme` y `AdminColors` centralizan paleta, tipografia y controles. |
| Claridad | Alto | Headers, filtros y tablas son faciles de entender. |
| Accesibilidad basica | Medio-Alto | Contraste y tooltips en iconos; chips usan color y texto. |
| Interactividad real | Medio | Varias acciones aun son placeholders visuales. |

### 5.7 Modulos administrativos

| Modulo | Estado | Evidencia | Que falta para nivel maximo |
|---|---|---|---|
| Login admin | Cumple parcialmente | `AdminLoginScreen`, `AdminSessionService`. | Validar usuario/password y logout visible. |
| Dashboard | Cumple | `AdminDashboardScreen`. | Deltas reales o calculados. |
| Usuarios | Cumple parcialmente | `AdminUsersScreen`. | Ver detalle, editar estado, bloquear con persistencia mock. |
| Servicios | Cumple parcialmente | `AdminServicesScreen`. | Pausar/eliminar/editar con efecto real. |
| Ordenes | Cumple parcialmente | `AdminOrdersScreen`. | Cambiar estado/cancelar y detalle real. |
| Reportes | Cumple parcialmente | `AdminReportsScreen`, CSV. | PDF/Excel o filtro por fecha funcional. |
| Configuracion | Cumple parcialmente | `AdminSettingsScreen`. | Guardar campos de texto y persistencia. |

## 6. Extras premium

| Extra premium | Estado | Evidencia | Comentario |
|---|---|---|---|
| Dark mode | No cumple | Admin usa `AdminTheme.light`; movil usa tema oscuro. | Podria sumar, pero no es obligatorio. |
| Dashboard en tiempo real | No cumple | Datos vienen de repositorios mock sin streams. | Alto impacto si se integrara Firebase, pero costoso. |
| Firebase | No cumple | No hay dependencias Firebase; hay TODO en `AdminRepository`. | No necesario para aprobar, pero limita extras. |
| Exportacion PDF | Cumple parcialmente | Boton visual `Exportar PDF`. | No genera archivo. |
| Exportacion Excel | Cumple parcialmente | Boton visual `Exportar Excel`. | No genera archivo `.xlsx`. |
| Exportacion CSV | Cumple | `AdminExportService.downloadAdminReportCsv()`. | Buen extra aunque PDF menciona PDF/Excel. |
| Mapas interactivos | No cumple | Movil tiene tracking visual, no mapa interactivo admin. | No recomendable implementarlo ahora salvo que sea central al proyecto. |
| Notificaciones | Cumple parcialmente | Icono en topbar. | Sin datos ni panel. |
| Roles de usuario | Cumple parcialmente | `UserRole`, tabla de roles en settings. | Sin permisos reales. |
| Animaciones avanzadas | No cumple | No se usa `flutter_animate`. | Bajo impacto comparado con CRUD/reportes. |

## 7. Simulacion de evaluacion por rubrica

| Rubro | Porcentaje | Estado actual | Nota estimada | Justificacion |
|---|---:|---|---:|---|
| Dashboard administrativo | 20 % | Muy solido | 19 / 20 | Tiene shell, sidebar, topbar, dashboard, metricas, quick actions y actividad. |
| Integracion con el proyecto | 20 % | Buena, pero mock | 16 / 20 | Reutiliza repositorio/modelos y no rompe mobile; falta backend/auth real y acciones persistentes. |
| Visualizacion de datos | 15 % | Cumple completo | 14 / 15 | Incluye lineas, barras y circular con `fl_chart`; datos historicos son mock. |
| Diseno UI/UX | 15 % | Profesional | 14 / 15 | Tema coherente y visual SaaS; algunos botones son solo visuales. |
| Arquitectura y organizacion | 10 % | Muy buena | 9 / 10 | Capas admin claras, provider/repository/services/widgets. |
| Responsive Design | 5 % | Bueno | 4.5 / 5 | Breakpoints, drawer tablet y grids; conviene mostrarlo en video. |
| Reporteria | 5 % | Media-alta | 3.5 / 5 | CSV funcional, metricas y tabla; PDF/Excel y filtro fecha no funcionales. |
| Innovacion y extras premium | 10 % | Limitado | 4 / 10 | CSV, roles visuales y sesion local; sin Firebase, real-time, dark mode ni animaciones. |
| **Total estimado** | **100 %** | **Aprobado alto** | **84 / 100** | Proyecto fuerte para laboratorio; nota maxima depende de completar acciones/reportes/extras. |

## 8. Riesgos de evaluacion

| Riesgo | Impacto | Detalle |
|---|---|---|
| Botones de accion sin efecto | Alto | Ver, editar, bloquear, pausar, eliminar, cambiar estado y cancelar son principalmente visuales. Si el profesor los prueba, se nota incompleto. |
| Login admin no valida credenciales | Medio-Alto | `AdminSessionService` guarda sesion, pero no verifica email/password ni rol real. |
| PDF/Excel no funcionales | Medio | El PDF menciona exportacion PDF/Excel como extra premium; el proyecto tiene CSV real y botones visuales para PDF/Excel. |
| Filtro por fecha en reportes visual | Medio | Existe UI de filtro, pero no cambia los datos. |
| Datos mock visibles | Medio | Actividad, graficas y algunos usuarios/ordenes son simulados. Es aceptable si se explica como arquitectura preparada para Firebase. |
| Notificaciones solo icono | Bajo-Medio | Cumple visualmente topbar, pero no funcionalmente. |
| Entregables academicos faltantes | Alto | Se necesita ZIP, manual tecnico con capturas y video de 5 a 10 minutos. |
| Refresh directo en hosting real | Medio | Con `flutter run` funciona; en hosting se debe configurar fallback SPA. |
| Emulador Android mata proceso por memoria | Bajo para laboratorio web | No afecta Web, pero conviene no presentarlo como error de la app. |

## 9. Fortalezas importantes

| Fortaleza | Por que suma puntos |
|---|---|
| Separacion limpia de `/admin` | Muestra criterio arquitectonico y evita romper el flujo movil. |
| Uso real de `go_router` con `ShellRoute` | Cumple navegacion web modular profesional. |
| Widgets reutilizables admin | Facilita mantenimiento y demuestra escalabilidad. |
| Graficas completas con `fl_chart` | Cumple el minimo de visualizacion de datos con buena calidad. |
| Tablas con `DataTable2` | Mejor presentacion de datos administrativos. |
| Exportacion CSV funcional en Web | Extra practico y defendible aunque no sea PDF/Excel. |
| Reutilizacion de `MarketplaceRepository` y modelos | Buena integracion con el proyecto base. |
| Tema admin separado | Evita contaminar el tema movil y mejora calidad visual. |
| Build web y analyzer limpios | Reduce riesgo tecnico en entrega. |
| Preparacion para Firebase | `AdminRepository` deja contrato claro para reemplazar mocks. |

## 10. Mejoras finales priorizadas

| Prioridad | Mejora | Impacto en nota | Dificultad | Tiempo estimado |
|---|---|---|---|---|
| 1 | Hacer funcional una accion por modulo: bloquear usuario, pausar servicio, cancelar/cambiar estado de orden. | Alto | Media | 2 - 4 horas |
| 2 | Implementar filtro de fecha real en reportes. | Alto | Media | 1.5 - 3 horas |
| 3 | Agregar exportacion Excel simple o mejorar CSV con boton unico claramente funcional. | Medio-Alto | Media | 2 - 4 horas |
| 4 | Agregar logout y validacion basica de credenciales admin mock. | Medio-Alto | Baja | 1 - 2 horas |
| 5 | Crear capturas y completar manual tecnico academico. | Alto | Baja | 1 - 2 horas |
| 6 | Grabar video demostrativo de 5 a 10 minutos. | Alto | Baja | 1 hora |
| 7 | Agregar contador/lista simple de notificaciones mock. | Medio | Baja | 1 - 2 horas |
| 8 | Agregar modo oscuro admin. | Medio | Media | 2 - 4 horas |
| 9 | Agregar animaciones sutiles con `flutter_animate`. | Bajo-Medio | Baja | 1 - 2 horas |
| 10 | Integracion Firebase real. | Alto, pero costoso | Alta | 8 - 16+ horas |

## 11. Recomendacion final

### El proyecto actualmente aprobaria?

Si. El proyecto deberia aprobar con margen porque cumple el nucleo obligatorio: dashboard web profesional, navegacion modular, sidebar, topbar, estadisticas, graficas, responsive, modulos administrativos, reportes y estructura separada.

### Nota aproximada

La nota estimada actual es **84 / 100**. Con una buena exposicion, capturas, video y explicacion de que los mocks estan encapsulados para futura integracion con Firebase, podria acercarse a **88 / 100**.

### Que tan cerca esta de un producto real?

Visual y arquitectonicamente esta cerca de un producto real: aproximadamente **75 %**. Funcionalmente esta mas cerca de un prototipo avanzado: aproximadamente **55 %**, porque las acciones administrativas y los datos en tiempo real todavia no estan implementados.

### Tres cosas que mas subirian la nota

1. Hacer funcionales las acciones clave de usuarios, servicios y ordenes usando el provider/repositorio mock.
2. Completar reportería: filtro de fecha real y exportacion Excel o CSV mas formal.
3. Preparar entregables academicos: manual tecnico con capturas y video demostrativo responsive.

### Funcionalidades que no vale la pena implementar ya

| Funcionalidad | Motivo |
|---|---|
| Firebase completo | Alto costo para el tiempo restante; basta dejar arquitectura preparada. |
| Mapas interactivos admin | No es central para el dashboard administrativo solicitado. |
| Dark mode admin completo | Suma extra, pero menos que acciones/reportes reales. |
| Animaciones avanzadas | Bajo impacto si lo obligatorio ya se cumple. |
| PDF complejo | Mejor implementar Excel/CSV simple y defendible que PDF incompleto. |

## 12. Estado de validacion

| Comando | Resultado |
|---|---|
| `flutter analyze` | Exitoso, sin issues. |
| `flutter test` | Exitoso, 1 test aprobado. |
| `flutter build web` | Exitoso, build generado en `build\web`. |

## 13. Conclusiones del profesor simulado

El dashboard cumple los requisitos obligatorios con buen nivel tecnico. La arquitectura esta bien separada, la UI tiene consistencia profesional y la visualizacion de datos cubre lo solicitado. El proyecto se ve presentable para laboratorio.

Las areas que impedirian una nota sobresaliente son la falta de acciones administrativas reales, autenticacion real o semireal, exportacion PDF/Excel no funcional, filtros de reportes visuales y ausencia de extras premium fuertes como Firebase, tiempo real o dark mode.

Con mejoras pequenas pero visibles en interactividad administrativa y reportería, el proyecto podria subir varios puntos sin reescribir la arquitectura.
