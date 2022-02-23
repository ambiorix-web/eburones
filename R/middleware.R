#' Eburones
#' 
#' Session middleware.
#' 
#' @param storage Storage class to keep track of sessions.
#' @param session Function to run when a session is created or retrieved.
#' 
#' @importFrom ambiorix token_create
#' 
#' @export 
eburones <- function(
  storage = Local$new(),
  session = \(req, res) list()
) {
  if(!is.function(session))
    stop("`session` must be a function")

  if(length(methods::formalArgs(session)) != 2)
    stop("`session` must accept 2 arguments: req, and res")

  \(req, res) {

    user <- req$cookie$eburonesUser
    if(storage$has(user)) {
      req$session <- storage$get(user)
      obj <- session(req, res)
      storage$set(user, obj)
      return(NULL)
    }

    # new user token
    token <- token_create(8L)

    # set the user
    obj <- session(req, res)

    storage$set(token, obj)
    req$session <- obj
    
    # set the cookie
    res$cookie("eburonesUser", token)

    return(NULL)
  }
}