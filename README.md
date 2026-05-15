# flood-risk-valencia
Análisis de riesgo de inundación en colegios, hospitales y centros de salud de Valencia tras la DANA 2024. App Shiny interactiva.
# 🌊 Análisis de Riesgo de Inundación en Centros Esenciales — Provincia de Valencia

> **Proyecto de Visualización de Datos** · Universitat de València  
> 🥈 **Accésit** — Entre los 2 mejores grupos de toda la promoción

[![R](https://img.shields.io/badge/R-Shiny-276DC3?logo=r&logoColor=white)](https://shiny.posit.co/)
[![Leaflet](https://img.shields.io/badge/Leaflet-GIS-199900?logo=leaflet)](https://leafletjs.com/)
[![ShinyApps](https://img.shields.io/badge/Desplegado%20en-shinyapps.io-blue)](https://hugofrasquet.shinyapps.io/miniproyecto_vd_entrega/)
[![QGIS](https://img.shields.io/badge/SIG-QGIS-589632?logo=qgis)](https://qgis.org/)

---

## 📌 Contexto

Tras la **DANA del 29 de octubre de 2024** en Valencia —una de las mayores catástrofes naturales de la historia reciente de España con más de 200 víctimas mortales— surgió la necesidad urgente de analizar qué infraestructuras críticas quedan expuestas ante eventos de inundación similares o incluso más extremos.

Este proyecto estudia el **riesgo de inundación** de los centros esenciales de la provincia de Valencia: **colegios, hospitales y centros de salud**, cruzando su localización geográfica con las zonas de inundación oficial según distintos **períodos de retorno hidrológico** (T10, T100, T500 años).

---

## 🎯 Objetivos

- Identificar qué colegios, hospitales y centros de salud están en zona de riesgo de inundación.
- Clasificar el riesgo según el **período de retorno** (probabilidad estadística de que ocurra una inundación de esa magnitud en un año dado).
- Proveer visualizaciones interactivas que permitan explorar el riesgo por municipio, tipo de centro o río/barranco.
- Proporcionar recomendaciones de actuación para cada tipo de instalación.

---

## 🗺️ Demo en vivo

🔗 **[Abrir la aplicación](https://hugofrasquet.shinyapps.io/miniproyecto_vd_entrega/)**

La app incluye:

| Sección | Contenido |
|---|---|
| **Inicio** | Contexto de la DANA y descripción del proyecto |
| **Vista conjunta** | Mapa general + Centros en riesgo clasificados por río/barranco |
| **Colegios** | Mapa general, riesgo por nivel T, gráficos, tabla y recomendaciones |
| **Hospitales** | Mapa general, riesgo por nivel T, gráficos, tabla y recomendaciones |
| **Centros de Salud** | Mapa general, riesgo por nivel T, gráficos, tabla y recomendaciones |
| **Fuentes y créditos** | Datos utilizados y herramientas |

---

## 🧪 Períodos de Retorno

| Período | Significado | Color en mapa |
|---|---|---|
| **T10** | Inundación con probabilidad del 10% cada año (frecuente) | 🟡 Amarillo |
| **T100** | Inundación con probabilidad del 1% cada año (grave) | 🟠 Naranja |
| **T500** | Inundación con probabilidad del 0.2% cada año (extremo) | 🔴 Rojo |

---

## 🏗️ Estructura del proyecto

```
📦 miniproyecto-inundaciones-valencia/
├── app.R                          # Aplicación Shiny completa (UI + Server)
├── www/
│   ├── logo.png                   # Logo de la aplicación
│   ├── codigos_postales_municipios.csv
│   │
│   ├── # --- Zonas de inundación (polígonos) ---
│   ├── inundaciones__valencia_T10.geojson   # ⚠️ Ver nota sobre datos grandes
│   ├── inundaciones_valencia_T100.geojson
│   ├── inundaciones__valencia_T500.geojson
│   ├── inundaciones_valencia_T10.shp  (+ .dbf, .prj, .shx, .cpg)
│   ├── inundaciones_valencia_T100.shp (+ ...)
│   ├── inundaciones__valencia_T500.shp (+ ...)
│   │
│   ├── # --- Colegios ---
│   ├── colegios_valencia.geojson
│   ├── colegios_riesgo_10.geojson
│   ├── colegios_riesgo_100.geojson
│   ├── colegios_riesgo_500.geojson
│   ├── colegios_en_riesgo_total.geojson
│   │
│   ├── # --- Hospitales ---
│   ├── hospitales_total.geojson
│   ├── hospitales_t10.geojson
│   ├── hospitales_t100.geojson
│   ├── hospitales_t500.geojson
│   │
│   └── # --- Centros de Salud ---
│       ├── centros_salud_total.geojson
│       ├── centros_salud_t10.geojson
│       ├── centro_salud_t100.geojson
│       └── centros_salud_t500.geojson
│
├── rsconnect/                     # Configuración de despliegue en shinyapps.io
├── .gitignore
└── README.md
```

> ⚠️ **Nota sobre archivos grandes:** Los archivos GeoJSON de zonas de inundación pueden superar los 50–266 MB cada uno. GitHub rechaza archivos >100 MB. Se recomienda usar **Git LFS** o descargar los datos originales directamente desde las fuentes (ver sección [Fuentes de datos](#-fuentes-de-datos)).

---

## 🚀 Cómo ejecutar localmente

### 1. Requisitos previos

Tener instalado **R** (≥ 4.1) y los siguientes paquetes:

```r
install.packages(c(
  "shiny",
  "leaflet",
  "sf",
  "dplyr",
  "ggplot2",
  "DT",
  "bslib",
  "plotly"
))
```

### 2. Clonar el repositorio

```bash
git clone https://github.com/hugofrasquet/miniproyecto-inundaciones-valencia.git
cd miniproyecto-inundaciones-valencia
```

> Si los datos geoespaciales grandes están en Git LFS, necesitarás [instalar Git LFS](https://git-lfs.com/) y ejecutar `git lfs pull`.

### 3. Lanzar la app

```r
# Desde la consola de R o RStudio
shiny::runApp("app.R")
```

O directamente en RStudio: abrir `app.R` y pulsar **Run App**.

---

## 🛠️ Stack tecnológico

| Herramienta | Uso |
|---|---|
| **R + Shiny** | Framework principal de la aplicación web |
| **Leaflet** | Mapas interactivos |
| **sf** | Lectura y transformación de datos geoespaciales |
| **ggplot2 + plotly** | Gráficos estadísticos e interactivos |
| **DT** | Tablas interactivas |
| **bslib** | Temas y diseño UI |
| **QGIS** | Procesado SIG: intersección de capas, transformación de coordenadas |
| **shinyapps.io** | Despliegue en la nube |

---

## 📂 Fuentes de datos

| Dataset | Fuente |
|---|---|
| Zonas de inundación T10 / T100 / T500 | [Confederación Hidrográfica del Júcar](https://www.chj.es) · [MITECO](https://www.miteco.gob.es) |
| Cartografía base | [Institut Cartogràfic Valencià (ICV)](https://icv.gva.es) |
| Hospitales CV | [Dades Obertes GVA](https://dadesobertes.gva.es/es/dataset/sanidad-sip-hospitales) |
| Centros de Salud CV | [Dades Obertes GVA](https://dadesobertes.gva.es/es/dataset/sanidad-sip-centros-salud) |
| Códigos postales | [GitHub / walterleonardo](https://github.com/walterleonardo/codigos_postales_espa-a) |

---

## 👥 Autores

Proyecto desarrollado por el **Grupo 12** para la asignatura de *Visualización de Datos* de la Universitat de València:

- **Hugo Frasquet García**
- Alberto Dalmau
- Pablo Pons
- Rubén Sierra
- Maksym Myronenko

---

## 🏆 Reconocimientos

> 🥈 **Accésit** en el miniproyecto de Visualización de Datos — entre los 2 mejores grupos de toda la promoción de la Universitat de València (curso 2024–2025).

---

## 📄 Licencia

Este proyecto tiene fines académicos y de divulgación. Los datos geoespaciales pertenecen a sus respectivos organismos públicos (CHJ, MITECO, ICV, GVA).
