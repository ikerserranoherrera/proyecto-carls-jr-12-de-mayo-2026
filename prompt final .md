# 🗃️ Plan de Implementación: Aplicación Multiplataforma `carlsr jr`
> **Nota:** Este documento es un **blueprint procedural**. No contiene código fuente. Está diseñado para guiar el desarrollo paso a paso, garantizando arquitectura limpia, escalabilidad y cumplimiento de buenas prácticas en Flutter + Provider + Base de Datos Relacional.

---

## 🎯 Objetivo General
Desarrollar una aplicación multiplataforma (Android, iOS, Web) llamada `carlsr jr` con autenticación segura, gestión de estado centralizada, modelo relacional SQL normalizado y experiencia de usuario adaptativa, siguiendo un flujo de trabajo iterativo y profesional.

---

## 🗃️ Contrato de Datos: Esquema SQL Relacional
Utiliza exclusivamente la siguiente estructura como capa de datos. Todas las decisiones de arquitectura, repositorios y mapeo de estado deben derivar de estas entidades:

### 📄 Tabla: `users`
| Atributo | Tipo de Dato | Restricciones / Notas |
|----------|--------------|------------------------|
| `id` | UUID / VARCHAR(36) | PRIMARY KEY, generado automáticamente |
| `email` | VARCHAR(255) | UNIQUE, NOT NULL, validado por regex |
| `password_hash` | VARCHAR(255) | NOT NULL (hash seguro: bcrypt/argon2) |
| `display_name` | VARCHAR(100) | NULLABLE |
| `role` | ENUM('user', 'admin', 'guest') | DEFAULT 'user' |
| `is_email_verified` | BOOLEAN | DEFAULT FALSE |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP |
| `updated_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP, ON UPDATE |

### 📄 Tabla: `user_sessions`
| Atributo | Tipo de Dato | Restricciones / Notas |
|----------|--------------|------------------------|
| `id` | UUID / VARCHAR(36) | PRIMARY KEY |
| `user_id` | UUID / VARCHAR(36) | FOREIGN KEY → users.id, ON DELETE CASCADE |
| `refresh_token` | VARCHAR(512) | UNIQUE, NOT NULL |
| `expires_at` | TIMESTAMP | NOT NULL |
| `device_fingerprint` | VARCHAR(255) | NULLABLE |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP |

### 📄 Tabla: `activity_logs`
| Atributo | Tipo de Dato | Restricciones / Notas |
|----------|--------------|------------------------|
| `id` | UUID / VARCHAR(36) | PRIMARY KEY |
| `user_id` | UUID / VARCHAR(36) | FOREIGN KEY → users.id, NULLABLE |
| `action_type` | VARCHAR(50) | NOT NULL (ej: 'LOGIN', 'PROFILE_UPDATE', 'LOGOUT') |
| `metadata` | JSON / TEXT | NULLABLE |
| `ip_address` | VARCHAR(45) | NULLABLE |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP, INDEXADO |

### 📄 Tabla: `app_config`
| Atributo | Tipo de Dato | Restricciones / Notas |
|----------|--------------|------------------------|
| `id` | UUID / VARCHAR(36) | PRIMARY KEY |
| `config_key` | VARCHAR(100) | UNIQUE, NOT NULL |
| `config_value` | JSON / TEXT | NOT NULL |
| `last_updated_by` | UUID / VARCHAR(36) | FOREIGN KEY → users.id, NULLABLE |
| `updated_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP |

---

## 📋 Fase 1: Diseño UI/UX y Arquitectura de Información
1. **Definición de Alcance y Flujos de Usuario**
   - Mapear journey principal: Registro → Login → Pantalla principal → Perfil → Cierre de sesión.
   - Identificar roles (usuario estándar, administrador, invitado) y sus permisos por pantalla.
   - Documentar casos de borde: recuperación de contraseña, sesión expirada, modo offline, rollback de transacciones fallidas.

