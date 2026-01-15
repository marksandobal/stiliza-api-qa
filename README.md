# Stiliza API

API RESTful para la gestión de usuarios, perfiles y empresas, construida con Ruby on Rails.

## ✨ Características

*   Autenticación de usuarios basada en JWT (JSON Web Tokens) utilizando Devise.
*   Registro de usuarios con confirmación por correo electrónico y verificación.
*   Recuperación de contraseñas.
*   Gestión de perfiles de usuario.
*   Soporte para múltiples empresas y asignación de usuarios a ellas.
*   Documentación de API interactiva con Swagger (Rswag).

## 🛠️ Stack Tecnológico

*   **Ruby:** (versión especificada en `.ruby-version`)
*   **Ruby on Rails:** (versión especificada en `Gemfile`)
*   **Base de Datos:** PostgreSQL
*   **Servidor:** Puma
*   **Autenticación:** Devise & `devise-jwt`
*   **Serializers:** `active_model_serializers`
*   **Documentación API:** `rswag`

## 📋 Requisitos Previos

Asegúrate de tener instalado lo siguiente en tu sistema:

*   Ruby (ver `.ruby-version`)
*   Bundler
*   PostgreSQL

## 🚀 Instalación

Sigue estos pasos para configurar el entorno de desarrollo local:

1.  **Clona el repositorio:**
    ```bash
    git clone https:/`/github.com/tu-usuario/stiliza-api.git`
    cd stiliza-api
    ```

2.  **Instala las gemas:**
    ```bash
    bundle install
    ```

## ⚙️ Configuración de Variables de Ambiente

Crea un archivo `.env` en la raíz del proyecto y configura las variables necesarias. Puedes usar el archivo ``example.env`` como referencia.

## Base de Datos
### Crea la base de datos:

```sh
rails db:create
```

### Ejecuta las migraciones:

```sh
rails db:migrate
```
(Opcional) Puebla la base de datos con datos de prueba:

```sh
rails db:seed
```

Swagger API Documentation
Para acceder a la documentación interactiva de la API, inicia el servidor de Rails con el siguiente comando:

```sh
rails server
```

Luego, abre tu navegador y visita la siguiente URL:

[https://stiliza-api-qa.onrender.com/api-docs](https://stiliza-api-qa.onrender.com/api-docs)

Encontrarás todos los endpoints, modelos y podrás probar la API directamente desde la interfaz de Swagger.

📂 Estructura del Proyecto
El proyecto sigue la estructura convencional de una aplicación Ruby on Rails, con algunas adiciones clave:
stiliza-api/
├── app/
│ ├── controllers/ # Controladores de la aplicación, incluyendo Devise y API.
│ ├── models/ # Modelos de Active Record.
│ ├── serializers/ # Serializers para formatear las respuestas JSON.
│ └── jobs/ # Trabajos en segundo plano (si aplica).
├── config/
│ ├── routes.rb # Definición de rutas de la API.
│ └── initializers/ # Configuraciones de Devise, Rswag, etc.
├── db/
│ ├── migrate/ # Migraciones de la base de datos.
│ └── schema.rb # Esquema actual de la base de datos.
├── spec/ # Pruebas RSpec.
│ ├── request/ # Pruebas de integración para los endpoints.
│ └── factories/ # Factorías para crear objetos de prueba.
└── swagger/ # Archivos generados por Rswag.

## 📚 Recursos Adicionales
[Documentación de Ruby on Rails](https://guides.rubyonrails.org/)
[https://github.com/heartcombo/devise](https://github.com/heartcombo/devise)
[https://github.com/rswag/rswag](https://github.com/rswag/rswag)

## ⚖️ Licencia y Propiedad

Este es un **repositorio privado**. El código fuente, los conceptos técnicos y los activos contenidos en este proyecto son propiedad intelectual de **[Nombre de tu Empresa]**.

* **Prohibida su reproducción:** No se permite la copia, distribución o modificación de este código sin autorización previa por escrito.
* **Uso Restringido:** El acceso a este repositorio está limitado exclusivamente a personal autorizado y colaboradores bajo contrato de confidencialidad (NDA).

Copyright © 2026 **[Nombre de tu Empresa]** - Todos los derechos reservados.
