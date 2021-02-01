# load libraries
library(shiny)
library(leaflet)
library(dplyr)
library(leaflet.extras)
library(ggplot2)
library(plyr)
library(markdown)
library(DT)

### IMPORT
# Lade finalen Datensatz
path_skript <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(path_skript)

load("Finaler_Datensatz_12.RData") # interner Name "komp_flows_geo"

### GUI
# erstelle GUI-Fenster
ui <- fluidPage(
  navbarPage(
    "Shiny Visualisierung - Gruppe 12",
    # erster Reiter mit Karte
    tabPanel(
      "Karte",
      leafletOutput("mymap", width = 1920, height = 820),
      absolutePanel(
        id = "controls", class = "panel panel-default",
        fixed = TRUE,
        draggable = FALSE,
        top = 40, left = "auto",
        right = 20,
        bottom = 20,
        width = 380,
        height = 500,
        wellPanel(
          HTML(markdownToHTML(
            fragment.only = TRUE,
            text = c("<h1>Liefervolumen der Werke</h1>")
          )),
          radioButtons("OEM_Werke",
            "OEM Auswahl",
            width = "200px",
            inline = TRUE,
            choiceValues = c(11, 12, 21, 22),
            choiceNames = c("11", "12", "21", "22")
          ),
          plotOutput("plot_oem", height = "400px")
        )
      )
    ),
    # zweiter Reiter mit dem zugrundeliegenden Datensatz
    tabPanel(
      "Daten",
      DT::dataTableOutput("df_table")
    )
  )
)

# weise map statische Eigenschaften zu
map <- leaflet() %>%
  addProviderTiles("Stamen.TonerLite") %>%
  setView(25, 52, zoom = 5.5)


### FUNKTIONEN
# Funktion zur Entfernungsberechnung aus zwei Punkten mittels Geo-Koordinaten
calc_distance <- function(lat_1, lon_1, lat_2, lon_2) {
  deg_to_rad <- function(degrees) {
    return(degrees*3.1416/180)
  }
  earth_radius <- 6371
  d_lat <- deg_to_rad(lat_2 - lat_1)
  d_lon <- deg_to_rad(lon_2 - lon_1)
  lat_1_rad <- deg_to_rad(lat_1)
  lat_2_rad <- deg_to_rad(lat_2)

  a <- sin(d_lat/2) * sin(d_lat/2) + sin(d_lon/2) * sin(d_lon/2) * cos(lat_1_rad) * cos(lat_2_rad)
  c <- 2 * atan2(sqrt(a), sqrt(1 - a))
  return(round(earth_radius * c, digits = 0))
}

# Funktion die die Farbwerte in einer Skala berechnet und einzelnen Farbwert ausgibt
get_col_scale_value <- function(OEM,
                             n,
                             col_1 = "yellow",
                             col_2 = "red",
                             num_elem = 10) {
  df_temp <- subset(komp_flows_geo, Werk_O == OEM)
  n_max <- max(df_temp$n)
  n_min <- min(df_temp$n)
  col_func <- colorRampPalette(c(col_1, col_2))
  col_vec <- col_func(num_elem)
  x <- round(((n - n_min) / (n_max - n_min)) * (num_elem - 1), digits = 0) + 1
  return(col_vec[x])
}
# Funktion die color-Vektor für Legende erstellt
get_col_vectors <- function(OEM,
                          col_1 = "yellow",
                          col_2 = "red",
                          num_elem = 10) {
  df_temp <- subset(komp_flows_geo, Werk_O == OEM)
  n_max <- max(df_temp$n)
  n_min <- min(df_temp$n)
  col_func <- colorRampPalette(c(col_1, col_2))
  col_vec <- col_func(num_elem)
  n_vec <- paste(
    ">",
    round_any(
      seq(n_min, n_max, by = (n_max - n_min) / (num_elem - 1)),
      1000,
      floor
    )
  )
  return(data.frame(col_vec, n_vec))
}


# Funktion, die einen Dataframe mit den Koordinaten der Linien und den Volumenstroemen
# des gewaehlten OEMs erstellt
get_coord_lines <- function(OEM) {
  df_temp <- subset(komp_flows_geo, Werk_O == OEM)
  lng <- c()
  lat <- c()
  n <- c()
  colors <- c()
  for (i in 1:nrow(df_temp)) {
    lng <- c(lng, df_temp$Laengengrad_K[[i]], df_temp$Laengengrad_O[[i]])
    lat <- c(lat, df_temp$Breitengrad_K[[i]], df_temp$Breitengrad_O[[i]])
    n <- c(n, df_temp$n[[i]], df_temp$n[[i]])
    colors <- c(
      colors,
      get_col_scale_value(OEM, df_temp$n[[i]]),
      get_col_scale_value(OEM, df_temp$n[[i]])
    )
  }
  return(data.frame(lng, lat, n, colors))
}