2. **Prototipado y Sistema de Diseño**
   - Crear wireframes de baja fidelidad para validar navegación y flujos críticos.
   - Diseñar mockups de alta fidelidad en Figma/Adobe XD con:
     - Paleta cromática, tipografía, espaciado (8pt grid).
     - Componentes reutilizables: botones, campos de entrada, cards, loaders, toasts, formularios validados.
   - Aplicar directrices de **Material 3** o **Cupertino** según prioridad de plataforma, con adaptación responsive para escritorio/web.

3. **Arquitectura de Información**
   - Estructurar pantallas por módulos: `auth/`, `home/`, `profile/`, `settings/`, `admin/` (si aplica).
   - Definir rutas nombradas y navegación guardada (stack lógico con `go_router` o `auto_route`).
   - Preparar assets: iconos, ilustraciones, logos optimizados para múltiples densidades y modo oscuro/claro.

---

## 🛠️ Fase 2: Configuración del Entorno y Gestión de Dependencias
1. **Entorno de Desarrollo**
   - Instalar Flutter SDK estable y configurar PATH.
   - Instalar VS Code con extensiones oficiales: `Flutter`, `Dart`, `SQL Tools`, `Pubspec Assist`, `Error Lens`.
   - Configurar emuladores/simuladores, entorno web y cliente SQL para pruebas locales.

2. **Inicialización del Proyecto**
   - Generar proyecto base con soporte multiplataforma habilitado.
   - Estructurar carpetas por capas: `lib/core/`, `lib/features/`, `lib/data/repositories/`, `lib/domain/`, `lib/presentation/`.
   - Configurar linter (`analysis_options.yaml`) y formateador (`dart format`).

3. **Declaración de Dependencias (`pubspec.yaml`)**
   - **Core:** `flutter`, `provider` (gestión de estado).
   - **SQL/Red:** `drift` o `postgres`/`supabase_flutter` (según motor), `dio` o `http`, `dotenv`.
   - **UI/UX:** `google_fonts`, `flutter_svg`, `cached_network_image`, `shimmer`.
   - **Autenticación/Seguridad:** `flutter_secure_storage`, `formz`, `intl`, `crypto`/`bcrypt` (si hashing en cliente/servidor separado).
   - **Utilidades:** `go_router`, `logger`, `connectivity_plus`, `shared_preferences`.
   - **Desarrollo/Testing:** `flutter_lints`, `mocktail`, `flutter_test`.
   > *Nota:* Mantener versiones compatibles con la última LTS de Flutter. Usar `flutter pub upgrade` periódicamente.

---

## 🔐 Fase 3: Autenticación y Gestión de Sesiones
1. **Flujo de Registro y Login**
   - Definir políticas de contraseña: longitud mínima, caracteres especiales, validación en tiempo real.
   - Implementar pantallas: `Login`, `Register`, `Forgot Password`, `Email Verification`.
   - Separar lógica de hashing del lado del servidor; el cliente envía credenciales cifradas vía HTTPS.

2. **Mapeo de Sesiones y Tokens**
   - Generar `refresh_token` y almacenarlo en `user_sessions` con `expires_at`.
   - Implementar rotación de tokens, cierre de sesión remoto y invalidación por `device_fingerprint`.
   - Persistir tokens de forma segura usando `flutter_secure_storage`.

3. **Gestión de Estado de Autenticación**
   - Crear `AuthProvider` con `ChangeNotifier` que escuche: `authenticated`, `loading`, `expired`, `unverified`.
   - Validar `role` al iniciar sesión para redirección condicional (ej: admin → panel, user → home).
   - Implementar timeout de inactividad y reconexión silenciosa con `refresh_token`.

---

## 🗄️ Fase 4: Capa de Datos SQL y Arquitectura de Repositorios
1. **Diseño de Acceso a Datos (DAO/Repository)**
   - Crear repositorios aislados por entidad: `UserRepository`, `SessionRepository`, `LogRepository`, `ConfigRepository`.
   - Aplicar patrón `UnitOfWork` para transacciones críticas (ej: registro + creación de sesión + log inicial).
   - Manejar `SQLException`, retry logic y timeouts de red.

