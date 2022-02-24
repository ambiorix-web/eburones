#' Eburones
#' 
#' Session middleware.
#' 
#' @param backend Storage class to keep track of sessions.
#' @param session Function to run when a session is created or retrieved.
#' 
#' @importFrom ambiorix token_create
#' 
#' @export 
eburones <- function(
  backend = Local$new(),
  session = \(req, res) list()
) {
  if(!is.function(session))
    stop("`session` must be a function")

  if(length(methods::formalArgs(session)) != 2)
    stop("`session` must accept 2 arguments: req, and res")

  \(req, res) {

    # user from cookie
    user <- req$cookie$eburonesUser

    # user found
    if(backend$has(user)) {
      req$session <- backend$get(user)
      obj <- session(req, res)
      backend$set(user, obj)
      return(NULL)
    }

    # create new user
    token <- token_create(8L)

    # set the user
    obj <- session(req, res)

    backend$set(token, obj)
    req$session <- obj
    
    # set the cookie
    res$cookie("eburonesUser", token)

    return(NULL)
  }
}