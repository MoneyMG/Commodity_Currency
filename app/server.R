#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(plotly)
library(ggplot2)
library(slider)
library(broom)
library(plm)


function(input, output, session) {
    
    output$historical_text <- renderUI({
      html_content <- readLines("content/historical_text.html")
      HTML(paste(html_content, collapse = "\n"))
    })
    
    
    output$importer_reg <- renderPlotly({
      
      visdat <- read.csv("./content/visdat.csv")
      
      plt <- ggplot(visdat, 
                    aes(x = forcats::fct_reorder(country, beta), y = beta, ymin = beta - std.error, ymax = beta + std.error, color = Significant, 
                        text = paste("Country:", country, "<br>Beta:", round(beta, 2), "<br>Std. Error:", round(std.error, 2)))) +
        geom_pointrange() +
        coord_flip() +
        theme_minimal() +
        labs(title = "Commodity Beta Coefficients for Net Exporters",
             x = '',
             y = '') +
        scale_color_manual(values = c("TRUE" = "#275d38", "FALSE" = "#ffc107"))
      
      plotly::ggplotly(plt, tooltip = "text")
    }
    )
    
    
    
    output$importer_reg_sup <- renderText({
      
      "The described framework provides an economically intuitive foundation for defining a 'commodity currency' and refining its qualification criteria.
      If a country's exports (imports) significantly shape market expectations for its currency, fluctuations in commodity export prices should have a direct impact 
      on its exchange rate, leading to a positive (negative) beta."
      
    }
    )
    
    output$alt_beta <- renderPlotly({
      
      fullset <- read.csv("./content/fullset.csv")
      
      cur <- dplyr::case_when(
        input$Type == "Strongly Positive" ~ "MXN",
        input$Type == "Moderately Postive" ~ "RUB",
        input$Type ==  "Slightly Postive" ~ "NOK"
        )
      
      index <- paste0(stringr::str_sub(cur, 1, 2), '_CMDTY')
      
      fullset <- if (input$Type == "Strongly Positive") {
          fullset %>% tidyr::drop_na()
        } else {
          fullset
        }
      
      betadat <- fullset %>% 
        dplyr::select(date, !!sym(cur), !!sym(index)) %>% 
        
        dplyr::mutate("{cur}_vol" := slider::slide_dbl(
          .x = !!sym(cur),
          .f = ~ sd(.x, na.rm = T),
          .before = 11,
          .complete = T
        ),
        "{index}_vol" := slider::slide_dbl(
          .x = !!sym(index),
          .f = ~ sd(.x, na.rm = T),
          .before = 11,
          .complete = T
        ),
        Correlation = slider::slide2_dbl(
          .x = !!sym(cur),
          .y = !!sym(index),
          .f = ~ cor(.x, .y,  use = "complete.obs"),
          .before = 11,
          .complete = T
        ),
        Ratio = get(paste0(index, "_vol")) / get(paste0(cur, "_vol")),
        Beta = Correlation * Ratio) %>% 
        tidyr::drop_na() %>% 
        tidyr::pivot_longer(
          -date,
          names_to = 'series',
          values_to = 'value'
        )
      
      
      plt1 <- plotly::plot_ly() %>% 
        plotly::add_trace(
          data = betadat %>% dplyr::filter(grepl("Ratio", series)), 
          x = ~date, 
          y = ~value, 
          type = 'scatter', 
          mode = 'lines', 
          line = list(color = 'gray'),  
          name = "Ratio",
          text = ~paste("Date:", date, "<br>Volatility Ratio:", round(value, 4)),
          hoverinfo = "text"
        ) %>% 
        plotly::add_trace(
          data = betadat %>% dplyr::filter(grepl("Correlation", series)), 
          x = ~date, 
          y = ~value, 
          type = 'scatter', 
          mode = 'lines', 
          line = list(color = 'darkgray'),  
          name = "Correlation",
          text = ~paste("Date:", date, "<br>Correlation:", round(value, 4)),
          hoverinfo = "text"
        ) %>% 
        plotly::add_trace(
          data = betadat %>% dplyr::filter(grepl("Beta", series)), 
          x = ~date, 
          y = ~value, 
          type = 'scatter', 
          mode = 'lines', 
          line = list(color = '#275d38'),  
          name = "Beta",
          text = ~paste("Date:", date, "<br>Beta:", round(value, 2)),
          hoverinfo = "text"
        )
      
      plt2 <- betadat %>% 
        dplyr::filter(grepl("vol", series)) %>% 
        plotly::plot_ly(
          x = ~date,
          y = ~value,
          color = ~series,
          type = 'scatter',
          mode = 'lines',
          colors = c('#ffc107', "#e68900"),
          text = ~paste("Date:", date, "<br>Volatility:", round(value, 4)),
          hoverinfo = "text"
        ) %>% 
        plotly::layout(
          yaxis = list(tickformat = ".0%")
        )
      
      plotly::subplot(plt1, plt2, nrows = 2, heights = c(.7,.3), shareX = T) %>% 
        plotly::layout(
          xaxis = list(title = '', type = 'date', tickformat = "%Y-%m", dtick = "M12")
        )
    })
    
    output$segway <- renderText({
      
      "
      Although a static beta regression serves as a rudimentry screen for commodity exposure. It is Time sensitive. 
      Even with full a full DOL replication the betas presented here would vary due to varying market dynamics through time.
      
      "
      
    })
    
    output$ident_real <- renderText({
      
      "
      
      Out of the three interactable options, the Norwegian Krone presents the clearest and most compelling story in terms of how commodity 
      price movements influence exchange rate predictability in net exporter countries. Its strong correlation with oil prices, combined with its status as a small,
      less liquid currency, makes it an ideal example of how shifts in commodity prices directly drive currency values. This dynamic is particularly evident when compared to the other currencies,
      as the Krone’s movements provide a more straightforward narrative around the interplay of liquidity, uncertainty, and commodity price exposure.
      
      
      "
      
    })
    
    output$panel_write <- renderUI({
      html_content <- readLines("content/panelwrite.html")
      HTML(paste(html_content, collapse = "\n"))
    })
      
    output$panel_vis <- renderPlotly({
      
      data <- read.csv("./content/Panel_Regression.csv")

      data <- plm::pdata.frame(data, index = c("Country", "Month_Year"))


      fe_model <- plm::plm(Month_Ahead_FX ~ CEP_Log + RER_Level + Momentum_Log + DXY_Level + FX_Vol_Abs + TED_Rel + VIX_Rel + NBER,
                      data = data, model = "within")

      metrics <- broom::tidy(fe_model) %>% 
        dplyr::select(-c(std.error, statistic)) %>% 
        dplyr::mutate(
        pvals = -log10(p.value),  
        Significant = p.value < 0.1
      )

      plotly::plot_ly(
        metrics,
        x = ~estimate,
        y = ~pvals,
        text = ~term,
        type = "scatter", 
        mode = "markers+text",
        marker = list(size = 10, color = ifelse(metrics$Significant, '#275d38', '#ffc107')),
        textposition = 'top') %>%
        plotly::layout(
          title = 'FX Change Prediction: Coefficients and Statistical Significance (1 Month)',
          xaxis = list(title = "Coefficient Estimate"),
          yaxis = list(title = "P-value (-log10)"),
          showlegend = FALSE) %>% 
        plotly::add_annotations(x = 0.15, y = 4,text = paste0("R-squared: ", round(broom::glance(fe_model)$r.squared, 3),
                                                              "<br>Fstat: ", round(broom::glance(fe_model)$statistic, 3)),
                                showarrow = F, font = list(size = 14))
    })

}
