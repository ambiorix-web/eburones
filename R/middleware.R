#' Eburones
#' 
#' Session middleware.
#' 
#' @param backend Storage class to keep track of callbacks.
#' @param callback Function to run when a callback is created or retrieved.
#' 
#' @importFrom ambiorix token_create
#' 
#' @export 
eburones <- function(
  backend = Local$new(),
  callback = \(req, res) list()
) {
  if(!is.function(callback))
    stop("`callback` must be a function")

  if(length(methods::formalArgs(callback)) != 2)
    stop("`callback` must accept 2 arguments: req, and res")

  \(req, res) {

    # user from cookie
    user <- req$cookie$eburonesUser

    # user found
    if(backend$has(user)) {
      req$callback <- backend$get(user)
      obj <- callback(req, res)
      backend$set(user, obj)
      return(NULL)
    }

    # create new user
    token <- token_create(8L)

    # set the user
    obj <- callback(req, res)

    backend$set(token, obj)
    req$callback <- obj
    
    # set the cookie
    res$cookie("eburonesUser", token)

    return(NULL)
  }
}