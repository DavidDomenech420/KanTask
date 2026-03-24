# KanTask 

Mi primer proyecto de arquitectura móvil completo, construido desde cero utilizando **Flutter** para el frontend y **Supabase** como motor de backend. 

Más que una simple lista de tareas, KanTask es un sistema Kanban diseñado con el objetivo de comprender a fondo cómo interactúan las interfaces móviles con la lógica de bases de datos relacionales, la seguridad en la nube y el ciclo de vida de los componentes nativos.



## Filosofía del Proyecto

El enfoque principal de este desarrollo no ha sido usar código prefabricado ni "cajas negras", sino entender cómo funcionan los engranajes de la tecnología por dentro. Por ello, la arquitectura del proyecto separa estrictamente la experiencia visual (UI) de la lógica de negocio y la seguridad del servidor (Backend).

## Stack Tecnológico

* **Frontend:** Flutter & Dart (Gestión de estado, animaciones Drag & Drop, encapsulamiento de componentes).
* **Backend:** Supabase (PostgreSQL, Autenticación, Triggers SQL, Row Level Security, Edge Functions).
* **Despliegue Android:** Kotlin DSL (`build.gradle.kts`), Keystore criptográfico, Android App Bundle (.aab).

---

## Arquitectura y Flujo de la Aplicación

### 1. Sistema de Autenticación y Enrutamiento Inteligente
Para maximizar la comodidad del usuario y proteger las rutas, se ha implementado un sistema de redirección inicial:
* **Splash Screen / Enrutador:** Al abrir la app, el sistema verifica el estado de la sesión de Supabase localmente. Si no hay sesión, redirige al `Login`; si la hay, salta al `Home` sin pantallas de carga innecesarias.
* **Seguridad de Identidad:** El registro utiliza la API de Auth de Supabase, requiriendo validación por correo electrónico para garantizar que no existan cuentas fantasma en la base de datos.

### 2. El Motor de Base de Datos (PostgreSQL en Supabase)
En lugar de saturar el código de Flutter con validaciones pesadas, he delegado las responsabilidades críticas a la base de datos para asegurar que el sistema sea robusto sin importar el cliente que lo consuma:
* **Triggers SQL (Automatización):** Para evitar que el usuario inicie con una pantalla vacía, se programó un *Trigger* en PostgreSQL que escucha la inserción en la tabla de `auth.users`. Al detectarlo, ejecuta una función interna que crea automáticamente un tablero llamado "Personal" y asigna al usuario como dueño.
* **Integridad Referencial:** Las tablas (`boards`, `tasks`, `board_members`, `board_invites`) están unidas por llaves foráneas en cascada, garantizando que si se borra un tablero, todas sus tareas e invitados desaparezcan limpiamente de la memoria.

### 3. Seguridad Avanzada: Row Level Security (RLS) y RPCs
El sistema cuenta con una arquitectura de seguridad estricta para que ningún usuario pueda leer o modificar tableros que no le pertenecen.
* **Políticas RLS:** Se configuraron políticas para aislar los datos. Un usuario solo puede hacer un `SELECT` o `UPDATE` de un tablero si su `auth.uid()` coincide con el `owner_id` o si forma parte de la tabla `board_members`.
* **RPC (Remote Procedure Call) con Privilegios Elevados:** Para resolver cruces complejos de seguridad (como un administrador eliminando a un miembro de un tablero), se diseñó una función SQL con la etiqueta `SECURITY DEFINER`. Esto actúa como un "Gerente VIP" que valida la identidad del administrador y ejecuta el borrado, evitando bloqueos por ambigüedad de tipos en las políticas nativas.



### 4. Arquitectura de Invitaciones (Edge Functions & Resend)
KanTask permite el trabajo colaborativo mediante un sistema de invitaciones asíncrono.
* Se dividió la lógica en usuarios "Pendientes" (`board_invites`) y "Miembros activos" (`board_members`).
* Las invitaciones por correo no se envían desde el teléfono del usuario (lo cual sería inseguro), sino que el cliente de Flutter invoca una **Edge Function** (TypeScript/Deno) alojada en Supabase. Esta función se comunica de forma segura con la API de **Resend** para entregar los correos electrónicos.

### 5. Frontend: Gestión de Estado y Ciclo de Vida (Flutter)
La interfaz no solo pinta datos, sino que maneja la memoria eficientemente:
* **Manejo de Memoria (Failsafe Async):** Se implementaron validaciones `if (!mounted) return;` después de cada llamada a la base de datos. Esto previene el clásico error de Flutter (`setState() called after dispose()`) si el usuario cierra el PopUp antes de que el servidor responda.

### 6. Sistema Kanban Interactivo (UI/UX)
El gestor de tareas está diseñado para ser táctil e intuitivo, protegiendo al usuario de acciones destructivas accidentales:
* **Drag and Drop:** Las tareas se pueden mantener pulsadas y arrastrar libremente entre columnas (Pendiente, En Progreso, Completado).
* **Prevención de Errores Lógicos:** Si el usuario tiene un único tablero, el botón de eliminar se desactiva visual y lógicamente, impidiendo que la base de datos quede en un estado inconsistente (sin tableros a los que navegar).
* **Auto-Navegación:** Al eliminar el tablero activo (si hay más disponibles), la aplicación intercepta el borrado y cambia el foco automáticamente al primer tablero de la lista.

---

## 🚀 Preparación para Producción
El proyecto está configurado bajo los estándares modernos de Android:
* Transición completa de Groovy a **Kotlin DSL** (`build.gradle.kts`) para la gestión de dependencias y scripts de construcción.
* Integración segura de firmas criptográficas (Keystore) mediante variables de entorno en `key.properties`.
* Empaquetado optimizado en formato **Android App Bundle (.aab)**, listo para su distribución modular en Google Play Store.