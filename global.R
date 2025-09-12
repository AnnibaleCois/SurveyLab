################################################################################################################################################################################
# SurveyLab - A virtual environment for learning survey methods                                                                                                                #
# Version 4                                                                                                                                                                    #
# Author: Annibale Cois (AnnibaleCois@gmail.com)                                                                                                                               #
# Created: 04/2025                                                                                                                                                             #  
#                                                                                                                                                                              # 
# Global                                                                                                                                                                       #
#                                                                                                                                                                              #  
################################################################################################################################################################################

library(shiny)
library(shinyBS)
library(shinycssloaders)
library(shinydashboard)
library(shinydashboardPlus)
library(shinyjs)
library(shinyWidgets)
library(shinybusy)
library(shinyauthr)
library(rintrojs)
library(shinyalert)

library(tidyverse)
library(plyr)
library(rhandsontable)
library(lubridate)
library(stringr)
library(glue)
library(writexl)

library(fst)
library(httr2)
library(jsonlite)
library(DBI)
library(RSQLite)

library(EnvStats)
library(STAND)
library(TSP)
library(sampling)
library(digest)
library(presize)
library(survey)
options(survey.lonely.psu = "adjust")

library(ggplot2)
library(igraph)

################################################################################################################################################################################
# LOAD CODE                                                                                                                                                                    # 
################################################################################################################################################################################

source("connections.R")     # DATABASE CONNECTIONS MANAGEMENT

################################################################################################################################################################################
# UTILITY FUNCTIONS                                                                                                                                                            # 
################################################################################################################################################################################

# OVERRIDE FUNCTION shinibusy::busy_start_up

splashscreen <- function (loader, text = NULL, mode = c("timeout", "auto", "manual"),timeout = 500, color = "#112446", background = "#f0f0f0", image) 
{
  if (!inherits(loader, "shiny.tag")) 
    stop("loader must be an HTML tag object!")
  mode <- match.arg(mode)
  loader <- tagAppendAttributes(loader, style = "margin: auto;")
  tagList(html_dependency_startup(), 
            tags$div(class = "shinybusy-startup", style = paste0("background-color:", background, "; background-image: url(",image,"); background-size:cover;"), 
            tags$div(class = "shinybusy-startup-content", style = paste0("color:", color, ";"), loader, tags$br(), text)
          ), 
          tags$script(type = "application/json",`data-for` = "shinybusy-start-up", toJSON(list(mode = mode, timeout = timeout), auto_unbox = TRUE, json_verbatim = TRUE)))
}
environment(splashscreen) <- environment(busy_start_up)

# CALCULATE NUMBER OF DECIMAL DIGITS FOR PRESENTING PRECISION IN POWER CALCULATION

ndigits <- function(n) { 
  if (floor(n) >= 10) {
    return(0)
  } else if (floor(n) >= 1) {
    return(1)
  } else {
    x <- format(n, scientific = FALSE)
    nzeros <- attr(regexpr("(?<=\\.)0+", x, perl = TRUE), "match.length")
    nzeros <- ifelse(nzeros >= 0, nzeros, 0)
    return(nzeros + 2)
  }
} 

# CALCULATE SEED FOR RANDOM NUMBER GENERATOR

randomseed <- function(regen, seed) {
  if (regen == "FIXED"){
    actualseed <- seed
  } else if (regen == "USER") {
    actualseed <- credentials()$info[10]
  } else {
    actualseed <- round(runif(1,1,1000),0) 
  }
  return(actualseed)
}

# UTILITY FUNCTIONS

loadRData <- function(fileName) { # loads an RData file, and returns it
  load(fileName)
  get(ls()[ls() != "fileName"])
}



################################################################################################################################################################################
# SETTINGS                                                                                                                                                                     # 
################################################################################################################################################################################

# AUTHENTICATION 
# AUTHTYPE: "dbase" = USES SQL lite DATABASE HOSTED ON SERVER (file: "users/user_data.sqlite"); 
#           "cloud" = USES SQL lite DATABASE HOSTED ON CLOUD (URL and TOKEN as environment variables TURSO_DB_URL, TURSO_AUTH_TOKEN); 
#            "test" = USES user_data.RData DATABASE STORED INTERNALLY (ONLY for testing, don not support concurrent access)

AUTHENTICATE <- TRUE 
AUTHTYPE <- "cloud"                    

# APPEARANCE, GRAPHICS, PLOTS 

