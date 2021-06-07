local log = require("log")
local Api = require("coreApi")
local json = require("json")
local http = require("http")

local dictionary = {}
function ReceiveFriendMsg(CurrentQQ, data)
    if string.find(data.Content, "天气") == 1 and data.MsgType ~=
        "TempSessionMsg" then
        city = data.Content:gsub("天气", "")
        log.notice("keyword-->%s", city)
        if city == "" then return 1 end
        str = weather(city)
        Api.Api_SendMsg(CurrentQQ, {
            toUser = data.FromUin,
            sendToType = 1,
            sendMsgType = "TextMsg",
            groupid = 0,
            content = str,
            atUser = 0
        })
    end
    if string.find(data.Content, "天气") == 1 and data.MsgType ==
        "TempSessionMsg" and data.ToUin == tonumber(CurrentQQ) then
        city = data.Content:gsub("天气", "")
        log.notice("keyword-->%s", city)
        if city == "" then return 1 end
        str = weather(city)
        Api.Api_SendMsg(CurrentQQ, {
            toUser = data.FromUin,
            sendToType = 3,
            sendMsgType = "TextMsg",
            groupid = data.TempUin,
            content = str,
            atUser = 0
        })
    end
    return 1
end
function ReceiveGroupMsg(CurrentQQ, data)
    if string.find(data.Content, "天气") == 1 then
        if string.find(data.Content, "天气i") or string.find(data.Content, "真") or string.find(data.Content, "不" )or string.find(data.Content, "了") or string.find(data.Content, "菜单") or string.find(data.Content, "啊") or string.find(data.Content, "，") or string.find(data.Content, "？") or string.find(data.Content, "?") then return 1 end
        city = data.Content:gsub("天气 ", "")
        city = city:gsub("天气", "")
        log.notice("keyword-->%s", city)
        if city == "" then return 1 end
        j = weather(city)
        local str = ""
        if j == "error" and string.find(data.Content, "天气 ") == 1 then
            local weather_code = {
                "201", "202", "203", "204", "204", "204", "204", "204", "204",
                "204", "204", "204", "205", "205", "205", "206", "206", "207",
                "207", "206", "208", "208"
            }
            math.randomseed(os.time())
            str = string.format(
                      [[{"app":"com.tencent.weather","desc":"天气","view":"RichInfoView","ver":"0.0.0.1","prompt":"[应用]天气","meta":{"richinfo":{"adcode":"","air":"5","city":"%s","date":"%s","max":"%s","min":"-%s","ts":"15158613","type":"%s","wind":""}},"config":{"forward":1,"autosize":1,"type":"card"}}]],
                      city, os.date("%m月%d日", os.time()),
                      math.random(20, 40000), math.random(20, 20000),
                      weather_code[math.random(1, #weather_code)])
        else
            local weather_code_map = {
                ["晴"] = "201",
                ["多云"] = "202",
                ["阴"] = "203",
                ["雨"] = "204",
                ["小雨"] = "204",
                ["中雨"] = "204",
                ["大雨"] = "204",
                ["暴雨"] = "204",
                ["大暴雨"] = "204",
                ["特大暴雨"] = "204",
                ["阵雨"] = "204",
                ["雷雨"] = "204",
                ["雪"] = "205",
                ["雨夹雪"] = "205",
                ["冰雹"] = "205",
                ["大雾"] = "206",
                ["浓雾"] = "206",
                ["扬尘"] = "207",
                ["沙尘暴"] = "207",
                ["雾"] = "206",
                ["霾"] = "208",
                ["雾霾"] = "208"
            }
            weather_code = weather_code_map[j.value[1].realtime.weather]
            str = string.format(
                      [[{"app":"com.tencent.weather","desc":"天气","view":"RichInfoView","ver":"1.0.0.217","prompt":"[应用]天气","meta":{"richinfo":{"adcode":"%s","air":"%s","city":"%s","date":"%s","max":"%s","min":"%s","ts":"1554951408","type":"%s","wind":"%s"}},"config":{"forward":1,"autosize":1,"type":"card"}}]],
                      tostring(j.value[1].cityid), j.value[1].pm25.aqi,
                      j.value[1].provinceName .. "-" .. j.value[1].city,
                      os.date("%m月%d日", os.time()) .. " " ..
                          j.value[1].weathers[1].week:gsub("星期", "周"),
                      j.value[1].weathers[1].temp_day_c,
                      j.value[1].weathers[1].temp_night_c, weather_code,
                      j.value[1].realtime.wS:gsub("级", ""))
        end
        log.notice("天气卡片-->%s", str)
        Api.Api_SendMsg(CurrentQQ, {
            toUser = data.FromGroupId,
            sendToType = 2,
            sendMsgType = "JsonMsg",
            groupid = 0,
            content = str,
            atUser = 0
        })
    end
    return 1
end
function ReceiveEvents(CurrentQQ, data, extData) return 1 end

function weather(city)
    city = city:gsub("市", "")
    city = city:gsub("区", "")
    local f, _ = io.open('./Plugins/data/stationID.json', "r")
    local content = f:read("*all")
    f:close()
    local ID_Data = json.decode(content)
    local city_id = ID_Data["m"][city]
    log.notice("city_id-->%s", city_id)
    if city_id then
        response, error_message = http.request("GET",
                                               "http://aider.meizu.com/app/weather/listWeather?cityIds=" ..
                                                   city_id)
        local html = response.body
        local j = json.decode(html)
        return j
    else
        return "error"
    end
end
