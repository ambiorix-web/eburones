#' Local backend
#' 
#' Local backend for sessions. 
#' Do not use this in production, it will likely leka memory and 
#' will not track sessions on load balancers.
#' 
#' @importFrom fastmap fastmap
#' 
#' @export 
Local <- R6::R6Class(
  "Local",
  public = list(
    #' @details Constructor
    initialize = function() {
      private$.map <- fastmap()
    },
    #' @details Add a key-value pair to the map.
    #' @param key Key of the `value`.
    #' @param value Value to store.
    set = function(key, value) {
      private$.map$set(key, value)
      invisible(self)
    },
    #' @details Check whether a key is present in the map.
    #' @param key Key of the `value`.
    has = function(key) {
      if(is.null(key))
        return(FALSE)

      private$.map$has(key)
    },
    #' @details Retrieve a value given its key.
    #' @param key Key of the `value`.
    get = function(key) {
      private$.map$get(key)
    }
  ), 
  private = list(
    .map = NULL
  )
)