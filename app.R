library(shiny)
library(leaflet)
library(sf)
library(dplyr)
library(ggplot2)
library(DT)
library(bslib)
library(plotly)

# ---- Estilo de gráficos ----
theme_riesgo <- theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, color = "#2c3e50"),
    axis.title = element_text(color = "#2c3e50"),
    axis.text = element_text(color = "#34495e"),
    panel.grid.major = element_line(color = "#ecf0f1")
  )

# ---- Funciones auxiliares ----
safe_label <- function(data, var) {
  if (var %in% names(data)) {
    return(as.formula(paste0("~", var)))
  } else {
    return(NULL)
  }
}

# ---- Cargar Datos ----
colegios <- st_read("www/colegios_valencia.geojson", quiet = TRUE)
colegios_riesgo_10 <- st_read("www/colegios_riesgo_10.geojson", quiet = TRUE) %>% st_cast("POINT")
colegios_riesgo_100 <- st_read("www/colegios_riesgo_100.geojson", quiet = TRUE) %>% st_cast("POINT")
colegios_riesgo_500 <- st_read("www/colegios_riesgo_500.geojson", quiet = TRUE) %>% st_cast("POINT")


hospitales <- st_read("www/hospitales_total.geojson", quiet = TRUE)
hospitales <- st_transform(hospitales, crs = 4326)
hospitales_riesgo_10 <- st_read("www/hospitales_t10.geojson", quiet = TRUE) %>% st_cast("POINT")
hospitales_riesgo_100 <- st_read("www/hospitales_t100.geojson", quiet = TRUE) %>% st_cast("POINT")
hospitales_riesgo_500 <- st_read("www/hospitales_t500.geojson", quiet = TRUE) %>% st_cast("POINT")

zonas_10 <- st_read("www/inundaciones__valencia_T10.geojson", quiet = TRUE) %>% st_transform(4326)
zonas_100 <- st_read("www/inundaciones_valencia_T100.geojson", quiet = TRUE) %>% st_transform(4326)
zonas_500 <- st_read("www/inundaciones__valencia_T500.geojson", quiet = TRUE) %>% st_transform(4326)


# Cambios Hugo
cp_municipios <- read.csv("www/codigos_postales_municipios.csv", stringsAsFactors = FALSE)
hospitales$CEN_CODPOS <- as.character(hospitales$CEN_CODPOS)
cp_municipios$codigo_postal <- as.character(cp_municipios$codigo_postal)

hospitales <- hospitales %>%
  left_join(cp_municipios, by = c("CEN_CODPOS" = "codigo_postal"))

riesgo_10 <- st_read("www/hospitales_t10.geojson", quiet = TRUE) %>% st_cast("POINT")
riesgo_100 <- st_read("www/hospitales_t100.geojson", quiet = TRUE) %>% st_cast("POINT")
riesgo_500 <- st_read("www/hospitales_t500.geojson", quiet = TRUE) %>% st_cast("POINT")

zonas_10 <- st_read("www/inundaciones__valencia_T10.geojson", quiet = TRUE)
zonas_10 <- st_transform(zonas_10, crs = 4326)
zonas_100 <- st_read("www/inundaciones_valencia_T100.geojson", quiet = TRUE)
zonas_100 <- st_transform(zonas_100, crs = 4326)
zonas_500 <- st_read("www/inundaciones__valencia_T500.geojson", quiet = TRUE)
zonas_500 <- st_transform(zonas_500, crs = 4326)

riesgo_10$CEN_CODPOS <- as.character(riesgo_10$CEN_CODPOS)
riesgo_100$CEN_CODPOS <- as.character(riesgo_100$CEN_CODPOS)
riesgo_500$CEN_CODPOS <- as.character(riesgo_500$CEN_CODPOS)

riesgo_10 <- riesgo_10 %>% left_join(cp_municipios, by = c("CEN_CODPOS" = "codigo_postal"))
riesgo_100 <- riesgo_100 %>% left_join(cp_municipios, by = c("CEN_CODPOS" = "codigo_postal"))
riesgo_500 <- riesgo_500 %>% left_join(cp_municipios, by = c("CEN_CODPOS" = "codigo_postal"))

# Asegurar sistema de coordenadas compatible
hospitales <- st_transform(hospitales, crs = 4326)
riesgo_10 <- st_transform(riesgo_10, crs = 4326)
riesgo_100 <- st_transform(riesgo_100, crs = 4326)
riesgo_500 <- st_transform(riesgo_500, crs = 4326)

centros <- st_read("www/centros_salud_total.geojson", quiet = TRUE)
riesgo_10_salud <- st_read("www/centros_salud_t10.geojson", quiet = TRUE) %>% st_cast("POINT")
riesgo_100_salud <- st_read("www/centro_salud_t100.geojson", quiet = TRUE) %>% st_cast("POINT")
riesgo_500_salud <- st_read("www/centros_salud_t500.geojson", quiet = TRUE) %>% st_cast("POINT")
zonas_10_salud <- st_read("www/inundaciones__valencia_T10.geojson", quiet = TRUE)
zonas_10_salud <- st_transform(zonas_10_salud, crs = 4326)

