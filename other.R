library(tidyverse)

translate <- function(En, Es, whichlang){
  if (whichlang == "English") {En} else {Es} 
}




# Match Ref Values
RefE <- function(cap,alt, whichlang) {
  alt <- if (alt == "Si") {"Yes"} else {alt}
  rowcall <- dplyr::filter (Ref_Vals_RefE, Capacity_range == cap & Altitude == alt) %>% select(RefE)
  unname(unlist(rowcall))
}

RefH <- function(ty) {
  if (ty == "Steam/Hot Water") {0.9} 
  else if (ty == "Steam / agua caliente") {0.9} 
  else if (ty == "Direct use of combustion gases") {0.8}
  else if (ty == "Uso directo de los gases de combustión")  {0.8}
}

fp <- function(volt) {
  rowcall <- dplyr::filter (Ref_Vals_fp, Voltage_range == volt) %>% select(fp)
  unname(unlist(rowcall))
}

AEP_fxn <- function(E,RefE,fp,H,RefH,F_) {
  (E/(RefE*fp)) + (H/RefH) - F_
}

ELC_fxn <- function(E,RefE,fp,H,RefH,F_) {
  ((E/(RefE*fp)) + (H/RefH) - F_)*RefE
}

qual_fxn <- function(lang, elc){
  if (elc > 0) {
    if (lang == "English") {"Yes"} else {"Si"}
  }  else {"No"}
   }
