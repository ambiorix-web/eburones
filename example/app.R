setwd("./example")
here::i_am(".here")

devtools::load_all()
library(ambiorix)

app <- Ambiorix$new()

pv <- \(req, res) {

  if(is.null(req$session))
    return(
        list(
        page_views = 1L
      )
    )

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