2. **Migraciones Versionadas y Gestión de Conexiones**
   - Implementar sistema de migraciones incrementales con versión numérica (`V1__init.sql`, `V2__add_indexes.sql`).
   - Configurar pool de conexiones, keep-alive y estrategia de fallback si el motor es local (`SQLite`) o remoto (`PostgreSQL`/`Supabase`).
   - Validar esquema en startup; bloquear ejecución si hay migraciones pendientes fallidas.

3. **Arquitectura con Provider y Mapeo de Entidades**
   - Definir `Models` Dart inmutables (`equatable`/`freezed`) mapeados 1:1 con columnas SQL.
   - Implementar `ChangeNotifier` por dominio: `UserProvider`, `SessionProvider`, `AppConfigProvider`.
   - Gestionar estados UI: `loading`, `success`, `error`, `empty`, `sync_pending` (si aplica caché local).

---

## 🚀 Fase 5: Integración UI ↔ Estado ↔ Base de Datos
1. **Implementación de UI Adaptativa y Formularios**
   - Construir widgets modales y reutilizables siguiendo el sistema de diseño.
   - Aplicar `LayoutBuilder`, `MediaQuery` y `Theme` para responsive design.
   - Integrar animaciones sutiles (`AnimatedSwitcher`, `Hero`, `Implicit animations`).

2. **Conexión Asíncrona y Manejo de Estados**
   - Enlazar formularios a validadores (`formz`) y a repositorios vía Providers.
   - Consumir `FutureProvider`/`StreamProvider` con manejo explícito de errores de red y BD.
   - Implementar caché local o cola de sincronización diferida si se requiere funcionamiento offline.

3. **Navegación, Guards y Flujo de App**
   - Configurar router con guard de autenticación y redirección por `role`.
   - Implementar bottom navigation, drawers o tabs según arquitectura UX.
   - Preparar deep links y web URLs para compartir contenido o recuperar sesión.

---

## 🧪 Fase 6: Pruebas, Optimización y Despliegue Multiplataforma
1. **Estrategia de Testing**
   - Unit tests: validación de modelos, lógica de negocio, repositorios mockeados con `mocktail`.
   - Widget tests: interacción con formularios, estados de carga/error, navegación.
   - Integration tests: flujo completo registro → login → sesión → logout → verificación en logs.
   - Validar migraciones en entorno aislado y rollback automático en caso de fallo.

2. **Optimización de Rendimiento**
   - Lazy loading para listas y consultas paginadas (`LIMIT/OFFSET` o `keyset`).
   - Minimizar rebuilds con `Provider.of(context, listen: false)` y `select`.
   - Indexar columnas críticas (`email`, `user_id`, `created_at`), evitar `SELECT *`, usar proyecciones explícitas.
   - Perfilado con Flutter DevTools: CPU, memoria, red, queries SQL.

3. **Despliegue y Cumplimiento**
   - Generar builds firmados para Android (`.aab`) y iOS (`.ipa`).
   - Configurar metadata: iconos, splash, permisos, política de privacidad.
   - Cumplir GDPR/CCPA: consentimiento, exportación de datos, eliminación segura de `users` + cascada en sesiones/logs.
   - Publicar en Play Store, App Store Connect y hosting estático para Web.
   - Configurar pipeline CI/CD (GitHub Actions/Fastlane) con ejecución de tests y migraciones en staging.

---

## 📅 Cronograma Sugerido (Iterativo, 6–8 Semanas)
| Semana | Entregable Clave |
|--------|------------------|
| 1 | UI/UX finalizado, arquitectura de carpetas, `pubspec.yaml` estable |
| 2 | Entorno SQL configurado, migraciones V1, Auth funcionando, validaciones |
| 3 | Repositorios DAO implementados, transacciones, mapeo de Providers |
| 4 | Pantallas core conectadas, navegación con guards, manejo de estados/error |
| 5 | Testing integral, optimización de queries, corrección de bugs |
| 6–8 | Despliegue, validación en stores, documentación, handoff |

---

