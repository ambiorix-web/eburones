#' DBI Backend
#' 
#' DBI backend for sessions. 
#' 
#' @param con Live DBI connection.
#' @param table Name of table to store sessions.
#' The table must exists, it must also contain the expected 
#' columns, as well as a `key` column where the user token will
#' be stored.
#' 
#' @importFrom DBI dbExistsTable dbGetQuery dbExecute dbAppendTable
#' 
#' @export 
DBI <- R6::R6Class(
  "DBI",
  public = list(
    #' @details Constructor
    initialize = function(con, table) {
      if(missing(con))
        stop("Missing `con`")

      if(missing(table))
        stop("Missing `table`")

      if(!dbExistsTable(con, table))
        stop(sprintf("Table `%s` does not exist", table))

      cnt <- dbGetQuery(
        con,
        sprintf(
          "SELECT * FROM %s LIMIT 1;",
          table
        )
      )

      if(!"key" %in% names(cnt))
        stop(
          sprintf("`%s` does not contain a `key` column")
        )

      private$.con <- con
      private$.table <- table
    },
    #' @details Add a key-value pair to the map.
    #' @param key Key of the `value`.
    #' @param value Value to store.
    set = function(key, value) {
      if(!is.data.frame(value))
        stop("`value` must be a data.frame")

      if(nrow(value) != 1)
        stop("`value` must be a data.frame of 1 row")

      if(!self$has(key)) {
        value$key <- key
        dbAppendTable(private$.con, private$.table, value)
        return(invisible(self))
      }

      dbExecute(
        private$.con,
        update_statement(
          private$.table,
          key,
          value
        )
      )

      invisible(self)
    },
    #' @details Check whether a key is present in the map.
    #' @param key Key of the `value`.
    has = function(key) {
      if(is.null(key))
        return(FALSE)

      dbGetQuery(
        private$.con,
        sprintf(
          "SELECT key FROM %s WHERE key = '%s'",
          private$.table,
          key
        )
      ) |> 
        nrow() |> 
        as.logical()
    },
    #' @details Retrieve a value given its key.
    #' @param key Key of the `value`.
    get = function(key) {
      res <- dbGetQuery(
        private$.con,
        sprintf(
          "SELECT * FROM %s WHERE key = '%s'",
          private$.table,
          key
        )
      )

      res$key <- NULL
      return(res)
    }
  ), 
  private = list(
    .con = NULL,
    .table = NULL
  )
)

#' Update Statement
#' 
#' Create an update statement.
#' 
#' @param table Name of the table.
#' @param key Key (token).
#' @param value Data.frame row to update.
#' 
#' @keywords internal
update_statement <- function(table, key, value) {
  values <- parse_values(value)
  q <- paste(
    names(value),
    values,
    sep = " = ",
    collapse = ", "
  )
  sprintf("UPDATE %s SET %s WHERE key = '%s';", table, q, key)
}

#' Parse
#' 
#' Parse values to return SQL compliant values.
#' 
#' @param value Values to parse.
#' 
#' @keywords internal
parse_values <- function(value) {
  value <- unname(value)

  sapply(value, \(v) {
    if(is.factor(v) || is.character(v)) 
      v <- paste0("'", v, "'")

    if(is.logical(v))
      v <- as.integer(v)

    v
  })
}
