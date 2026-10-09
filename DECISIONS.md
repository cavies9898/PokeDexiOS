# Decisiones técnicas — PokéDex iOS

Réplica de la app Android (`Kotlin + Compose + MVVM + Clean`) en SwiftUI (iOS 17+, Xcode 26).

## Stack

- **SwiftUI + MVVM + Clean**: capas `App` (DI, navegación, entry), `Domain` (modelos, casos de uso, protocolos de repositorio), `Data` (SQLite, repositorios, mappers), `Presentation` (views + ViewModels `@Observable`).
- **Coordinator por pestaña**: cada tab (Inicio/Equipo/Favoritos/Ajustes) gestiona su propia pila de navegación. La bottom bar solo se oculta al empujar una pantalla, igual que en Android.
- **Factory / DI manual**: `AppEnvironment` centraliza los 18 casos de uso y las fábricas de ViewModels. Sin frameworks de DI.

## Persistencia

- **SQLite3 C API del sistema** (`import SQLite3`) en lugar de GRDB/Room: cero dependencias de terceros, control total del SQL (que es el mismo que usa la app Android) y comportamiento idéntico en transacciones.
- `pokedex.db` (51 MB, 811 Pokémon) va en el bundle y se copia a `Application Support/PokeDex/` en el primer arranque (misma estrategia que Android con `copyDatabaseFromAssets`).
- `pokedex_user.db` guarda favoritos y equipos con el mismo esquema (`favorites`, `teams`, `pokemon_team` con FK `ON DELETE CASCADE`).
- **Reactividad**: en Android se usa Room `ValueObservation`. Aquí, `UserDatabase` es un `actor` con `changesStream() -> AsyncStream<Void>` que emite tras cada escritura; los repositorios re-consultan por tick. Equivalente funcional, sin dependencias.

## Decisiones de comportamiento (réplica exacta)

Se replican bugs/quirks del Android a propósito; no se "corrigieron":

- `genderRate 0` → "100% ♀" y `8` → "100% ♂" (inverso respecto del juego), `-1` → "Sin género".
- Pasos de hueco = valor crudo de `hatch_counter` ("X pasos" o "—").
- Peso = `weight / 100.0`, altura = `height / 10.0`.
- Sin estado vacío en Home/Favoritos (la lista simplemente queda vacía).
- Filtros `unknown`/`shadow` se muestran como el resto.
- Sin pull-to-refresh ni paginación: la lista completa se carga de una vez.
- Settings es un placeholder `Text("Pantalla de Ajustes")`, igual que el Android, y la pestaña está oculta de la bottom bar (queda Inicio/Equipo/Favoritos).
- El selector de filtros de Home no usa modals: al tocar "Filtrar por tipo" se despliega un panel inline en el header con chips de categoría (Tipo, Generación, …) y chips de opciones en `FlowLayout` que aplican el filtro al toque, sin sheet inferior.
- Streams sin emisión → 0 eventos → la pantalla muestra su mensaje de error ("Error al cargar los Pokémon" / "Error al cargar los favoritos").
- `Task { }` en Swift captura `self` implícitamente; los ViewModels mutan `uiState` tras `await` en `@MainActor`.

## Mensajes en español (idénticos al Android)

"El equipo ya tiene 6 Pokémon", "Pokémon duplicado", "Pokémon no encontrado en el equipo", "El nombre no puede estar vacío", "No se pudo calcular la cobertura", "Debes crear un equipo antes de agregar Pokémon", "Descargando datos, por favor espera...", etc.

## Constantes

`MAX_STAT = 255`, `MAX_TEAM_SCORE = 600`, `statCount = 6`, `TEAM_SIZE = 6`, `COLLAPSED_COUNT = 10` (movimientos), 18 colores de tipo (Paleta PokeAPI), luminancia `0.299R + 0.587G + 0.114B > 0.6` → texto oscuro, si no blanco.

## Diferencias técnicas respecto de Android

- Room DAOs → consultas SQL crudas sobre `PokedexDatabase`/`UserDatabase` (actores).
- `Flow` + `StateFlow` → `AsyncStream` + `@Observable` (`Observation`).
- Composables → Views SwiftUI; `NavigationHost` por pestaña → `PushNavigationView` propio (transición scale+fade 260/180 ms) que solo renderiza el tope de la pila.
- El proyecto usa **aislamiento por defecto `MainActor`** (`SWIFT_DEFAULT_ACTOR_ISOLATION`): por eso `DatabaseHelper`, `SQLiteConnection` y las tareas guardadas en los ViewModels están marcados `nonisolated` / `nonisolated(unsafe)`.
- `ArrayDeque` no existe con `SWIFT_VERSION = 5.0`; se usa `[Node]` con `removeFirst()`.

## Tests

Puerto de la suite JUnit/Kotlin con **Swift Testing** (`@Test` / `#expect`), 45 tests:

- `AnalyzeTeamUseCaseTests` y `GetTeamStatsUseCaseTests`: port directo de los tests de dominio del Android.
- Nuevos: `DisplayNameFormatterTests`, `TypesCSVTests`, `TypeChartTests` (multiplicadores, debilidades dual-type, cobertura ordenada por score), `EvolutionChainOrdererTests` (BFS, ramas, ciclos, condiciones), `FilterPipelineTests` (búsqueda, categorías, orden, direcciones por defecto), `TeamValidationTests` (equipo lleno, duplicado, no encontrado, nombre vacío, mensajes exactos) con repositorios mock.

Verificado: `xcodebuild build` sin errores y las 45 pruebas pasan en simulador iOS 26.5; arranque real verificado con captura (grid, tipos y bottom bar correctos).
