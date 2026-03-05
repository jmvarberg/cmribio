## code to prepare `grch38` dataset goes here

#making internal copy of annotables::grch38 to remove dependency
grch38 <- annotables::grch38

usethis::use_data(grch38, overwrite = TRUE)
