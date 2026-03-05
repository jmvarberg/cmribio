## code to prepare `grcm38` dataset goes here

#making internal copy of annotables::grcm38 to remove dependency
grcm38 <- annotables::grcm38

usethis::use_data(grcm38, overwrite = TRUE)
