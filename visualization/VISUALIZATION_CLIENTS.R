library(shiny)
library(ggplot2)
library(dplyr)

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
df <- data.frame(Date = dates,
                 Customers = customers,
                 Revenue = revenue,
                 Orders = orders,
                 CustomerGroup = customer_groups)

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
  plotOutput("customer_groups")
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
}
shinyApp(ui, server)


