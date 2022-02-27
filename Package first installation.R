# you need to install rtools before. Link: https://cran.r-project.org/bin/windows/Rtools/
writeLines('PATH="${RTOOLS40_HOME}\\usr\\bin;${PATH}"', con = "~/.Renviron")
#restart R
install.packages("shiny")
if (!requireNamespace("BiocManager", quietly=TRUE))
  install.packages("BiocManager")
BiocManager::install("ChemmineR")
BiocManager::install("ChemmineOB")
if(!require(Hmisc)) install.packages("Hmisc",repos = "http://cran.us.r-project.org")
if(!require(MALDIquant)) install.packages(c("MALDIquant", "MALDIquantForeign"))
install.packages("data.table")
install.packages('DT')
install.packages("wildcard")
install.packages("Rdisop")