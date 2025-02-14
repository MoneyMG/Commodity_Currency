FROM --platform=linux/amd64 rocker/shiny-verse:latest 
RUN apt-get update && apt-get install -y git



RUN git clone https://github.com/MoneyMG/Commodity_Currency.git /srv/shiny-server/Commodity_Currency
RUN Rscript /srv/shiny-server/Commodity_Currency/requirements.R

# Make the Shiny app available at port 3838
EXPOSE 3838

# Run the app 1
CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/Commodity_Currency/app', host = '0.0.0.0', port = 3838)"]