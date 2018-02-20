    #  A function to install packages, taken from setup for extending the 
    #   tidyverse workshop
    
    please_install <- function(pkgs, install_fun = install.packages) {
      if (length(pkgs) == 0) {
        return(invisible())
      }
      if (!interactive()) {
        stop("Please run in interactive session", call. = FALSE)
      }

      title <- paste0(
        "Ok to install these packges?\n",
        paste("* ", pkgs, collapse = "\n")
      )
      ok <- menu(c("Yes", "No"), title = title) == 1

      if (!ok) {
        return(invisible())
      }

      install_fun(pkgs)
    }
    
    #  Do you have these?
    wild542 <- c("usethis", "testthat", "dplyr", "tidyr", "purrr", "devtools",
      "glue", "readr", "stringr", "tibble", "broom", "rjags", "R2jags", "coda",
      "jagsUI", "mcmcplots")
    
    have <- rownames(installed.packages())
    needed <- setdiff(wild542, have)

    please_install(needed)