setwd("./example")
here::i_am(".here")

devtools::load_all()
library(ambiorix)

app <- Ambiorix$new()

pv <- \(req, res) {

  # no session = new user
  if(is.null(req$session))
    return(
      data.frame(
        page_views = 1L
      )
    )

  # existing user = increment
  data.frame(
    page_views = req$session$page_views + 1L
  ) 
}

con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
DBI::dbExecute(
  con,
  "CREATE TABLE sessions (
    key TEXT,
    page_views INTEGER
  )"
)

backend <- DBI$new(con, "sessions")

app$use(
  eburones(backend = backend, session = pv)
)

app$get("/", \(req, res){
  res$sendf("Hello there for the %s time", req$session$page_views)
})

app$start()
