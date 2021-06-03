local log = require("log")
local Api = require("coreApi")
local json = require("json")
local http = require("http")
function ReceiveFriendMsg(CurrentQQ, data)
    if string.find(data.Content, "翻译") == 1 then
        local keyword = ""
        local sl = "auto"
        local tl = "en"
        if string.find(data.Content, "翻译成中文") == 1 then
            keyword = data.Content:gsub("翻译成中文 ", "")
            keyword = keyword:gsub("翻译成中文", "")
            tl = "zh-CN"
        end
        if string.find(data.Content, "翻译成英文") == 1 then
            keyword = data.Content:gsub("翻译成英文", "")
            keyword = keyword:gsub("翻译成英文", "")
            tl = "en"
        end
        if string.find(data.Content, "翻译成日文") == 1 then
            keyword = data.Content:gsub("翻译成日文", "")
            keyword = keyword:gsub("翻译成日文", "")
            tl = "ja-JP"
        end
        if keyword ~= "" then
            keyword = url_encode(keyword)
            log.notice("keyword-->%s", keyword)
            response, error_message = http.request("GET",
                                                   "http://translate.google.cn/translate_a/single?",
                                                   {
                query = "client=gtx&sl=" .. sl .. "&tl=" .. tl .. "&dt=t&q=" ..
                    keyword,

                headers = {}
            })
            local html = response.body
            log.notice("html-->%s", html)
            local re = json.decode(html)
            local resultstr = re[1][1][1]
            sendfriendresult(CurrentQQ, data, resultstr)
            keyword = nil
            sl = nil
            tl = nil
        end
    end
    return 1
end
function ReceiveGroupMsg(CurrentQQ, data)
    if string.find(data.Content, "翻译") == 1 then
        local keyword = ""
        local sl = "auto"
        local tl = "en"
        if string.find(data.Content, "翻译成中文") == 1 then
            keyword = data.Content:gsub("翻译成中文 ", "")
            keyword = keyword:gsub("翻译成中文", "")
            tl = "zh-CN"
        end
        if string.find(data.Content, "翻译成英文") == 1 then
            keyword = data.Content:gsub("翻译成英文", "")
            keyword = keyword:gsub("翻译成英文", "")
            tl = "en"
        end
        if string.find(data.Content, "翻译成日文") == 1 then
            keyword = data.Content:gsub("翻译成日文", "")
            keyword = keyword:gsub("翻译成日文", "")
            tl = "ja-JP"
        end
        if keyword ~= "" then
            keyword = url_encode(keyword)
            log.notice("keyword-->%s", keyword)
            response, error_message = http.request("GET",
                                                   "http://translate.google.cn/translate_a/single?",
                                                   {
                query = "client=gtx&sl=" .. sl .. "&tl=" .. tl .. "&dt=t&q=" ..
                    keyword,

                headers = {}
            })
            local html = response.body
            log.notice("html-->%s", html)
            local re = json.decode(html)
            local resultstr = re[1][1][1]
            sendgroupresult(CurrentQQ, data, resultstr)
            keyword = nil
            sl = nil
            tl = nil
        end
    end
    return 1
end
function ReceiveEvents(CurrentQQ, data, extData) return 1 end

function sendgroupresult(CurrentQQ, data, resultstr)
    if resultstr == "" then return 1 end
    ApiRet = Api.Api_SendMsg(CurrentQQ, {
        toUser = data.FromGroupId,
        sendToType = 2,
        sendMsgType = "TextMsg",
        groupid = 0,
        content = "翻译结果:" .. resultstr,
        atUser = 0

    })
    return 1
end
function sendfriendresult(CurrentQQ, data, resultstr)
    if resultstr == "" then return 1 end
    ApiRet = Api.Api_SendMsg(CurrentQQ, {

        toUser = data.FromUin,
        sendToType = 1,
        sendMsgType = "TextMsg",
        groupid = 0,
        content = "翻译结果:" .. resultstr,
        atUser = 0

    })
    return 1
end

function url_encode(str)
    if (str) then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w ])", function(c)
            return string.format("%%%02X", string.byte(c))
        end)
        str = string.gsub(str, " ", "+")
    end
    return str
end

function url_decode(str)
    str = string.gsub(str, "+", " ")
    str = string.gsub(str, "%%(%x%x)",
                      function(h) return string.char(tonumber(h, 16)) end)
    str = string.gsub(str, "\r\n", "\n")
    return str
end
