# Based off: https://blog.jessfraz.com/post/r-containers-for-data-science/

# our R base image - verse gives us pandoc - necessary for rmarkdown
FROM rocker/verse

# install packages
RUN echo 'install.packages(c("ggplot2", "lubridate", "dplyr", "forcats", "reshape2", "knitr", "rmarkdown", "gtools"), repos="http://cran.us.r-project.org", dependencies=TRUE)' > /tmp/packages.R \
    && Rscript /tmp/packages.R

# create an R user
ENV HOME /home/user
RUN useradd --create-home --home-dir $HOME user \
    && chown -R user:user $HOME

WORKDIR $HOME
USER user

# set the command
CMD ["Rscript", "/home/user/jiraR/init.R"]
