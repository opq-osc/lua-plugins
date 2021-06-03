local log = require("log")
local Api = require("coreApi")
local json = require("json")
local http = require("http")

function ReceiveFriendMsg(CurrentQQ, data)
    if data.MsgType ~= "TempSessionMsg" then
        if string.find(data.Content, "来点买家秀") == 1 then
            send_to_friend(CurrentQQ, data,
                           "http://127.0.0.1:222/meizi/?type=mjx")
        end
    end
    if data.MsgType == "TempSessionMsg" and data.ToUin == tonumber(CurrentQQ) then
        if string.find(data.Content, "来点买家秀") == 13 then
            send_to_private(CurrentQQ, data,
                            "http://127.0.0.1:222/meizi/?type=mjx")
        end
    end
    return 1
end
function ReceiveGroupMsg(CurrentQQ, data)
    if string.find(data.Content, "来点买家秀") == 1 then
        info = mjx()
        img_url = "http://127.0.0.1:222/meizi/mjx1/"..info.path
        log.notice("url:%s", img_url)
        content = "“" .. info.title .. "”"
        log.notice("comment:%s", content)
        send_pic_to_group(CurrentQQ, data.FromGroupId, content, img_url)
    end
    return 1
end
function ReceiveEvents(CurrentQQ, data, extData) return 1 end

function mjx()
    local type = {'f', 'g', 'h', 'i', 'a', 'b', 'c', 'd', 'e', 'j', 'k', 'l'}
    math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 7)))
    randomNum = math.random(12)
    response, error_message = http.request("GET", "http://127.0.0.1:222/meizi/",
                                           {
        query = "type=mjx1&c=" .. type[randomNum],
        headers = {
            ["Accept"] = "*/*",
            ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36"
        }
    })
    local html = response.body
    local info = json.decode(html)
    return info
end

function send_to_friend(CurrentQQ, data, img_url)
    Api.Api_SendMsg(CurrentQQ, {
        toUser = data.FromUin,
        sendToType = 1,
        sendMsgType = "PicMsg",
        groupid = 0,
        content = "",
        picUrl = img_url,
        picBase64Buf = "",
        fileMd5 = "",
        atUser = 0
    })
end

function send_to_private(CurrentQQ, data, img_url)
    Api.Api_SendMsg(CurrentQQ, {
        toUser = data.FromUin,
        sendToType = 3,
        sendMsgType = "PicMsg",
        groupid = data.TempUin,
        content = "",
        picUrl = img_url,
        picBase64Buf = "",
        fileMd5 = "",
        atUser = 0
    })
end

function send_pic_to_group(CurrentQQ, toUid, str, img_url)
    Api.Api_SendMsgV2(CurrentQQ, {
        ToUserUid = toUid,
        SendToType = 2,
        SendMsgType = "PicMsg",
        Content = str,
        PicUrl = img_url
    })
end
