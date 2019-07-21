houseFunc <- function(jaspResults, dataset, options)
{
  mainTable(jaspResults, options)
}

moneyFormat <- "dp:0"



mainTable <- function(jaspResults, options)
{
  if(!is.null(jaspResults[["mainTable"]])) return();

  table     <- createJaspTable(title="Overview", dependencies=c("housePrice", "interest", "linear", "years"));
    
  table$addColumnInfo(name="year",      title="Year"                                   )
  table$addColumnInfo(name="month",     title="Month"                                  )
	table$addColumnInfo(name="principal", title="Principal",          format=moneyFormat )
  table$addColumnInfo(name="interest",  title="Interest",           format=moneyFormat )
  table$addColumnInfo(name="payment",   title="Principal Payment",  format=moneyFormat )
  table$addColumnInfo(name="totalPay",  title="Total Payment",      format=moneyFormat )
  table$addColumnInfo(name="rent",      title="Rent Payment",       format=moneyFormat )

  table$setExpectedSize(rows=options$years * 12)

  jaspResults[["mainTable"]] <- table

  mortgageDF <- calculateMortgage(jaspResults, options)

  table$setData(mortgageDF)
  table$addRows(calculateTotalRow(mortgageDF))
}

calculateMortgage <- function(jaspResults, options)
{
  if(!is.null(jaspResults[["mortgage"]])) return(jaspResults[["mortgage"]]$object);

  mortgage <- list()

  if(options$linear) { mortgage <- calculateLinear(options);
  } else {             mortgage <- calculateAnnuities(options); }
  
  jaspResults[["mortgage"]] <- createJaspState(mortgage, dependencies=c("housePrice", "interest", "linear", "years", "rent", "perYear"));
  
  return(jaspResults[["mortgage"]]$object)
}

calculateLinear <- function(options)
{
  loan      <- options$housePrice
  interest  <- options$interest
  years     <- options$years
  months    <- years * 12
  payYear   <- loan / years
  payMonth  <- payYear / 12
  principal <- loan
  rent      <- options$rent

  outDF     <- data.frame()

  for(month in 0:(months-1))
  {
    intMonth  <- principal * interest / 12
    isNewYear <- month%%12 == 0 
    year      <- ""

    if(isNewYear) year <- 1 + (month / 12)

    newRow    <- list(year=year, month=month + 1, principal=principal, interest=intMonth, payment=payMonth, totalPay=intMonth + payMonth, rent=rent, .isNewGroup=isNewYear)
    outDF     <- rbind(outDF, newRow)
    principal <- principal - payMonth
  }

  return(outDF)
}

#bron: https://financieel.infonu.nl/hypotheek/98121-hoe-reken-je-de-annuiteitenhypotheek-uit.html
calculateAnnuities <- function(options)
{
  loan      <- options$housePrice
  interest  <- options$interest
  years     <- options$years
  months    <- years * 12
  intMonth  <- interest / 12
  payMonth  <- intMonth / (1 - ((1 + intMonth) ^ (-1 * months))) * loan
  
  principal <- loan
  rent      <- options$rent

  outDF     <- data.frame()
  
  totalPay  <- 0
  totalRent <- 0
  totalInt  <- 0

  for(month in 0:(months-1))
  {
    intPay    <- principal * intMonth
    actPay    <- payMonth - intPay

    isNewYear <- month%%12 == 0 
    year      <- ""
    if(isNewYear) year <- 1 + (month / 12)


    newRow    <- list(year=year, month=month + 1, principal=principal, interest=intPay, payment=actPay, totalPay=payMonth, rent=rent, .isNewGroup=isNewYear)
    outDF     <- rbind(outDF, newRow)
    principal <- principal - actPay
  }

  return(outDF)
}


calculateTotalRow <- function(mortgageDF)
{
  return(list(year="Total:", month="", principal="", interest=sum(mortgageDF$interest), payment=sum(mortgageDF$payment), totalPay=sum(mortgageDF$totalPay), rent=sum(mortgageDF$rent), .isNewGroup=TRUE))
}