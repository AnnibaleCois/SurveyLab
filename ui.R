################################################################################################################################################################################
# SurveyLab - A virtual environment for learning survey methods                                                                                                                #
# Version 4                                                                                                                                                                    #
# Author: Annibale Cois (AnnibaleCois@gmail.com)                                                                                                                               #
# Created: 04/2025                                                                                                                                                             #  
#                                                                                                                                                                              # 
# User Interface                                                                                                                                                               #
#                                                                                                                                                                              #  
################################################################################################################################################################################

ui <- dashboardPage(  
  skin = "black",
  title = "SurveyLab",
  options = list(sidebarExpandOnHover = FALSE),

  ##############################################################################################################################################################################
  # HEADER                                                                                                                                                                     #
  ##############################################################################################################################################################################
    
  header = dashboardHeader(
      fixed = TRUE,
      title = h2(id = "m_logo", HTML("<a href='#' onclick='window.location.reload();'><span style = 'color:#FFFFFF;'>Survey</span><span style = 'color:#F05222; font-style: italic;'>Lab</span> </a>"),
      height = 40, style = "color: #FFFFFF;"),
      titleWidth = 230,
      disable = FALSE,
      tags$li(style = "text-align:left; position:absolute; left: 50px; top:-12px;", div(h2(""), height = 40), class = "dropdown"),
      tags$li(
        dropdownButton(
          br(),
          div(style = "text-align: center;",
              HTML("<h2>Survey<span style = 'color:#F05222; font-style: italic;'>Lab</span></h2>"),
              p("Cheatsheet")
          ),
          br(),
          notificationItem(text = tags$div("Explore the environment.", tags$br()), icon = icon("binoculars", class = "icostyle_menu")),
          notificationItem(text = tags$div("Design the data collection tool.",tags$br(), style = "text-align:justify;"), icon = icon("object-group", class = "icostyle_menu")),
          notificationItem(text = tags$div("Define the sampling strategy.",tags$br(), style = "text-align:justify;"), icon = icon("brain", class = "icostyle_menu")),
          notificationItem(text = tags$div("Select a sample.",tags$br(), style = "text-align:justify;"),icon = icon("magnifying-glass", class = "icostyle_menu")),
          notificationItem(text = tags$div("Estimate the achievable power.",tags$br(), style = "text-align:justify;"),icon = icon("crosshairs", class = "icostyle_menu")),
          notificationItem(text = tags$div("Collect the data from the population.",tags$br(), style = "text-align:justify;"),icon = icon("magnifying-glass-location", class = "icostyle_menu")),          
          notificationItem(text = tags$div("Analyse the data.",tags$br(), style = "text-align:justify;"), icon = icon("chart-simple", class = "icostyle_menu")),             
          #notificationItem(text = tags$div("One-o-One interviews.",tags$br(), style = "text-align:justify;"),icon = icon("user", class = "icostyle_menu", style = "color: grey;")),
          #notificationItem(text = tags$div("Modify item list.",tags$br(), style = "text-align:justify;"),icon = icon("clipboard-question", class = "icostyle_menu", style = "color: grey;")),          
          notificationItem(text = tags$div("Share estimates.",tags$br(), style = "text-align:justify;"), icon = icon("share", class = "icostyle_menu")),      
          br(),          
          notificationItem(text = tags$div("Modify settings (administrators only).",tags$br(), style = "text-align:justify;"),icon = icon("tasks", class = "chart-simple")),          
          notificationItem(text = tags$div("Manage users (administrators only).",tags$br(), style = "text-align:justify;"), icon = icon("user-times", class = "chart-simple")),             
          notificationItem(text = tags$div("Visualise shared estimates (administrators only).",tags$br(), style = "text-align:justify;"), icon = icon("eye", class = "chart-simple")),  
          notificationItem(text = tags$div("Visualise system logs (administrators only).",tags$br(), style = "text-align:justify;"), icon = icon("code", class = "chart-simple")),  
          br(),
          tags$li(
            p("Use the menu on the left to navigate the SurveyLab and conduct your virtual surveys. Don't use the browser's commands", span("<--", style = "font-weight: bold; color:F05222"), " and ", span("-->", style = "font-weight: bold; color:F05222"), ": this will reset your survey and you will need to login again!", style = "margin:14px; text-align: justify;"),
            p("", style = "margin:14px; text-align: justify;"),
            p("Click in the icon", span(icon("user", style = "font-weight: bold; color:F05222")), "on the top left to change you password and logout from the SurveyLab.", style = "margin:14px; text-align: justify;"),
            p("", style = "margin:14px; text-align: justify;"),
            p("You can download the SurbveyLab manual from here: ", downloadLink("downloadManual", span(icon("book", style = "font-weight: bold; color:F05222"))), ".", style = "margin:14px; text-align: justify;")
          ),
          circle = FALSE,
          status = "dropdownbutton",
          size = "sm",
          icon = NULL,
          label = "Help",
          tooltip = FALSE,
          right = TRUE,
          up = FALSE,
          width = "400px",
          margin = "10px",
          inline = FALSE,
          inputId = NULL
        ),
        class = "dropdown",
        style = "border: none; margin-top: 12px; font-size: 50%;"
      ),
      tags$li(
          dropdownButton(
            tags$li(
              br(),
              div(style = "text-align: center;",
                  HTML("<div style = 'filter: drop-shadow(5px 5px 10px rgba(0, 0, 0, 0.5));'><img src = 'img/logo.svg' height ='100' /></div>"),
                  HTML("<h2>Survey<span style = 'color:#F05222; font-style: italic;'>Lab</span></h2>"),
                  p("A virtual environment for learning survey methods")
              ),
              br(),
              p(strong("Version: "), RELEASE_VE, style = "margin-left:14px; margin-bottom:0;"), 
              p(strong("Release: "), paste(RELEASE_NO, " (", RELEASE_DATE, ")", sep = ""), style = "margin-left:14px; margin-bottom:0;"), 
              p(strong("Data version: "), paste(substr(DATAVERSION,2,2), substr(DATAVERSION,4,4), sep = "."), style = "margin-left:14px; margin-bottom:0;"), 
              br(),
              HTML(paste0("<p style = 'margin-left:14px; margin-bottom: 4px;'><i class='fa-regular fa-copyright'></i> 2021-", format(Sys.time(), '%Y'), " Annibale Cois, 
                          <a href = 'mailto:annibale.cois@mrc.ac.za')>annibale.cois@mrc.ac.za</a></p>")),
              HTML(paste0("<p style = 'margin-left:14px; margin-bottom: 4px;'><i class='fa-regular fa-circle-user defcol'></i> Web: <a href = 'https://annibalecois.github.io/')>https://annibalecois.github.io/</a></p>")),
              HTML(paste0("<p style = 'margin-left:14px; margin-bottom: 20px;'><i class='fa-solid fa-code defcol'></i> Source code: <a href = 'https://github.com/AnnibaleCois/SurveyLab')>https://github.com/AnnibaleCois/SurveyLab</a></p>")),
            ),
            circle = FALSE,
            status = "dropdownbutton",
            size = "sm",
            icon = NULL,
            label = "About",
            tooltip = FALSE,
            right = TRUE,
            up = FALSE,
            width = "400px",
            margin = "10px",
            inline = FALSE,
            inputId = NULL
          ),
        class = "dropdown",
        style = "border: none; margin-top: 12px; font-size: 50%;"
      ),
      tags$li(
        tags$div(
        dropdownButton(
          tags$li(
            actionLink("lout", label = " LOGOUT", icon = icon("user-times", style = "margin-right: 5px;"), class = "logout")
          ),
          tags$li(
            actionLink("pwchange", label = "CHANGE PASSWORD", icon = icon("key", style = "margin-right: 5px;"), class = "logout")
          ),
          circle = FALSE,
          status = "dropdownbutton",
          size = "sm",
          icon = icon("user"),
          label = "",
          tooltip = FALSE,
          right = TRUE,
          up = FALSE,
          width = "400px",
          margin = "10px",
          inline = FALSE,
          inputId = NULL
        ),
        class = "invisible",
        id = "account"),
        class = "dropdown",
        style = "border: none; margin-top: 12px; font-size: 50%;"
      ),
      tags$li(
          p(" "),
          style = "padding: 20px;",
          class = "dropdown"
      )
      
    ),     
   
  ##############################################################################################################################################################################
  # SIDEBAR                                                                                                                                                                    #
  ##############################################################################################################################################################################
    
    sidebar = dashboardSidebar(
      useShinyjs(),
      tags$style("#sidebarItemExpanded {overflow: hidden auto; max-height: 100vh;}"),
      tags$style(".dropdown-menu {max-height: 500px; overflow-y: auto;}"),
      minified = TRUE, 
      collapsed = TRUE,    
      width = 230,    
      id = "sidebar",
      introBox(
        br(),
        sidebarMenu(id = "SIDEMENU", 

                    hidden(menuItem("SPLASH", tabName = "splash")),
                    
                    h4(id = "m_survey", style = "margin-left: 10px; margin-top: 15px; font-weight:bold;", class = "sidetext","SURVEY"),
                    menuItem("EXPLORE", tabName = "explore", icon = icon("binoculars", style = "margin-right: 5px;")),
                    menuItem("TOOL", tabName = "design", icon = icon("object-group", style = "margin-right: 5px;")),
                    menuItem("STRATEGY", tabName = "strategy", icon = icon("brain", style = "margin-right: 5px;")),
                    menuItem("SAMPLING", tabName = "sample", icon = icon("magnifying-glass", style = "margin-right: 5px;")),
                    menuItem("POWER ANALYSIS", tabName = "power", icon = icon("crosshairs", style = "margin-right: 5px;")),  
                    menuItem("SURVEY", tabName = "survey",icon = icon("magnifying-glass-location",  style = "margin-right: 5px; margin-right: 5px;")),
                    menuItem("ANALYSIS", tabName = "analysis",icon = icon("chart-simple",  style = "margin-right: 5px; margin-right: 5px;")),
                    
                    #h4(id = "m_deep", style = "margin-left: 10px; margin-top: 15px; font-weight:bold;", class = "sidetext","IN DEEP"), 
                    #menuItem("INTERVIEWS", tabName = "interviews", icon = icon("user", style = "margin-right: 5px;")),
                    #menuItem("ITEMS", tabName = "custitems", icon = icon("clipboard-question", style = "margin-right: 5px;")),

                    h4(id = "m_share", style = "margin-left: 10px; margin-top: 15px; font-weight:bold;", class = "sidetext","SHARE"), 
                    menuItem("SHARE", tabName = "upload", icon = icon("share", style = "margin-right: 5px;")),
                    
                    h4(id = "m_settings", style = "margin-left: 10px; font-weight:bold;", class = "sidetext","SYSTEM"),
                    menuItem("SETTINGS", tabName = "settings", icon = icon("tasks", style = "margin-right: 5px;")),                    

                    h4(id = "m_admin", style = "margin-left: 10px; font-weight:bold;", class = "sidetext", "ADMIN"),  # ONLY IF PERMISSION = ADMIN 
                    menuItem("USERS", tabName = "users", icon = icon("user-times",  style = "margin-right: 5px;")),
                    menuItem("VISUALISE", tabName = "visualise", icon = icon("eye",  style = "margin-right: 5px;")),   
                    menuItem("LOGS", tabName = "logs", icon = icon("code",  style = "margin-right: 5px;")),   
                    
                    hidden(menuItem("A", tabName = "statusvars", icon = icon("tasks", style = "margin-right: 5px;"),
                             textInput(inputId = "tab_change_trigger",label = "", value = "splash,0"),      
                            
                             numericInput(inputId = "currentTown_explore",label = "", value = 0),
                             numericInput(inputId = "currentTown_sample",label = "", value = 1),
                             textInput(inputId = "currentHousehold",label = "", value = ""),

                             textInput(inputId = "sam_currentSample_tlist",label = "", value = ""),
                             textInput(inputId = "sam_currentSample_hlist",label = "", value = ""),
                             textInput(inputId = "sam_currentSample_ilist",label = "", value = ""),
                             
                             textInput(inputId = "tool_items",label = "", value = ""),
                             numericInput(inputId = "tool_qnum",label = "", value = 0),
                             numericInput(inputId = "tool_mnum",label = "", value = 0),
                             
                             textInput(inputId = "survey_sample_vars",label = "", value = ""),
                             textInput(inputId = "survey_pop_vars",label = "", value = ""),
                             textInput(inputId = "survey_collected",label = "", value = ""),
                             numericInput(inputId = "survey_cost_trigger",label = "", value = 0),
                             textInput(inputId = "survey_collect_trigger",label = "", value = ""),
                             numericInput(inputId = "survey_download_trigger",label = "", value = 0),
                             numericInput(inputId = "survey_upload_trigger",label = "", value = 0),
                             numericInput(inputId = "survey_varlist_trigger",label = "", value = 0),
                             
                             textInput(inputId = "estimates_share",label = "", value = ""),
                             textInput(inputId = "delete_share",label = "", value = ""),
                             numericInput(inputId = "refresh_share_trigger",label = "", value = 0),
                             numericInput(inputId = "results_share_trigger",label = "", value = 0),
                             
                             textInput(inputId = "strategy_strategy",label = "", value = ""),
                             numericInput(inputId = "targetagemin_strategy",label = "", value = 0),
                             numericInput(inputId = "targetagemax_strategy",label = "", value = 0),
                             textInput(inputId = "targetsex_strategy",label = "", value = "0"),                             
                             numericInput(inputId = "strategy_sample",label = "", value = 0),
                             textInput(inputId = "power_calc",label = "", value = ""),
                             
                             textInput(inputId = "regionstats",label = "", value = ""),
                             textInput(inputId = "envirstats",label = "", value = ""),
                             textInput(inputId = "townstats",label = "", value = ""),
                             textInput(inputId = "hospstats",label = "", value = ""),
                             textInput(inputId = "clinstats",label = "", value = ""),
                             
                             numericInput(inputId = "userbase_updated_trigger",label = "", value = 0),
                             textInput(inputId = "delete_users",label = "", value = ""),
                             textInput(inputId = "add_users",label = "", value = ""),
                             textInput(inputId = "add_userbase",label = "", value = ""),
                             
                             textInput(inputId = "update_settings",label = "", value = ""),
                             numericInput(inputId = "default_settings_trigger",label = "", value = 0)
                    ))
            )
      )
      #
      # HTML(paste0("<div id = 'm_credits' style = 'color: #FFFFFF; position: fixed; bottom: 0px; left: 0px; height: 50px; width: 210px; background: #222D32;'>",
      #             "<br/><a href = 'mailto:annibalecois@gmail.com' style = 'margin-left: 10px; margin-top: 8px;')><i class='fa-regular fa-copyright'></i> 2021-",format(Sys.time(), "%Y"), 
      #             " Annibale Cois<a href = ''></a></div>"))
      
      ),
    
  ##############################################################################################################################################################################
  # BODY                                                                                                                                                                       #
  ##############################################################################################################################################################################
    
    body = dashboardBody(
      tags$head(
        tags$style(HTML('.main-header .sidebar-toggle .sidebar-mini')),
        tags$link(rel = "icon", href = "img/favicon.png"),
        tags$link(rel = "stylesheet", type = "text/css", href = "https://use.fontawesome.com/releases/v5.11.2/css/all.css"),
        tags$link(rel = "stylesheet", type = "text/css", href = "https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap"),
        tags$link(rel="stylesheet", href="css/jquerysctipttop.css"),
        tags$link(rel="stylesheet", href="css/normalize.css?v=1.0"),
        tags$link(rel="stylesheet", href="css/bpopup.min.css"),
        tags$link(rel="stylesheet", href="css/tabulator_surveylab.min.css"),
        tags$link(rel="stylesheet", href="css/gspinner.css"),
        tags$link(rel = "stylesheet", type = "text/css", href = "css/surveylab.css"),  # Custom css
        tags$script(type="text/javascript", src="js/svg-inject.min.js"),               # Load library for map injection
        tags$script("SVGInject.setOptions({makeIdsUnique: false, 
                                          useCache: false, 
                                          afterInject: function(img, svg) {
                                            if (typeof town !== 'undefined') { 
                                              sam_currentSample_hlist[town].forEach(function(household) {
                                                x1 = document.getElementById(household);
                                                x1.style.fill = '#000000';
                                                x1.style.stroke = '#000000';
                                              }
                                              )
                                            }
                                          }})"),                                       # Set injection library options
        uiOutput('style_tag'),                                                         # Set background colors and manage duplicated IDs in towns
        includeHTML("www/help/help_splash.html")                                       # Help popup in splash screen
      ),
      useShinyjs(),
      introjsUI(),
      splashscreen(
        loader =
            div(class = "text-white",
              HTML("<div style = 'filter: drop-shadow(5px 5px 10px rgba(0, 0, 0, 0.7)); margin-bottom: -80px;'><img src = 'img/logo.svg' height = '250'; width = '250';/></div>"),
              h1(class = "mb-3", HTML("Survey<span class = 'lab'>Lab</span>"), style = "font-size: 800%;"),
                h5(class = "mb-4", "A virtual environment for learning survey methods", style = "font-size: 300%;"),
                br(),
                actionLink(inputId = "start", label = "LOGIN", class = "btn btn-outline-light btn-lg m-2", style = "font-size: 200%; color: white;"),
                a(class = "btn btn-outline-light btn-lg m-2", onclick = "$('#helppopup').bPopup();", style = "font-size: 200%; color: white;", role = "button", "WHAT IS THIS?")
              ), 
        text = "",
        mode = "timeout",
        timeout = TIMEOUT,
        color = "#FFFFFF",
        background = "#FFFFFF",
        image = "img/splash_dark.png"
      ),
      
      if (AUTHENTICATE) {shinyauthr::loginUI("login", 
                            title = HTML(paste0(
                            "<h3 class = 'text-center' style = 'font-weight: bold;'>",
                            " Survey<span style = 'color:#F05222; font-style:italic;'>Lab</span> 4</h3><h5 class = 'text-center' style = 'font-weight: bold;'>Release ", 
                            RELEASE_NO," (", RELEASE_DATE, ")</h5><br/>")),
                            additional_ui = tagList(
                            tags$div("", actionLink("homepage", "Cancel"), style = "text-align: left; margin-top: 15px;")
                            )
      )
      },
  
      tabItems(
        tabItem(tabName = "splash"),
        tabItem(tabName = "explore", htmlTemplate("www/templates/explore.html")),
        tabItem(tabName = "design", htmlTemplate("www/templates/design.html")),
        tabItem(tabName = "sample", htmlTemplate("www/templates/sample.html")),
        tabItem(tabName = "survey", htmlTemplate("www/templates/survey.html")),
        tabItem(tabName = "strategy", htmlTemplate("www/templates/strategy.html")),
        tabItem(tabName = "power", htmlTemplate("www/templates/power.html")),
        tabItem(tabName = "analysis", htmlTemplate("www/templates/analyse.html")),
        tabItem(tabName = "upload", htmlTemplate("www/templates/upload.html")),
        tabItem(tabName = "visualise", htmlTemplate("www/templates/share.html")),
        tabItem(tabName = "users", htmlTemplate("www/templates/users.html")),
        tabItem(tabName = "settings", htmlTemplate("www/templates/settings.html")),
        tabItem(tabName = "logs", htmlTemplate("www/templates/logs.html"))
      ),
      
      downloadButton("downloadData", label = "", style = "display:none;"),          # Invisible button for data download
      downloadButton("downloadUserbase", label = "", style = "display:none;"),    # Invisible button for userbase download
      
      tags$script(type="text/javascript", src="js/jquery.bpopup-0.11.0.min.js"),    # Popup management library
      tags$script(type="text/javascript", src="js/panzoom.js"),                     # Panzoom library
      tags$script(type="text/javascript", src="js/panzoom_settings_1.js"),          # Panzoom library settings    
      tags$script(type="text/javascript", src="js/jquery-ui.min.js"),               # Design tool management   
      tags$script(type="text/javascript", src="js/chart.js"),                       # Charts  
      tags$script(type="text/javascript", src="js/tabulator.js"),                   # Tables  
      tags$script(type="text/javascript", src="js/g-spinner.js"),                   # Spinner
      
      # Custom scripts
      
      tags$script(TOWNSELECT_EXPLORE),                                               # Initialize town selector in explore tab
      tags$script(TOWNSELECT_SAMPLE),                                                # Initialize town selector in sample tab
      tags$script(type="text/javascript", src="js/ui_global.js"),                    # Initialize global javascript variables
      tags$script(type="text/javascript", src="js/ui_sample.js"),
      tags$script(type="text/javascript", src="js/ui_explore.js"),
      tags$script(type="text/javascript", src="js/ui_design.js"),
      tags$script(type="text/javascript", src="js/ui_survey.js"),
      tags$script(type="text/javascript", src="js/ui_analysis.js"),
      tags$script(type="text/javascript", src="js/ui_strategy.js"),
      tags$script(type="text/javascript", src="js/ui_power.js"),
      tags$script(type="text/javascript", src="js/ui_share.js"),
      tags$script(type="text/javascript", src="js/ui_users.js"),
      tags$script(type="text/javascript", src="js/ui_settings.js"),
      tags$script(type="text/javascript", src="js/ui_logs.js"),
      tags$script(type="text/javascript", src="js/ui_help.js")                      # Load help sections ine each tab
    )
)
