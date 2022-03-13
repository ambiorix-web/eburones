<!-- badges: start -->
<!-- badges: end -->

# eburones

User sessions for [ambiorix](https://ambiorix.dev).

## Installation

Get it from Github.

``` r
# install.packages("remotes")
remotes::install_github("devOpifex/eburones")
```

## Example

:warning: You are strongly advised to use 
[scilis](https://github.com/devOpifex/scilis)
secure your cookies.

Simply use the `eburones` middleware.

__Local__

:warning: The local backend should only be used for local development,
never in production. 
It will also not properly track sessions with 
[belgic](https://github.com/belgic), across machines, and
data will be lost when the server is restarted.

```r
library(eburones)
library(ambiorix)

app <- Ambiorix$new()

app$use(eburones())

app$get("/", \(req, res){
  print(req$session)
  res$send("Hello there!")
})

app$start()
```

Below is an example to track page views.
We create a callback function that returns a list containing the number
of page views.
This callback is run at every request for the session, we 
increment it at every visit.

```r
library(eburones)
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
  eburones(callback = pv)
)

app$get("/", \(req, res){
  res$sendf("Hello there for the %s time", req$session$page_views)
})

app$start()
```

__DBI__

There is a DBI backend.
We implement the same page view tracker as above. 
One difference is that the DBI backend expects the callback
to return a `data.frame` of 1 row.

```r
library(eburones)
library(ambiorix)

app <- Ambiorix$new()

pv <- \(req, res) {

  # new user return a data.frame
  if(is.null(req$session))
    return(
      data.frame(
        page_views = 1L
      )
    )

  # we need to return a data.frame (1 row)
  data.frame(
    page_views = req$session$page_views + 1L
  ) 
}

# we create a connection to a database (SQLite in this case)
con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:"o)

# we need to create the table we'll use to store sessions
# it must contain a key column where user token will be stored
DBI::dbExecute(
  con,
  "CREATE TABLE sessions (
    key TEXT,
    page_views INTEGER
  )"
)

backend <- DBI$new(con, "sessions")

app$use(
  eburones(backend = backend, callback = pv)
)

app$get("/", \(req, res){
  res$sendf("Hello there for the %s time", req$session$page_views)
})

app$start()
```

__Mongodb__

```r
library(eburones)
library(ambiorix)
library(mongolite)

m <- mongo(
  url = "mongodb://localhost/?ssl=true", 
  options = ssl_options(
    weak_cert_validation = TRUE
  )
)

mongo <- Mongo$new(m, "user")

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
  eburones(
    backend = mongo, 
    callback = pv
  )
)

app$get("/", \(req, res){
  res$sendf("Hello there for the %s time", req$session$page_views)
})

app$start()
```