## ✅ Checklist de Validación Pre-Lanzamiento
- [ ] Autenticación cubre registro, login, recuperación, verificación y cierre seguro.
- [ ] Contraseñas hashadas correctamente; tokens rotados y persistidos de forma segura.
- [ ] Migraciones SQL versionadas, probadas en emulador y con rollback validado.
- [ ] Provider maneja estados sin memory leaks, usa `select` y evita rebuilds innecesarios.
- [ ] UI es responsive, accesible y coherente con el sistema de diseño definido.
- [ ] Pruebas unitarias, de widget e integración con cobertura >70% y mocks de repositorios.
- [ ] Builds firmados, metadatos completos, política de privacidad y flujo GDPR implementados.
- [ ] CI/CD configurado o documentación de release manual clara y reproducible.

---

📌 **Siguiente Paso Recomendado:**  
Una vez validado este plan, indica por qué fase deseas profundizar primero. Te entregaré el material correspondiente **sin saltar a código** hasta que lo solicites explícitamente con el formato: `✅ Procede a generar el código para la Fase X`.

## RESULTADO

# 🗃️ Plan de Implementación Completo: Aplicación Multiplataforma `carlsr jr`
> **Nota:** Este documento es un blueprint procedural. No contiene código fuente. Está diseñado para guiar el desarrollo paso a paso, garantizando arquitectura limpia, escalabilidad y cumplimiento de buenas prácticas en Flutter + Provider + Base de Datos Relacional.

---

## 🎯 Objetivo General
Desarrollar una aplicación multiplataforma (Android, iOS, Web) llamada `carlsr jr` con autenticación segura, gestión de estado centralizada, modelo relacional SQL normalizado y experiencia de usuario adaptativa, siguiendo un flujo de trabajo iterativo y profesional.

---

## 🗃️ Contrato de Datos: Esquema SQL Relacional (Referencia)
Utiliza exclusivamente la siguiente estructura como capa de datos. Todas las decisiones de arquitectura, repositorios y mapeo de estado deben derivar de estas entidades:

| Tabla | Claves / Restricciones Relevantes |
|-------|----------------------------------|
| `users` | `id` (UUID/PK), `email` (UNIQUE), `password_hash` (bcrypt/argon2), `role` (ENUM), `is_email_verified`, timestamps |
| `user_sessions` | `user_id` (FK → users.id, ON DELETE CASCADE), `refresh_token` (UNIQUE), `expires_at`, `device_fingerprint` |
| `activity_logs` | `user_id` (FK, NULLABLE), `action_type`, `metadata` (JSON/TEXT), `ip_address`, `created_at` (INDEXED) |
| `app_config` | `config_key` (UNIQUE), `config_value` (JSON/TEXT), `last_updated_by` (FK), `updated_at` |

---

## 📋 Fase 1: Diseño UI/UX y Arquitectura de Información
| Paso | Acción | Criterio de Validación | Entregable |
|------|--------|------------------------|------------|
| 1.1 | Mapear flujos de usuario (registro, login, recuperación, dashboard, perfil, logout) con diagramas de estados. | Cada flujo cubre casos felices y bordes (token expirado, email no verificado, rol inválido). | Documento de flujos UX. |
| 1.2 | Definir sistema de diseño: paleta, tipografía, espaciado 8pt, componentes base, modo claro/oscuro. | Consistencia visual validada en 3 breakpoints (móvil, tablet, desktop). | Kit de componentes reutilizables. |
| 1.3 | Crear wireframes de baja fidelidad para todas las pantallas críticas. | Navegación lógica sin rutas huérfanas o bucles infinitos. | Wireframes aprobados. |
| 1.4 | Diseñar mockups de alta fidelidad con estados: loading, success, error, empty. | Todos los componentes usan el sistema de diseño y respetan accesibilidad. | Mockups finales en Figma/Adobe XD. |
| 1.5 | Definir arquitectura de rutas nombradas y guards por rol (`user`, `admin`, `guest`). | Matriz de permisos por ruta documentada y validada. | Mapa de rutas + matriz de seguridad. |

