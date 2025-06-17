# Balloon Game 🎈

Un juego 2D desarrollado en Godot donde controlas un globo que debe evitar meteoritos y pájaros mientras intenta mantenerse en el aire el mayor tiempo posible.

## 📋 Descripción del Juego

**Balloon Game** es un juego de supervivencia donde el jugador controla un globo que debe esquivar obstáculos que caen del cielo y vuelan desde los lados. El objetivo es sobrevivir el mayor tiempo posible y obtener la puntuación más alta.

### Características Principales:
- **Controles simples**: Un solo botón para hacer flotar el globo
- **Física realista**: Gravedad y sistema de impulsos
- **Múltiples obstáculos**: Meteoritos desde arriba y pájaros desde los lados
- **Sistema de puntuación**: Puntos por tiempo sobrevivido y obstáculos superados
- **Guardado automático**: Las mejores puntuaciones se guardan automáticamente
- **Interfaz completa**: Menú de inicio, HUD del juego y pantalla de Game Over

## 🎮 Controles

- **Acción Principal**: Hacer clic y mantener presionado para hacer flotar el globo hacia el cursor
- **Menú**: Botones en pantalla para navegar por las opciones

## 🏗️ Arquitectura del Proyecto

### Estructura de Archivos:

```
scripts/
├── bird.gd          # Lógica de los pájaros enemigos
├── floor.gd         # Detección de colisión con el suelo
├── hud.gd           # Interfaz de usuario y gestión de datos
├── main.gd          # Controlador principal del juego
├── meteorito.gd     # Lógica de los meteoritos
└── player.gd        # Controlador del globo jugador
```

### Componentes Principales:

#### 🎈 Player (`player.gd`)
- **Tipo**: Area2D
- **Funcionalidades**:
  - Sistema de flotación basado en la posición del cursor
  - Animaciones de flotación y muerte
  - Detección de colisiones con obstáculos
  - Sistema de respawn
  - Efectos de sonido integrados

```gdscript
# Propiedades configurables
@export var fall_gravity := 10    # Fuerza de gravedad
@export var magnitude = 50        # Fuerza del impulso
```

#### 🎯 Main (`main.gd`)
- **Controlador central** del juego
- **Gestiona**:
  - Spawn de enemigos (meteoritos y pájaros)
  - Sistema de puntuación
  - Estados del juego (inicio, jugando, game over)
  - Música de fondo
  - Pantalla de colaboración inicial
  - Limpieza de enemigos al reiniciar

#### 🌟 HUD (`hud.gd`)
- **Interfaz de usuario** completa
- **Características**:
  - Pantalla de inicio
  - Contador de puntuación en tiempo real
  - Cronómetro de supervivencia
  - Pantalla de Game Over con estadísticas
  - **Sistema de guardado** en JSON (`user://save_data.json`)
  - Records de máxima puntuación y tiempo

#### ☄️ Meteorito (`meteorito.gd`)
- **Obstáculos** que caen desde arriba
- Se eliminan automáticamente al salir de pantalla
- Auto-destrucción cuando el juego se pausa

#### 🐦 Bird (`bird.gd`)
- **Enemigos voladores** que vienen desde los lados
- Dos spawns: izquierda y derecha
- Sprites volteados según la dirección

#### 🏢 Floor (`floor.gd`)
- **Zona de muerte** en la parte inferior
- Detecta colisión con el jugador
- Transición automática a Game Over

## 🔧 Sistemas Técnicos

### Sistema de Spawn
- **Meteoritos**: Spawn desde arriba en intervalos regulares
- **Pájaros**: Spawn simultáneo desde izquierda y derecha
- **Paths**: Uso de Path2D para posiciones aleatorias de spawn
- **Velocidades**: Rangos aleatorios (150-250 unidades/segundo)

### Sistema de Puntuación
```gdscript
# Incremento automático cada segundo
func _on_score_timer_timeout() -> void:
	score += 1
	hud.update_score(score)
```

### Sistema de Guardado
```gdscript
# Estructura de datos guardados
var game_data = {
	"max_score": 0,
	"max_time_passed": 0
}
```

### Gestión de Estados
- **Engine.time_scale**: Control de pausa/reanudación
- **Señales**: Comunicación entre componentes
- **Timers**: Control de eventos temporales

## 🎵 Audio

El juego incluye varios efectos de sonido:
- **Música de fondo**: Reproducción continua durante el juego
- **Sonido de tap**: Al hacer flotar el globo
- **Sonido de explosión**: Cuando el globo es destruido

## 💾 Persistencia de Datos

- **Archivo**: `user://save_data.json`
- **Datos guardados**:
  - Puntuación máxima alcanzada
  - Tiempo máximo de supervivencia
- **Guardado automático**: Al terminar cada partida

## 🚀 Características Técnicas

### Optimizaciones:
- **Queue_free()**: Eliminación automática de objetos fuera de pantalla
- **Limpieza de memoria**: Eliminación de enemigos al pausar/reiniciar
- **Grupos de nodos**: Organización eficiente para operaciones masivas

### Controles de Flujo:
- **Pantalla de colaboración**: Solo se muestra en el primer lanzamiento
- **Estados de actividad**: Variables de control para evitar acciones no deseadas
- **Timers coordinados**: Sincronización de eventos del juego

## 🎨 Animaciones

- **Player**: Animaciones de flotación y muerte con flip horizontal
- **Meteoritos**: Rotación basada en dirección de movimiento
- **Pájaros**: Flip horizontal según dirección de vuelo

## 🔄 Flujo del Juego

1. **Inicio**: Pantalla de colaboración (solo primera vez)
2. **Menú Principal**: Botón de inicio y records
3. **Gameplay**: Control del globo, esquivar obstáculos
4. **Game Over**: Mostrar estadísticas y opción de reinicio
5. **Reinicio**: Vuelta al menú principal

## 🛠️ Requisitos Técnicos

- **Engine**: Godot 4.x
- **Plataforma**: Multiplataforma (Windows, Linux, macOS, móviles)
- **Dependencias**: Solo recursos internos de Godot

## 📈 Posibles Mejoras

- Múltiples tipos de obstáculos
- Niveles de dificultad progresiva
- Efectos de partículas
- Leaderboards online
- Achievements/Logros

---

*Desarrollado con ❤️ en Godot Engine*
