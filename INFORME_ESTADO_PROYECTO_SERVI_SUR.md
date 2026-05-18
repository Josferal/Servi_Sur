# Informe de Estado del Proyecto - Servi Sur

Este documento queda como anexo ejecutivo. La guía principal de revisión se encuentra en `MANUAL_REVISION_LABORATORIO.md` y la presentación general del proyecto en `README.md`.

## Estado General

| Área | Estado |
|---|---|
| App móvil | Prototipo funcional con datos mock. |
| Dashboard web | Implementado con módulos administrativos principales. |
| Navegación | Implementada con `go_router`. |
| Estado global | Implementado con `provider`. |
| Datos | Mock mediante repositorios. |
| Autenticación | Mock/local para el administrador. |
| Exportación | CSV funcional en web. |
| Backend real | Pendiente. |

## Validaciones Recomendadas

```bash
flutter pub get
flutter analyze
flutter test
flutter build web
```

## Resumen Técnico

Servi Sur cuenta con una separación clara entre la app móvil y el dashboard administrativo. El módulo `lib/admin` contiene su propia estructura de rutas, tema, pantallas, widgets, providers, servicios y repositorios.

La base actual es adecuada para entrega académica y revisión técnica. Para una versión productiva se recomienda conectar autenticación real, persistencia de datos, control de roles, acciones administrativas reales, mapas y reportería avanzada.

## Documentos Relacionados

| Documento | Uso |
|---|---|
| `README.md` | Presentación breve tipo GitHub. |
| `MANUAL_REVISION_LABORATORIO.md` | Manual detallado para revisión académica. |
| `EVALUACION_CUMPLIMIENTO_LABORATORIO.md` | Anexo de cumplimiento frente a la rúbrica. |