✅ **Gate de Salida Fase 1:** Aprobación formal de flujos, diseño visual y mapa de rutas.

---

## 🛠️ Fase 2: Configuración del Entorno y Gestión de Dependencias
| Paso | Acción | Criterio de Validación | Entregable |
|------|--------|------------------------|------------|
| 2.1 | Instalar Flutter SDK LTS, configurar emuladores, cliente SQL y herramientas de red. | `flutter doctor` sin warnings críticos; entorno de BD local accesible. | Checklist de entorno listo. |
| 2.2 | Inicializar proyecto multiplataforma y aplicar estructura por capas (`core/`, `data/`, `domain/`, `presentation/`). | Árbol de directorios coincide con contrato arquitectónico definido. | Repositorio base estructurado. |
| 2.3 | Configurar `analysis_options.yaml` con linter estricto y reglas de formato. | `flutter analyze` y `dart format` pasan sin errores ni excepciones. | Configuración de linting aplicada. |
| 2.4 | Declarar dependencias en `pubspec.yaml` según blueprint y bloquear versiones compatibles. | `flutter pub get` sin conflictos; tree-shaking activado para Web. | `pubspec.yaml` versionado y validado. |
| 2.5 | Configurar gestión de variables de entorno (`.env` por perfil: dev, staging, prod). | Secretos no comprometidos en VCS; fallbacks definidos para claves faltantes. | Template `.env.example` + loader de entorno. |
| 2.6 | Verificar compilación limpia en Android, iOS y Web en modo debug. | 3 builds locales sin errores de dependencia o assets faltantes. | Reporte de compilación multiplataforma. |

✅ **Gate de Salida Fase 2:** Proyecto base funcional, dependencias resueltas, entorno listo para lógica de negocio.

---

## 🔐 Fase 3: Autenticación y Gestión de Sesiones
| Paso | Acción | Criterio de Validación | Entregable |
|------|--------|------------------------|------------|
| 3.1 | Documentar políticas de contraseña y validación en tiempo real (longitud, complejidad, feedback UI). | Reglas cubren OWASP ASVS; validación no bloquea UX. | Especificación de políticas de credenciales. |
| 3.2 | Implementar pantallas estáticas de `Login`, `Register`, `Forgot Password`, `Email Verification`. | Diseño 1:1 con mockups; formularios con validación visual sin lógica de red. | UI de autenticación lista. |
| 3.3 | Diseñar modelo de estado para `AuthProvider` (`ChangeNotifier`): estados, transiciones y listeners. | Diagrama de estados cubre: `idle → loading → authenticated → expired → unverified → error`. | Documentación de máquina de estados. |
| 3.4 | Definir flujo de tokens: generación, rotación, invalidación por `device_fingerprint` y `expires_at`. | Lógica de ciclo de vida documentada; compatibilidad con `flutter_secure_storage`. | Contrato de gestión de sesiones. |
| 3.5 | Establecer reglas de redirección condicional por `role` y timeout de inactividad. | Guard de navegación validado contra matriz de permisos de Fase 1. | Matriz de enrutamiento seguro. |
| 3.6 | Validar flujo completo de autenticación en papel (sin código): desde envío hasta refresh/logout. | No hay brechas de estado ni condiciones no manejadas. | Checklist de flujo auth aprobado. |

✅ **Gate de Salida Fase 3:** Lógica de autenticación y sesiones completamente especificada y lista para mapeo con DB.

---

