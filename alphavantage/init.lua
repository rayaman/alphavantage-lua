local bin = require("bin")
local alpha = {}
alpha.APIKey = ""
local loadedssl,https = pcall(require,"ssl.https")
local loadedreq,luajitrequest = pcall(require,"luajit-request")
local request
if loadedssl then
	function request(url)
		return https.request(url)
	end
end
if loadedreq and not loadedssl then
	function request(url)
		return luajitrequest.send(url).body
	end
end
if request == nil then
	error("Was unable to load an ssl request library!")
end
function string:split(inSplitPattern, outResults)
	if not outResults then
		outResults = {}
	end
	local theStart = 1
	local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
	while theSplitStart do
		table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
		theStart = theSplitEnd + 1
		theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
	end
	table.insert( outResults, string.sub( self, theStart ) )
	return outResults
end
function alpha.setAPIKey(key)
	alpha.APIKey = key
end
function alpha.getPhysicalCurrencyList(force)
	local dat = ""
	if bin.fileExists("PCL.dat") and not force then
		dat = bin.load("PCL.dat").data
	else
		dat = request("https://www.alphavantage.co/physical_currency_list/")
		bin.new(dat):tofile("PCL.dat")
	end
	if alpha.pcl then return alpha.pcl end
	local c = {}
	local lines = dat:lines()
	local a,b
	for i = 2,#lines-1 do
		a,b = lines[i]:match("(.-),(.+)")
		c[a]=b
	end
	alpha.pcl = c
	return c
end
function alpha.getDigitalCurrencyList(force)
	local dat = ""
	if bin.fileExists("DCL.dat") and not force then
		dat = bin.load("DCL.dat").data
	else
		dat = request("https://www.alphavantage.co/digital_currency_list/")
		bin.new(dat):tofile("DCL.dat")
	end
	if alpha.dcl then return alpha.dcl end
	local c = {}
	local lines = dat:lines()
	local a,b
	for i = 2,#lines-1 do
		a,b = lines[i]:match("(.-),(.+)")
		c[a]=b
	end
	alpha.dcl = c
	return c
