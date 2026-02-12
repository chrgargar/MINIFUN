# 📱 Guía para Ejecutar MINIFUN en Android Studio

## 🎯 Método 1: Desde Android Studio (Recomendado para Presentación)

### Paso 1: Abrir el Proyecto
1. Abre **Android Studio**
2. Selecciona **"Open an Existing Project"** o **"Abrir"**
3. Navega a: `C:\Users\eliojeara\Music\Workspaces\proyecto\MINIFUN`
4. Haz clic en **"OK"**

### Paso 2: Esperar la Indexación
- Android Studio indexará el proyecto (puede tomar 1-2 minutos)
- Verás una barra de progreso en la parte inferior
- Espera a que termine antes de continuar

### Paso 3: Iniciar el Emulador
1. En la barra superior de Android Studio, busca el selector de dispositivos
2. Haz clic en el dropdown de dispositivos
3. Selecciona **"Medium Phone API 36.1"** (o cualquier emulador disponible)
4. Si no está ejecutándose, haz clic en el ícono de play ▶️ junto al nombre del emulador
5. Espera 30-60 segundos a que el emulador arranque completamente

### Paso 4: Ejecutar la Aplicación
1. Una vez que el emulador esté listo (verás la pantalla de inicio de Android)
2. En Android Studio, haz clic en el botón verde de **"Run"** ▶️ (o presiona Shift + F10)
3. La aplicación se compilará e instalará en el emulador
4. Espera 1-3 minutos la primera vez (compilación inicial)

---

## 🚀 Método 2: Desde la Terminal (Más Rápido)

### Opción A: Con Emulador

```bash
# 1. Lanzar el emulador
flutter emulators --launch Medium_Phone_API_36.1

# 2. Esperar 30-60 segundos a que arranque

# 3. Ejecutar la app
flutter run
```

### Opción B: En Windows (Desktop)

```bash
# Ejecutar directamente en Windows
flutter run -d windows
```

### Opción C: En Chrome (Web)

```bash
# Ejecutar en el navegador
flutter run -d chrome
```

---

## 🔧 Solución de Problemas Comunes

### Problema 1: "No devices found"
**Solución:**
```bash
# Verificar dispositivos disponibles
flutter devices

# Listar emuladores
flutter emulators

# Lanzar emulador específico
flutter emulators --launch Medium_Phone_API_36.1
```

### Problema 2: "Android licenses not accepted"
**Solución:**
```bash
flutter doctor --android-licenses
# Presiona 'y' para aceptar todas las licencias
```

### Problema 3: El emulador no arranca
**Solución:**
1. Abre Android Studio
2. Ve a **Tools > AVD Manager**
3. Haz clic en el ícono de play ▶️ junto a tu emulador
4. Espera a que arranque completamente

### Problema 4: Errores de compilación
**Solución:**
```bash
# Limpiar el proyecto
flutter clean

# Obtener dependencias
flutter pub get

# Intentar ejecutar de nuevo
flutter run
```

---

## 📊 Comandos Útiles

```bash
# Ver información del sistema Flutter
flutter doctor

# Ver dispositivos conectados
flutter devices

# Limpiar el proyecto
flutter clean

# Obtener dependencias
flutter pub get

# Ejecutar tests
flutter test

# Compilar para Android (APK)
flutter build apk

# Compilar para Windows
flutter build windows
```

---

## 🎓 Para la Presentación con tu Profesor

### Preparación Previa:
1. **Antes de la clase:**
   - Abre Android Studio
   - Inicia el emulador
   - Ejecuta la app una vez para asegurarte de que funciona
   - Deja todo listo

2. **Durante la presentación:**
   - Muestra el código de los tests en `test/`
   - Ejecuta `flutter test` para mostrar que todos pasan
   - Abre `reporte_tests.html` para mostrar el reporte visual
   - Ejecuta la app en el emulador para demostrar funcionalidad

### Puntos Clave a Mencionar:
- ✅ 33 tests unitarios implementados
- ✅ 100% de tests pasando
- ✅ Cobertura de: Models, Validators, Constants, Services, Providers
- ✅ Arquitectura limpia con separación de responsabilidades
- ✅ Integración con backend mediante API REST

---

## 📱 Dispositivos Disponibles

Actualmente tienes disponibles:
- **Emulador Android:** Medium Phone API 36.1
- **Windows Desktop:** Para desarrollo rápido
- **Chrome/Edge:** Para pruebas web

---

## ⚡ Atajos de Teclado en Android Studio

- **Shift + F10** - Ejecutar la aplicación
- **Shift + F9** - Ejecutar en modo debug
- **Ctrl + F5** - Hot Reload (mientras la app está corriendo)
- **Ctrl + Shift + F5** - Hot Restart
- **Alt + Shift + F10** - Seleccionar configuración y ejecutar

---

## 🎯 Siguiente Paso

**Para ejecutar ahora mismo:**

1. Espera a que el emulador termine de arrancar (verás la pantalla de inicio de Android)
2. Ejecuta en la terminal:
   ```bash
   flutter run
   ```
3. O usa Android Studio con el botón Run ▶️

¡Listo para mostrar tu proyecto! 🚀