## 🗄️ Fase 4: Capa de Datos SQL y Arquitectura de Repositorios
| Paso | Acción | Criterio de Validación | Entregable |
|------|--------|------------------------|------------|
| 4.1 | Seleccionar motor SQL (local/remoto) y configurar pool de conexiones, timeouts y keep-alive. | Conexión establecida; validación de latencia y reconexión automática. | Configuración de conexión documentada. |
| 4.2 | Implementar sistema de migraciones versionadas (`V1`, `V2`, etc.) con rollback controlado. | Migraciones aplicadas en orden inverso sin pérdida de datos críticos. | Scripts de migración + registro de versiones. |
| 4.3 | Definir contratos de repositorio (`UserRepository`, `SessionRepository`, `LogRepository`, `ConfigRepository`). | Interfaces expuestas cubren todas las columnas de tu esquema SQL. | Contratos de capa de datos firmados. |
| 4.4 | Diseñar patrón `UnitOfWork` para transacciones atómicas (ej: registro + sesión + log inicial). | Commit/rollback documentado; aislamiento de fallos garantizado. | Diagrama de transacciones críticas. |
| 4.5 | Establecer estrategia de mapeo 1:1 entre entidades SQL y modelos Dart inmutables. | Cada columna tiene tipo Dart equivalente; valores `NULLABLE` manejados explícitamente. | Especificación de mapeo de entidades. |
| 4.6 | Definir política de manejo de errores SQL, reintentos exponenciales y timeouts. | Errores de red, constraints y locks cubiertos con fallbacks UI claros. | Matriz de errores DB → UI. |

✅ **Gate de Salida Fase 4:** Capa de datos completamente especificada, migraciones versionadas y repositorios contractuales listos.

---

## 🚀 Fase 5: Integración UI ↔ Estado ↔ Base de Datos
| Paso | Acción | Criterio de Validación | Entregable |
|------|--------|------------------------|------------|
| 5.1 | Configurar árbol de `Provider` en `main.dart` con inyección por feature y aislamiento de contexto. | Sin rebuilds globales; `listen: false` aplicado donde corresponda. | Árbol de Providers documentado. |
| 5.2 | Vincular validadores de formularios (`formz` o equivalente) a repositorios vía Providers. | Validación síncrona en UI; asíncrona (ej: email único) manejada con debounce. | Flujo de validación mapeado. |
| 5.3 | Implementar estados asíncronos (`loading`, `success`, `error`, `empty`) con feedback UI coherente. | Transiciones suaves; sin estados colgados o fugas de memoria. | Especificación de estados UI. |
| 5.4 | Configurar router con guards de autenticación y redirección por rol. | Acceso bloqueado según `role`; deep links validados. | Navegación segura implementada en diseño. |
| 5.5 | Aplicar responsive design (`LayoutBuilder`, `MediaQuery`, `Theme`) a pantallas core. | UI adaptable sin desbordes; modo oscuro/claro coherente. | Guía de adaptación visual aplicada. |
| 5.6 | Definir estrategia offline/caché (si aplica): cola de sincronización y conflicto de datos. | Datos críticos accesibles sin red; sincronización en cola con prioridad. | Arquitectura de sincronización documentada. |

✅ **Gate de Salida Fase 5:** Flujo completo UI → Provider → Repository → DB especificado y validado en papel.

---

## 🧪 Fase 6: Pruebas, Optimización y Despliegue Multiplataforma
| Paso | Acción | Criterio de Validación | Entregable |
|------|--------|------------------------|------------|
| 6.1 | Diseñar pirámide de pruebas: unit (modelos/repos), widget (UI/states), integration (flujos completos). | Cobertura objetivo >70%; mocks alineados con contratos de Fase 4. | Estrategia de testing documentada. |
| 6.2 | Configurar entornos aislados para pruebas de migración y rollback. | Migraciones fallidas no corrompen BD de staging; rollback automático validado. | Checklist de pruebas DB. |
| 6.3 | Planificar optimización: lazy loading, proyecciones SQL, indexación, `Provider.select`. | DevTools audit: CPU <16ms/frame, memoria estable, queries optimizadas. | Guía de rendimiento aplicada. |
| 6.4 | Diseñar pipeline CI/CD: lint, test, build, firma, upload a staging. | Pipeline verde en main; artefactos firmados y versionados. | Configuración CI/CD documentada. |
| 6.5 | Preparar cumplimiento legal: GDPR/CCPA, exportación/eliminación de datos, política de privacidad. | Flujos de borrado en cascada (`users → sessions → logs`) validados. | Documentación de cumplimiento. |
| 6.6 | Generar builds finales, metadata de stores y handoff técnico. | Builds firmados, screenshots, descripciones, claves de API revocadas de prod. | Paquete de release completo. |

