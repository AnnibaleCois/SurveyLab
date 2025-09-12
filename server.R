################################################################################################################################################################################
# SurveyLab - A virtual environment for learning survey methods                                                                                                                #
# Version 4                                                                                                                                                                    #
# Author: Annibale Cois (AnnibaleCois@gmail.com)                                                                                                                               #
# Created: 04/2025                                                                                                                                                             #  
#                                                                                                                                                                              # 
# Server                                                                                                                                                                       #
#                                                                                                                                                                              #  
################################################################################################################################################################################

server <- function(input, output, session) {

  ##############################################################################################################################################################################
  # SPLASH SCREEN & INITIAL STATUS                                                                                                                                             #
  ##############################################################################################################################################################################
  
  observeEvent(input$start, {
    remove_start_up(timeout = 0, session = shiny::getDefaultReactiveDomain()) 
  })  
  
  addCssClass(id = "sidebar", class = "inactiveLink")
  addCssClass(selector = "a[data-value='interviews']", class = "inactiveItem")
  addCssClass(selector = "a[data-value='custitems']", class = "inactiveItem")
  addCssClass(selector = "a[data-value='settings']", class = "inactiveItem")
  addCssClass(selector = "a[data-value='users']", class = "inactiveItem")
  addCssClass(selector = "a[data-value='visualise']", class = "inactiveItem")
  addCssClass(selector = "a[data-value='logs']", class = "inactiveItem")
  
  addCssClass(selector = "a[data-value='power']", class = "inactiveItem")
  addCssClass(selector = "a[data-value='survey']", class = "inactiveItem")
  addCssClass(selector = "a[data-value='analysis']", class = "inactiveItem")
  
  runjs("document.getElementsByClassName('sidebar-toggle')[0].style.visibility = 'hidden';")
  addCssClass(id = "m_logo", class = "invisible")
  addCssClass(id = "m_credits", class = "invisible")

  ##############################################################################################################################################################################
  # AUTHENTICATION & CREDITS                                                                                                                                                   #
  ##############################################################################################################################################################################

  if (AUTHENTICATE) {
    credentials <- shinyauthr::loginServer(
      id = "login",
      data = load_userbase(AUTHTYPE),
      user_col = user,
      pwd_col = password_hash,
      sodium_hashed = TRUE,
      log_out = reactive(logout_init())
    )
    
  } else {
    credentials <- function(authenticate) {
      permissions <- "Limited"
      user <- ""
      A <- data.frame(user, permissions)
      LIST <- list(user_auth = TRUE, info = A)
    }
  }
  
  logout_init <- shinyauthr::logoutServer(id = "logout", active = reactive(credentials()$user_auth))
  
  observe({
    if (credentials()$user_auth) {
      removeCssClass(selector = "body", class = "sidebar-collapse")
      if (AUTHENTICATE) {
        removeCssClass(id = "account", class = "invisible")
        if (credentials()$info[3] == "admin") {
          #removeCssClass(selector = "a[data-value='interviews']", class = "inactiveItem")
          #removeCssClass(selector = "a[data-value='custitems']", class = "inactiveItem")
          removeCssClass(selector = "a[data-value='settings']", class = "inactiveItem")
          removeCssClass(selector = "a[data-value='users']", class = "inactiveItem")
          removeCssClass(selector = "a[data-value='visualise']", class = "inactiveItem")
          removeCssClass(selector = "a[data-value='logs']", class = "inactiveItem")
          updateNumericInput(inputId = "userbase_updated_trigger",value = rnorm(1))
        }  
      }
      removeCssClass(id = "m_logo", class = "invisible")
      removeCssClass(id = "m_credits", class = "invisible")
      removeCssClass(id = "sidebar", class = "inactiveLink")
      runjs("document.getElementsByClassName('sidebar-toggle')[0].style.visibility = 'visible';")
    } else {
      addCssClass(selector = "body", class = "sidebar-collapse")
    }
  })
  
  user_info <- reactive({
    credentials()$info
  })
  
  observeEvent(input$lout, {
    session$reload()
  })
  
  # CHANGE PASSWORD DIALOG BOX   
  
  changePW <- function(failed = 0) {
    modalDialog(
      passwordInput("pwd1", "New password", placeholder = "5 or more characters"),
      passwordInput("pwd2", "New password (repeat)",placeholder = "5 or more characters"),
      if (failed == 0) {
        div(tags$b("Type the new password and repeat."))
      } else if (failed == 1) {
        div(tags$b("Invalid password", style = "color: red;"))
      } else if (failed == 2) {
        div(tags$b("Password successfully updated", style = "color: red;"))
      },
      footer = tagList(
        if (failed < 2) { 
          modalButton("Cancel")
        } else {
          modalButton("OK")
        },
        if (failed < 2) actionButton("ok", "OK")
      )
    )
  }
  
  observeEvent(input$pwchange, {
    req(credentials()$user_auth)
    showModal(changePW())
  })
  
  observeEvent(input$ok, {
    if (!is.null(input$pwd1) && !is.null(input$pwd1) && str_length(input$pwd1) > 4 && input$pwd1 == input$pwd2) {
      loguser <- user_info()
      update_userbase(user = loguser$user, password_hash = sodium::password_store(input$pwd1), auth = AUTHTYPE)   
      user_base <- load_userbase(AUTHTYPE)
      showModal(changePW(failed = 2))
    } else {
      showModal(changePW(failed = 1))
    }
  })
  
  ##############################################################################################################################################################################
  # SIDEBAR & DYNAMIC INTERFACE                                                                                                                                                #
  ##############################################################################################################################################################################
  
  # DYNAMIC SIDEBAR ELEMENTS: ENABLE/DISABLE DEPENDING ON DATA (SAMPLE SELECTED/NOT SELECTED, TOOLS DEFINED/NOT DEFINED, SURVEY CONDUCTED/NOT CONDUCTED)
  
  menuObserved <- reactive({
    list(input$sam_currentSample_ilist,input$tool_items,input$survey_collected, refreshMenuStatus())
  })
  
  observeEvent(
    menuObserved(),
    {
      q <- ifelse(is.null(input$tool_items), FALSE, str_length(input$tool_items) > 0)
      s <- ifelse(is.null(input$sam_currentSample_ilist), FALSE, str_length(input$sam_currentSample_ilist) > 0)
      p <- ifelse(is.null(input$survey_collected), FALSE, str_length(input$survey_collected) > 0)
      if (q & s) {
        removeCssClass(selector = "a[data-value='power']", class = "inactiveItem")
        removeCssClass(selector = "a[data-value='survey']", class = "inactiveItem")
      } else {
        addCssClass(selector = "a[data-value='power']", class = "inactiveItem")
        addCssClass(selector = "a[data-value='survey']", class = "inactiveItem")
      }
      if (q & s & p) {
        removeCssClass(selector = "a[data-value='analysis']", class = "inactiveItem")
      } else {
        addCssClass(selector = "a[data-value='analysis']", class = "inactiveItem")
      }
    }
  )
  
  # HIDE/SHOW ITEMS ON THE SIDEBAR DEPENDING ON ITS STATUS 
  
  observeEvent(input$sidebar, {
    if(input$sidebar) {
      removeCssClass(id = "m_survey", class = "invisible")
      removeCssClass(id = "m_admin", class = "invisible")
      removeCssClass(id = "m_deep", class = "invisible")
      removeCssClass(id = "m_settings", class = "invisible")
      removeCssClass(id = "m_share", class = "invisible")
      removeCssClass(id = "m_logo", class = "invisible")
      removeCssClass(id = "m_credits", class = "invisible")
    } else {
      addCssClass(id = "m_survey", class = "invisible")
      addCssClass(id = "m_admin", class = "invisible")
      addCssClass(id = "m_share", class = "invisible")
      addCssClass(id = "m_deep", class = "invisible")
      addCssClass(id = "m_settings", class = "invisible")
      addCssClass(id = "m_logo", class = "invisible")
      addCssClass(id = "m_credits", class = "invisible")
    }
  })

   # MANAGE SWAP BETWEEN TABS 
  
  TABSAPPEARANCE <- '.content-wrapper {background-image: url(""); background-color: #FFFFFFFF} .skin-black .main-header .navbar {background-color:#FFFFFF;' 
  
  output$style_tag <- renderUI({
    if (input$SIDEMENU %in% c("settings", "interviews", "custitems","logs")) {
      return(tags$style(HTML(TABSAPPEARANCE)))
    } else if (input$SIDEMENU %in% c("explore")) {
      runjs('replaceSvg(container = "panzoom-element_world", town = 0)') 
      return(tags$style(HTML(TABSAPPEARANCE)))
    } else if (input$SIDEMENU %in% c("sample")) {
      runjs('document.getElementById("hssize_town").innerHTML = 0;document.getElementById("issize_town").innerHTML = 0;')
      runjs(paste0('replaceSvg(container = "panzoom-element_sample", town = ',0,')'))
      return(tags$style(HTML(TABSAPPEARANCE)))
    } else if (input$SIDEMENU %in% c("strategy")) {  
      runjs("Shiny.setInputValue('survey_varlist_trigger', Math.random()); Shiny.setInputValue('tab_change_trigger', 'strategy,' + Math.random());")
      return(tags$style(HTML(TABSAPPEARANCE)))
    } else if (input$SIDEMENU %in% c("power")) {    
      runjs("Shiny.setInputValue('survey_varlist_trigger', Math.random()); Shiny.setInputValue('tab_change_trigger', 'power,' + Math.random());")
      return(tags$style(HTML(TABSAPPEARANCE)))
    } else if (input$SIDEMENU %in% c("design")) {
      runjs('updateTools(tool_items);')     
      return(tags$style(HTML(TABSAPPEARANCE)))
    } else if (input$SIDEMENU %in% c("survey")) {
      runjs('updateSurvey();')    
      return(tags$style(HTML(TABSAPPEARANCE)))
    } else if (input$SIDEMENU %in% c("analysis") ){
      runjs("Shiny.setInputValue('survey_varlist_trigger', Math.random());")  # updateAnalysis();")
      return(tags$style(HTML(TABSAPPEARANCE)))
    } else if (input$SIDEMENU %in% c("upload") ){
      runjs("Shiny.setInputValue('survey_varlist_trigger', Math.random());")
      return(tags$style(HTML(TABSAPPEARANCE)))  
    } else if (input$SIDEMENU %in% c("visualise") ){
      return(tags$style(HTML(TABSAPPEARANCE))) 
    } else if (input$SIDEMENU %in% c("users") ){
      return(tags$style(HTML(TABSAPPEARANCE))) 
    } else if (credentials()$user_auth) {
      return(tags$style(HTML('.content-wrapper {background-image: url("img/splash_light.png")}')))
    }
  })  # BACKGROUNDS, JS EXECUTED AT LOADING TIME

  observeEvent(input$SIDEMENU,{ 
    updateTabsetPanel(session, "SIDEMENU", input$SIDEMENU)
    }) # SWAPPING BETWEEN TABS FROM JAVASCRIPT (1)
  observe({
    input$tab_change_trigger
    x <- strsplit(input$tab_change_trigger, split = ",", fixed = TRUE)[[1]][1]
    updateTabsetPanel(session, "SIDEMENU", selected =  x)
  }) # SWAPPING BETWEEN TABS FROM JAVASCRIPT (trigger: input$tab_change_trigger)
  
  # ADAPT THE INTERFACE BY SAMPLING TYPE
  
  observe({input$strategy_sample
    session$sendCustomMessage("handler_strategy_type", input$strategy_sample)
  })
  
  # MANAGES CHANGES IN TOWN IN THE EXPLORE AND SAMPLE TABS
  
  observe({
    input$currentTown_explore
    town <- input$currentTown_explore
    data <- subset(E,Town_Code == input$currentTown_explore & Suburb_Name == "All")
    pop <- sum(subset(E,Town_Code == 0)$Population)
    hous <- sum(subset(E,Town_Code == 0)$Households)
    data = list(town, data, pop, hous)
    session$sendCustomMessage(type = "handler_status_explore", data)
  }) # EXPLORE (trigger: input$currentTown_explore)
  observe({
    input$currentTown_sample
    town <- input$currentTown_sample
    data <- subset(E,Town_Code == input$currentTown_sample & Suburb_Name == "All")
    data <- list(town, data)
    session$sendCustomMessage(type = "handler_status_sample", data)
  }) # EXPLORE (trigger: input$currentTown_sample)
 
  # SHOW HOUSEHOLD MEMBERS WHEN A HOUSEHOLD IS SELECTED
  
  observe({
    input$currentHousehold
    town <- input$currentTown_sample
    data <- subset(P,Town_Code == input$currentTown_sample & HID == input$currentHousehold)[, c("HID","IID","SEX","AGE","POPGROUP")]
    data$sex <- as.numeric(data$SEX)
    data$agecat <- as.numeric(cut(data$AGE, include.lowest = TRUE, breaks = c(0,9,19,39,64,150)))
    data$popgroup <- as.numeric(data$POPGROUP)
    data <- list(data[, c("HID","IID","sex","agecat","popgroup")])
    session$sendCustomMessage(type = "handler_household_members", data)
  }) # (trigger: input$currentHousehold)
  
  # UPDATE ITEM LIST IN THE VARIABLE SELECTORS 
  
  observeEvent(
    input$survey_varlist_trigger, 
    {
      qs <- as.numeric(str_split(input$tool_items, fixed(",")))
      q <- Q[Q$QCODE %in% qs, c("ITEM","VARIABLE","SCALE")] 
      qcat <- q[q$SCALE == "cat", c("ITEM","VARIABLE")]
      data = list(c("",q$ITEM),c("",q$VARIABLE),c("",qcat$ITEM),c("",qcat$VARIABLE))
      session$sendCustomMessage(type = "handler_survey_questvar", data)
    }) # (trigger: input$survey_varlist_trigger)
 
  # REFRESH PAGE WHEN USER EXITS FROM LOGIN
  
  observeEvent(input$homepage, {
    session$reload()
  })
  
  # DOWNLOAD MANUAL
  
  output$downloadManual <- downloadHandler(
    filename = function() {
      paste("SurveyLab_Manual_", RELEASE_VE, ".pdf", sep = "")
    },
    content = function(file) {
      file.copy("www/help/SurveyLab_Manual.pdf", file)
    }
  )
  
  ##############################################################################################################################################################################
  # SAMPLING & POWER CALCULATIONS                                                                                                                                              #
  ##############################################################################################################################################################################

  observeEvent(
    input$strategy_strategy,
    {
      tryCatch(
        {
          set.seed(randomseed(RGEN, SEED))
          STRAT <- input$strategy_strategy

          if (STRAT[1] != "") { # ignore at start

            # SUBSET TARGET POPULATION

            TARGET_AGEMIN <- as.numeric(STRAT[10]) # MINIMUM AGE
            TARGET_AGEMAX <- as.numeric(STRAT[11]) # MAXIMUM AGE
            TARGET_SEX <- STRAT[13:(12 + as.numeric(STRAT[12]))] # SEXES
            TARGET_TOWN <- STRAT[(13 + as.numeric(STRAT[12])):(length(STRAT) - 1)] # TOWNS

            PO <- droplevels(subset(P, TOWN %in% TARGET_TOWN & SEX %in% TARGET_SEX & AGE >= TARGET_AGEMIN & AGE <= TARGET_AGEMAX))
            PO <- PO[order(PO$REGION, PO$TOWN, PO$SUBURB, PO$HID, PO$IID), ] # TARGET POPULATION (FULL DATA)
            TARGET_POP_SIZE <- nrow(PO)

            # PREPARE PARAMETERS FOR SAMPLING ACCORDING TO STRATEGY

            CTYPE <- STRAT[2] # TYPE OF CLUSTERING
            STRATVAR <- STRAT[1] # STRATIFICATION VARIABLE
            CLUSTVAR1 <- STRAT[3] # CLUSTER VARIABLE LEVEL 1 (HIGHER)
            CLUSTVAR2 <- STRAT[6] # CLUSTER VARIABLE LEVEL 2 (LOWER)
            NS1 <- ifelse(CLUSTVAR1 != "NONE", as.numeric(STRAT[4]), 1) # SAMPLE SIZE AT LEVEL 1 (HIGHER)
            PPS1 <- STRAT[5] == "TRUE" # PPS FLAG AT LEVEL 1
            NS2 <- ifelse(CLUSTVAR2 != "NONE", as.numeric(STRAT[7]), 1) # NSAMPLE SIZE AT LEVEL 2 (LOWER)
            PPS2 <- STRAT[8] == "TRUE" # PPS FLAG AT LEVEL 2
            NS3 <- as.numeric(STRAT[9]) # SAMPLE SIZE AT INDIVIDUAL LEVEL (PER CLUSTER)

            # DRAW SAMPLE

            P0 <- PO[, c("REGION", "TOWN", "SUBURB", "HID", "IID")]
            if (STRATVAR != "NONE") {
              S0 <- table(P0[, STRATVAR]) / nrow(P0)
              STRATA <- unique(P0[, STRATVAR])
            } else {
              S0 <- table((P0 %>% mutate(SurveyLab = "SurveyLab"))$SurveyLab)
              S0[1] <- 1
              STRATA <- "NONE"
            }

            ILIST <- NULL
            PROBS0 <- NULL
            PROBS1 <- NULL
            PROBS2 <- NULL
            PROBS3 <- NULL

            REPLACE1 <- 0
            REPLACE2 <- 0
            REPLACE3 <- 0

            MAXRATIO1 <- 0
            MAXRATIO2 <- 0
            MAXRATIO3 <- 0

            for (co in c(1:length(STRATA))) {
              if (length(STRATA) > 1) {
                P1 <- droplevels(P0[P0[, STRATVAR] == STRATA[co], ]) # SELECT STRATUM
              } else {
                P1 <- P0
              } # STRATIFICATION YES/NO

              if (CTYPE == "TWO") {
                C1 <- table(P1[, CLUSTVAR1]) / nrow(P1) # CLUSTER1 SAMPLING PROBABILITIES PPS
                if (!PPS1) { # EQUAL SAMPLING PROBABILITIES
                  nam <- names(C1)
                  NCLUST <- length(unique(P1[, CLUSTVAR1]))
                  C1 <- rep(1 / NCLUST, NCLUST)
                  attr(C1, "names") <- nam
                }
                S1 <- try(sample(C1, NS1, prob = C1), silent = TRUE) # SAMPLE CLUSTER 1
                if (inherits(S1, "try-error")) {
                  REPLACE1 <- REPLACE1 + 1
                  S1 <- sample(C1, NS1, prob = C1, replace = TRUE)
                  S1 <- S1[!duplicated(S1)]
                }
                MAXRATIO1 <- max(MAXRATIO1, length(S1) / length(C1))
                for (c1 in c(1:length(S1))) {
                  P2 <- droplevels(P1[P1[, CLUSTVAR1] == names(S1)[c1], ]) # SELECT CLUSTER 1
                  C2 <- table(P2[, CLUSTVAR2]) / nrow(P2) # CLUSTER2 SAMPLING PROBABILITIES PPS
                  if (!PPS2) { # EQUAL SAMPLING PROBABILITIES
                    nam <- names(C2)
                    NCLUST <- length(unique(P2[, CLUSTVAR2]))
                    C2 <- rep(1 / NCLUST, NCLUST)
                    attr(C2, "names") <- nam
                  }
                  S2 <- try(sample(C2, NS2, prob = C2), silent = TRUE) # SAMPLE CLUSTER 2
                  if (inherits(S2, "try-error")) {
                    S2 <- sample(C2, length(C2))
                    REPLACE2 <- REPLACE2 + 1
                  }
                  MAXRATIO2 <- max(MAXRATIO2, length(S2) / length(C2))
                  for (c2 in c(1:length(S2))) {
                    P3 <- droplevels(P2[P2[, CLUSTVAR2] == names(S2)[c2], ]) # SELECT CLUSTER 2
                    C3 <- table(P3[, "IID"]) / nrow(P3)
                    S3 <- try(sample(P3$IID, NS3, prob = NULL), silent = TRUE) # SAMPLE INDIVIDUALS WITH EQUAL PROBABILITY
                    if (inherits(S3, "try-error")) {
                      S3 <- sample(P3$IID, length(P3$IID))
                      REPLACE3 <- REPLACE3 + 1
                    }
                    MAXRATIO3 <- max(MAXRATIO3, length(S3) / length(C3))
                    ILIST <- c(ILIST, S3)
                    PROBS1 <- c(PROBS1, rep(C1[c1], length(S3)))
                    PROBS2 <- c(PROBS2, rep(C2[c2], length(S3)))
                    PROBS3 <- c(PROBS3, C3[S3])
                  }
                }
              } else if (CTYPE == "ONE") {
                C1 <- table(P1[, CLUSTVAR1]) / nrow(P1) # CLUSTER1 SAMPLING PROBABILITIES PPS
                if (!PPS1) { # EQUAL SAMPLING PROBABILITIES
                  nam <- names(C1)
                  NCLUST <- length(unique(P1[, CLUSTVAR1]))
                  C1 <- rep(1 / NCLUST, NCLUST)
                  attr(C1, "names") <- nam
                }
                S1 <- try(sample(C1, NS1, prob = C1), silent = TRUE) # SAMPLE CLUSTER 1
                if (inherits(S1, "try-error")) {
                  S1 <- sample(C1, length(C1))
                  REPLACE1 <- REPLACE1 + 1
                }
                MAXRATIO1 <- max(MAXRATIO1, length(S1) / length(C1))
                for (c1 in c(1:length(S1))) {
                  P3 <- droplevels(P1[P1[, CLUSTVAR1] == names(S1)[c1], ]) # SELECT CLUSTER 1
                  C3 <- table(P3[, "IID"]) / nrow(P1)
                  S3 <- try(sample(P3$IID, NS3, prob = NULL), silent = TRUE) # SAMPLE INDIVIDUALS WITH EQUAL PROBABILITY
                  if (inherits(S3, "try-error")) {
                    S3 <- sample(P3$IID, length(P3$IID))
                    REPLACE3 <- REPLACE3 + 1
                  }
                  MAXRATIO3 <- max(MAXRATIO3, length(S3) / length(C3))
                  ILIST <- c(ILIST, S3)
                  PROBS1 <- c(PROBS1, rep(C1[c1], length(S3)))
                  PROBS2 <- c(PROBS2, rep(1, length(S3)))
                  PROBS3 <- c(PROBS3, C3[S3])
                }
              } else { # SIMPLE
                C3 <- table(P1[, "IID"]) / nrow(P1)
                S3 <- try(sample(P1$IID, NS3, prob = NULL), silent = TRUE) # SAMPLE INDIVIDUALS WITH EQUAL PROBABILITY
                if (inherits(S3, "try-error")) {
                  S3 <- sample(P1$IID, length(P1$IID))
                  REPLACE3 <- REPLACE3 + 1
                }
                MAXRATIO3 <- max(MAXRATIO3, length(S3) / length(C3))
                ILIST <- c(ILIST, S3)
                PROBS1 <- c(PROBS1, rep(1, length(S3)))
                PROBS2 <- c(PROBS2, rep(1, length(S3)))
                PROBS3 <- c(PROBS3, C3[S3])
              }
            }

            PROBS <- data.frame(Probs = PROBS1 * PROBS2 * PROBS3, IID = ILIST)
            SAMPLE <- subset(PO, IID %in% ILIST)

            SEP <- unlist(str_locate_all(ILIST, "_"))
            SEP_T2 <- SEP[seq(2, length(SEP), 6)] - 1
            SEP_HH <- SEP[seq(3, length(SEP), 6)] - 1
            TSAMPLE <- unique(substr(ILIST, start = 3, stop = SEP_T2))

            HSAMPLE <- rep(list(list()), nrow(TNAMES))
            ISAMPLE <- rep(list(list()), nrow(TNAMES))
            HSIZE <- rep(0, nrow(TNAMES))
            ISIZE <- rep(0, nrow(TNAMES))

            STNAMES <- TNAMES[TNAMES$Town_Code %in% TSAMPLE, c("Town_Name", "Town_Code")]

            for (i in c(1:nrow(STNAMES))) {
              XS <- subset(SAMPLE, TOWN == STNAMES[i, ]$Town_Name)
              HS <- unique(XS$HID)
              IS <- unique(XS$IID)

              index <- STNAMES[i, ]$Town_Code
              HSAMPLE[index] <- list(HS)
              HSIZE[index] <- length(HS)

              ISAMPLE[index] <- list(IS)
              ISIZE[index] <- length(IS)
            }

            TSIZE <- length(TSAMPLE)
            THSIZE <- length(unique(substr(ILIST, start = 1, stop = SEP_HH)))
            TISIZE <- length(ILIST)

            # FORMAT OUTPUT

            hs <- unlist(HSAMPLE)
            is <- unlist(ISAMPLE)
            qnum <- input$tool_qnum
            mnum <- input$tool_mnum

            d <- P[P$HID %in% hs, c("HID", "IID", "REGION", "TOWN", "SUBURB")]
            s <- S[S$ID %in% hs, c("TOWNNAME", "XC", "YC")]
            nt <- table(d$TOWN)
            nt <- length(nt[nt > 0])
            ns <- table(d$SUBURB)
            ns <- length(ns[ns > 0])
            nr <- table(d$REGION)
            nr <- length(nr[nr > 0])
            ni <- length(is)

            # Administration time
            qtime <- as.numeric(qnum) * TQ + as.numeric(mnum) * TM

            # Maximum sampling ratios

            X <- c(
              ifelse(MAXRATIO1 > 0, paste0(round(MAXRATIO1 * 100, 1), "%"), NA),
              ifelse(MAXRATIO2 > 0, paste0(round(MAXRATIO2 * 100, 1), "%"), NA),
              ifelse(MAXRATIO3 > 0, paste0(round(MAXRATIO3 * 100, 1), "%"), NA)
            )
            MAXRATIO <- paste(X[!is.na(X)], collapse = " / ")

            # Cost
            COST_BASE <- 0

            for (t in unique(d$TOWN)) {
              si <- subset(s, TOWNNAME == t)[, c("XC", "YC")]
              ES <- ETSP(si)
              tour <- solve_TSP(ES)
              COST_BASE <- COST_BASE + attr(tour, which = "tour_length")
            }

            COST_BASE <- COST_BASE / MAXCOST * 100 * (1 + QCOST * floor((as.numeric(qnum) + as.numeric(mnum)) / 10)) # COLLECTION COST
            COST_SETUP <- (SETUP1 * ns + SETUP2 * nt + SETUP3 * nr) * 100 * (1 + QCOST * floor((as.numeric(qnum) + as.numeric(mnum)) / 10)) # SETUP COST
            COST_TOTAL <- COST_BASE + COST_SETUP # TOTAL SURVEY COST
            COST_UNIT <- COST_TOTAL / ni # COST PER UNIT

            # RETURN VALUES TO JS

            data <- list(
              TSAMPLE, HSAMPLE, ISAMPLE, TSIZE, THSIZE, TISIZE, HSIZE, ISIZE, round(COST_SETUP, 1), round(COST_BASE, 1), round(COST_TOTAL, 1),
              REPLACE1, REPLACE2, REPLACE3, TARGET_POP_SIZE, MAXRATIO
            )
            session$sendCustomMessage(type = "handler_update_sample", data)
            
            # Re-enable the menu 
            runjs("$('.sidebar-menu a').removeClass('inactiveItem');")
            refreshMenuStatus(refreshMenuStatus()+1)

            # UPDATE GLOBAL VARIABLE HOLDING THE SELECTION PROBABILITIES & SET THE FLAG INDICATING RANDOM SAMPLING

            updateTextInput(inputId = "strategy_sample", value = 1)
            session$userData$survey_probs <- PROBS
            
            # Clean environment
            rm(PO, PROBS, SAMPLE,TSAMPLE, HSAMPLE, ISAMPLE, TSIZE, THSIZE, TISIZE, HSIZE, ISIZE, COST_SETUP, COST_BASE, COST_TOTAL,REPLACE1, 
            REPLACE2, REPLACE3, TARGET_POP_SIZE, MAXRATIO)
          }
        },
        error = function(e) {
          # Log the error in the Server Log and the console (only seen by administrators)
          session$sendCustomMessage(type = "handler_logs", list(e$message, credentials()$info[1][[1]],"sampling"))
          message("Sampling error: ", e$message) # log to console
          # Notify the user
          output <- paste("Something went wrong: check your sampling strategy.")
          runjs("$('#samplespinner').gSpinner('hide');")
          showNotification(
            ui = output,
            duration = NULL,
            closeButton = TRUE,
            type = "error"
          )
        }
      )
    }
  ) # RANDOM SAMPLING ACCORDING TO STRATEGY (trigger: input$strategy_strategy)

  observeEvent(
    input$power_calc,
    {
      tryCatch(
        {
          STRAT <- input$power_calc

          if (STRAT[1] != "") { # ignore at start

            # SUBSET TARGET POPULATION

            TARGET_AGEMIN <- as.numeric(STRAT[10]) # MINIMUM AGE
            TARGET_AGEMAX <- as.numeric(STRAT[11]) # MAXIMUM AGE
            TARGET_SEX <- STRAT[13:(12 + as.numeric(STRAT[12]))] # SEXES
            TARGET_TOWN <- STRAT[(13 + as.numeric(STRAT[12])):(length(STRAT) - 1 - 7)] # TOWNS

            PO <- droplevels(subset(P, TOWN %in% TARGET_TOWN & SEX %in% TARGET_SEX & AGE >= TARGET_AGEMIN & AGE <= TARGET_AGEMAX))
            PO <- PO[order(PO$REGION, PO$TOWN, PO$SUBURB, PO$HID, PO$IID), ] # TARGET POPULATION (FULL DATA)

            # PREPARE PARAMETERS FOR CALCULATION

            SSIZE <- length(unlist(input$sam_currentSample_ilist)) # SAMPLE SIZE AT INDIVIDUAL LEVEL

            STRATVAR <- STRAT[1] # STRATIFICATION VARIABLE
            if (STRATVAR == "NONE") {
              STRATA <- "NONE"
              NSTRATASIZE <- c(SSIZE)
            } else {
              STRATA <- unique(PO[, STRATVAR])
              NSTRATASIZE <- as.numeric(table(PO[PO$IID %in% unlist(input$sam_currentSample_ilist), c(STRATVAR)]))
            }

            NSTRATA <- length(STRATA)
            CTYPE <- STRAT[2] # TYPE OF CLUSTERING
            CLUSTVAR1 <- STRAT[3] # CLUSTER VARIABLE LEVEL 1 (HIGHER)

            # POWER CALCULATION PARAMETERS
            POWER_OUTCOME <- STRAT[length(STRAT) - 7] # OUTCOME
            POWER_EXPPROP <- as.numeric(STRAT[length(STRAT) - 6]) / 100 # EXPECTED PROPORTION IN POPULATION
            POWER_EXPSD <- as.numeric(STRAT[length(STRAT) - 5]) # EXPECTED SD IN POPULATION
            POWER_EXPDEFF <- as.numeric(STRAT[length(STRAT) - 4]) # ESTIMATED DEFF
            POWER_EXPAUTO <- STRAT[length(STRAT) - 3] == "TRUE" # AUTOMATIC CALCULATION OF EXPPRO/EXPSD AND DEFF (true)
            POWER_RRMIN <- as.numeric(STRAT[length(STRAT) - 2]) / 100 # MINIMUM RESPONSE RATE
            POWER_RRMAX <- as.numeric(STRAT[length(STRAT) - 1]) / 100 # MAXIMUM RESPONSE RATE

            # RR RANGE

            RR <- seq(round(max(0.05, POWER_RRMIN) / 0.05) * 0.05, round(min(1, POWER_RRMAX) / 0.05) * 0.05, 0.05)

            # CALCULATE PRECISION

            PREC <- matrix(0, nrow = length(RR), ncol = NSTRATA + 1)

            V <- capture.output(str(P[POWER_OUTCOME][[1]]))
            V1 <- substr(V, 2, 2)

            if (POWER_EXPAUTO) {
              if (V1 == "n") { # numeric variable
                POWER_EXPSD <- sd(PO[, POWER_OUTCOME], na.rm = TRUE)
              } else {
                V2 <- as.numeric(substr(V, 12, 13))
                if (V2 == 2) {
                  POWER_EXPPROP <- prop.table(table(PO[, POWER_OUTCOME]))[1]
                  names(POWER_EXPPROP) <- NULL
                } else {
                  Y <- abs(prop.table(table(PO[, POWER_OUTCOME])) - 0.5)
                  POWER_EXPPROP <- mean(PO[, POWER_OUTCOME] == names(Y)[which.min(Y)], na.rm = TRUE)
                  names(POWER_EXPPROP) <- NULL
                }
              }

              # DEFF

              if (CTYPE == "NONE" & STRATVAR == "NONE") {
                POWER_EXPDEFF <- 1
              } else {
                if (CTYPE == "NONE" & STRATVAR != "NONE") {
                  SAMPLE <- PO[PO$IID %in% unlist(input$sam_currentSample_ilist), c(STRATVAR, POWER_OUTCOME)]
                  W <- 1 / session$userData$survey_probs$Probs / sum(1 / session$userData$survey_probs$Probs) * length(session$userData$survey_probs$Probs)
                  X1 <- svymean(as.formula(paste0("~", POWER_OUTCOME)), design = svydesign(id = ~0, strata = SAMPLE[, STRATVAR], weights = W, data = SAMPLE), na.rm = TRUE, deff = TRUE)
                  X2 <- svymean(as.formula(paste0("~", POWER_OUTCOME)), design = svydesign(id = ~1, strata = NULL, data = SAMPLE), na.rm = TRUE, deff = TRUE)
                  POWER_EXPDEFF <- round(max(attr(X1, "var")) / max(attr(X2, "var")), 1)
                  rm(SAMPLE,W,X1,X2)
                } else if (CTYPE != "NONE" & STRATVAR == "NONE") {
                  SAMPLE <- PO[PO$IID %in% unlist(input$sam_currentSample_ilist), c(CLUSTVAR1, POWER_OUTCOME)]
                  W <- 1 / session$userData$survey_probs$Probs / sum(1 / session$userData$survey_probs$Probs) * length(session$userData$survey_probs$Probs)
                  X1 <- svymean(as.formula(paste0("~", POWER_OUTCOME)), design = svydesign(id = ~0, strata = SAMPLE[, STRATVAR], weights = W, data = SAMPLE), na.rm = TRUE, deff = TRUE)
                  X2 <- svymean(as.formula(paste0("~", POWER_OUTCOME)), design = svydesign(id = ~1, strata = NULL, data = SAMPLE), na.rm = TRUE, deff = TRUE)
                  POWER_EXPDEFF <- round(max(attr(X1, "var")) / max(attr(X2, "var")), 1)
                  rm(SAMPLE,W,X1,X2)
                } else {
                  SAMPLE <- P[P$IID %in% unlist(input$sam_currentSample_ilist), c(CLUSTVAR1, STRATVAR, POWER_OUTCOME)]
                  W <- 1 / session$userData$survey_probs$Probs / sum(1 / session$userData$survey_probs$Probs) * length(session$userData$survey_probs$Probs)
                  X1 <- svymean(as.formula(paste0("~", POWER_OUTCOME)), design = svydesign(id = ~0, strata = SAMPLE[, STRATVAR], weights = W, data = SAMPLE), na.rm = TRUE, deff = TRUE)
                  X2 <- svymean(as.formula(paste0("~", POWER_OUTCOME)), design = svydesign(id = ~1, strata = NULL, data = SAMPLE), na.rm = TRUE, deff = TRUE)
                  POWER_EXPDEFF <- round(max(attr(X1, "var")) / max(attr(X2, "var")), 1)
                  rm(SAMPLE,W,X1,X2)
                }
              }
            }

            if (V1 == "n") { # numeric variable
              for (j in c(1:length(RR))) {
                PREC[j, NSTRATA + 1] <- prec_mean(mean = 1, sd = POWER_EXPSD, n = SSIZE * RR[j] / POWER_EXPDEFF, conf.level = 0.95)$conf.width / 2
              }

              for (s in c(1:NSTRATA)) {
                for (j in c(1:length(RR))) {
                  PREC[j, s] <- prec_mean(mean = 1, sd = POWER_EXPSD, n = NSTRATASIZE[s] * RR[j] / POWER_EXPDEFF, conf.level = 0.95)$conf.width / 2
                }
              }
            } else {
              for (j in c(1:length(RR))) {
                PREC[j, NSTRATA + 1] <- prec_prop(p = POWER_EXPPROP, n = SSIZE * RR[j] / POWER_EXPDEFF, conf.level = 0.95, method = c("wilson", "agresti-coull")[ifelse(SSIZE * RR[j] / POWER_EXPDEFF < 40, 1, 2)])$conf.width / 2 * 100
              }
              for (s in c(1:NSTRATA)) {
                for (j in c(1:length(RR))) {
                  PREC[j, s] <- prec_prop(p = POWER_EXPPROP, n = NSTRATASIZE[s] * RR[j] / POWER_EXPDEFF, conf.level = 0.95, method = c("wilson", "agresti-coull")[ifelse(NSTRATASIZE[s] * RR[j] / POWER_EXPDEFF < 40, 1, 2)])$conf.width / 2 * 100
                }
              }
            }

            PREC <- data.frame(PREC)
            colnames(PREC)[NSTRATA + 1] <- "TOTAL"
            WORST <- round(max(PREC[nrow(PREC), ]), 1)
            PREC$RR <- round(RR * 100, 0)
            data <- list(POWER_EXPDEFF, PREC, V1, POWER_EXPSD, POWER_EXPPROP * 100, WORST)
            session$sendCustomMessage(type = "handler_power_calculations", data)
            
            # Clean environment
            rm(POWER_EXPDEFF, PREC, V1, POWER_EXPSD, POWER_EXPPROP,WORST)
            
          }
        },
        error = function(e) {
          # Log the error in the Server Log and the console (only seen by administrators)
          session$sendCustomMessage(type = "handler_logs", list(e$message, credentials()$info[1][[1]],"power"))
          message("Power calculation error: ", e$message) # log to console
          # Notify the user
          output <- paste("Something went wrong: check your inputs")
          runjs("$('#powerspinner').gSpinner('hide');")
          showNotification(
            ui = output,
            duration = NULL,
            closeButton = TRUE,
            type = "error"
          )
        }
      )
    }
  ) # POWER CALCULATIONS (trigger: input$power_calc)


  observe({
    input$survey_cost_trigger

    tryCatch(
      {
        hs <- input$sam_currentSample_hlist
        is <- input$sam_currentSample_ilist
        qnum <- input$tool_qnum
        mnum <- input$tool_mnum

        d <- P[P$HID %in% hs, c("HID", "IID", "REGION", "TOWN", "SUBURB")]
        s <- S[S$ID %in% hs, c("TOWNNAME", "XC", "YC")]
        nt <- table(d$TOWN)
        nt <- length(nt[nt > 0])
        ns <- table(d$SUBURB)
        ns <- length(ns[ns > 0])
        nr <- table(d$REGION)
        nr <- length(nr[nr > 0])
        ni <- length(is)
        # Administration time
        qtime <- as.numeric(qnum) * TQ + as.numeric(mnum) * TM
        # Cost
        COST_BASE <- 0

        for (t in unique(d$TOWN)) {
          si <- subset(s, TOWNNAME == t)[, c("XC", "YC")]
          ES <- ETSP(si)
          tour <- solve_TSP(ES)
          COST_BASE <- COST_BASE + attr(tour, which = "tour_length")
        }

        COST_BASE <- COST_BASE / MAXCOST * 100 * (1 + QCOST * floor((as.numeric(qnum) + as.numeric(mnum)) / 10)) # COLLECTION COST
        COST_SETUP <- (SETUP1 * ns + SETUP2 * nt + SETUP3 * nr) * 100 * (1 + QCOST * floor((as.numeric(qnum) + as.numeric(mnum)) / 10)) # SETUP COST
        COST_TOTAL <- COST_BASE + COST_SETUP # TOTAL SURVEY COST
        COST_UNIT <- COST_TOTAL / ni # COST PER UNIT

        data <- list(round(COST_SETUP, 1), round(COST_BASE, 1), round(COST_TOTAL, 1), round(COST_UNIT, 2))
        session$sendCustomMessage(type = "handler_survey_cost", data)
        
        # Clean environment
        rm(d,s)
        
      },
      error = function(e) {
        # Log the error in the Server Log and the console (only seen by administrators)
        session$sendCustomMessage(type = "handler_logs", list(e$message, credentials()$info[1][[1]],"cost"))
        message("Cost calculation error: ", e$message) # log to console
        # Notify the user
        output <- paste("Something went wrong: notify the administrator.")
        runjs("$('#samplespinner').gSpinner('hide');")
        showNotification(
          ui = output,
          duration = NULL,
          closeButton = TRUE,
          type = "error"
        )
      }
    )
  }) # CALCULATE COST (trigger: input$survey_cost_trigger)
  
  ##############################################################################################################################################################################
  # SURVEY AND ANALYSIS                                                                                                                                                        #
  ##############################################################################################################################################################################
  
  observeEvent(
    input$survey_collect_trigger,
    {
      tryCatch(
        {
          set.seed(randomseed(RGEN, SEED))
          if (length(input$survey_collect_trigger) == 0) {
            session$userData$survey_responses <- NULL
          } else {
            ts <- unlist(str_split(input$sam_currentSample_tlist, fixed(",")))
            is <- unlist(str_split(input$sam_currentSample_ilist, fixed(",")))
            qs <- as.numeric(str_split(input$tool_items, fixed(",")))
            q <- Q[Q$QCODE %in% qs, ]
            varlist <- unique(c("WEALTH", "AGECAT1", "SEX", "IID", "HID", "REGION", "TOWN", "SUBURB", q$VARIABLE))
            P$TOWNCODE <- unlist(strsplit(P$IID, split = "_", fixed = TRUE))[seq(from = 2, to = length(P$IID) * 4, by = 4)]
            d <- P[P$IID %in% is & P$TOWNCODE %in% ts, varlist]

            if (nrow(d) > 0) {

              d$WEALTH1 <- d$WEALTH
              d$SEX1 <- d$SEX
              varlist <- unique(c("WEALTH1", "AGECAT1", "SEX1", "IID", "HID", "REGION", "TOWN", "SUBURB", q$VARIABLE))
              d <- d[, varlist]
              dtime <- format(Sys.time(), "%Y/%m/%d %X")
              colnames(d)[1:3] <- c("W", "A", "S")
              d$S <- as.numeric(d$S)
              d$A <- as.numeric(d$A)
              d$R <- as.numeric(d$REGION)
              d$HR <- ""
              d$IR <- ""

              # HOUSEHOLD CONSENT
              
              d$HR <- vhrr(d$W)
              d[d$HR != "Consent",q$VARIABLE] <- NA

              # INDIVIUAL AND ITEM CONSENT

              d[d$HR == "Consent" & !is.na(d$HR),]$IR <- virr(d[d$HR == "Consent", ]$A, d[d$HR == "Consent", ]$S, d[d$HR == "Consent", ]$R)
              d[d$IR != "Consent" & !is.na(d$IR),q$VARIABLE] <- NA
           
              for (i in 1:length(q$VARIABLE)) {
                v <- q$VARIABLE[i]
                itcons <- vitrr(q[q$VARIABLE == v, ]$TYPE, i)   
                d[d$IR == "Consent" & !is.na(d$IR) & !itcons, v] <-  NA
              }
            
              x <- d[!duplicated(d$HID), ]$HR
              hconsent <- length(x[x == "Consent"])
              iconsent <- length(d$IR[!is.na(d$IR) & d$IR == "Consent"])

              # RESPONSE RATES

              RESPRATES_TOTAL <- c(round(hconsent / length(unique(d$HID)) * 100, 1), 
                                   round((iconsent / length(unique(d$IID)))/(hconsent / length(unique(d$HID))) *100,1))
              HRESPRATE_REGION <- NULL
              IRESPRATE_REGION <- NULL
              HRESPRATE_TOWN <- NULL
              IRESPRATE_TOWN <- NULL

              RNAMES <- unique(d$REGION)
              for (r in RNAMES) {
                dd <- subset(d, REGION == r)
                x1 <- dd[!duplicated(dd$HID), ]$HR
                hconsent1 <- length(x1[x1 == "Consent"])
                iconsent1 <- length(dd$IR[!is.na(dd$IR) & dd$IR == "Consent"])
                hconsent2 <- round(hconsent1/length(unique(dd$HID)) * 100, 1)
                iconsent2 <- round((iconsent1 / length(unique(dd$IID)))/(hconsent1 / length(unique(dd$HID))) *100,1)
                HRESPRATE_REGION <- c(HRESPRATE_REGION, ifelse(is.finite(hconsent2), hconsent2, 0))
                IRESPRATE_REGION <- c(IRESPRATE_REGION, ifelse(is.finite(iconsent2), iconsent2, 0))
              }

              RESPRATES_REGION <- data.frame(Region = RNAMES, HRR = HRESPRATE_REGION, IRR = IRESPRATE_REGION)

              TNAM <- unique(d$TOWN)
              for (r in TNAM) {
                dd <- subset(d, TOWN == r)
                x1 <- dd[!duplicated(dd$HID), ]$HR
                hconsent1 <- length(x1[x1 == "Consent"])
                iconsent1 <- length(dd$IR[!is.na(dd$IR) & dd$IR == "Consent"])
                hconsent2 <- round(hconsent1/length(unique(dd$HID)) * 100, 1)
                iconsent2 <- round((iconsent1 / length(unique(dd$IID)))/(hconsent1 / length(unique(dd$HID))) *100,1)
                HRESPRATE_TOWN <- c(HRESPRATE_TOWN, ifelse(is.finite(hconsent2), hconsent2, 0))
                IRESPRATE_TOWN <- c(IRESPRATE_TOWN, ifelse(is.finite(iconsent2), iconsent2, 0))
              }

              RESPRATES_TOWN <- data.frame(Town = TNAM, HRR = HRESPRATE_TOWN, IRR = IRESPRATE_TOWN)
              RESPRATES_TOWN <- merge(RESPRATES_TOWN, TNAMES[, c("Town_Name", "Region_Name")], by.x = "Town", by.y = "Town_Name")
              RESPRATES_TOWN <- RESPRATES_TOWN[order(RESPRATES_TOWN$Region, RESPRATES_TOWN$Town), ]

              RESPONSES <- d[, unique(c("IID", "HID", "HR", "IR", "REGION", "TOWN", "SUBURB", q$VARIABLE))]

              # FILTER (ONLY SELECTED TOWNS IN SURVEY)

              RESPONSES$tcode <- as.numeric(unlist(strsplit(RESPONSES$HID, "_", fixed = TRUE))[rep(c(FALSE, TRUE, FALSE))])
              RESPONSES <- subset(RESPONSES, tcode %in% input$survey_collect_trigger)
              RESPONSES$tcode <- NULL

              if (input$strategy_sample == 1) {
                RESPONSES <- merge(RESPONSES, session$userData$survey_probs, by = c("IID"))
              }

              data <- list(
                RESPONSES,
                q$ITEM,
                q$TYPE,
                c("IID", "HID", "hconsent", "iconsent", q$VARIABLE),
                hconsent,
                iconsent,
                RESPRATES_TOTAL,
                RESPRATES_REGION,
                RESPRATES_TOWN,
                nrow(RESPONSES),
                Sys.time()
              )

              # UPDATE GLOBAL VARIABLE HOLDING THE OUTPUT DATASET

              session$userData$survey_responses <- RESPONSES
              session$userData$codebook <- subset(Q, VARIABLE %in% colnames(RESPONSES))[, c("VARIABLE","ITEM","SCALE")]
              session$sendCustomMessage(type = "handler_survey_collect", data)
              
              # Clean environment
              rm(q, d, RESPONSES, RESPRATES_TOTAL, RESPRATES_REGION, RESPRATES_TOWN, hconsent, iconsent)
              
              # Re-enable the menu 
              runjs("$('.sidebar-menu a').removeClass('inactiveItem');")
              refreshMenuStatus(refreshMenuStatus()+1)

            }
          }
        },
      error = function(e) {
        # Log the error in the Server Log and the console (only seen by administrators)
        session$sendCustomMessage(type = "handler_logs", list(e$message, credentials()$info[1][[1]],"target estimates"))
        message("Estimation error: ", e$message) # log to console
        # Notify the user
        output <- paste("Something went wrong: check your inputs.")
        showNotification(
          ui = output,
          duration = NULL,
          closeButton = TRUE,
          type = "error"
        )
      }
      )
    }
  ) # SURVEY TARGET POPULATION (trigger: input$survey_collect_trigger)

  observeEvent(
    req(input$survey_sample_vars),
    {
      tryCatch(
        {
          OUTCOME <- input$survey_sample_vars[1]
          GROUP <- input$survey_sample_vars[2]

          if (GROUP == "NONE") {
            DS <- session$userData$survey_responses[, c(OUTCOME,OUTCOME)]
            DS[,2] <- "All respondents"
          } else {
            DS <- session$userData$survey_responses[, c(OUTCOME, GROUP)]
          }
          if (!is.null(DS)) {
            colnames(DS) <- c("Variable", "Group")
            #DS <- droplevels(DS[complete.cases(DS), ])
            TABLE_SAMPLE <- NULL
            if (OUTCOME %in% CATEGORICAL) {
              TABLE_SAMPLE <- as.data.frame.matrix(round(prop.table(table(DS$Group, DS$Variable, useNA = "no"), margin = c(1)) * 100, 2))
              X <- rownames(TABLE_SAMPLE)
              TABLE_SAMPLE <- cbind(X, TABLE_SAMPLE)
              colnames(TABLE_SAMPLE)[1] <- "Group"
              rownames(TABLE_SAMPLE) <- NULL
            } else {
              TABLE_SAMPLE <- DS %>%
                group_by(Group) %>%
                dplyr::summarize(
                  mean = mean(Variable, na.rm = TRUE),
                  lower = mean(Variable, na.rm = TRUE) - qnorm(1 - ALPHA / 2) * sd(Variable, na.rm = TRUE) / sqrt(n()),
                  upper = mean(Variable, na.rm = TRUE) + qnorm(1 - ALPHA / 2) * sd(Variable, na.rm = TRUE) / sqrt(n()),
                  max = max(Variable, na.rm = TRUE),
                  min = min(Variable, na.rm = TRUE),
                  iqr1 = quantile(Variable, probs = c(0.25), na.rm = TRUE),
                  iqr2 = quantile(Variable, probs = c(0.75), na.rm = TRUE)
                )
            }
            data <- list(toJSON(TABLE_SAMPLE, dataframe = "rows"))
            session$sendCustomMessage(type = "handler_analysis_sample", data)
            
            # Clean environment
            rm(OUTCOME, GROUP, DS,TABLE_SAMPLE)
            
          }
        },
        error = function(e) {
          # Log the error in the Server Log and the console (only seen by administrators)
          session$sendCustomMessage(type = "handler_logs", list(e$message, credentials()$info[1][[1]], "sample estimates"))
          message("Estimation error: ", e$message) # log to console
          # Notify the user
          output <- paste("Something went wrong: check your inputs.")
          showNotification(
            ui = output,
            duration = NULL,
            closeButton = TRUE,
            type = "error"
          )
        }
      )
    }
  ) # CALCULATE SAMPLE ESTIMATES (trigger: input$survey_sample_vars)

  observeEvent(
    req(input$survey_pop_vars),
    {
      tryCatch(
        {
          TARGET <- input$survey_pop_vars[1]
          OUTCOME <- input$survey_sample_vars[1]
          GROUP <- input$survey_sample_vars[2]
          DS <- session$userData$survey_responses[, c("TOWN", "REGION", "SUBURB")]

          if (GROUP == "NONE") {
            if (!is.null(DS)) {
              agemin <- as.numeric(input$targetagemin_strategy)
              agemax <- as.numeric(input$targetagemax_strategy)
              sex <- input$targetsex_strategy
              
              DP <- NULL
              if (TARGET == "surveylab") {
                try(DP <- subset(P, AGE >= agemin & AGE <= agemax & SEX %in% sex)[, c(OUTCOME,OUTCOME)], silent = FALSE)
              } else if (TARGET == "regions") {
                try(DP <- subset(P, AGE >= agemin & AGE <= agemax & SEX %in% sex & REGION %in% unique(DS$REGION))[, c(OUTCOME,OUTCOME)], silent = FALSE)
              } else if (TARGET == "towns") {
                try(DP <- subset(P, AGE >= agemin & AGE <= agemax & SEX %in% sex & TOWN %in% unique(DS$TOWN))[, c(OUTCOME,OUTCOME)], silent = FALSE)
              } else if (TARGET == "suburbs") {
                try(DP <- subset(P, AGE >= agemin & AGE <= agemax & SEX %in% sex & SUBURB %in% unique(DS$SUBURB))[, c(OUTCOME,OUTCOME)], silent = FALSE)
              }
              
              DP <- DP[complete.cases(DP), ]
              DP[,2] <- "Target population"
              
              colnames(DP) <- c("Variable", "Group")
              TABLE_POP <- NULL
              if (OUTCOME %in% CATEGORICAL) {
                TABLE_POP <- as.data.frame.matrix(round(prop.table(table(DP$Group, DP$Variable, useNA = "no"), margin = c(1)) * 100, 2))
                X <- rownames(TABLE_POP)
                TABLE_POP <- cbind(X, TABLE_POP)
                colnames(TABLE_POP)[1] <- "Group"
                rownames(TABLE_POP) <- NULL
              } else {
                try(TABLE_POP <- DP %>%
                      group_by(Group) %>%
                      dplyr::summarize(
                        mean = mean(Variable, na.rm = TRUE),
                        max = max(Variable, na.rm = TRUE),
                        min = min(Variable, na.rm = TRUE),
                        iqr1 = quantile(Variable, probs = c(0.25), na.rm = TRUE),
                        iqr2 = quantile(Variable, probs = c(0.75), na.rm = TRUE)
                      ), silent = TRUE)
              }
              
              data <- list(toJSON(TABLE_POP, dataframe = "rows"))
              session$sendCustomMessage(type = "handler_analysis_pop", data)
            }
          } else {
            if (!is.null(DS)) {
            agemin <- as.numeric(input$targetagemin_strategy)
            agemax <- as.numeric(input$targetagemax_strategy)
            sex <- input$targetsex_strategy
            
            DP <- NULL
            if (TARGET == "surveylab") {
              try(DP <- subset(P, AGE >= agemin & AGE <= agemax & SEX %in% sex)[, c(OUTCOME, GROUP)], silent = FALSE)
            } else if (TARGET == "regions") {
              try(DP <- subset(P, AGE >= agemin & AGE <= agemax & SEX %in% sex & REGION %in% unique(DS$REGION))[, c(OUTCOME, GROUP)], silent = FALSE)
            } else if (TARGET == "towns") {
              try(DP <- subset(P, AGE >= agemin & AGE <= agemax & SEX %in% sex & TOWN %in% unique(DS$TOWN))[, c(OUTCOME, GROUP)], silent = FALSE)
            } else if (TARGET == "suburbs") {
              try(DP <- subset(P, AGE >= agemin & AGE <= agemax & SEX %in% sex & SUBURB %in% unique(DS$SUBURB))[, c(OUTCOME, GROUP)], silent = FALSE)
            }

            DP <- DP[complete.cases(DP), ]
            colnames(DP) <- c("Variable", "Group")
            TABLE_POP <- NULL
            if (OUTCOME %in% CATEGORICAL) {
              TABLE_POP <- as.data.frame.matrix(round(prop.table(table(DP$Group, DP$Variable, useNA = "no"), margin = c(1)) * 100, 2))
              X <- rownames(TABLE_POP)
              TABLE_POP <- cbind(X, TABLE_POP)
              colnames(TABLE_POP)[1] <- ""
              rownames(TABLE_POP) <- NULL
            } else {
              try(TABLE_POP <- DP %>%
                group_by(Group) %>%
                dplyr::summarize(
                  mean = mean(Variable, na.rm = TRUE),
                  max = max(Variable, na.rm = TRUE),
                  min = min(Variable, na.rm = TRUE),
                  iqr1 = quantile(Variable, probs = c(0.25), na.rm = TRUE),
                  iqr2 = quantile(Variable, probs = c(0.75), na.rm = TRUE)
                ), silent = TRUE)
            }

            data <- list(toJSON(TABLE_POP, dataframe = "rows"))
            session$sendCustomMessage(type = "handler_analysis_pop", data)
            
            # Clean environment
            rm(TARGET, OUTCOME, GROUP, DP,TABLE_POP)
            
          }
          }  
      },
      error = function(e) {
        # Log the error in the Server Log and the console (only seen by administrators)
        session$sendCustomMessage(type = "handler_logs", list(e$message, credentials()$info[1][[1]],"population parameters"))
        message("Population parameters error: ", e$message) # log to console
        # Notify the user
        output <- paste("Something went wrong: notify the administrator.")
        showNotification(
          ui = output,
          duration = NULL,
          closeButton = TRUE,
          type = "error"
        )
      }
      )
    }
  ) # CALCULATE POPULATION PARAMETERS (trigger: input$survey_pop_vars)
  
  ##############################################################################################################################################################################
  # EXPORT RESULTS                                                                                                                                                             #
  ##############################################################################################################################################################################
  
  # DOWNLOAD RESULTS FILE

  output$downloadData <- downloadHandler(
    filename = function() {
      #paste("responses:", format(Sys.time(), format = "%F:%R"), ".csv", sep = "")
      paste("responses:", format(Sys.time(), format = "%F:%R"), ".xlsx", sep = "")
    },
    content = function(file) {
      #write.csv(session$userData$survey_responses, file)
      writexl::write_xlsx(list(Responses = session$userData$survey_responses, Codebook = session$userData$codebook), path = file)
    },
    contentType = "text/csv"
  )
  outputOptions(output, "downloadData", suspendWhenHidden = FALSE)

  # UPLOAD ESTIMATES TO SERVER

  observeEvent(input$estimates_share, {
    if (req(input$estimates_share[1]) == "-1") {
      dbExecute(SHAREDTABLEDB, "DELETE FROM shared_data_table;")
      data <- dbGetQuery(SHAREDTABLEDB, "SELECT * FROM shared_data_table")
      session$sendCustomMessage(type = "handler_shared_table", list(data, NPART))
    } else {
      IDS <- dbGetQuery(SHAREDTABLEDB, "SELECT N FROM shared_data_table")[[1]]
      rownum <- 0
      if (length(IDS) > 0) {
        rownum <- max(IDS)
      }
      new_row <- data.frame(
        N = rownum + 1, User = ifelse(AUTHENTICATE, credentials()$info[1][[1]], "User"), 
        Estimate = input$estimates_share[2], lb = input$estimates_share[3], ub = input$estimates_share[4], Notes = input$estimates_share[5],
        stringsAsFactors = FALSE
      )
      dbAppendTable(SHAREDTABLEDB,"shared_data_table",new_row)
    }
  })

  # VISUALISE ESTIMATES
  
  observeEvent(input$refresh_share_trigger, {
    data <- dbGetQuery(SHAREDTABLEDB, "SELECT * FROM shared_data_table")
    session$sendCustomMessage(type = "handler_shared_table", list(data, NPART))
  })
  
  # DELETE ESTIMATE
  
  observeEvent(input$delete_share, {
    numdel <- as.numeric(req(input$delete_share[1]))
    sql_query <- sprintf(
      "DELETE FROM shared_data_table WHERE N IN (%s);",
      paste(numdel, collapse = ", ")
    )
    dbExecute(SHAREDTABLEDB, sql_query)
    data <- dbGetQuery(SHAREDTABLEDB, "SELECT * FROM shared_data_table")
    session$sendCustomMessage(type = "handler_shared_table", list(data, NPART))
  })
  
  # UPLOAD DATA FILE TO SERVER

  observeEvent(input$results_share_trigger, {
    datafile <- req(session$userData$survey_responses)
    filename <- paste0(credentials()$info[1][[1]], "_", format(Sys.time(), format = "%Y_%m-%d_%H_%M_%S"),".RData")
    save(datafile, file = paste0("shared/",filename))
  })

  ##############################################################################################################################################################################
  # ADMIN USERS                                                                                                                                                                #
  ##############################################################################################################################################################################
  
  # UPDATE USERS TABLE
  
  observeEvent(input$userbase_updated_trigger, {
    user_base <- req(load_userbase(AUTHTYPE)) 
    user_base <- user_base %>% mutate(`#` = c(1:nrow(user_base)))
    session$sendCustomMessage(type = "handler_users_table", list(user_base[, c("#","user","name","permissions")]))
  })
  
  observeEvent(input$delete_users, {
    userdel <- req(input$delete_users)
    delete_userbase(userdel, auth = AUTHTYPE)
    user_base <- req(load_userbase(AUTHTYPE)) 
    user_base <- user_base %>% mutate(`#` = c(1:nrow(user_base)))
    session$sendCustomMessage(type = "handler_users_table", list(user_base[, c("#","user","name","permissions")]))
  })
  
  observeEvent(input$add_users, {
    adduser <- req(input$add_users)
    currentusers <- load_userbase(auth = AUTHTYPE)$user
    user <- adduser[1]

    if (!(user %in% currentusers)) {
      if (str_length(adduser[1]) >= 1 & adduser[1] != " " & str_length(adduser[2]) >= 1 & adduser[2] != " ") {
        add_userbase(user = user, name = adduser[2], permissions = user <- adduser[3], auth = AUTHTYPE)
        user_base <- req(load_userbase(AUTHTYPE))
        user_base <- user_base %>% mutate(`#` = c(1:nrow(user_base)))
        session$sendCustomMessage(type = "handler_users_table", list(user_base[, c("#", "user", "name", "permissions")]))
      } else {
        showNotification(
          ui = "Username & name cannot be empty.",
          duration = NULL,
          closeButton = TRUE,
          type = "error"
        )
      }
    } else {
      showNotification(
        ui = "Username not available.",
        duration = NULL,
        closeButton = TRUE,
        type = "error"
      )
    }
  })
  
  observeEvent(input$add_userbase, {
    adduser <- req(input$add_userbase)
    if (credentials()$info[3] == "admin" & input$add_userbase[2] == "TRUE") {
      selection <- input$add_userbase[1]
      file <- paste0("uploads/user_base_",selection,".RData")
      dataframe <- loadRData(file)
      new_userbase(dataframe, AUTHTYPE) 
      new <- load_userbase(AUTHTYPE) 
      new <- new %>% mutate(`#` = c(1:nrow(new)))
      session$sendCustomMessage(type = "handler_users_table", list(new[, c("#","user","name","permissions")]))
    }
  })
  
  # DOWNLOAD USERBASE 
  
  output$downloadUserbase <- downloadHandler(
    filename = function() {
      paste("userbase:", format(Sys.time(), format = "%F:%R"), ".RData", sep = "")
    },
    content = function(file) {
      currentuserbase <- load_userbase(auth = AUTHTYPE)
      save(currentuserbase, file = file)
    },
    contentType = "text/csv"
  )
  outputOptions(output, "downloadUserbase", suspendWhenHidden = FALSE)
  
  
  # When a new session starts, increase count
  isolate({
    active_users(active_users() + 1)
  })
  
  # When the session ends, decrease count
  session$onSessionEnded(function() {
    isolate({
      active_users(active_users() - 1)
    })
  })
  
  observeEvent(active_users(), {
    session$sendCustomMessage(type = "handler_users_current", list(active_users()))
  })
  
  ##############################################################################################################################################################################
  # PARAMETERS AND SETTINGS                                                                                                                                                    #
  ##############################################################################################################################################################################
  
  # CHANGE TO SETTINGS 
  
  observeEvent(input$update_settings, {
    data <- req(input$update_settings)
    
    uthrp <- as.numeric(data[c(2:4,6:8,10:12)])
    uthrp <- matrix(uthrp, nrow = 3, ncol = 3, byrow = TRUE)
    uthrp <- uthrp / rowSums(uthrp)
    HRR <<- round(uthrp,2)
    HRRDF <- t(cbind(wealth = c("I","II","III"),data.frame(HRR)))
    
    utirp <- as.numeric(data[c(14:22,24:32)])
    utirp <- pmax(0, pmin(1, utirp))
    utirp <- matrix(utirp, nrow = 2, ncol = 9, byrow = TRUE)
    IRR <<- round(utirp,2)
    IRRDF <- t(cbind(sex = c("Males","Females"),data.frame(IRR)))
    
    utrrp <- as.numeric(data[c(33:37)])
    RRR <<- round(utrrp,2)
    RRRDF <- t(data.frame(RRR))

    FATIG <<- max(1,round(as.numeric(data[38]),2))
    RGEN <<- data[39]
    
    session$sendCustomMessage("handler_settings_tables", list(HRRDF,IRRDF,RRRDF,FATIG,RGEN))
  })
  
  observeEvent(input$default_settings_trigger, {
    HRR <<- HRR_DEFAULT
    IRR <<- IRR_DEFAULT
    RRR <<- RRR_DEFAULT
    FATIG <<- FATIG_DEFAULT
    RGEN <<- RGEN_DEFAULT
    HRRDF <- t(cbind(wealth = c("I","II","III"),data.frame(HRR)))
    IRRDF <- t(cbind(sex = c("Males","Females"),data.frame(IRR)))
    RRRDF <- t(data.frame(RRR))

    session$sendCustomMessage("handler_settings_tables", list(HRRDF,IRRDF,RRRDF,FATIG,RGEN))
  })
  
  # TRANSFER GLOBAL PARAMETERS TO JAVASCRIPT CODE
  
  quest <- subset(Q, TYPE == "Q")  
  meas <- subset(Q, TYPE == "M") 
  items <- as.numeric(unlist(strsplit("",",")))
  NTOWNS <- nrow(TNAMES)
  EUPLOAD <- ENABLEUPLOAD
  parameters <- list(quest, meas, items, TQ, TM, TNAMES[order(TNAMES$Town_Code),], ITEMTIME, QQPROGRESS, QMPROGRESS, CATEGORICAL, CONTINUOUS, TCOLORS, NTOWNS, REGIONCOLORS,
                     REGIONCOLORS_ACCENT,QMSCALE,EUPLOAD)
  session$sendCustomMessage("handler_parameters_initialize", parameters)
  
  HRRDF <- t(cbind(wealth = c("I","II","III"),data.frame(HRR)))
  IRRDF <- t(cbind(sex = c("Males","Females"),data.frame(IRR)))
  RRRDF <- t(data.frame(RRR))

  session$sendCustomMessage("handler_settings_tables", list(HRRDF,IRRDF,RRRDF,FATIG,RGEN))

  # SERVICE VARIABLES
  
  refreshMenuStatus <- reactiveVal(0)
  
  ##############################################################################################################################################################################
  # FUNCTIONS                                                                                                                                                                  #
  ##############################################################################################################################################################################

  # HOUSEHOLD RESPONSE
  hrr <- function(wealth) {
    index = try(which(rmultinom(1, 1, HRR[wealth, ]) == 1), silent = TRUE) 
    if (is(index,"try-error")) {
      index <- 3
    }
    return(c("Consent", "Refusal", "Absent")[index])
  }
  vhrr <- Vectorize(hrr)
  
  # INDIVIDUAL RESPONSE
  irr <- function(agecat, sex, region) {
    index = try(rbinom(1, 1, IRR[sex, agecat]*RRR[region]) + 1, silent = TRUE) 
    if (is(index,"try-error")) {
      index <- 1
    }
    return(c("Refusal", "Consent")[index])
  }
  virr <- Vectorize(irr)
  
  
  # ITEM RESPONSE
  itrr <- function(type, i) {
    index = try(rbinom(1, 1, TRR[ifelse(type == "M", 1, 2)] * FATIG^(-floor(i / 10))) + 1, silent = TRUE)
    if (is(index,"try-error")) {
      index <- 1
    }
    return(c(FALSE, TRUE)[index])
  }
  vitrr <- Vectorize(itrr)
  
  ##############################################################################################################################################################################
  # POPUP MANAGEMENT                                                                                                                                                           #
  ##############################################################################################################################################################################

  observe({  
    input$regionstats
    data <- subset(E, Region_Name == input$regionstats & Suburb_Name == "All")[, c(
      "Region_Code", "Region_Name", "Town_Name", "Capital", "Eoffice", "Mclinic", "Hospital", "Population", "Mean_Wealth", "Gini_Wndex"
    )]
    rstats <- subset(data, Town_Name == "All")[, c(
      "Region_Code", "Region_Name", "Capital", "Eoffice", "Mclinic", "Hospital", "Population", "Mean_Wealth", "Gini_Wndex"
    )]
    
    tstats <- subset(data, Town_Name != "All")[, c("Town_Name", "Population", "Capital")]
    tstats$Fraction <- round(tstats$Population / sum(tstats$Population) * 100, 1)
    rstats$Capital <- subset(tstats, Capital == "TRUE")$Town_Name
    tstats$Capital <- NULL
    colnames(tstats)[1] <- "Town"
    data <- list(rstats, toJSON(tstats, dataframe="rows"))
    session$sendCustomMessage(type = "handler_popup_region", data)
  }) # REGIONAL STATISTICS  

  observe({ 
    input$townstats
    data <- subset(E, Town_Code == input$townstats)[, c(1:3, 6:25)]
    tstats <- data[data$Suburb_Name == "All", c(
      "Town_Name", "Capital", "Moffice", "Eoffice", "Mclinic", "Hospital", "Altitude", "Mine_lead", "Mine_gold", "Powerstation_coal", "Mean_Wealth",
      "Gini_Wndex", "Population", "Households"
    )]
    tstats[, "Capital"] <- ifelse(tstats[, "Capital"], "Yes", "No")
    substats <- data[data$Suburb_Name != "All", c("Suburb_Name", "Mean_Wealth", "Gini_Wndex", "Population", "Households")]
    colnames(substats) <- c("Suburb", "Average wealth", "Gini Index", "Population", "Households")
    data <- list(tstats, toJSON(substats, dataframe="rows"))
    session$sendCustomMessage(type = "handler_popup_moffice", data)
  }) # MUNICIPAL OFFICES STATISTICS   

  observe({  
    input$envirstats
    data <- subset(E, Region_Name == input$envirstats & Suburb_Name == "All")[, c(
      "Region_Name", "Town_Name", "Altitude", "Temp_avg", "Temp_max", "Temp_min", "Rain_avg", "PM25"
    )]
    rstats <- subset(data, Town_Name == "All")
    tstats <- subset(data, Town_Name != "All")
    tstats <- tstats[, 2:ncol(tstats)]  
    colnames(tstats) <- c("Town", "Altitude", "Average temp", "Max temp", "Min temp", "Rainfall", "PM25")
    data <- list(rstats, toJSON(tstats, dataframe="rows"))
    session$sendCustomMessage(type = "handler_popup_eoffice", data)
  }) # ENVIRONMENTAL OFFICES   

  observe({   
    input$hospstats
    if (!is.null(input$hospstats)) {
      data <- subset(H, Plabel == input$hospstats)[, c(
        "Facility_NAme", "Beds", "Headcount", "Doctors", "Nurses",
        "SER_1", "SER_2", "SER_3", "SER_4", "SER_5", "SER_6", "SER_7", "SER_8", "SER_9"
      )]
      for (i in c(6:14)) {
        data[, i] <- ifelse(data[, i] == 1, "<span class = 'defcol'>Offered</span>", "Not offered")
      }
      session$sendCustomMessage(type = "handler_popup_hospital", data)
    }
  }) # HOSPITAL STATISTICS
 
  observe({  
    input$clinstats
    if (!is.null(input$clinstats)) {
      data <- subset(H, Plabel == input$clinstats)[, c(
        "Facility_NAme", "Beds", "Headcount", "Doctors", "Nurses",
        "SER_1", "SER_2", "SER_3", "SER_4", "SER_5", "SER_6", "SER_7", "SER_8", "SER_9"
      )]
      for (i in c(6:14)) {
        data[, i] <- ifelse(data[, i] == 1, "<span class = 'defcol'>Offered</span>", "Not offered")
      }
      session$sendCustomMessage(type = "handler_popup_clinic", data)
    }
  }) # CLINICS STATISTICS 

}
  