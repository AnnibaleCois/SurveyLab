################################################################################################################################################################################
# SurveyLab - A virtual environment for learning survey methods                                                                                                                #
# Version 4                                                                                                                                                                    #
# Author: Annibale Cois (AnnibaleCois@gmail.com)                                                                                                                               #
# Created: 04/2025                                                                                                                                                             #  
#                                                                                                                                                                              # 
# Database connections                                                                                                                                                         #
#                                                                                                                                                                              #  
################################################################################################################################################################################

  # CLOUD DATABASE URL

TURSODB <- "https://userbase-annibalecois.aws-eu-west-1.turso.io/v2/pipeline"

################################################################################################################################################################################
# SUPPORT FUNCTIONS                                                                                                                                                            # 
################################################################################################################################################################################

build_insert_statements <- function(df, table_name) { # convert a dataframe to a SQL INSERT statement
  cols <- names(df)
  values_list <- apply(df, 1, function(row) {
    vals <- sapply(row, function(x) {
      if (is.numeric(x)) x else sprintf("'%s'", x)
    })
    paste0("(", paste(vals, collapse = ", "), ")")
  })
  
  paste0(
    "INSERT INTO ", table_name, " (", paste(cols, collapse = ", "), ") VALUES ",
    paste(values_list, collapse = ", "), ";"
  )
}

tursoExecute<- function(TURSODB,sql_query) { # execute a sql query on TURSO (and closes the connections)
  requests <- list(
    list(type = "execute", stmt = list(sql = sql_query)),
    list(type = "close")
  )
  body <- list(requests = requests)
  resp <- request(TURSODB) %>%
    req_method("POST") %>%
    req_headers(
      Authorization = paste("Bearer", Sys.getenv("DBTOKEN")),
      `Content-Type` = "application/json"
    ) %>%
    req_body_json(body) %>%
    req_perform() %>%
    resp_body_json(simplifyVector = FALSE)
  
  execute_entry <- NULL
  for (r in resp$results) {
    if (!is.null(r$response$type) && r$response$type == "execute") {
      execute_entry <- r$response$result
      break
    }
  }
  df <- convert_df(execute_entry)
  return(df)
}

convert_df <- function(execute_result) { # convert turso execute result into a data.frame
  # execute_result should be the "result" object with cols & rows
  cols <- vapply(execute_result$cols, `[[`, "", "name")
  rows <- execute_result$rows
  if (length(cols) == 0 || length(rows) == 0) {
    # return empty df with columns if available
    return(setNames(data.frame(matrix(nrow = 0, ncol = length(cols))),
                    cols))
  }
  # rows are arrays of strings; convert to data.frame
  df <- as.data.frame(do.call(rbind, lapply(rows, function(r) {
    # convert each value to NA if null string marker is used (depends on response)
    sapply(r, function(x) if (is.null(x)) NA_character_ else as.character(x))
  })), stringsAsFactors = FALSE)
  names(df) <- cols
  # elimninate spurious rows 
  df <- subset(df, user != "text")
  return(df)
}

################################################################################################################################################################################
# CONNECT FUNCTIONS                                                                                                                                                            # 
# PRESENT A UNIFORM INTERFACE BUT USE DIFFERENT BACKENDS (LOCAL R FILE, LOCAL SQL-LITE DATABASE, TURSO CLOUD DATABASE) DEPENDING ON THE AUTH PARAMETER                         #
################################################################################################################################################################################

load_userbase <- function(auth) { # LOAD USER BASE
  if (auth == "test") {
    user_base <- loadRData("users/user_base_test.RData")
  } else if (auth == "dbase") {
    sql_query <- "SELECT * FROM users;"
    USERDB <- dbConnect(RSQLite::SQLite(), "users/user_data.sqlite")
    user_base <- dbGetQuery(USERDB, "SELECT * FROM users;")
    dbDisconnect(USERDB)    
  } else if (auth == "cloud") {
    sql_query <- "SELECT * FROM users;"
    user_base <- tursoExecute(TURSODB,sql_query)
  }
  return(user_base)  
}