centros$CEN_CODPOS <- as.character(centros$CEN_CODPOS)
cp_municipios$codigo_postal <- as.character(cp_municipios$codigo_postal)
centros <- centros %>%
  left_join(cp_municipios, by = c("CEN_CODPOS" = "codigo_postal"))

riesgo_10_salud$CEN_CODPOS <- as.character(riesgo_10_salud$CEN_CODPOS)
riesgo_100_salud$CEN_CODPOS <- as.character(riesgo_100_salud$CEN_CODPOS)
riesgo_500_salud$CEN_CODPOS <- as.character(riesgo_500_salud$CEN_CODPOS)

riesgo_10_salud <- riesgo_10_salud %>% left_join(cp_municipios, by = c("CEN_CODPOS" = "codigo_postal"))
riesgo_100_salud <- riesgo_100_salud %>% left_join(cp_municipios, by = c("CEN_CODPOS" = "codigo_postal"))
riesgo_500_salud <- riesgo_500_salud %>% left_join(cp_municipios, by = c("CEN_CODPOS" = "codigo_postal"))

centros <- st_transform(centros, crs = 4326)
riesgo_10_salud <- st_transform(riesgo_10_salud, crs = 4326)
riesgo_100_salud <- st_transform(riesgo_100_salud, crs = 4326)
riesgo_500_salud <- st_transform(riesgo_500_salud, crs = 4326)

riesgo_10_centsa_conjunto <- st_read("www/centros_salud_t10.geojson", quiet = TRUE) %>% st_cast("POINT")
riesgo_100_centsa_conjunto <- st_read("www/centro_salud_t100.geojson", quiet = TRUE) %>% st_cast("POINT")
riesgo_500_centsa_conjunto <- st_read("www/centros_salud_t500.geojson", quiet = TRUE) %>% st_cast("POINT")

riesgo_10_centsa_conjunto <- st_transform(riesgo_10_centsa_conjunto, crs = 4326)
riesgo_100_centsa_conjunto <- st_transform(riesgo_100_centsa_conjunto, crs = 4326)
riesgo_500_centsa_conjunto <- st_transform(riesgo_500_centsa_conjunto, crs = 4326)
colegios_riesgo_100 <- st_transform(colegios_riesgo_100, crs = 4326)


riesgo_100_centsa_conjunto <- riesgo_100_centsa_conjunto %>%
  rename(Denominacion = CEN_DESCLA)
riesgo_500_centsa_conjunto <- riesgo_500_centsa_conjunto %>%
  rename(Denominacion = CEN_DESCLA)

todos_riesgos_10 <- bind_rows(colegios_riesgo_10, riesgo_10_centsa_conjunto)
todos_riesgos_100 <- bind_rows(colegios_riesgo_100, riesgo_100_centsa_conjunto)
todos_riesgos_500 <- bind_rows(colegios_riesgo_500, riesgo_500_centsa_conjunto)

colegios_2 <- st_read("www/colegios_valencia.geojson", quiet = TRUE)
hospitales_2 <- st_read("www/hospitales_total.geojson", quiet = TRUE)
centros_2 <- st_read("www/centros_salud_total.geojson", quiet = TRUE)
cp_municipios <- read.csv("www/codigos_postales_municipios.csv", stringsAsFactors = FALSE)

hospitales_2 <- st_transform(hospitales_2, crs = 4326)
colegios_2 <- st_transform(colegios_2, crs = 4326)
centros_2 <- st_transform(centros_2, crs = 4326)

hospitales_2$CEN_CODPOS <- as.character(hospitales_2$CEN_CODPOS)
cp_municipios$codigo_postal <- as.character(cp_municipios$codigo_postal)
centros_2$CEN_CODPOS <- as.character(centros_2$CEN_CODPOS)

hospitales_2 <- hospitales_2 %>%
  left_join(cp_municipios, by = c("CEN_CODPOS" = "codigo_postal"))
centros_2 <- centros_2 %>%
  left_join(cp_municipios, by = c("CEN_CODPOS" = "codigo_postal"))

hospitales_2 <- hospitales_2 %>%
  rename(Localidad = municipio_nombre)
centros_2 <- centros_2 %>%
  rename(Localidad = municipio_nombre)
hospitales_2 <- hospitales_2 %>%
  rename(Denominacion = CEN_DESCLA)
centros_2 <- centros_2 %>%
  rename(Denominacion = CEN_DESCLA)
centros_general <- bind_rows(colegios_2, hospitales_2, centros_2)
centros_general$Localidad <- tolower(centros_general$Localidad)



# ---- UI COMPLETO ----
custom_css <- tags$head(tags$style(HTML(".leaflet-container { background: white !important; } .shiny-download-link { margin-top: 10px; } h4 { text-align: center; font-weight: bold; }")))

