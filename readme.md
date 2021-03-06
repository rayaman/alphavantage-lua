A Lua wrapper for the alphavantage API

Please refer to: https://www.alphavantage.co/documentation/ for what everything does. If you find any bugs feel free to contact me.

This requires luasec to be installed. However, luajit request is also compatiable with this.

#Usage
```lua
alpha = require("alphavantage")
alpha.setAPIKey("your-api-key")
```

List of methods and arguments, again for details refer to the above link, it explains it in detail. I am only going over how I wraped things.

# alpha.setAPIKey(string: key)
Sets the API key
# alpha.getPhysicalCurrencyList(boolean: force)
returns a list of Physical Currencies
# alpha.getDigitalCurrencyList(boolean: force)
returns a list of Digital Currencies

**Note:** The above 2 function have a table format of key: "currency code" val: "name of currency". Also these functions also cache a file containing a list of currencies. Setting force to true will force the function to request a list of currencies again.
# alpha.globalQuote(symbols)
returns the current price and metadata of a stock or a table of stocks
# alpha.timeSeriesDaily(symbols, outputsize)
# alpha.timeSeriesDailyAdjusted(symbols,outputsize)
# alpha.timeSeriesWeekly(symbols,outputsize)
# alpha.timeSeriesWeeklyAdjusted(symbols,outputsize)
# alpha.timeSeriesMonthly(symbols,outputsize)
# alpha.timeSeriesMonthlyAdjusted(symbols,outputsize)
# alpha.timeSeriesIntraday(symbols,interval,outputsize)
# alpha.currencyExchangeRate(from,to)
# alpha.currencyExchangeIntraday(from,to,interval,outputsize)
# alpha.currencyExchangeDaily(from,to,outputsize)
# alpha.currencyExchangeWeekly(from,to,outputsize)
# alpha.currencyExchangeMonthly(from,to,outputsize)
# alpha.digitalCurrencyIntraday(symbols,market)
# alpha.digitalCurrencyDaily(symbols,market)
# alpha.digitalCurrencyWeekly(symbols,market)
# alpha.digitalCurrencyMonthly(symbols,market)
# alpha.getSMA(symbol,interval,time_period,series_type)
# alpha.getEMA(symbol,interval,time_period,series_type)
# alpha.getWMA(symbol,interval,time_period,series_type)
# alpha.getDEMA(symbol,interval,time_period,series_type)
# alpha.getTEMA(symbol,interval,time_period,series_type)
# alpha.getTRIMA(symbol,interval,time_period,series_type)
# alpha.getKAMA(symbol,interval,time_period,series_type)
# alpha.getMAMA(symbol,interval,time_period,series_type,fastlimit,slowlimit)
# alpha.getT3(symbol,interval,time_period,series_type)
# alpha.getMACD(symbol,interval,time_period,series_type,t)
# alpha.getMACDEXT(symbol,interval,time_period,series_type,t)
# alpha.getSTOCH(symbol,t)
# alpha.getSTOCHF(symbol,t)
# alpha.getRSI(symbol,interval,time_period,series_type)
# alpha.getSTOCHRSI(symbol,interval,time_period,series_type)
# alpha.getWILLR(symbol,interval,time_period,t)
# alpha.getADX(symbol,interval,time_period,t)
# alpha.getADXR(symbol,interval,time_period,t)
# alpha.getAPO(symbol,interval,time_period,series_type,t)
# alpha.getPPO(symbol,interval,time_period,series_type,t)
# alpha.getMOM(symbol,interval,time_period,series_type)
# alpha.getBOP(symbol,interval)
# alpha.getCCI(symbol,interval,time_period)
# alpha.getCMO(symbol,interval,time_period,series_type)
# alpha.getROC(symbol,interval,time_period,series_type)
# alpha.getROCR(symbol,interval,time_period,series_type)
# alpha.getAROON(symbol,interval,time_period)
# alpha.getAROONOSC(symbol,interval,time_period)
# alpha.getMFI(symbol,interval,time_period)
# alpha.getTRIX(symbol,interval,time_period,series_type)
# alpha.getULTOSC(symbol,interval,t)
# alpha.getDX(symbol,interval,time_period)
# alpha.getMinusDI(symbol,interval,time_period)
# alpha.getPlusDI(symbol,interval,time_period)
# alpha.getMinusDM(symbol,interval,time_period)
# alpha.getPlusDM(symbol,interval,time_period)
# alpha.getBBands(symbol,interval,time_period,series_type,t)
# alpha.getMidpoint(symbol,interval,time_period,series_type)
# alpha.getMidprice(symbol,interval,time_period)
# alpha.getSAR(symbol,interval,t)
# alpha.getTRange(symbol,interval)
# alpha.getATR(symbol,interval,time_period)
# alpha.getNATR(symbol,interval,time_period)
# alpha.getAD(symbol,interval)
# alpha.getADOSC(symbol,interval)
# alpha.getOBV(symbol,interval)
# alpha.getHTTrendLine(symbol,interval,time_period,series_type,t)
# alpha.getHTSine(symbol,interval,time_period,series_type,t)
# alpha.getHTTrendMode(symbol,interval,time_period,series_type,t)
# alpha.getHTDCPeriod(symbol,interval,time_period,series_type,t)
# alpha.getHTDCPhase(symbol,interval,time_period,series_type,t)
# alpha.getHTPhasor(symbol,interval,time_period,series_type,t)
# alpha.getSectorPreformance()