# Funktion, die einen Dataframe mit den Koordinaten der Marker und dem Namen des Herstellers,
# Namen des Werkes, der Gesamtzahl der gelieferten Komponenten und der Entfernung
# des gewÃ¤hlten OEMs erstellt
get_coord_markers <- function(OEM) {
  df_temp <- subset(komp_flows_geo, Werk_O == OEM)
  # Koordinaten des OEMs als ersten Vektoreintrag
  lng <- c(df_temp$Laengengrad_O[[1]])
  lat <- c(df_temp$Breitengrad_O[[1]])
  werk_k <- c("OEM")
  hersteller_k <- c("OEM")
  n <- c(0)
  ort_k <- c(df_temp$ORT_O[[1]])
  entfernung <- c(0)
  for (i in 1:nrow(df_temp)) {
    lng <- c(lng, df_temp$Laengengrad_K[[i]])
    lat <- c(lat, df_temp$Breitengrad_K[[i]])
    werk_k <- c(werk_k, df_temp$Werk_K[[i]])
    hersteller_k <- c(hersteller_k, df_temp$Hersteller_K[[i]])
    n <- c(n, df_temp$n[[i]])
    entfernung <- c(
      entfernung,
      calc_distance(
        df_temp$Breitengrad_K[[i]],
        df_temp$Laengengrad_K[[i]],
        lat[[1]],
        lng[[1]]
      )
    )
    ort_k <- c(ort_k, df_temp$ORT_K[[i]])
  }
  return(data.frame(
    lng,
    lat,
    werk_k,
    hersteller_k,
    n,
    entfernung, 
    ort_k
  ))
}

### SERVER-Funktion
# rendert die Karte mit den GUI-Elementen
# weißt GUI-Elementen Reaktionen zu

server <- function(input,
                   output,
                   session) {
  icons <- iconList(
    icon_oem = makeIcon("./Zusaetzliche Dateien/icon_OEM.png",
      iconHeight = 30,
      iconWidth = 30),
    icon_k = makeIcon("./Zusaetzliche Dateien/icon_K.png",
      iconHeight = 24,
      iconWidth = 24)
  )
  output$mymap <- renderLeaflet({
    map
  })

  # stelle Daten auf zweitem Reiter dar
  output$df_table <- DT::renderDataTable({
    DT::datatable(komp_flows_geo,
      style = "bootstrap")
  })

  # erstelle barplot
  output$plot_oem <- renderPlot({
    data_sub <- filter(
      komp_flows_geo,
      Werk_O == input$OEM_Werke)
    ggplot(
      data_sub,
      aes(factor(Werk_K), n)) +
      geom_col(color = "orange", fill = "orange") +
      labs(x = "Komponentenwerke", y = "Teilemengen") +
      scale_y_continuous(labels = scales::comma) +
      theme(
        axis.text = element_text(size = 12),
        axis.title = element_text(size = 14, face = "bold"),
        axis.text.x = element_text(angle = 45))
  })

  # reagiere auf Radiobuttonwahl
  observe({
    # proxy erlaubt nachtraegliche aenderung einer bereits gerenderten Karte
    proxy <- leafletProxy("mymap")
    for (i in c(11, 12, 21, 22)) {
      if (i == input$OEM_Werke) {
        # loesche alte Marker, Linien und Legende
        proxy %>%
          clearMarkers() %>%
          clearShapes() %>%
          clearControls()
        # fuege marker und Linien hinzu fuer OEM
        coord_lines <- get_coord_lines(OEM = i)
        coord_markers <- get_coord_markers(OEM = i)
        for (m in 1:nrow(coord_markers)) {
          if (m == 1) {
            icon_choice <- 1
          } # wenn m == 1 -> OEM, icon "Fabrik"
          else {
            icon_choice <- 2
          }
          # wenn m > 1 handelt es sich um Komponentenhersteller, icon "Zahnrad"
          proxy %>% addMarkers(
            data = coord_markers,
            lng = ~ lng[m],
            lat = ~ lat[m],
            icon = icons[[icon_choice]],
            layerId = paste(
              "marker",
              i,
              "_",
              m
            ),
            popup = paste(
              "Ort: ", coord_markers$ort_k[m], "<br>",
              "Hersteller: ", coord_markers$hersteller_k[m], "<br>",
              "Werk: ", coord_markers$werk_k[m], "<br>",
              "Volumen: ", coord_markers$n[m], "<br>",
              "Entfernung zum OEM: ", coord_markers$entfernung[m], "km"
            )
          )
        }
        for (m in seq(1, nrow(coord_lines), 2)) {
          proxy %>%
            addPolylines(
              data = coord_lines,
              lng = coord_lines$lng[m:(m + 1)],
              lat = coord_lines$lat[m:(m + 1)],
              layerId = paste("line", i, "_", m),
              color = coord_lines$colors[m],
              fill = TRUE,
              weight = 7.5
            )
        }
        # berechne Farbskala abhaengig vom OEM und fuege Legende hinzu
        col_df <- get_col_vectors(i)
        proxy %>%
          addLegend(
            data = col_df,
            title = "Teilemengen",
            labels = ~n_vec,
            colors = ~col_vec,
            position = "bottomleft"
          )
      }
    }
  })
}

# starte Shiny-App mit GUI "ui" und der server-Funktion
shinyApp(ui, server)
