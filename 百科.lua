local log = require("log")
local Api = require("coreApi")
local json = require("json")
local http = require("http")

function ReceiveFriendMsg(CurrentQQ, data)
    if string.find(data.Content, "百科") == 1 and data.MsgType ~=
        "TempSessionMsg" then
        keyword = data.Content:gsub("百科 ", "")
        keyword = keyword:gsub("百科", "")
        log.notice("keyword-->%s", keyword)
        local baike_data = baike(keyword)
        if baike_data == "" then return 1 end
        local str = "搜索「" .. keyword .. "」结果：\n" ..
                        baike_data['abstract'] .. "\n\n详情：" ..
                        baike_data['image']
        local img_url = baike_data["image"]
        Api.Api_SendMsg(CurrentQQ, {
            toUser = data.FromUin,
            sendToType = 1,
            sendMsgType = "PicMsg",
            groupid = 0,
            content = str,
            picUrl = img_url,
            picBase64Buf = "",
            fileMd5 = "",
            atUser = 0
        })
    end
    if data.MsgType == "TempSessionMsg" and data.ToUin == data.ToUin ==
        tonumber(CurrentQQ) and string.find(data.Content, "百科") == 13 then
        keyword = data.Content:gsub("百科 ", "")
        keyword = keyword:gsub("百科", "")
        log.notice("keyword-->%s", keyword)
        local baike_data = baike(keyword)
        if baike_data == "" then return 1 end
        local str = "搜索「" .. keyword .. "」结果：\n" ..
                        baike_data['abstract'] .. "\n\n详情：" ..
                        baike_data['url']
        local img_url = baike_data["image"]
        Api.Api_SendMsg(CurrentQQ, {
            toUser = data.FromUin,
            sendToType = 3,
            sendMsgType = "PicMsg",
            groupid = data.TempUin,
            content = str,
            picUrl = img_url,
            picBase64Buf = "",
            fileMd5 = "",
            atUser = 0
        })
    end
    return 1
end
function ReceiveGroupMsg(CurrentQQ, data)
    if string.find(data.Content, "百科") == 1 then
        keyword = data.Content:gsub("百科 ", "")
        keyword = keyword:gsub("百科", "")
        if keyword == "" then return 1 end
        log.notice("keyword-->%s", keyword)
        local baike_data = baike(keyword)
        if baike_data == "" then return 1 end
        local str = "搜索「" .. keyword .. "」结果：\n" ..
                        SubStringUTF8(baike_data['abstract'], 1, 200) ..
                        "..\n\n详情：" .. baike_data['url']
        log.notice("baike_data-->%s", str)
        local img_url = baike_data["image"]
        log.notice("cover-->%s", img_url)
        if img_url then
            Api.Api_SendMsg(CurrentQQ, {
                toUser = data.FromGroupId,
                sendToType = 2,
                sendMsgType = "PicMsg",
                content = str,
                picUrl = img_url,
                groupid = 0,
                picBase64Buf = "",
                fileMd5 = "",
                atUser = 0
            })
        else
            Api.Api_SendMsg(CurrentQQ, {
                toUser = data.FromGroupId,
                sendToType = 2,
                sendMsgType = "TextMsg",
                groupid = 0,
                content = str,
                atUser = 0
            })
        end
    end
    return 1
end
function ReceiveEvents(CurrentQQ, data, extData) return 1 end

function baike(keyword)
    if keyword == "" then return 1 end
    response, error_message = http.request("GET",
                                           "http://baike.baidu.com/api/openapi/BaikeLemmaCardApi",
                                           {
        query = "scope=103&format=json&appid=379020&bk_key=" ..
            url_encode(keyword) .. "&bk_length=600"
    })
    html = response.body
    local i = 1
    while (string.find(html, '"errno":2')) do
        if i >= 10 then
            return ""
        else
            response, error_message = http.request("GET",
                                                   "http://baike.baidu.com/api/openapi/BaikeLemmaCardApi",
                                                   {
                query = "scope=103&format=json&appid=379020&bk_key=" ..
                    url_encode(keyword) .. "&bk_length=600"
            })
            html = response.body
            i = i + 1
        end
    end
    local j = json.decode(html)
    return j
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

function SubStringUTF8(str, startIndex, endIndex)
    if startIndex < 0 then
        startIndex = SubStringGetTotalIndex(str) + startIndex + 1;
    end

    if endIndex ~= nil and endIndex < 0 then
        endIndex = SubStringGetTotalIndex(str) + endIndex + 1;
    end

    if endIndex == nil then
        return string.sub(str, SubStringGetTrueIndex(str, startIndex));
    else
        return string.sub(str, SubStringGetTrueIndex(str, startIndex),
                          SubStringGetTrueIndex(str, endIndex + 1) - 1);
    end
end

function SubStringGetTrueIndex(str, index)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat
        lastCount = SubStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until (curIndex >= index);
    return i - lastCount;
end

-- 获取中英混合UTF8字符串的真实字符数量
function SubStringGetTotalIndex(str)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat
        lastCount = SubStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until (lastCount == 0);
    return curIndex - 1;
end

-- 返回当前字符实际占用的字符数
function SubStringGetByteCount(str, index)
    local curByte = string.byte(str, index)
    local byteCount = 1;
    if curByte == nil then
        byteCount = 0
    elseif curByte > 0 and curByte <= 127 then
        byteCount = 1
    elseif curByte >= 192 and curByte <= 223 then
        byteCount = 2
    elseif curByte >= 224 and curByte <= 239 then
        byteCount = 3
    elseif curByte >= 240 and curByte <= 247 then
        byteCount = 4
    end
    return byteCount;
end