✅ **Gate de Salida Fase 6:** Aplicación lista para publicación, con auditoría de calidad, seguridad y cumplimiento.

---

## 📊 Matriz de Dependencias Críticas
| Fase | Depende de | Bloquea |
|------|------------|---------|
| 1 | Requisitos de negocio | Diseño UI, mapa de rutas, permisos por rol |
| 2 | Fase 1 aprobada | Estructura de proyecto, dependencias, compilación base |
| 3 | Fase 2 + Políticas de seguridad | AuthProvider, gestión de tokens, guards de navegación |
| 4 | Fase 2 + Esquema SQL definido | Repositorios, migraciones, UnitOfWork, mapeo de modelos |
| 5 | Fases 3 y 4 completas | Integración UI↔State↔DB, responsive, navegación segura |
| 6 | Fase 5 estable | Testing, optimización, CI/CD, publicación stores |

---

## 🛡️ Puntos de Control y Gestión de Riesgos
- **Riesgo:** Migraciones SQL corruptas en producción.  
  **Mitigación:** Validar en entorno espejo; nunca ejecutar migraciones destructivas sin backup y rollback probado.
- **Riesgo:** Memory leaks por Providers no dispuestos.  
  **Mitigación:** Auditoría con `flutter devtools` y uso estricto de `Consumer`/`select` en lugar de `Provider.of` global.
- **Riesgo:** Tokens comprometidos o rotación fallida.  
  **Mitigación:** `flutter_secure_storage` + invalidación por huella de dispositivo + refresh automático con backoff.
- **Riesgo:** Rebuilds masivos en UI.  
  **Mitigación:** Separar Providers por dominio; usar `context.select` para escuchar solo campos relevantes.

---

## 📅 Cronograma Sugerido (Iterativo, 6–8 Semanas)
| Semana | Entregable Clave |
|--------|------------------|
| 1 | UI/UX finalizado, arquitectura de carpetas, `pubspec.yaml` estable |
| 2 | Entorno SQL configurado, migraciones V1, Auth funcionando, validaciones |
| 3 | Repositorios DAO implementados, transacciones, mapeo de Providers |
| 4 | Pantallas core conectadas, navegación con guards, manejo de estados/error |
| 5 | Testing integral, optimización de queries, corrección de bugs |
| 6–8 | Despliegue, validación en stores, documentación, handoff |

---

## ✅ Checklist de Validación Pre-Lanzamiento
- [ ] Autenticación cubre registro, login, recuperación, verificación y cierre seguro.
- [ ] Contraseñas hashadas correctamente; tokens rotados y persistidos de forma segura.
- [ ] Migraciones SQL versionadas, probadas en emulador y con rollback validado.
- [ ] Provider maneja estados sin memory leaks, usa `select` y evita rebuilds innecesarios.
- [ ] UI es responsive, accesible y coherente con el sistema de diseño definido.
- [ ] Pruebas unitarias, de widget e integración con cobertura >70% y mocks de repositorios.
- [ ] Builds firmados, metadatos completos, política de privacidad y flujo GDPR implementados.
- [ ] CI/CD configurado o documentación de release manual clara y reproducible.

---

📌 **Instrucción de Continuidad:**  
Este plan está listo para ejecución procedural. No se generará código fuente hasta que lo solicites explícitamente.  
Cuando estés listo para avanzar a la implementación técnica, responde únicamente con:  
`✅ Procede a generar el código para la Fase X`  
*(donde `X` es el número de la fase que deseas materializar primero)*.

---
💾 **Cómo guardar este documento:**
1. Selecciona todo el texto desde `# 🗃️ Plan de Implementación...` hasta el final.
2. Copia (`Ctrl+C` / `Cmd+C`).
3. Pégalo en un editor de texto (VS Code, Notepad, TextEdit, etc.).
4. Guarda el archivo como `plan_carlsr_jr.md`.
5. Ábrelo con cualquier visor Markdown o exporta a PDF si lo prefieres.