update_userbase <- function(user, password_hash, auth) { # CHANGE PASSWORS FOR USER user  
  if (auth == "test") {
    user_base <- loadRData("data/user_base.RData")
    user_base[user_base$user == user,]$password_hash <- password_hash
    save(user_base, file = "data/user_base.RData") 
    user_base <- NULL
  } else if (auth == "dbase") {
    USERDB <- dbConnect(RSQLite::SQLite(), "users/user_data.sqlite")
    sql_query <- paste0("UPDATE users SET password_hash = '", password_hash ,"' WHERE user = '", user, "';")
    dbExecute(USERDB, sql_query)
    dbDisconnect(USERDB)
  } else if (auth == "cloud") {
    sql_query <- paste0("UPDATE users SET password_hash = '", password_hash ,"' WHERE user = '", user, "';")
    nrecords <- tursoExecute(TURSODB,sql_query)
  }
}

delete_userbase <- function(users, auth) { # DELETE USER user
  if (auth == "test") {
    user_base <- loadRData("data/user_base.RData")
    user_base <- subset(user_base, !(user %in% users)) 
    save(user_base, file = "data/user_base.RData") 
    user_base <- NULL
  } else if (auth == "dbase") {
    USERDB <- dbConnect(RSQLite::SQLite(), "users/user_data.sqlite")
    quoted_users <- paste0("'", users, "'")
    sql_query <- sprintf(
      "DELETE FROM users WHERE user IN (%s);",
      paste(quoted_users, collapse = ", ")
    )
    dbExecute(USERDB, sql_query)
    dbDisconnect(USERDB)
  } else if (auth == "cloud") {
    quoted_users <- paste0("'", users, "'")
    sql_query <- sprintf(
      "DELETE FROM users WHERE user IN (%s);",
      paste(quoted_users, collapse = ", ")
    )
    nrecords <- tursoExecute(TURSODB,sql_query)
  }
}

add_userbase <- function(user, name, permissions, auth) { # ADD NEW USER with username = user, name = name, permission = permission, password = 12345, seed = random
  newrow <- data.frame(
      user = character(1), 
      password_hash = character(1), 
      permissions = character(1), 
      name = character(1), 
      recdate = character(1), 
      orgname = character(1), 
      orgtype = character(1), 
      email = character(1), 
      lastaccess = character(1), 
      seed = numeric(1),
      stringsAsFactors = FALSE
    )
    newrow[1,]$user <- user
    newrow[1,]$name <- name
    newrow[1,]$permissions <- permissions
    newrow[1,]$seed <- round(runif(1,1,999),0)
    newrow[1,]$password_hash <- sodium::password_store("12345")
  
  if (auth == "test") {
    user_base <- loadRData("data/user_base.RData")
    user_base <- rbind(user_base,newrow)
    save(user_base, file = "data/user_base.RData") 
    user_base <- NULL
  } else if (auth == "dbase") {
    USERDB <- dbConnect(RSQLite::SQLite(), "users/user_data.sqlite")
    dbWriteTable(USERDB, "users", newrow, append = TRUE)
    dbDisconnect(USERDB)
  } else if (auth == "cloud") {
    sql_query <- build_insert_statements(newrow, "users")
    nrecords <- tursoExecute(TURSODB,sql_query)
  }
}

new_userbase <- function(new_userbase, auth) { # UPLOAD A NEW USER DATABASE (passed as a R datafile) REPLACING THE CURRENT ONE
  if (auth == "test") {
    save(new_userbase, file = "data/user_base.RData") 
  } else if (auth == "dbase") {
    USERDB <- dbConnect(RSQLite::SQLite(), "users/user_data.sqlite")
    dbWriteTable(USERDB, "users", new_userbase, overwrite = TRUE)
    dbDisconnect(USERDB)
  } else if (auth == "cloud") {
    sql_query <- "DELETE FROM users;"
    nrecords <- tursoExecute(TURSODB,sql_query)
    sql_query <- build_insert_statements(new_userbase, "users")
    nrecords <- tursoExecute(TURSODB,sql_query)
  }
}  
