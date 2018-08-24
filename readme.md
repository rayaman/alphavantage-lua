A Lua wrapper for the alpha vantage API

Please refer to: https://www.alphavantage.co/documentation/ for what everything does. If you find any bugs feel free to contact me.

This requires luasec to be installed. However, luajit request is also compatible with this. Would require a bit of changes but should be easy to do.

Until a proper documentation is made refer to the site listed above. For each method all required arguments except "function" are the arguments needed for the command to work. All optional arguments can be passed as the last argument in the function call for example:

```lua
alpha.getBBands("MSFT","1min","60","open",{
	nbdevup = 2,
	nbdevdn = 2,
	matype = 0
})
```
All optional values work like this. This way one could refer to the official alpha vantage documentation and still be able to use this library. 
*Note:* the optional type "datatype" and "apikey" are managed automatically where applicable


#Usage
```lua
alpha = require("alphavantage")
alpha.setAPIKey("your-api-key")
```

List of methods and arguments, again for details refer to the above link, it explains it in detail. I am only going over how I wraped things.

##alpha.setAPIKey(string: key)
Sets the API key
##alpha.getPhysicalCurrencyList(boolean: force)
returns a list of Physical Currencies
##alpha.getDigitalCurrencyList(boolean: force)
returns a list of Digital Currencies
**Note:** The above 2 function have a table format of key: "currency code" val: "name of currency". Also these functions also cache a file containing a list of currencies. Setting force to true will force the function to request a list of currencies again.
##alpha.timeSeriesDaily(symbols, outputsize)
##alpha.timeSeriesDailyAdjusted(symbols,outputsize)
##alpha.timeSeriesWeekly(symbols,outputsize)
##alpha.timeSeriesWeeklyAdjusted(symbols,outputsize)
##alpha.timeSeriesMonthly(symbols,outputsize)
##alpha.timeSeriesMonthlyAdjusted(symbols,outputsize)
##alpha.timeSeriesIntraday(symbols,interval,outputsize)
##alpha.currencyExchangeRate(from,to)
##alpha.currencyExchangeIntraday(from,to,interval,outputsize)
##alpha.currencyExchangeDaily(from,to,outputsize)
##alpha.currencyExchangeWeekly(from,to,outputsize)
##alpha.currencyExchangeMonthly(from,to,outputsize)
##alpha.digitalCurrencyIntraday(symbols,market)
##alpha.digitalCurrencyDaily(symbols,market)
##alpha.digitalCurrencyWeekly(symbols,market)
##alpha.digitalCurrencyMonthly(symbols,market)
##alpha.getSMA(symbol,interval,time_period,series_type)
##alpha.getEMA(symbol,interval,time_period,series_type)
##alpha.getWMA(symbol,interval,time_period,series_type)
##alpha.getDEMA(symbol,interval,time_period,series_type)
##alpha.getTEMA(symbol,interval,time_period,series_type)
##alpha.getTRIMA(symbol,interval,time_period,series_type)
##alpha.getKAMA(symbol,interval,time_period,series_type)
##alpha.getMAMA(symbol,interval,time_period,series_type,fastlimit,slowlimit)
##alpha.getT3(symbol,interval,time_period,series_type)
##alpha.getMACD(symbol,interval,time_period,series_type,t)
##alpha.getMACDEXT(symbol,interval,time_period,series_type,t)
##alpha.getSTOCH(symbol,t)
##alpha.getSTOCHF(symbol,t)
##alpha.getRSI(symbol,interval,time_period,series_type)
##alpha.getSTOCHRSI(symbol,interval,time_period,series_type)
##alpha.getWILLR(symbol,interval,time_period,t)
##alpha.getADX(symbol,interval,time_period,t)
##alpha.getADXR(symbol,interval,time_period,t)
##alpha.getAPO(symbol,interval,time_period,series_type,t)
##alpha.getPPO(symbol,interval,time_period,series_type,t)
##alpha.getMOM(symbol,interval,time_period,series_type)
##alpha.getBOP(symbol,interval)
##alpha.getCCI(symbol,interval,time_period)
##alpha.getCMO(symbol,interval,time_period,series_type)
##alpha.getROC(symbol,interval,time_period,series_type)
##alpha.getROCR(symbol,interval,time_period,series_type)
##alpha.getAROON(symbol,interval,time_period)
##alpha.getAROONOSC(symbol,interval,time_period)
##alpha.getMFI(symbol,interval,time_period)
##alpha.getTRIX(symbol,interval,time_period,series_type)
##alpha.getULTOSC(symbol,interval,t)
##alpha.getDX(symbol,interval,time_period)
##alpha.getMinusDI(symbol,interval,time_period)
##alpha.getPlusDI(symbol,interval,time_period)
##alpha.getMinusDM(symbol,interval,time_period)
##alpha.getPlusDM(symbol,interval,time_period)
##alpha.getBBands(symbol,interval,time_period,series_type,t)
##alpha.getMidpoint(symbol,interval,time_period,series_type)
##alpha.getMidprice(symbol,interval,time_period)
##alpha.getSAR(symbol,interval,t)
##alpha.getTRange(symbol,interval)
##alpha.getATR(symbol,interval,time_period)
##alpha.getNATR(symbol,interval,time_period)
##alpha.getAD(symbol,interval)
##alpha.getADOSC(symbol,interval)
##alpha.getOBV(symbol,interval)
##alpha.getHTTrendLine(symbol,interval,time_period,series_type,t)
##alpha.getHTSine(symbol,interval,time_period,series_type,t)
##alpha.getHTTrendMode(symbol,interval,time_period,series_type,t)
##alpha.getHTDCPeriod(symbol,interval,time_period,series_type,t)
##alpha.getHTDCPhase(symbol,interval,time_period,series_type,t)
##alpha.getHTPhasor(symbol,interval,time_period,series_type,t)
##alpha.getSectorPreformance()