SPINNER <- 0          # SPINNER TYPE
TIMEOUT <- 3600000    # TIMEOUT FOR SPLASH SCREEN (MILLISECONDS)

# VERSION NUMBER 

RELEASE_VE <- "4"   # VERSION
RELEASE_NO <- "1"   # NUMBER
RELEASE_DATE <- "September 2025"

# DATA VERSION 

DATAVERSION <- "v1_1"

# RANDOM NUMBER GENERATOR BASE SEED

SEED <- 196312  # SEED 

# DEFAULT PARAMETERS FROM EXTERNAL FILE 

SETTINGS <- read.csv("data/settings.csv")

for (i in c(1: length(SETTINGS$parameter))) {
  par <- trimws(SETTINGS$parameter[i])
  value <- SETTINGS$value[i]
  type <- SETTINGS$type[i]
  if (type == "numeric") {
    assign(par, as.numeric(value))
  } else if (type == "string") {
    assign(par, value)
  } else if (type == "vector") {
    assign(par, as.numeric(unlist(strsplit(value,",", fixed = TRUE))))
  } else if ((type == "matrix")) {
    ROWS <- unlist(strsplit(value, ";", fixed = TRUE))
    NROW <- length(ROWS)
    DATA <- as.numeric(unlist(strsplit(paste(ROWS, collapse = ","),",",fixed = TRUE))) 
    NCOL <- length(DATA)/NROW
    assign(par,matrix(DATA, nrow = NROW, ncol = NCOL, byrow = TRUE))
  }
}
IRR_DEFAULT[1,] <- round(IRR_DEFAULT[1,] / 1.04,3)
IRR_DEFAULT[2,] <- round(IRR_DEFAULT[2,] * 1.04,3)

# ENABLE/DISABLE SERVER UPLOAD

ENABLEUPLOAD <- 0 # ) = DISABLED, 1 = ENABLED

################################################################################################################################################################################
# INTIALIZE                                                                                                                                                                    #
################################################################################################################################################################################

# SET CHOSEN SPINNER  
  
SPINNER <- ifelse(SPINNER == 0, floor(runif(1,1.5,8.5)), SPINNER)
if (SPINNER == 2) SPINNER == 1
if (SPINNER == 3) SPINNER == 4

# LOAD DEFAULT PARAMETERS 

SETUP1 <- SETUP1_DEFAULT
SETUP2 <- SETUP2_DEFAULT
SETUP3 <- SETUP3_DEFAULT
QCOST <- QCOST_DEFAULT
HRR <- HRR_DEFAULT
IRR <- IRR_DEFAULT
TRR <- TRR_DEFAULT
RRR <- RRR_DEFAULT 
FATIG <- FATIG_DEFAULT
TQ <- TQ_DEFAULT
TM <- TM_DEFAULT
ITEMTIME <- ITEMTIME_DEFAULT
QQPROGRESS <- QQPROGRESS_DEFAULT
QMPROGRESS <- QMPROGRESS_DEFAULT
QMSCALE <- QMSCALE_DEFAULT
ALPHA <- ALPHA_DEFAULT
RGEN <- RGEN_DEFAULT
NPART <- NPART_DEFAULT

# LOAD WORLD MAP

file.copy(paste0("data/",DATAVERSION,"/world.svg"), "www/maps/world.svg", overwrite = TRUE)

# LOAD STATIC DATA

if (TRUE) { # if TRUE uses compressed files
  S <- read_fst(paste0("data/",DATAVERSION,"/locations.fst"))       # Geolocation of households (for cost calculations, compressed)
  P <- read_fst(paste0("data/",DATAVERSION,"/population.fst"))      # Population data (compressed)
} else {
  
  load(paste0("data/",DATAVERSION,"/locations.RData"))       # Geolocation of households (for cost calculations)
  load(paste0("data/",DATAVERSION,"/population.RData"))      # Population data
}  
  
load(paste0("data/",DATAVERSION,"/environment.RData"))     # Environment statistics
load(paste0("data/",DATAVERSION,"/healthsystem.RData"))    # Health facilities statistics
load(paste0("data/",DATAVERSION,"/items.RData"))           # Items for data collection tool

# SUBSET POPULATION DATA 

P <- P[,unique(c("IID","TOWN","Town_Code","REGION","SUBURB","HID","MEMBER","GLOBAL_WINDEX","WEALTH","SEX","AGE","AGECAT","AGECAT1","POPGROUP",Q$VARIABLE))]

# ADD WEALTH TERTILE

