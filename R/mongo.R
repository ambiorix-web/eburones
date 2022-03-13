#' Mongo backend
#' 
#' Mongo db backend for sessions.
#' 
#' @export 
Mongo <- R6::R6Class(
  "Mongo",
  public = list(
    #' @details Constructor
    #' @param con Live DBI connection.
    #' @param key Name of key to use internally.
    initialize = function(con, key) {
      if(missing(con))
        stop("Missing `con`")

      if(missing(key))
        stop("Missing `key`")

      private$.con <- con
      private$.key <- key
    },
    #' @details Add a key-value pair to the map.
    #' @param key Key of the `value`.
    #' @param value Value to store.
    set = function(key, value) {
      # in the even the results of get were used here
      value[[private$.key]] <- NULL

      mongo_key <- private$.make_key(key)
      obj <- private$.make_obj(key, value)
      private$.con$update(mongo_key, obj, upsert = TRUE)
      invisible(self)
    },
    #' @details Check whether a key is present in the map.
    #' @param key Key of the `value`.
    has = function(key = NULL) {
      if(is.null(key))
        return(FALSE)

      key <- private$.make_key(key)
      private$.con$find(key) |> 
        length() |> 
        as.logical()
    },
    #' @details Retrieve a value given its key.
    #' @param key Key of the `value`.
    get = function(key) {
      if(is.null(key))
        return(FALSE)

      key <- private$.make_key(key)
      private$.con$find(key)
    }
  ), 
  private = list(
    .con = NULL,
    .key = NULL,
    .make_key = function(value) {
      sprintf('{"%s":"%s"}', private$.key, value)
    },
    .make_obj = function(key, value) {
      value[[private$.key]] <- key
      json <- ambiorix::serialise(value)
      paste0('{"$set":', json, '}')
    }
  )
)
