# AgroManager

Sistema de gestión integral de finca con GPS, clima en Chiriquí, Panamá, sensores IoT y control de acceso por roles.

**Multiplataforma:** Android · iOS · Web · Windows · macOS · Linux

---

## Requisitos

| Herramienta | Versión | Descarga |
|-------------|---------|----------|
| Flutter SDK | ≥ 3.12 | [flutter.dev](https://flutter.dev) |
| Dart SDK | ≥ 3.12 | incluido con Flutter |
| Git | ≥ 2.0 | [git-scm.com](https://git-scm.com) |
| Firebase CLI | última | `npm install -g firebase-tools` |

---

## Inicio rápido

```bash
# 1. Clonar e instalar dependencias
cd agromanager
flutter pub get

# 2. Ejecutar en Chrome
flutter run -d chrome

# 3. O en Android (celular conectado o emulador)
flutter run

# 4. O en Windows
flutter run -d windows
```

---

## Configuración

### 1. API de clima (OpenWeatherMap)

Ya incluida en `lib/config/constants.dart`:
```dart
static const String weatherApiKey = '72c074fd029ea709c8556e780ca50415';
```

Si caduca, regístrate en [openweathermap.org](https://openweathermap.org/api) y reemplázala.

### 2. Firebase (autenticación + nube)

```bash
# 1. Crear proyecto en https://console.firebase.google.com

# 2. Agregar apps:
#    - Android: package "com.agromanager"
#    - Web: nombre "AgroManager Web"

# 3. Descargar archivos de configuración:
#    - google-services.json → android/app/
#    - firebase_options.dart → lib/ (con flutterfire configure)

# 4. Habilitar servicios en Firebase Console:
#    - Authentication → Sign-in method → Email/Password
#    - Firestore Database → Crear (modo prueba)
#    - (Opcional) Hosting para web

# 5. Configurar primer Super Admin:
#    - Crear colección "user_roles"
#    - Documento con ID = uid del usuario
#    - Campo "role": "super_admin"
```

### 3. Sensores IoT

Ver sección **Integración con hardware** más abajo.

---

## Ejecutar en cada plataforma

### Web
```bash
# Desarrollo
flutter run -d chrome

# Producción
flutter build web --release
# Los archivos estáticos quedan en: build/web/
# Puedes subirlos a Firebase Hosting, Netlify, Vercel, etc.
```

### Android
```bash
# Conecta tu celular por USB (depuración USB activada)
# O usa un emulador Android

# Desarrollo
flutter run

# Producción (APK)
flutter build apk --release
# Genera: build/app/outputs/flutter-apk/app-release.apk

# Producción (App Bundle - recomendado para Play Store)
flutter build appbundle --release
# Genera: build/app/outputs/bundle/release/app-release.aab
```

### iOS
```bash
# Solo en macOS con Xcode
flutter run
flutter build ios --release
```

### Windows
```bash
flutter run -d windows
flutter build windows --release
# Genera: build/windows/runner/Release/
```

### Linux
```bash
flutter run -d linux
flutter build linux --release
```

### macOS
```bash
flutter run -d macos
flutter build macos --release
```

---

## Estructura del proyecto

```
lib/
├── main.dart                     # Entry point + Provider + Firebase init
├── app.dart                      # MaterialApp + rutas + auth flow
├── config/
│   ├── constants.dart            # API keys, coordenadas, roles
│   └── theme.dart                # Tema claro/oscuro Material 3
├── models/
│   ├── crop.dart                 # Cultivo
│   ├── livestock.dart            # Ganado
│   ├── inventory_item.dart       # Inventario
│   ├── finance_record.dart       # Finanzas
│   ├── farm_task.dart            # Tareas
│   ├── weather_data.dart         # Clima
│   └── sensor_data.dart          # Sensores IoT
├── services/
│   ├── database_service.dart     # SQLite local
│   ├── weather_service.dart      # OpenWeatherMap API
│   ├── location_service.dart     # GPS
│   ├── firebase_service.dart     # Firebase Auth + Firestore
│   ├── mqtt_service.dart         # MQTT (hardware real)
│   ├── lorawan_service.dart      # LoRaWAN (ChirpStack/TTN)
│   ├── iot_service.dart          # Gestión de sensores
│   ├── notification_service.dart # Notificaciones push
│   ├── export_service.dart       # PDF/CSV
│   ├── role_service.dart         # Roles de usuario
│   └── offline_service.dart      # Cola offline
├── providers/
│   └── app_provider.dart         # State management
├── screens/
│   ├── auth/                     # Login + Registro
│   ├── dashboard/                # Dashboard principal
│   ├── map/                      # Mapa GPS
│   ├── weather/                  # Clima
│   ├── crops/                    # Cultivos CRUD
│   ├── livestock/                # Ganado CRUD
│   ├── inventory/                # Inventario CRUD
│   ├── finances/                 # Finanzas + gráficos
│   ├── tasks/                    # Tareas CRUD
│   ├── sensors/                  # Sensores IoT + config MQTT
│   ├── reports/                  # Reportes PDF/CSV + Analytics
│   └── admin/                    # Panel de administración
└── widgets/
    ├── app_drawer.dart           # Menú lateral con roles
    ├── stat_card.dart            # Tarjeta de estadística
    ├── loading_widget.dart       # Cargando
    └── empty_state.dart          # Estado vacío
```

---

## Roles de usuario

| Rol | Permisos |
|-----|----------|
| **Super Admin** | Acceso total. Puede gestionar usuarios y roles |
| **Administrador** | Todo excepto gestionar roles |
| **Capataz** | Cultivos, ganado, inventario, tareas |
| **Usuario** | Solo lectura en módulos operativos |

Los roles se asignan desde el panel **Admin** en la app (solo visible para Super Admin y Admin).

---

## Integración con hardware

### MQTT (sensores WiFi - ESP32, ESP8266, etc.)

**Código ejemplo para ESP32:**

```cpp
#include <WiFi.h>
#include <PubSubClient.h>

const char* ssid = "TU_WIFI";
const char* password = "TU_CLAVE";
const char* mqtt_server = "broker.hivemq.com";

WiFiClient espClient;
PubSubClient client(espClient);

void setup() {
  Serial.begin(115200);
  WiFi.begin(ssid, password);
  client.setServer(mqtt_server, 1883);
}

void loop() {
  if (!client.connected()) {
    client.connect("AgroManagerSensor");
  }
  client.loop();

  // Leer sensor de humedad de suelo (ejemplo)
  float soilMoisture = analogRead(34) * 100.0 / 4095.0;
  float temperature = dht.readTemperature();

  // Publicar en formato JSON
  String payload = "{\"value\": " + String(soilMoisture) + ", \"unit\": \"%\", \"battery\": 85}";
  client.publish("agromanager/sensors/soil_moisture", payload.c_str());

  delay(30000); // cada 30 segundos
}
```

**Topics por defecto:**
- `agromanager/sensors/soil_moisture` — Humedad del suelo (%)
- `agromanager/sensors/temperature` — Temperatura (°C)
- `agromanager/sensors/humidity` — Humedad ambiente (%)
- `agromanager/sensors/rain` — Lluvia (mm)
- `agromanager/sensors/wind` — Viento (m/s)
- `agromanager/sensors/ph` — pH del suelo

### LoRaWAN (ChirpStack / The Things Network)

1. Registra tu dispositivo en ChirpStack o TTN
2. Configura el payload formatter para que decodifique en JSON
3. En la app: Sensores → Configuración → LoRaWAN
4. Ingresa: servidor, puerto, API Key, Application ID, Device EUI

---

## Despliegue a producción

### Opción 1: Firebase Hosting (Web) + Firebase Auth

```bash
# 1. Instalar Firebase CLI
npm install -g firebase-tools

# 2. Iniciar sesión
firebase login

# 3. Inicializar hosting
firebase init hosting

# 4. Construir web
flutter build web --release

# 5. Desplegar
firebase deploy --only hosting
```

### Opción 2: Netlify (Web)

```bash
flutter build web --release
# Arrastra la carpeta build/web a Netlify Drop
# O conecta tu repo de GitHub
```

### Opción 3: Play Store (Android)

```bash
# Generar APK firmado
flutter build apk --release

# O App Bundle (recomendado)
flutter build appbundle --release

# Subir a Google Play Console
```

### Opción 4: Servidor propio (Web)

```bash
flutter build web --release
# Copiar build/web/* a /var/www/agromanager/
# Configurar Nginx o Apache
```

---

## Variables de entorno (opcional)

Para no hardcodear API keys en producción, crea un archivo `.env`:

```env
WEATHER_API_KEY=72c074fd029ea709c8556e780ca50415
FIREBASE_API_KEY=...
```

Y usa `flutter_dotenv` para cargarlas en tiempo de ejecución.

---

## Licencia

Uso privado — AgroManager © 2026