end
function alpha.dataToTable(data)
	local c = {
		MetaData = {},
		History = {}
	}
	local lines = data:lines(str)
	local tab = {}
	local tag = lines[1]:split(",")
	for i = 2,#lines-1 do
		tab = lines[i]:split(",")
		local t={}
		c.History[#c.History+1]=t
		for e = 1,#tag do
			t[tag[e]]=tab[e]
		end
	end
	return c
end
local function simpleparse(command,symbols,outputsize,interval)
	local cmd
	local data = {}
	if type(symbols)=="string" then
		symbols = {symbols}
	end
	local str = ""
	if outputsize then
		str = str .. "&outputsize=".. outputsize
	end
	if interval then
		str = "&interval="..interval
	end
	for i=1,#symbols do
		cmd = "https://www.alphavantage.co/query?function="..command.."&symbol="..symbols[i].."&datatype=csv&apikey="..alpha.APIKey..str
		dat = request(cmd)
		if dat:find("Invalid API call") then
			return nil, "Invalid API call"
		else
			data[i]=alpha.dataToTable(dat)
			data[i].MetaData = {
				Symbol = symbols[i],
				MostRecentData = data[i].History[1]
			}
		end
	end
	return data
end
-- api.TIME_SERIES_DAILY
function alpha.timeSeriesDaily(symbols,outputsize)
	return simpleparse("TIME_SERIES_DAILY",symbols,outputsize)
end
-- api.TIME_SERIES_DAILY_ADJUSTED
function alpha.timeSeriesDailyAdjusted(symbols,outputsize)
	return simpleparse("TIME_SERIES_DAILY_ADJUSTED",symbols,outputsize)
end
-- api.TIME_SERIES_WEEKLY
function alpha.timeSeriesWeekly(symbols,outputsize)
	return simpleparse("TIME_SERIES_WEEKLY",symbols,outputsize)
end
-- api.TIME_SERIES_WEEKLY_ADJUSTED
function alpha.timeSeriesWeeklyAdjusted(symbols,outputsize)
	return simpleparse("TIME_SERIES_WEEKLY_ADJUSTED",symbols,outputsize)
end
-- api.TIME_SERIES_MONTHLY
function alpha.timeSeriesMonthly(symbols,outputsize)
	return simpleparse("TIME_SERIES_MONTHLY",symbols,outputsize)
end
-- api.TIME_SERIES_MONTHLY_ADJUSTED
function alpha.timeSeriesMonthlyAdjusted(symbols,outputsize)
	return simpleparse("TIME_SERIES_MONTHLY_ADJUSTED",symbols,outputsize)
end
-- api.GLOBAL_QUOTE
function alpha.globalQuote(symbols)
	local cmd
	local data = {}
	if type(symbols)=="string" then
		symbols = {symbols}
	end
	local str = ""
	for i=1,#symbols do
		cmd = "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol="..symbols[i].."&datatype=csv&apikey="..alpha.APIKey
		dat = request(cmd)
		print(dat)
		if dat:find("Invalid API call") then
			return nil, "Invalid API call"
		else
			data[i]=alpha.dataToTable(dat)
			data[i].MetaData = {
				Symbol = symbols[i],
				MostRecentData = data[i].History[1]
			}
		end
	end
	return data
end
-- api.TIME_SERIES_INTRADAY
local _interval = {
	["1min"]=true,
	["5min"]=true,
	["15min"]=true,
	["30min"]=true,
	["60min"]=true,
	["daily"]=true,
	["monthly"]=true,
	["weekly"]=true,
}
function alpha.timeSeriesIntraday(symbols,interval,outputsize)
	interval = interval or "5min"
	if not _interval[interval] then
		return nil,interval.." is not a supported interval that can be used"
	end
	return simpleparse("TIME_SERIES_INTRADAY",symbols,outputsize,interval)
end

-- api.CURRENCY_EXCHANGE_RATE
function alpha.currencyExchangeRate(from,to)
	local dat = request("https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency="..from.."&to_currency="..to.."&apikey="..alpha.APIKey)
	if dat:find("Invalid API call") then
		return nil, "Invalid API call"
	else
		local c = {}
		local lines = dat:lines()
		local var,val
		for i = 3,#lines-2 do
			var,val = lines[i]:match("%d-%. (.-)\": \"(.-)\"")
			c[(var:gsub("Currency.",""))]=tonumber(val) or val
		end
		return c
	end
end
local function simpleFXParse(cmd,from,to,interval,outputsize)
	if outputsize then
		outputsize = "&outputsize="..outputsize
	end
	interval = interval or ""
	local dat = request("https://www.alphavantage.co/query?function="..cmd.."&from_symbol="..from.."&to_symbol="..to..interval.."&apikey="..alpha.APIKey.."&datatype=csv"..outputsize)
	if dat:find("Invalid API call") then
		return nil, "Invalid API call"
	else
		local data = alpha.dataToTable(dat)
		data.MetaData.From = from
		data.MetaData.To = to
		data.MetaData.MostRecentData = data.History[1]
		return data
	end
end
-- api.FX_INTRADAY
function alpha.currencyExchangeIntraday(from,to,interval,outputsize)
	interval = interval or "5min"
	if not _interval[interval] then
		return nil,interval.." is not a supported interval that can be used"
	end
	return simpleFXParse("FX_INTRADAY",from,to,"&interval="..interval,outputsize)
end
-- api.FX_DAILY
function alpha.currencyExchangeDaily(from,to,outputsize)
	return simpleFXParse("FX_DAILY",from,to,nil,outputsize)
end
-- api.FX_WEEKLY
function alpha.currencyExchangeWeekly(from,to,outputsize)
	return simpleFXParse("FX_WEEKLY",from,to,nil,outputsize)
end
-- api.FX_MONTHLY
function alpha.currencyExchangeMonthly(from,to,outputsize)
	return simpleFXParse("FX_MONTHLY",from,to,nil,outputsize)
end
local function simpleDigitalParse(command,symbols,market)
	local data = {}
	if type(symbols)=="string" then
		symbols = {symbols}
	end
	for i=1,#symbols do
		dat = request("https://www.alphavantage.co/query?function="..command.."&symbol="..symbols[i].."&market="..market.."&datatype=csv&apikey="..alpha.APIKey)
		if dat:find("Invalid API call") then
			return nil, "Invalid API call"
		else
			data[symbols[i]]=alpha.dataToTable(dat)
			data[symbols[i]].MetaData.Symbol = symbols[i]
			data[symbols[i]].MetaData.Market = market
			data[symbols[i]].MetaData.MostRecentData = data[symbols[i]].History[1]
		end
	end
	return data
end
-- api.DIGITAL_CURRENCY_INTRADAY
function alpha.digitalCurrencyIntraday(symbols,market)
	return simpleDigitalParse("DIGITAL_CURRENCY_INTRADAY",symbols,market)
end
-- api.DIGITAL_CURRENCY_DAILY
function alpha.digitalCurrencyDaily(symbols,market)
	return simpleDigitalParse("DIGITAL_CURRENCY_DAILY",symbols,market)
end
-- api.DIGITAL_CURRENCY_WEEKLY
function alpha.digitalCurrencyWeekly(symbols,market)
	return simpleDigitalParse("DIGITAL_CURRENCY_WEEKLY",symbols,market)
end
-- api.DIGITAL_CURRENCY_MONTHLY
function alpha.digitalCurrencyMonthly(symbols,market)
	return simpleDigitalParse("DIGITAL_CURRENCY_MONTHLY",symbols,market)
end
alpha.Close = "close"
alpha.Open = "open"
alpha.High = "high"
alpha.Low = "low"
local function technicalParsers(cmd,symbol,interval,time_period,series_type,t)
	local extras = ""
	interval = interval or "monthly"
	time_period=time_period or "60"
	if not _interval[interval] then
		return nil,interval.." is not a supported interval that can be used"
	end
	for i,v in pairs(t or {}) do
		extras=extras.."&"..i.."="..v
	end
	local data = request("https://www.alphavantage.co/query?function="..cmd.."&datatype=csv&symbol="..symbol.."&interval="..interval.."&time_period="..time_period.."&series_type="..series_type.."&apikey="..alpha.APIKey..extras)
	if data:find("Invalid API call") then
		return nil, "Invalid API call"
	end
	data = alpha.dataToTable(data)
	data.MetaData.Symbol = symbol
	data.MetaData.MostRecentData = data.History[1]
	return data
end
local function technicalParsers2(cmd,symbol,t)
	local extras = ""
	for i,v in pairs(t or {}) do
		extras=extras.."&"..i.."="..v
	end
	local c = "https://www.alphavantage.co/query?function="..cmd.."&datatype=csv&symbol="..symbol.."&apikey="..alpha.APIKey..extras
	print(c)
	local data = request(c)
	if data:find("Invalid API call") then
		return nil, "Invalid API call"
	end
	data = alpha.dataToTable(data)
	data.MetaData.Symbol = symbol
	data.MetaData.MostRecentData = data.History[1]
	return data
end
-- api.SMA
function alpha.getSMA(symbol,interval,time_period,series_type)
	return technicalParsers("SMA",symbol,interval,time_period,series_type)
end
-- api.EMA
function alpha.getEMA(symbol,interval,time_period,series_type)
	return technicalParsers("EMA",symbol,interval,time_period,series_type)
end
-- api.WMA
function alpha.getWMA(symbol,interval,time_period,series_type)
	return technicalParsers("WMA",symbol,interval,time_period,series_type)
end
-- api.DEMA
function alpha.getDEMA(symbol,interval,time_period,series_type)
	return technicalParsers("DEMA",symbol,interval,time_period,series_type)
end
-- api.TEMA
function alpha.getTEMA(symbol,interval,time_period,series_type)
	return technicalParsers("TEMA",symbol,interval,time_period,series_type)
end
-- api.TRIMA
function alpha.getTRIMA(symbol,interval,time_period,series_type)
	return technicalParsers("TRIMA",symbol,interval,time_period,series_type)
end
-- api.KAMA
function alpha.getKAMA(symbol,interval,time_period,series_type)
	return technicalParsers("KAMA",symbol,interval,time_period,series_type)
end
-- api.MAMA
function alpha.getMAMA(symbol,interval,time_period,series_type,fastlimit,slowlimit)
	return technicalParsers("MAMA",symbol,interval,time_period,series_type,{
		fastlimit=fastlimit,
		slowlimit=slowlimit
	})
end
-- api.T3
function alpha.getT3(symbol,interval,time_period,series_type)
	return technicalParsers("T3",symbol,interval,time_period,series_type)
end
-- api.MACD
--fastperiod,slowperiod,signalperiod
function alpha.getMACD(symbol,interval,time_period,series_type,t)
	return technicalParsers("MACD",symbol,interval,time_period,series_type,t)
end
-- api.MACDEXT
--fastperiod,slowperiod,signalperiod,fastmatype,slowmatype,signalmatype
function alpha.getMACDEXT(symbol,interval,time_period,series_type,t)
	return technicalParsers("MACDEXT",symbol,interval,time_period,series_type,t)
end
-- api.STOCH
--fastkperiod,slowkperiod,slowdperiod,slowkmatype,slowdmatype
function alpha.getSTOCH(symbol,t)
	return technicalParsers2("STOCH",symbol,t)
end
-- api.STOCHF
function alpha.getSTOCHF(symbol,interval,t)
	local t = t or {
		interval = interval or "monthly"
	}
	return technicalParsers2("STOCHF",symbol,t)
end
-- api.RSI
function alpha.getRSI(symbol,interval,time_period,series_type)
	return technicalParsers("RSI",symbol,interval,time_period,series_type)
end
-- api.STOCHRSI
function alpha.getSTOCHRSI(symbol,interval,time_period,series_type)
	return technicalParsers("STOCHRSI",symbol,interval,time_period,series_type)
end
-- api.WILLR
function alpha.getWILLR(symbol,interval,time_period,t)
	t = t or {}
	interval = interval or "monthly"
	time_period=time_period or "60"
	if not _interval[interval] then
		return nil,interval.." is not a supported interval that can be used"
	end
	t.interval=interval
	t.time_period=time_period
	return technicalParsers2("WILLR",symbol,t)
end
-- api.ADX
function alpha.getADX(symbol,interval,time_period,t)
	t = t or {}
	interval = interval or "monthly"
	time_period=time_period or "60"
	if not _interval[interval] then
		return nil,interval.." is not a supported interval that can be used"
	end
	t.interval=interval
	t.time_period=time_period
	return technicalParsers2("ADX",symbol,t)
end
-- api.ADXR
function alpha.getADXR(symbol,interval,time_period,t)
	t = t or {}
	interval = interval or "monthly"
	time_period=time_period or "60"
	if not _interval[interval] then
		return nil,interval.." is not a supported interval that can be used"
	end
	t.interval=interval
	t.time_period=time_period
	return technicalParsers2("ADXR",symbol,t)
end
-- api.APO
function alpha.getAPO(symbol,interval,time_period,series_type,t)
	return technicalParsers("APO",symbol,interval,time_period,series_type,t)
end
-- api.PPO
function alpha.getPPO(symbol,interval,time_period,series_type,t)
	return technicalParsers("PPO",symbol,interval,time_period,series_type,t)
end
-- api.MOM
function alpha.getMOM(symbol,interval,time_period,series_type)
	return technicalParsers("MOM",symbol,interval,time_period,series_type)
end
-- api.BOP
function alpha.getBOP(symbol,interval)
	t = t or {}
	interval = interval or "monthly"
	if not _interval[interval] then
		return nil,interval.." is not a supported interval that can be used"
	end
	t.interval=interval
	return technicalParsers2("BOP",symbol,t)
end
-- api.CCI
function alpha.getCCI(symbol,interval,time_period)
	t = t or {}
	interval = interval or "monthly"
	time_period=time_period or "60"
	if not _interval[interval] then
		return nil,interval.." is not a supported interval that can be used"
	end
	t.interval=interval
	t.time_period=time_period
	return technicalParsers2("CCI",symbol,t)
end
-- api.CMO
function alpha.getCMO(symbol,interval,time_period,series_type)
	return technicalParsers("CMO",symbol,interval,time_period,series_type)
end
-- api.ROC
function alpha.getROC(symbol,interval,time_period,series_type)
	return technicalParsers("ROC",symbol,interval,time_period,series_type)
end
-- api.ROCR
function alpha.getROCR(symbol,interval,time_period,series_type)
	return technicalParsers("ROCR",symbol,interval,time_period,series_type)
end
-- api.AROON
function alpha.getAROON(symbol,interval,time_period)
	t = t or {}
	interval = interval or "monthly"
	time_period=time_period or "60"
	if not _interval[interval] then
		return nil,interval.." is not a supported interval that can be used"
	end
	t.interval=interval
	t.time_period=time_period
	return technicalParsers2("AROON",symbol,t)
end
-- api.AROONOSC
function alpha.getAROONOSC(symbol,interval,time_period)
	t = t or {}
	interval = interval or "monthly"
	time_period=time_period or "60"
	if not _interval[interval] then
		return nil,interval.." is not a supported interval that can be used"
	end
	t.interval=interval
	t.time_period=time_period
	return technicalParsers2("AROONOSC",symbol,t)
end
-- api.MFI
function alpha.getMFI(symbol,interval,time_period)
	t = t or {}
	interval = interval or "monthly"
	time_period=time_period or "60"
	if not _interval[interval] then
		return nil,interval.." is not a supported interval that can be used"
	end
	t.interval=interval
	t.time_period=time_period
	return technicalParsers2("MFI",symbol,t)
end
-- api.TRIX
function alpha.getTRIX(symbol,interval,time_period,series_type)
	return technicalParsers("TRIX",symbol,interval,time_period,series_type)
end
-- api.ULTOSC
function alpha.getULTOSC(symbol,interval,t)
	t = t or {}
	interval = interval or "monthly"
	if not _interval[interval] then
		return nil,interval.." is not a supported interval that can be used"
	end
	t.interval=interval
	t.time_period=time_period
	return technicalParsers2("ULTOSC",symbol,t)
end
-- api.DX
function alpha.getDX(symbol,interval,time_period)
	t = t or {}
	interval = interval or "monthly"
	time_period=time_period or "60"
	if not _interval[interval] then
		return nil,interval.." is not a supported interval that can be used"
	end
	t.interval=interval
	t.time_period=time_period
	return technicalParsers2("DX",symbol,t)
end
-- api.MINUS_DI
function alpha.getMinusDI(symbol,interval,time_period)
	t = t or {}
	interval = interval or "monthly"
	time_period=time_period or "60"
	if not _interval[interval] then
		return nil,interval.." is not a supported interval that can be used"
	end
	t.interval=interval
	t.time_period=time_period
	return technicalParsers2("MINUS_DI",symbol,t)
end
-- api.PLUS_DI
function alpha.getPlusDI(symbol,interval,time_period)
	t = t or {}
	interval = interval or "monthly"
	time_period=time_period or "60"
	if not _interval[interval] then
		return nil,interval.." is not a supported interval that can be used"
	end
	t.interval=interval
	t.time_period=time_period
	return technicalParsers2("PLUS_DI",symbol,t)
end
-- api.MINUS_DM
function alpha.getMinusDM(symbol,interval,time_period)
	t = t or {}
	interval = interval or "monthly"
	time_period=time_period or "60"
	if not _interval[interval] then
		return nil,interval.." is not a supported interval that can be used"
	end
	t.interval=interval
	t.time_period=time_period
	return technicalParsers2("MINUS_DM",symbol,t)
end
-- api.PLUS_DM
function alpha.getPlusDM(symbol,interval,time_period)
	t = t or {}
	interval = interval or "monthly"
	time_period=time_period or "60"
	if not _interval[interval] then
		return nil,interval.." is not a supported interval that can be used"
	end
	t.interval=interval
	t.time_period=time_period
	return technicalParsers2("PLUS_DM",symbol,t)
end
-- api.BBANDS
function alpha.getBBands(symbol,interval,time_period,series_type,t)
	return technicalParsers("BBANDS",symbol,interval,time_period,series_type,t)
end
-- api.MIDPOINT
function alpha.getMidpoint(symbol,interval,time_period,series_type)
	return technicalParsers("MIDPOINT",symbol,interval,time_period,series_type)
end
-- api.MIDPRICE
function alpha.getMidprice(symbol,interval,time_period)
	t = t or {}
	interval = interval or "monthly"
	time_period=time_period or "60"
	if not _interval[interval] then
		return nil,interval.." is not a supported interval that can be used"
	end
	t.interval=interval
	t.time_period=time_period
	return technicalParsers2("MIDPRICE",symbol,t)
end
-- api.SAR
function alpha.getSAR(symbol,interval,t)
	t = t or {}
	interval = interval or "monthly"
	if not _interval[interval] then
		return nil,interval.." is not a supported interval that can be used"
	end
	t.interval=interval
	return technicalParsers2("SAR",symbol,t)
end
-- api.TRANGE
function alpha.getTRange(symbol,interval)
	t = t or {}
	interval = interval or "monthly"
	if not _interval[interval] then
		return nil,interval.." is not a supported interval that can be used"
	end
	t.interval=interval
	return technicalParsers2("TRANGE",symbol,t)
end
-- api.ATR
function alpha.getATR(symbol,interval,time_period)
	t = t or {}
	interval = interval or "monthly"
	time_period=time_period or "60"
	if not _interval[interval] then
		return nil,interval.." is not a supported interval that can be used"
	end
	t.interval=interval
	t.time_period=time_period
	return technicalParsers2("ATR",symbol,t)
end
-- api.NATR
function alpha.getNATR(symbol,interval,time_period)
	t = t or {}
	interval = interval or "monthly"
	time_period=time_period or "60"
	if not _interval[interval] then
		return nil,interval.." is not a supported interval that can be used"
	end
	t.interval=interval
	t.time_period=time_period
	return technicalParsers2("NATR",symbol,t)
end
-- api.AD
function alpha.getAD(symbol,interval)
	t = t or {}
	interval = interval or "monthly"
	if not _interval[interval] then
		return nil,interval.." is not a supported interval that can be used"
	end
	t.interval=interval
	return technicalParsers2("AD",symbol,t)
end
-- api.ADOSC
function alpha.getADOSC(symbol,interval)
	t = t or {}
	interval = interval or "monthly"
	if not _interval[interval] then
		return nil,interval.." is not a supported interval that can be used"
	end
	t.interval=interval
	return technicalParsers2("ADOSC",symbol,t)
end
-- api.OBV
function alpha.getOBV(symbol,interval)
	t = t or {}
	interval = interval or "monthly"
	if not _interval[interval] then
		return nil,interval.." is not a supported interval that can be used"
	end
	t.interval=interval
	return technicalParsers2("OBV",symbol,t)
end
-- api.HT_TRENDLINE
function alpha.getHTTrendLine(symbol,interval,time_period,series_type,t)
	return technicalParsers("HT_TRENDLINE",symbol,interval,time_period,series_type,t)
end
-- api.HT_SINE
function alpha.getHTSine(symbol,interval,time_period,series_type,t)
	return technicalParsers("HT_SINE",symbol,interval,time_period,series_type,t)
end
-- api.HT_TRENDMODE
function alpha.getHTTrendMode(symbol,interval,time_period,series_type,t)
	return technicalParsers("HT_TRENDMODE",symbol,interval,time_period,series_type,t)
end
-- api.HT_DCPERIOD
function alpha.getHTDCPeriod(symbol,interval,time_period,series_type,t)
	return technicalParsers("HT_DCPERIOD",symbol,interval,time_period,series_type,t)
end
-- api.HT_DCPHASE
function alpha.getHTDCPhase(symbol,interval,time_period,series_type,t)
	return technicalParsers("HT_DCPHASE",symbol,interval,time_period,series_type,t)
end
-- api.HT_PHASOR
function alpha.getHTPhasor(symbol,interval,time_period,series_type,t)
	return technicalParsers("HT_PHASOR",symbol,interval,time_period,series_type,t)
end
-- api.SECTOR
function alpha.getSectorPreformance()
	local raw = request("https://www.alphavantage.co/query?function=SECTOR&apikey="..alpha.APIKey)
	raw=raw:gsub("  ","")
	local c = {}
	for section,data in raw:gmatch([["(.-)": {.(.-).}]]) do
		_section,desc = section:match("(.-): (.+)")
		if _section then
			_section=_section:gsub(" ","")
			section = _section
			c[section]={}
			c[section].Desc = desc
		else
			c[section]={}
		end
		for var,val in data:gmatch([["(.-)": "(.-)",?]]) do
			c[section][var]=val
		end
	end
	return c
end
return alpha