P$WEALTHT <- as.numeric(cut(P$WEALTH, breaks = quantile(P$WEALTH, probs = seq(0,1,length.out=4), na.rm = TRUE)))

# CATEGORISE VARIABLE BY SCALE OF MEASUREMENT 

X <- sapply(P, class)
CATEGORICAL <- subset(names(X), X == "factor" | X == "character")
CONTINUOUS <- subset(names(X), X=="numeric")

# MAXCOST
# Calculate maximum total distance to visit all households (to rescale costs uniformly)

MAXCOST <- 0
for (t in unique(S$TOWNNAME)) {
  si <- subset(S, TOWNNAME == t)[, c("XC", "YC")]
  ES <- ETSP(si)
  tour <- solve_TSP(ES)
  MAXCOST <- MAXCOST + attr(tour, which = "tour_length")
}

# TOWN NAMES & BACKGROUND COLORS

REGIONCOLORS <- c("#F1CEC0","#C9D4E8","#D2EABB","#E9CCE5","#BCE1D9")
REGIONCOLORS_ACCENT <- c("#E8471B","#3058E3","#7EE720","#E21FBe","#45DEAF")

TNAMES <- E[,c("Town_Code","Town_Name","Region_Code","Region_Name")]
TNAMES <- subset(TNAMES, Town_Code != 0)
TNAMES <- TNAMES[!duplicated(TNAMES),]
TNAMES <- TNAMES[order(TNAMES$Town_Name),]

TCOLORS <- rep("",nrow(TNAMES))
for (i in c(1:nrow(TNAMES))) {
  TCOLORS[TNAMES[i,]$Town_Code] <- REGIONCOLORS[TNAMES[i,]$Region_Code]
}  

# PREPARE CODE FOR TOWN NAMES SELECTOR BUTTON 

TOWNSELECT_SAMPLE <- "let bbar = document.getElementById('DROPDOWN_SAMPLE');"
for (j in c(1:nrow(TNAMES))) {
  if (TNAMES[j,'Town_Name'] != "All") {
    TOWNSELECT_SAMPLE <- paste0(TOWNSELECT_SAMPLE, "const Button",j,"= document.createElement('button');Button", j, ".textContent = '", TNAMES[j,'Town_Name'],"';Button",j,
                      ".onclick = function(container,town){replaceSvg(container = 'panzoom-element_sample', town = ",TNAMES[j,'Town_Code'],");};Button",j,
                      ".style = 'margin-right: 5px; margin-top: 5px; width: 125px; border: none; color: black; background-color:",
                      REGIONCOLORS[TNAMES[j,]$Region_Code], "!important';bbar.appendChild(Button",j,");")
  }
}

TOWNSELECT_EXPLORE <- "let bbar1 = document.getElementById('DROPDOWN_EXPLORE');"
for (j in c(1:nrow(TNAMES))) {
  if (TNAMES[j,'Town_Name'] != "All") {
    k <- j+200
    TOWNSELECT_EXPLORE <- paste0(TOWNSELECT_EXPLORE, "const Button",k,"= document.createElement('button');Button", k, ".textContent = '", TNAMES[j,'Town_Name'],"';Button",k,
                            ".onclick = function(container,town){replaceSvg(container = 'panzoom-element_world', town = ",TNAMES[j,'Town_Code'],");};Button",k,
                            ".style = 'margin-right: 5px; margin-top: 5px; width: 125px; border: none; color: black; background-color:", 
                            REGIONCOLORS[TNAMES[j,]$Region_Code], "!important';bbar1.appendChild(Button",k,");")
  }
}

# INITIALIZE AN IN-MEMORY SQLITE DATABASE FOR TABLE SHARING (AND MANAGE THE CLOSURE OF THE DATABASE WHEN THE APP CLOSES)

SHAREDTABLEDB <- dbConnect(RSQLite::SQLite(), "file:memory")
structure <- data.frame(
  N = numeric(), User = character(), Estimate = numeric(), lb = numeric(), ub = numeric(), Notes = character(),
  stringsAsFactors = FALSE
)
if (dbExistsTable(SHAREDTABLEDB, "shared_data_table")) {
  dbRemoveTable(SHAREDTABLEDB, "shared_data_table")
}
dbWriteTable(SHAREDTABLEDB, "shared_data_table", structure)

onStop(function() {
  dbDisconnect(SHAREDTABLEDB)
})

# INITIALISE GLOBAL VARIABLE TO TRACK ACTIVE USERS

active_users <- reactiveVal(0)
