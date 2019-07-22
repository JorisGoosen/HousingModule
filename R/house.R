houseFunc <- function(jaspResults, dataset, options)
{
  mortgagePlot(jaspResults, options)
  mortgageTable(jaspResults, options)
}

mortgageTable <- function(jaspResults, options)
{
  if(!is.null(jaspResults[["mortgageTable"]])) return();

  moneyFormat <- "dp:0"
  table       <- createJaspTable(title="Overview", position=2, dependencies=c("housePrice", "interest", "linear", "years", "rent", "perYear", "rentIncrease"));
    
                        table$addColumnInfo(name="year",      title="Year"                                   )
  if(!options$perYear)  table$addColumnInfo(name="month",     title="Month"                                  )
                        table$addColumnInfo(name="principal", title="Principal",          format=moneyFormat )
                        table$addColumnInfo(name="interest",  title="Interest Payment",   format=moneyFormat )
                        table$addColumnInfo(name="payment",   title="Principal Payment",  format=moneyFormat )
                        table$addColumnInfo(name="toPay",     title="Total Payment",      format=moneyFormat )
                        table$addColumnInfo(name="rent",      title="Rent Payment",       format=moneyFormat )

  table$showSpecifiedColumnsOnly  <- TRUE
  jaspResults[["mortgageTable"]]  <- table
  mortgageDF                      <- calculateMortgage(jaspResults, options, options$perYear)

  table$setData(mortgageDF)
  table$addRows(calculateTotalRow(mortgageDF))
}

moneyFormat <- function(money) { return(format(money, scientific=FALSE, big.mark='.')) }

mortgagePlot <- function(jaspResults, options)
{
  if(!is.null(jaspResults[["mortgagePlot"]])) return()

  mortgageDF <- calculateMortgage(jaspResults, options)
  totalRow   <- calculateTotalRow(mortgageDF)
  maxMoney   <- totalRow$payment - options$lossOnSale # invested money in house
  minMoney   <- min(c(-1 * totalRow$toPay, -1 * totalRow$rent, options$lossOnSale))
  roundMoney <- 50000
  maxMoney   <- round(   roundMoney + maxMoney      - (maxMoney      %% roundMoney))
  minMoney   <- round(-(roundMoney + abs(minMoney) - (abs(minMoney) %% roundMoney)))
  
  ySteps     <- seq(minMoney, maxMoney, roundMoney)
  xSteps     <- options$years

  mortgageSeries  <- -1 * c(0, mortgageDF$totalIntPay)
  rentSeries      <- -1 * c(0, mortgageDF$totalRent)
  profitSeries    <- c(0, mortgageDF$totalPay) - options$lossOnSale
  
  p          <- JASPgraphs::drawAxis(xName="Year", yName="Money", force = TRUE, yBreaks=ySteps, xBreaks=0:xSteps, yLabels=moneyFormat(ySteps), xLabels=0:xSteps ) +

    ggplot2::geom_line(data=data.frame(x=c(0, mortgageDF$month / 12), y=mortgageSeries ), mapping=ggplot2::aes(x=x, y=y, colour="mortgage") )  +
    ggplot2::geom_line(data=data.frame(x=c(0, mortgageDF$month / 12), y=rentSeries     ), mapping=ggplot2::aes(x=x, y=y, colour="rent")     )  +
    ggplot2::geom_line(data=data.frame(x=c(0, mortgageDF$month / 12), y=profitSeries   ), mapping=ggplot2::aes(x=x, y=y, colour="profit")   )  +
    ggplot2::geom_line(data=data.frame(x=c(0, options$years),   y=c(0, 0)),                                               mapping=ggplot2::aes(x=x, y=y), colour="grey", linetype=2 ) +
    ggplot2::scale_colour_manual(name="", values=c('mortgage'='red', 'rent'='black', 'profit'='blue'), labels=c('mortgage'="Payments to Mortgage", 'rent'="Payments to Landlord", 'profit'=paste0("Profit despite ",moneyFormat(options$lossOnSale), " loss")))
  
  p          <- JASPgraphs::themeJasp(p, legend.position="right", legend.title="Legend")
  plot       <- createJaspPlot(plot=p, title="Mortgage vs Rent over Time", width=1200, height=400, position=1, dependencies=c("housePrice", "interest", "linear", "years", "rent", "rentIncrease", "lossOnSale"))
  
  jaspResults[["mortgagePlot"]] <- plot
}

