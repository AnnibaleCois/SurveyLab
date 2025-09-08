################################################################################################################################################################################
# SurveyLab - A virtual environment for learning survey methods                                                                                                                #
# Version 4                                                                                                                                                                    #
# Author: Annibale Cois (AnnibaleCois@gmail.com)                                                                                                                               #
# Created: 04/2025                                                                                                                                                             #
#                                                                                                                                                                              #
# Utilities for Turso database                                                                                                                                                 #
#                                                                                                                                                                              #
################################################################################################################################################################################

# EXECUTE SQL QUERY ON TURSO

TURSODB <- "https://userbase-annibalecois.aws-eu-west-1.turso.io/v2/pipeline"
DBTOKEN <- ""

convert_df <- function(execute_result) { # convert execute result into a data.frame
  # execute_result should be the "result" object with cols & rows
  cols <- vapply(execute_result$cols, `[[`, "", "name")
  rows <- execute_result$rows
  if (length(cols) == 0 || length(rows) == 0) {
    # return empty df with columns if available
    return(setNames(
      data.frame(matrix(nrow = 0, ncol = length(cols))),
      cols
    ))
  }
  # rows are arrays of strings; convert to data.frame
  df <- as.data.frame(do.call(rbind, lapply(rows, function(r) {
    # convert each value to NA if null string marker is used (depends on response)
    sapply(r, function(x) if (is.null(x)) NA_character_ else as.character(x))
  })), stringsAsFactors = FALSE)
  names(df) <- cols
  df
}

tursoExecute <- function(database, sql_query) { # execute a sql query (and closes the connections)
  requests <- list(
    list(type = "execute", stmt = list(sql = sql_query)),
    list(type = "close")
  )
  body <- list(requests = requests)
  resp <- request(database) %>%
    req_method("POST") %>%
    req_headers(
      Authorization = paste("Bearer", auth_token),
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
  df <- exec_result_to_df(execute_entry)
  return(df)
}

# sql_query <- "SELECT * FROM users;"
# sql_query <- "DELETE FROM users;"

tursoExecute(TURSODB, sql_query)

# UPLOD COMPLETE USER BASE TO TURSO

df <- user_base

call_turso <- function(requests_list) {
  body <- list(requests = requests_list)
  resp <- request(TURSODB) %>%
    req_method("POST") %>%
    req_headers(
      Authorization = paste("Bearer", DBTOKEN),
      `Content-Type` = "application/json"
    ) %>%
    req_body_json(body) %>%
    req_perform() %>%
    resp_body_json(simplifyVector = FALSE)
  resp
}

# Build request list: BEGIN, INSERTs, COMMIT
requests <- list(
  list(type = "execute", stmt = list(sql = "BEGIN"))
)

# Append one execute per row
for (i in seq_len(nrow(df))) {
  row <- df[i, ]
  requests <- append(requests, list(
    list(
      type = "execute",
      stmt = list(
        sql = "INSERT INTO users (user,password_hash,permissions,name,recdate,orgname,orgtype,email,lastaccess,seed) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        args = list(
          list(type = "text", value = row$user),
          list(type = "text", value = row$password_hash),
          list(type = "text", value = row$permissions),
          list(type = "text", value = row$name),
          list(type = "text", value = row$recdate),
          list(type = "text", value = row$orgname),
          list(type = "text", value = row$orgtype),
          list(type = "text", value = row$email),
          list(type = "text", value = row$lastaccess),
          list(type = "text", value = as.character(row$seed))
        )
      )
    )
  ))
}

# Commit transaction and close
requests <- append(requests, list(
  list(type = "execute", stmt = list(sql = "COMMIT")),
  list(type = "close")
))

# Send to Turso
res <- call_turso(requests)

