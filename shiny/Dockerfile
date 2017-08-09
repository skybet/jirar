From rocker/shiny

RUN apt-get update && apt-get install -y libssl-dev libudunits2-dev

RUN echo 'install.packages(c("ggplot2", "lubridate", "dplyr", "forcats", "plotly"), repos="http://cran.us.r-project.org", dependencies=TRUE)' > /tmp/packages.R \
     && Rscript /tmp/packages.R

COPY . /srv/shiny-server/jirar