calculateMortgage <- function(jaspResults, options, perYear=FALSE)
{
  if(options$linear) 
    return(generateMortgageData(options, perYear, genCalculateLinearPaymentPerMonthFunction(options)))
  
  return(generateMortgageData(options, perYear, genCalculateAnnuityPaymentPerMonthFunction(options)))
}

generateMortgageData <- function(options, perYear, paymentFunc)
{
  loan      <- options$housePrice
  interest  <- options$interest
  years     <- options$years
  months    <- years * 12

  principal <- loan
  rent      <- options$rent

  outDF     <- data.frame()

  totalPay  <- 0
  totalRent <- 0
  totalInt  <- 0

  intYear   <- 0
  payYear   <- 0
  rentYear  <- 0
  princYear <- principal

  monthCnt  <- months
  if(!perYear) monthCnt <- monthCnt - 1 # We only want to shift over to the new month in the years overview

  for(month in 0:monthCnt)
  {
    isNewYear <- month%%12 == 0
    year      <- 1 + (month / 12)
    intMonth  <- calculateInterestPerMonth(principal, interest)
    payMonth  <- paymentFunc(principal)

    if(isNewYear) rent <- rent * (1 + options$rentIncrease)

    if(!perYear)
    {
      if(!isNewYear) 
        year      <- ""

      totalPay  <- totalPay  + payMonth
      totalRent <- totalRent + rent
      totalInt  <- totalInt  + intMonth

      newRow    <- list(year=year, month=month + 1, principal=principal, interest=intMonth, payment=payMonth, toPay=intMonth + payMonth, rent=rent, totalPay=totalPay, totalIntPay=totalPay+totalInt, totalRent=totalRent, totalInterest=totalInt, totalSavedRent=totalRent-totalPay, .isNewGroup=isNewYear)
      outDF     <- rbind(outDF, newRow)
    } else 
    {
      if(isNewYear && month > 0)
      {
        totalPay  <- totalPay  + payYear
        totalRent <- totalRent + rentYear
        totalInt  <- totalInt  + intYear

        newRow    <- list(year=year - 1, month=month + 1, principal=princYear, interest=intYear, payment=payYear, toPay=intYear + payYear, rent=rentYear, totalPay=totalPay, totalIntPay=totalPay+totalInt, totalRent=totalRent, totalInterest=totalInt, totalSavedRent=totalRent-totalPay, .isNewGroup=isNewYear)
        outDF     <- rbind(outDF, newRow)

        princYear <- princYear - payYear

        intYear   <- 0
        payYear   <- 0
        rentYear  <- 0
      }

      intYear   <- intYear  + intMonth
      payYear   <- payYear  + payMonth
      rentYear  <- rentYear + rent
    }

   
    principal <- principal - payMonth

    if(principal < 0) principal <- 0
  }

  return(outDF)
}

calculateInterestPerMonth <- function(principal, interestPerYear)
{
  return(principal * interestPerYear / 12)
}

genCalculateLinearPaymentPerMonthFunction <- function(options)
{
  loan    <- options$housePrice
  months  <- options$years * 12
  payment <- loan / months
  linFunc <- function(principal) { return(payment) }

  return(linFunc)
}

#bron: https://financieel.infonu.nl/hypotheek/98121-hoe-reken-je-de-annuiteitenhypotheek-uit.html
calculateAnnuity <- function(loan, interest, months)
{
  intMonth  <- interest / 12
  payMonth  <- intMonth / (1 - ((1 + intMonth) ^ (-1 * months))) * loan

  return(payMonth)
}

genCalculateAnnuityPaymentPerMonthFunction <- function(options)
{
  loan     <- options$housePrice
  interest <- options$interest
  months   <- options$years * 12
  annuity  <- calculateAnnuity(loan, interest, months)
  annFunc  <- function(principal) { return(annuity - calculateInterestPerMonth(principal, interest)) }

  return(annFunc)
}

calculateTotalRow <- function(mortgageDF)
{
  return(list(year="Total:", month="", principal="", interest=sum(mortgageDF$interest), payment=sum(mortgageDF$payment), toPay=sum(mortgageDF$toPay), rent=sum(mortgageDF$rent), .isNewGroup=TRUE))
}