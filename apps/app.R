library("pacman") 

pacman::p_load(shiny, ggplot2, dplyr, shinythemes)

# Генерируем фиктивные данные для примера
set.seed(123)
dates <- seq(Sys.Date() - 29, Sys.Date(), by = "day")
length(dates)
customers <- sample(100:1000, 30, replace = TRUE)
length(customers)
revenue <- sample(1000:10000, 30, replace = TRUE)
length(revenue)
orders <- sample(1:5, 30, replace = TRUE)
length(orders)
customer_groups <- sample(letters[1:3], 30, replace = TRUE)
length(customer_groups)

# Создаем фрейм данных
## For client data
df <- data.frame(Date = dates,
                 Customers = customers,
                 Revenue = revenue,
                 Orders = orders,
                 CustomerGroup = customer_groups)

#For GMV
data <- data.frame(
  date = seq(as.Date("2024-01-01"), by = "day", length.out = 90),
  category = sample(LETTERS[1:5], 90, replace = TRUE),
  gmv = runif(90, 100, 1000)
)

# Shiny приложение
ui <- fluidPage(
  # Заголовок
  titlePanel("Аналитический дэшборд по клиентам"),
  # Цифры
  fluidRow(
    column(4, verbatimTextOutput('df'), verbatimTextOutput("unique_customers")),
    column(4, verbatimTextOutput("avg_revenue")),
    column(4, verbatimTextOutput("avg_orders"))
  ),
  # Графики
  fluidRow(
    column(6, plotOutput("customer_trend")),
    column(6, plotOutput("order_trend"))
  ),
  # Pie Chart
  plotOutput("customer_groups"),
  #Start GMV
  theme = shinytheme("cerulean"),
  titlePanel("GMV Analytical Dashboard"),
      h3("1. Суммарный GMV за последние 30 дней"),
      verbatimTextOutput("gmv_total"), 
      br(),
      h3("2. Динамика GMV за последние 30 дней"),
      plotOutput("gmv_plot"),
      br(),
      fluidRow(
	column(6, plotOutput("gmv_pie")),
        column(6, plotOutput("gmv_bar"))
	  )
)  

server <- function(input, output) {
  output$unique_customers <- renderPrint({
    unique_customers <- nrow(df)
    paste('Всего уникальных клиентов за последние 30 дней =', unique_customers)
  })
  output$avg_revenue <- renderPrint({
    avg_revenue <- mean(df$Revenue)
    paste('Cредний чек за последние 30 дней =', round(avg_revenue, 0))
  })
  output$avg_orders <- renderPrint({
    avg_orders <- mean(df$Orders)
    paste('Среднее кол-во заказов на клиента за последние 30 дней =', round(avg_orders, 0))
  })
  output$customer_trend <- renderPlot({
    ggplot(df, aes(x = Date, y = Customers)) + geom_line() + labs(title = "Динамика кол-ва уникальных клиентов по дням", x = "Дата", y = "Клиенты")
  })
  output$order_trend <- renderPlot({
    ggplot(df, aes(x = Date, y = Orders)) + geom_line() + labs(title = "Динамика кол-ва покупок по дням", x = "Дата", y = "Покупки")
  })
  output$customer_groups <- renderPlot({
    df %>%
      group_by(CustomerGroup) %>%
      summarise(GMV = sum(Revenue)) %>%
      ggplot(aes(x="", y = GMV, fill = CustomerGroup)) + geom_bar(width = 1, stat = "identity") + coord_polar("y") + labs(title = 'Доля разных групп клиентов в GMV за последние 30 дней')
  })
  #Start GMV
  output$gmv_total <- renderText({
    sum(data$gmv[data$date >= Sys.Date() - 30])
  })
  output$gmv_total <- renderPrint({
    gmv_total_amount <- round(sum(data$gmv[data$date >= Sys.Date() - 30]), 0)
    paste('Суммарный GMV за последние 30 дней = ', gmv_total_amount)
  })  
  output$gmv_plot <- renderPlot({
    data %>%
      filter(date >= Sys.Date() - 30) %>%
      ggplot(aes(x = date, y = gmv)) +
      geom_line() +
      labs(title = "Динамика GMV за последние 30 дней",
           x = "Дата",
           y = "GMV")
  })
  output$gmv_pie <- renderPlot({
    data %>%
      filter(date >= Sys.Date() - 30) %>%
      group_by(category) %>%
      summarise(gmv = sum(gmv)) %>%
      ggplot(aes(x = "", y = gmv, fill = category)) +
      geom_bar(stat = "identity", width = 1) +
      coord_polar("y", start = 0) +
      labs(title = "Доля товаров каждой категории в GMV за последние 30 дней",
           x = "",
           y = "",
           fill = "Категория")
  })
  output$gmv_bar <- renderPlot({
    data %>%
      filter(date >= Sys.Date() - 30) %>%
      group_by(category) %>%
      summarise(gmv_total = sum(gmv)) %>% mutate(share = gmv_total / sum(gmv_total)) %>%
      ggplot(aes(x = category, y = share, fill = category)) +
      geom_bar(stat = "identity") +
      scale_y_continuous(labels = scales::percent) +
      labs(title = "Динамика доли товаров каждой категории в GM у за последние 30 дней",
           x = "Категория",
           y = "Доля в GMV",
           fill = "Категория")
  })  
}

shinyApp(ui, server)


