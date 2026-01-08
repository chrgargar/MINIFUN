# MINIFUN

MiniFun surge de la idea de crear una aplicación para quienes busquen volver a jugar aquellos
juegos que no se ven muy comúnmente, es una aplicación que inicialmente tendrá 6 juegos 
icónicos: Snake, Ahorcado, Buscaminas, Water Sort, Sopa de Letras y Sudoku. La idea es hacer
estos juegos más accesibles, incluyendo la opción de agregar niveles de dificultad y modoS
adicionales para mantener la diversión y el desafío.

Esta aplicación busca satisfacer tanto a jugadores casuales como más serios, ofreciendo
modalidades que le agregan dificultad a los niveles como: contrarreloj, modalidades sin
pistas, etc. 

## Elementos Principales

- **6 Juegos Casuales:** Snake, Sudoku, Water Sort, Sopa de Letras, Buscaminas, Ahorcado.
- **Sistema de modalidades:** Normal, Contrarreloj, Supervivencia, Perfecto, Premium.
- **Multiidioma:** - Español, Inglés, Francés, Portugués, Catalán
- **Personalización de la interfaz:** Tema (claro/oscuro)
- **Configuración de sonidos:** Música de fondo, personalizada para cada juego, con la opción de silenciar.
- **Clasificación por juegos:** Rachas de días jugados, récords. 
- **Guías Interactivas:** Instrucciones y controles para cada juego.
- **Características:**  Sistema de misiones diarias, categorías, temáticas y pistas. 

.......
## Juegos Disponibles

### Snake
Controla una serpiente para comer alimentos y crecer sin chocar.

**Modalidades:** Normal, Contrarreloj (30s), Supervivencia PRO (obstáculos)
- Velocidad variable, mapas temáticos, modo supervivencia. 

**Caractrísticas:**

| Comida | Tamaño | Puntos  |
|--------|--------|---------|
| Manzana|   +1   |   +10   |
| Fresa  |   +3   |   +20   |
| Moneda |   +0   |   +30   |



### Sudoku
Puzzle clásico con validación en tiempo real.

**Modalidades:** Fácil, Medio, Difícil, Contrarreloj, Perfecto (sin errores)

**Características:**
- Modo Lápiz (validación automática)
- Modo Notas (posibles números)
- Sistema de pistas


### Water Sort
Puzzle de clasificación de líquidos por color en tubos.

**Modalidades:** Contrarreloj, Normal 

**Características:**
- Tubos con capacidad de 4 segmentos
- Sistema de deshacer 

### Sopa de Letras
Encuentra palabras ocultas en una cuadrícula de letras.

**Modalidades**

| Dificultad | Tamaño |
|------------|--------|
| Fácil      |  10x10 |
| Medio      |  15x15 |
| Difícil    |  20x20 |

**Características-Direcciones:** Horizontal, vertical y diagonal

### Buscaminas
Clásico juego de descubrir casillas sin detonar minas.

**Modalidades:** Contrarreloj, fácil.

**Características:**



## Estructura del Proyecto

```
lib/
├── juegos/          # Lógica de cada juego
├── screens/         # Pantallas principales
├── widgets/         # Componentes reutilizables
├── tema/            # Temas e idiomas
├── providers/       # State management (Provider)
├── services/        # Audio y base de datos
├── models/          # Modelos de datos
├── constants/       # Constantes por juego
├── data/            # Guías de juegos
└── main.dart        # Punto de entrada

assets/
├── imagenes/        # Iconos y fondos
└── Sonidos/         # Música y efectos
```

## Tecnologías

|      Tecnología      | Versión |         Uso          |
| -----------------    |---------|    ------------      |
|  Flutter             | ^3.9.2  | Framework UI         |
|  Provider            |  6.1.1  | State Management     |
|  sqflite             |  2.3.0  | Base de datos local  |
|  audioplayers        |  6.1.0  | Sistema de audio     |
|  shared_preferences  |  2.2.2  | Almacenamiento local |

.....

## Instalación

1. Clona el repositorio:
```bash
git clone https://github.com/chrgargar/MINIFUN.git
cd MINIFUN
```

2. Instala las dependencias:
```bash
flutter pub get
```

3. Ejecuta la aplicación:
```bash
flutter run
```

## Plataformas Soportadas

- Android
- iOS
- Web
- Windows
- macOS
- Linux

## Arquitectura

El proyecto sigue el patrón **MVC + Provider**:

- **Models** - `UserModel` para gestión de usuarios
- **Views** - Pantallas en `lib/screens/`
- **Controllers** - Providers para estado global
- **Services** - `AudioService`, `DatabaseService`

## Sistema de Autenticación

- Login con usuario/email y contraseña
- Registro de nuevas cuentas
- Modo invitado con opción de conversión
- Sistema de racha de días consecutivos
- Misiones diarias, para ganar puntos


## Idiomas

| Código |   Idioma    |
|--------|   --------  |
|   es   |   Español   |
|   en   |   Inglés    |
|   fr   |   Français  |
|   pt   |   Português |
|   ca   |   Català    |

## Paleta de Colores

Morado Principal - `#7B3FF2` - Botones, títulos 
Morado Login - `#7B68B8` - Pantalla auth 
Amarillo Banner - `#FFEF62` - Banner PRO 
Verde Snake - `#2E7D32` - Cabeza serpiente 



## Autores
Christian García 
Elio Ojeda
Ashley Barrionuevo 


