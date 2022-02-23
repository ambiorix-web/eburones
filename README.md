<!-- badges: start -->
<!-- badges: end -->

# eburones

User sessions for [ambiorix](https://ambiorix.dev).

## Installation

``` r
# install.packages("remotes")
remotes::install_github("devOpifex/eburones")
```

## Example

Simply use the `eburones` middleware.

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

```r
library(eburones)
library(ambiorix)

app <- Ambiorix$new()

pv <- \(req, res) {

  # new user
  if(is.null(req$session))
    return(
      list(
        page_views = 1L
      )
    )

  # increment
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
```
