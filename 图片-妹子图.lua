local log = require("log")
local Api = require("coreApi")
local json = require("json")
local http = require("http")

function ReceiveFriendMsg(CurrentQQ, data)
    if data.MsgType ~= "TempSessionMsg" then
        if string.find(data.Content, "妹子图") == 1 then
            send_to_friend(CurrentQQ, data, "http://116.62.167.164:8080/mzt")
            send_to_friend(CurrentQQ, data,
                           "https://api.169740.com/api/rand.img2?")
            send_to_friend(CurrentQQ, data, "http://api.btstu.cn/sjbz/?lx=meizi")
            send_to_friend(CurrentQQ, data, "https://api.lyh6.top/api.php")
            send_to_friend(CurrentQQ, data, "https://api88.net/api/img/rand/")
        end
    end
    if data.MsgType == "TempSessionMsg" and data.ToUin == tonumber(CurrentQQ) then
        if string.find(data.Content, "妹子图") == 13 then
            send_to_private(CurrentQQ, data, "http://116.62.167.164:8080/mzt")
            send_to_private(CurrentQQ, data,
                            "https://api.169740.com/api/rand.img2?")
            send_to_private(CurrentQQ, data,
                            "http://api.btstu.cn/sjbz/?lx=meizi")
            send_to_private(CurrentQQ, data, "https://api.lyh6.top/api.php")
            send_to_friend(CurrentQQ, data, "https://api88.net/api/img/rand/")
        end
    end
    return 1
end
function ReceiveGroupMsg(CurrentQQ, data)
    if string.find(data.Content, "妹子图") == 1 then
        meizi_api_array = {
            "http://116.62.167.164:8080/mzt",
            "http://127.0.0.1:222/meizi/?type=purelady",
            "http://api.btstu.cn/sjbz/?lx=meizi",
            "https://apikey.net/?type=Mimg",
            "https://api88.net/api/img/rand/",
            "http://127.0.0.1:222/meizi/?type=purelady"
        }
        math.randomseed(os.time())
        i = math.random(1, #meizi_api_array)
        img_url = meizi_api_array[i]
        log.notice("the img_url is %s", img_url)
        send_to_group(CurrentQQ, data, img_url)
    end
    return 1
end
function ReceiveEvents(CurrentQQ, data, extData) return 1 end

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

function send_to_group(CurrentQQ, data, img_url)
    Api.Api_SendMsgV2(CurrentQQ, {
        ToUserUid = data.FromGroupId,
        SendToType = 2,
        SendMsgType = "PicMsg",
        Content = "",
        PicUrl = img_url
    })
end
