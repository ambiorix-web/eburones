setwd("./example")
here::i_am(".here")

devtools::load_all()
library(ambiorix)

app <- Ambiorix$new()

pv <- \(req, res) {

  # no session = new user
  if(is.null(req$session))
    return(
      list(
        page_views = 1L
      )
    )

  # existing user = increment
  list(
    page_views = req$session$page_views + 1L
  ) 
}

app$use(
  eburones(session = pv)
)

app$get("/", \(req, res){
  res$sendf("Hello there for the %s time", req$session$page_views)
})

app$start()