ui <- navbarPage(
  title = span(
    tags$img(src = "logo.png", height = "50px", style = "margin-right: 10px;"),
    "Centros en Riesgo de Inundación",
    style = "font-weight: bold; font-size: 20px;"
  ),
  theme = bs_theme(bootswatch = "flatly"),
  
  tabPanel("Inicio",
           fluidPage(
             custom_css,
             br(),
             fluidRow(
               column(12, align = "center",
                      h1("📍 Visualización del Riesgo de Inundación"),
                      
                      # Imagen principal
                      img(src = "https://misionessalesianas.org/wp-content/uploads/2024/11/colegio-dana-desperfectos-valencia-clases-destacado.jpg",
                          height = "300px", style = "margin:20px auto; display:block;"),
                      
                      # Párrafos informativos
                      p("Estudio sobre posibles riesgos de inundación en Hospitales, colegios y Centros de salud de la provincia de Valencia."),
                      p("Datos tratados con QGIS y visualizados con R + Shiny."),
                      
                      # Imagen adicional más pequeña
                      img(src = "https://th.bing.com/th/id/R.f2ccd552d8eefd5104b0c730d169ad5a?rik=lCJKxjjeE6alig&riu=http%3a%2f%2fwww.uv.es%2fetsedoc%2fWeb%2fLogos+X+aniver%2fetseUV+2l+10anys.jpg&ehk=PbYmanQ7mu7BC%2fUVGK5pQvL3i0Z%2bnQvZgqICUdOsgPw%3d&risl=&pid=ImgRaw&r=0",
                          height = "100px", style = "margin-top:30px; display:block;")
               )
             )
           )
  ),
  navbarMenu("🏥🏫 Conjunto General",
             tabPanel("🗺️ Mapa general",
                      sidebarLayout(
                        sidebarPanel(
                          selectInput("muni_general", "Filtrar por municipio:",
                                      choices = c("Todos", sort(unique(centros_general$Localidad))), selected = "Todos")
                        ),
                        mainPanel(leafletOutput("mapa_todos_general", height = 600),
                                  p("Este mapa muestra todos los Colegios, Hospitales y Centros de salud de la provincia de Valencia, con la opción de clasificarlos por municipio."))
                      )
               
             ),
             tabPanel("🌊 Centros en riesgo por Río",
                      sidebarLayout(
                        sidebarPanel(
                          radioButtons("escenario_riesgo", "Selecciona periodo de retorno:",
                                       choices = c("T = 10" = "10", "T = 100" = "100", "T = 500" = "500"),
                                       selected = "10"),
                          uiOutput("selector_rio")
                        ),
                        mainPanel(
                          leafletOutput("mapa_rio_dinamico", height = "600px"),
                          p("Este mapa muestra los Colegios, Hospitales y Centros de salud de la provincia de Valencia con riesgo de inundación, con la opción de clasificarlos por Rio y barranco y por periodo de retorno.")
                        )
                      )
             )
  ),
  navbarMenu("🏫 Colegios",
             tabPanel("🗺️ Mapa general",
                      sidebarLayout(
                        sidebarPanel(
                          selectInput("muni_col", "Filtrar por municipio:",
                                      choices = c("Todos", sort(unique(colegios$Localidad))), selected = "Todos")
                        ),
                        mainPanel(leafletOutput("mapa_colegios", height = 600),
                                  p("Este mapa muestra todos los Colegios de la provincia de Valencia, con la opción de clasificarlos por municipio."))
                      )
             ),
             tabPanel("⚠️ Riesgo por nivel",
                      fluidRow(
                        column(4, 
                               h4("Selecciona el nivel de riesgo:"),
                               radioButtons("nivel_riesgo", "Nivel de riesgo:",
                                            choices = list("Riesgo T = 10" = "c10", 
                                                           "Riesgo T = 100" = "c100", 
                                                           "Riesgo T = 500" = "c500"),
                                            selected = "c10")
                        ),
                        column(8, 
                               leafletOutput("mapa_riesgo", height = 400),
                               p("Este mapa muestra los colegios con riesgo de inundación de la provincia de Valencia según el periodo de retorno (T)")
                        )
                      )
             ),
             tabPanel("📊 Gráficos",
                      fluidRow(
                        column(6, plotOutput("grafico_cole_muni")),
                        column(6, plotOutput("grafico_cole_riesgo"))
                      )
             ),
             
             
             tabPanel("📋 Tabla",
                      fluidPage(
                        downloadButton("descarga_colegios", "Descargar CSV"),
                        DTOutput("tabla_colegios")
                      )
             ),
             tabPanel("Recomendaciones",
                      sidebarLayout(
                        sidebarPanel(
                          radioButtons(
                            inputId = "riesgo_recomendaciones",
                            label = "Selecciona el periodo de retorno:",
                            choices = c("T = 10" = "10", "T = 100" = "100", "T = 500" = "500"),
                            selected = "10",
                            inline = TRUE
                          )
                        ),
                        mainPanel(
                          conditionalPanel(
                            condition = "input.riesgo_recomendaciones == '10'",
                            HTML("
          <h3>🏫 Colegios</h3>
          <h4>Riesgo T = 10:</h4>
          <ul>
            <li>Suspensión de clases ante avisos meteorológicos naranja o rojo.</li>
            <li>Simulacros de evacuación obligatorios al menos una vez al trimestre.</li>
            <li>Supervisión periódica de accesos, salidas y patios para evitar acumulaciones de agua.</li>
            <li>Señalización clara de rutas de evacuación y puntos de reunión.</li>
            <li>Plan de autoprotección actualizado e integrado con el riesgo de inundación.</li>
          </ul>
        ")
                          ),
                          conditionalPanel(
                            condition = "input.riesgo_recomendaciones == '100'",
                            HTML("
          <h3>🏫 Colegios</h3>
          <h4>Riesgo T = 100:</h4>
          <ul>
            <li>Simulacro general de emergencia al menos una vez al año.</li>
            <li>Formación básica para el profesorado y personal de administración.</li>
            <li>Coordinación con Protección Civil y recepción de avisos en tiempo real.</li>
            <li>Estudio del entorno para mejorar drenaje y accesibilidad.</li>
            <li>Cartelería informativa sobre zonas seguras y procedimientos de emergencia.</li>
          </ul>
        ")
                          ),
                          conditionalPanel(
                            condition = "input.riesgo_recomendaciones == '500'",
                            HTML("
          <h3>🏫 Colegios</h3>
          <h4>Riesgo T = 500:</h4>
          <ul>
            <li>Evaluación estructural del centro cada dos años, especialmente en plantas bajas.</li>
            <li>Simulacro bienal de carácter informativo y de sensibilización.</li>
            <li>Inclusión del escenario de inundación en el plan de emergencias a largo plazo.</li>
            <li>Charlas anuales de concienciación para alumnos y familias.</li>
            <li>Fomento de campañas educativas sobre riesgos naturales.</li>
          </ul>
        ")
                          )
                        )
                      )
             )
             
  ),
  navbarMenu("🏥 Hospitales",
             tabPanel("🗺️ Mapa general",
                      sidebarLayout(
                        sidebarPanel(
                          selectInput("muni_hosp", "Filtrar por municipio:",
                                      choices = c("Todos", sort(unique(hospitales$municipio_nombre))), selected = "Todos")
                        ),
                        mainPanel(leafletOutput("mapa_hospitales", height = 600),
                                  p("Este mapa muestra todos los Hospitales de la provincia de Valencia, con la opción de clasificarlos por municipio."))
                      )
             ),
             tabPanel("⚠️ Riesgo por nivel (Hospitales)",
                      fluidRow(
                        column(4,
                               h4("Selecciona el nivel de riesgo:"),
                               radioButtons("nivel_riesgo_h", "Nivel de riesgo:",
                                            choices = list("Riesgo T = 10" = "h10", 
                                                           "Riesgo T = 100" = "h100", 
                                                           "Riesgo T = 500" = "h500"),
                                            selected = "h10")
                        ),
                        column(8,
                               leafletOutput("mapa_riesgo_h", height = 400),
                               p("Este mapa muestra los Hospitales con riesgo de inundación de la provincia de Valencia según el periodo de retorno (T)")
                        )
                      )
             ),
             tabPanel("📊 Gráficos",
                      fluidRow(
                        column(6, plotOutput("grafico_hosp_muni")),
                        column(6, plotOutput("grafico_hosp_riesgo"))
                      )
             ),
             tabPanel("📋 Tabla",
                      fluidPage(
                        downloadButton("descarga_hospitales", "Descargar CSV"),
                        DTOutput("tabla_hospitales")
                      )
             ),
             tabPanel("Recomendaciones",
                      sidebarLayout(
                        sidebarPanel(
                          radioButtons(
                            inputId = "riesgo_hospitales",
                            label = "Selecciona el periodo de retorno:",
                            choices = c("T = 10" = "10", "T = 100" = "100", "T = 500" = "500"),
                            selected = "10",
                            inline = TRUE
                          )
                        ),
                        mainPanel(
                          conditionalPanel(
                            condition = "input.riesgo_hospitales == '10'",
                            HTML("
          <h3>🏥 Hospitales</h3>
          <h4>Riesgo T = 10:</h4>
          <ul>
            <li>Implementación de planes de evacuación rápidos y coordinados.</li>
            <li>Simulacros específicos cada seis meses con todos los turnos.</li>
            <li>Asegurar accesos para ambulancias y evacuación de pacientes encamados.</li>
            <li>Refuerzo de generadores y sistemas eléctricos en zonas elevadas.</li>
            <li>Supervisión constante de los protocolos durante episodios críticos.</li>
          </ul>
        ")
                          ),
                          conditionalPanel(
                            condition = "input.riesgo_hospitales == '100'",
                            HTML("
          <h3>🏥 Hospitales</h3>
          <h4>Riesgo T = 100:</h4>
          <ul>
            <li>Formación anual para el personal médico y de emergencias.</li>
            <li>Refuerzo logístico ante alertas meteorológicas.</li>
            <li>Evaluación de accesos y zonas críticas (urgencias, quirófanos).</li>
            <li>Coordinación activa con servicios externos (112, Protección Civil).</li>
            <li>Comprobación del sistema de comunicación interna en emergencias.</li>
          </ul>
        ")
                          ),
                          conditionalPanel(
                            condition = "input.riesgo_hospitales == '500'",
                            HTML("
          <h3>🏥 Hospitales</h3>
          <h4>Riesgo T = 500:</h4>
          <ul>
            <li>Auditoría estructural completa del edificio cada 5 años.</li>
            <li>Plan de contingencia para fenómenos extremos no comunes.</li>
            <li>Estudio de reubicación temporal de servicios sensibles ante alertas prolongadas.</li>
            <li>Simulacros teóricos o revisiones documentales cada 2 años.</li>
            <li>Planificación de inversiones a largo plazo en infraestructuras resilientes.</li>
          </ul>
        ")
                          )
                        )
                      )
             )
  ),
  navbarMenu("🏥 Centros de Salud",
             tabPanel("🗺️ Mapa general",
                      sidebarLayout(
                        sidebarPanel(
                          selectInput("muni_centro", "Filtrar por municipio:",
                                      choices = c("Todos", sort(unique(centros$municipio_nombre))), selected = "Todos")
                        ),
                        mainPanel(leafletOutput("mapa_centros", height = 600),
                                  p("Este mapa muestra todos los Centros de Salud de la provincia de Valencia, con la opción de clasificarlos por municipio."))
                      )
             ),
             tabPanel("⚠️ Riesgo por nivel (Centros de salud)",
                      fluidRow(
                        column(4,
                               h4("Selecciona el nivel de riesgo:"),
                               radioButtons("nivel_riesgo_c", "Nivel de riesgo:",
                                            choices = list("Riesgo T = 10" = "c10", 
                                                           "Riesgo T = 100" = "c100", 
                                                           "Riesgo T = 500" = "c500"),
                                            selected = "c10")
                        ),
                        column(8,
                               leafletOutput("mapa_riesgo_c", height = 400),
                               p("Este mapa muestra los Centros de Salud con riesgo de inundación de la provincia de Valencia según el periodo de retorno (T)")
                        )
                      )
             ),
             tabPanel("📊 Gráficos",
                      fluidRow(
                        column(6, plotOutput("grafico_centros_muni")),
                        column(6, plotOutput("grafico_centros_riesgo"))
                      )
             ),
             tabPanel("📋 Tabla",
                      fluidPage(
                        downloadButton("descarga_centros_salud", "Descargar CSV"),
                        DTOutput("tabla_centros")
                      )
             ),
             tabPanel("Recomendaciones",
                      sidebarLayout(
                        sidebarPanel(
                          radioButtons(
                            inputId = "riesgo_salud",
                            label = "Selecciona el periodo de retorno:",
                            choices = c("T = 10" = "10", "T = 100" = "100", "T = 500" = "500"),
                            selected = "10",
                            inline = TRUE
                          )
                        ),
                        mainPanel(
                          conditionalPanel(
                            condition = "input.riesgo_salud == '10'",
                            HTML("
          <h3>🏥 Centros de Salud</h3>
          <h4>Riesgo T = 10:</h4>
          <ul>
            <li>Cierre preventivo ante avisos rojos y traslado temporal de servicios urgentes.</li>
            <li>Simulacros semestrales para todo el personal.</li>
            <li>Control de accesos, zonas de espera y farmacias en planta baja.</li>
            <li>Coordinación directa con ayuntamientos y centros hospitalarios cercanos.</li>
            <li>Señalización clara de salidas de emergencia y rutas alternativas.</li>
          </ul>
        ")
                          ),
                          conditionalPanel(
                            condition = "input.riesgo_salud == '100'",
                            HTML("
          <h3>🏥 Centros de Salud</h3>
          <h4>Riesgo T = 100:</h4>
          <ul>
            <li>Simulacros anuales con implicación de pacientes y personal.</li>
            <li>Actualización de protocolos de actuación y derivación a otros centros.</li>
            <li>Formación básica sobre actuación ante inundación.</li>
            <li>Verificación de funcionamiento de sistemas críticos (electricidad, red).</li>
            <li>Mantenimiento preventivo del entorno (desagües, techos, accesos).</li>
          </ul>
        ")
                          ),
                          conditionalPanel(
                            condition = "input.riesgo_salud == '500'",
                            HTML("
          <h3>🏥 Centros de Salud</h3>
          <h4>Riesgo T = 500:</h4>
          <ul>
            <li>Inclusión del escenario de inundación en el plan de centro a largo plazo.</li>
            <li>Revisión documental y estructural cada dos años.</li>
            <li>Coordinación pasiva con redes sanitarias comarcales.</li>
            <li>Charlas informativas a usuarios en campañas de invierno y lluvias.</li>
            <li>Evaluación de mejoras arquitectónicas con enfoque preventivo.</li>
          </ul>
        ")
                          )
                        )
                      )
             )
  ),
  tabPanel("📌 Fuentes y créditos",
           fluidPage(
             h4("🔗 Fuentes de los datos y herramientas utilizadas"),
             tags$ul(
               tags$li("🌐 Instituto Cartográfico Valenciano: ", tags$a(href="https://icv.gva.es", "https://icv.gva.es")),
               tags$li("💧 Confederación Hidrográfica del Júcar: ", tags$a(href="https://www.chj.es", "https://www.chj.es")),
               tags$li("♻️ Ministerio para la Transición Ecológica: ", tags$a(href="https://www.miteco.gob.es", "https://www.miteco.gob.es")),
               tags$li(" Hospitales Comunidad Valenciana: ", tags$a(href="https://dadesobertes.gva.es/es/dataset/sanidad-sip-hospitales", "https://dadesobertes.gva.es/es/dataset/sanidad-sip-hospitales")),
               tags$li(" Centros de Salud Comunidad Valenciana: ", tags$a(href="https://dadesobertes.gva.es/es/dataset/sanidad-sip-centros-salud", "https://dadesobertes.gva.es/es/dataset/sanidad-sip-centros-salud")),
               tags$li(" Códigos Postales: ", tags$a(href="https://github.com/walterleonardo/codigos_postales_espa-a/blob/main/codigos_postales.json", "https://github.com/walterleonardo/codigos_postales_espa-a/blob/main/codigos_postales.json")),
               tags$li("🧭 Procesado SIG: QGIS"),
               tags$li("📊 Visualización: R, Shiny, Leaflet, ggplot2, plotly")
             ),
             br(),
             p("Aplicación desarrollada por Alberto Dalmau, Hugo Frasquet, Pablo Pons, Rubén Sierra, Maksym Myronenko para el miniproyecto de Visualización de Datos (Universitat de València).",
               style = "font-style: italic; text-align: center;")
           )
  )
)

# ---- Server ----
server <- function(input, output, session) {
  general_filtrados <- reactive({
    if (input$muni_general == "Todos") return(centros_general)
    centros_general %>% filter(Localidad == input$muni_general)
  })
  output$mapa_todos_general <- renderLeaflet({
    leaflet(general_filtrados()) %>%
      addProviderTiles("CartoDB.Positron") %>%
      addCircleMarkers(radius = 5, color = "blue", stroke = TRUE, fillOpacity = 0.8,
                       label = ~Denominacion)
  })
  colegios_filtrados <- reactive({
    if (input$muni_col == "Todos") return(colegios)
    colegios %>% filter(Localidad == input$muni_col)
  })
  
  output$mapa_colegios <- renderLeaflet({
    leaflet(colegios_filtrados()) %>%
      addProviderTiles("CartoDB.Positron") %>%
      addCircleMarkers(radius = 5, color = "blue", stroke = TRUE, fillOpacity = 0.8,
                       label = ~Denominacion_Generica_ES)
  })
  
  output$mapa_riesgo <- renderLeaflet({
    # Inicializa un mapa vacío o base
    leaflet() %>%
      addProviderTiles("CartoDB.Positron")
  })
  
  # Mapa para riesgo 10 años
  observeEvent(input$nivel_riesgo, {
    if (input$nivel_riesgo == "c10") {
      output$mapa_riesgo <- renderLeaflet({
        leaflet(colegios_riesgo_10) %>%
          addProviderTiles("CartoDB.Positron") %>%
          addCircleMarkers(radius = 5, color = "orange", label = ~Denominacion_Generica_ES)
      })
    } else if (input$nivel_riesgo == "c100") {
      output$mapa_riesgo <- renderLeaflet({
        leaflet(colegios_riesgo_100) %>%
          addProviderTiles("CartoDB.Positron") %>%
          addCircleMarkers(radius = 5, color = "red", label = ~Denominacion_Generica_ES)
      })
    } else if (input$nivel_riesgo == "c500") {
      output$mapa_riesgo <- renderLeaflet({
        leaflet(colegios_riesgo_500) %>%
          addProviderTiles("CartoDB.Positron") %>%
          addCircleMarkers(radius = 5, color = "purple", label = ~Denominacion_Generica_ES)
      })
    }
  })
  
  
  output$grafico_cole_muni <- renderPlot({
    colegios %>%
      st_drop_geometry() %>%
      count(Localidad, name = "n") %>%
      top_n(10) %>%
      ggplot(aes(x = reorder(Localidad, n), y = n)) +
      geom_col(fill = "#3498db") + coord_flip() +
      labs(x = "Municipio", y = "Colegios", title = "Top municipios con más colegios") +
      theme_riesgo
  })
  
  output$grafico_cole_riesgo <- renderPlot({
    data.frame(
      Riesgo = c("10 años", "100 años", "500 años"),
      Total = c(nrow(colegios_riesgo_10), nrow(colegios_riesgo_100), nrow(colegios_riesgo_500))
    ) %>%
      ggplot(aes(x = Riesgo, y = Total, fill = Riesgo)) +
      geom_bar(stat = "identity") +
      scale_fill_manual(values = c("10 años" = "orange", "100 años" = "red", "500 años" = "purple")) +
      labs(y = "Colegios", title = "Colegios por nivel de riesgo") +
      theme_riesgo
  })
  # Para actualizar los ríos disponibles según el escenario
  output$selector_rio <- renderUI({
    rios_disponibles <- switch(input$escenario_riesgo,
                               "10" = unique(todos_riesgos_10$RIO),
                               "100" = unique(todos_riesgos_100$RIO),
                               "500" = unique(todos_riesgos_500$RIO))
    
    selectInput("rio_seleccionado", "Selecciona un río o barranco:",
                choices = rios_disponibles,
                selected = rios_disponibles[1])
  })

# Observador principal del mapa
  observe({
    req(input$escenario_riesgo, input$rio_seleccionado)
  
    datos_filtrados <- switch(input$escenario_riesgo,
                              "10" = todos_riesgos_10 %>% filter(RIO == input$rio_seleccionado),
                              "100" = todos_riesgos_100 %>% filter(RIO == input$rio_seleccionado),
                              "500" = todos_riesgos_500 %>% filter(RIO == input$rio_seleccionado))
  
    output$mapa_rio_dinamico <- renderLeaflet({
      leaflet() %>%
        addTiles() %>%
        addCircleMarkers(data = datos_filtrados,
                         color = "blue",
                         radius = 5,
                         stroke = FALSE,
                         fillOpacity = 0.7,
                         label = ~Denominacion)
    })
  })

  output$tabla_colegios <- DT::renderDataTable({
    colegios_filtrados() %>%
      st_drop_geometry() %>%
      select(Codigo, Denominacion_Generica_ES, Localidad, Titularidad, Comarca)
  })
  
  output$descarga_colegios <- downloadHandler(
    filename = function() {"colegios_filtrados.csv"},
    content = function(file) {
      write.csv(colegios_filtrados() %>% st_drop_geometry(), file, row.names = FALSE)
    }
  )
  
  
  hospitales_filtrados <- reactive({
    if (input$muni_hosp == "Todos") return(hospitales)
    hospitales[hospitales$municipio_nombre == input$muni_hosp, ]
  })
  
  output$mapa_hospitales <- renderLeaflet({
    leaflet(hospitales_filtrados()) %>%
      addProviderTiles("CartoDB.Positron") %>%
      addCircleMarkers(radius = 5, color = "blue", fillOpacity = 0.7,
                       label = ~CEN_DESCLA)
  })
  
  
  # Render inicial vacío (opcional, útil para asegurar carga base)
  output$mapa_riesgo_h <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("CartoDB.Positron")
  })
  
  # Observador para cambios en selección de nivel de riesgo
  observeEvent(input$nivel_riesgo_h, {
    if (input$nivel_riesgo_h == "h10") {
      output$mapa_riesgo_h <- renderLeaflet({
        leaflet() %>%
          addTiles() %>%
          addPolygons(data = zonas_10,
                      color = "red",
                      weight = 1,
                      fillOpacity = 0.7,
                      label = "Zona de riesgo 10 años") %>%
          addCircleMarkers(data = hospitales,
                           color = "blue",
                           radius = 5,
                           stroke = FALSE,
                           fillOpacity = 0.7,
                           label = ~CEN_DESCLA)
      })
    } else if (input$nivel_riesgo_h == "h100") {
      output$mapa_riesgo_h <- renderLeaflet({
        leaflet() %>%
          addTiles() %>%
          addPolygons(data = zonas_100,
                      color = "red",
                      weight = 1,
                      fillOpacity = 0.7,
                      label = "Zona de riesgo 100 años") %>%
          addCircleMarkers(data = hospitales,
                           color = "blue",
                           radius = 5,
                           stroke = FALSE,
                           fillOpacity = 0.7,
                           label = ~CEN_DESCLA)
      })
    } else if (input$nivel_riesgo_h == "h500") {
      output$mapa_riesgo_h <- renderLeaflet({
        leaflet() %>%
          addTiles() %>%
          addPolygons(data = zonas_500,
                      color = "red",
                      weight = 1,
                      fillOpacity = 0.7,
                      label = "Zona de riesgo 500 años") %>%
          addCircleMarkers(data = hospitales,
                           color = "blue",
                           radius = 5,
                           stroke = FALSE,
                           fillOpacity = 0.7,
                           label = ~CEN_DESCLA)
      })
    }
  })
  
  
  output$grafico_hosp_muni <- renderPlot({
    hospitales %>%
      st_drop_geometry() %>%
      count(municipio_nombre, name = "n") %>%
      top_n(10) %>%
      ggplot(aes(x = reorder(municipio_nombre, n), y = n)) +
      geom_col(fill = "#27ae60") + coord_flip() +
      labs(x = "Municipio", y = "Hospitales", title = "Top municipios con más hospitales") +
      theme_riesgo
  })
  
  output$grafico_hosp_riesgo <- renderPlot({
    tryCatch({
      total_10 <- if (!is.null(hospitales_riesgo_10) && inherits(hospitales_riesgo_10, "sf")) nrow(hospitales_riesgo_10) else 0
      total_100 <- if (!is.null(hospitales_riesgo_100) && inherits(hospitales_riesgo_100, "sf")) nrow(hospitales_riesgo_100) else 0
      total_500 <- if (!is.null(hospitales_riesgo_500) && inherits(hospitales_riesgo_500, "sf")) nrow(hospitales_riesgo_500) else 0
      
      df <- data.frame(
        Riesgo = c("10 años", "100 años", "500 años"),
        Total = c(total_10, total_100, total_500)
      )
      
      ggplot(df, aes(x = Riesgo, y = Total, fill = Riesgo)) +
        geom_bar(stat = "identity") +
        scale_fill_manual(values = c("10 años" = "orange", "100 años" = "red", "500 años" = "purple")) +
        labs(y = "Hospitales", title = "Hospitales por nivel de riesgo") +
        theme_riesgo
    }, error = function(e) {
      plot.new()
      text(0.5, 0.5, "No hay datos válidos para mostrar el gráfico", cex = 1.2)
    })
  })
  
  output$tabla_hospitales <- DT::renderDataTable({
    hospitales_filtrados() %>%
      st_drop_geometry() %>%
      select(any_of(c("CEN_DESCLA", "CEN_CODPOS", "municipio_nombre")))
  })
  
  output$descarga_hospitales <- downloadHandler(
    filename = function() {"hospitales_filtrados.csv"},
    content = function(file) {
      write.csv(hospitales_filtrados() %>% st_drop_geometry(), file, row.names = FALSE)
    }
  )
  
  centros_filtrados <- reactive({
    if (input$muni_centro == "Todos") return(centros)
    centros[centros$municipio_nombre == input$muni_centro, ]
  })
  output$mapa_centros <- renderLeaflet({
    leaflet(centros_filtrados()) %>%
      addProviderTiles("CartoDB.Positron") %>%
      addCircleMarkers(radius = 5, color = "blue", fillOpacity = 0.7,
                       label = ~CEN_DESCLA)
  })
  output$mapa_riesgo_c <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("CartoDB.Positron")
  })
  
  observeEvent(input$nivel_riesgo_c, {
    if (input$nivel_riesgo_c == "c10") {
      output$mapa_riesgo_c <- renderLeaflet({
        leaflet() %>%
          addTiles() %>%
          addPolygons(data = zonas_10_salud,
                      color = "red",
                      weight = 1,
                      fillOpacity = 0.7,
                      label = "Zona de riesgo 10 años") %>%
          addCircleMarkers(data = centros,
                           color = "blue",
                           radius = 5,
                           stroke = FALSE,
                           fillOpacity = 0.7,
                           label = ~CEN_DESCLA)
      })
    } else if (input$nivel_riesgo_c == "c100") {
      output$mapa_riesgo_c <- renderLeaflet({
        leaflet(riesgo_100_salud) %>%
          addTiles() %>%
          addCircleMarkers(color = "orange", radius = 5, label = ~CEN_DESCLA)
      })
    } else if (input$nivel_riesgo_c == "c500") {
      output$mapa_riesgo_c <- renderLeaflet({
        leaflet(riesgo_500_salud) %>%
          addTiles() %>%
          addCircleMarkers(color = "purple", radius = 5, label = ~CEN_DESCLA)
      })
    }
  })
  # Gráfico por municipio
  output$grafico_centros_muni <- renderPlot({
    centros %>%
      st_drop_geometry() %>%
      count(municipio_nombre, sort = TRUE) %>%
      head(15) %>%
      ggplot(aes(x = reorder(municipio_nombre, n), y = n)) +
      geom_col(fill = "#1f77b4") +
      geom_text(aes(label = n), hjust = -0.1, size = 4) +
      coord_flip() +
      labs(
        x = "Municipio",
        y = "Número de centros",
        title = "Centros de salud por municipio"
      ) +
      theme_minimal(base_size = 13) +
      theme(
        plot.title = element_text(face = "bold"),
        axis.title.y = element_text(margin = margin(r = 10))
      )
  })
  
  
  # Gráfico de centros en riesgo
  output$grafico_centros_riesgo <- renderPlot({
    data.frame(
      Periodo = c("10 años", "100 años", "500 años"),
      Total = c(nrow(riesgo_10_salud), nrow(riesgo_100_salud), nrow(riesgo_500_salud))
    ) %>%
      ggplot(aes(x = Periodo, y = Total, fill = Periodo)) +
      geom_col(width = 0.6) +
      geom_text(aes(label = Total), vjust = -0.5, size = 5) +
      scale_fill_manual(values = c("10 años" = "#e74c3c", "100 años" = "#f39c12", "500 años" = "#9b59b6")) +
      labs(
        title = "Centros de salud en riesgo por periodo de retorno",
        x = "Periodo de retorno",
        y = "Número de centros"
      ) +
      theme_minimal(base_size = 13) +
      theme(
        legend.position = "none",
        plot.title = element_text(face = "bold")
      )
  })
  
  
  # Tabla y descarga
  output$tabla_centros <- DT::renderDataTable({
    centros %>%
      st_drop_geometry() %>%
      select(CEN_DESCLA, CEN_CODPOS, municipio_nombre)
  })
  
  output$descargar <- downloadHandler(
    filename = function() { "centros_salud.csv" },
    content = function(file) {
      write.csv(st_drop_geometry(centros), file, row.names = FALSE)
    }
  )
  
}

shinyApp(ui, server)

