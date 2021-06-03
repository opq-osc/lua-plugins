local log = require("log")
local Api = require("coreApi")
local json = require("json")
local http = require("http")

function ReceiveFriendMsg(CurrentQQ, data)
    if data.MsgType ~= "TempSessionMsg" then
        if string.find(data.Content, "随机") == 1 then
            Api.Api_SendMsg(CurrentQQ, {
                toUser = data.FromUin,
                sendToType = 1,
                sendMsgType = "PicMsg",
                groupid = 0,
                content = "",
                picUrl = "http://www.dmoe.cc/random.php",
                picBase64Buf = "",
                fileMd5 = "",
                atUser = 0
            })
        end
    end
    if data.MsgType == "TempSessionMsg" and data.ToUin == tonumber(CurrentQQ) then
        if string.find(data.Content, "随机") == 13 then
            Api.Api_SendMsg(CurrentQQ, {
                toUser = data.FromUin,
                sendToType = 3,
                sendMsgType = "PicMsg",
                groupid = data.TempUin,
                content = "",
                picUrl = "http://www.dmoe.cc/random.php",
                picBase64Buf = "",
                fileMd5 = "",
                atUser = 0
            })
        end
    end
    return 1
end
function ReceiveGroupMsg(CurrentQQ, data)
    if string.find(data.Content, "随机") == 1 then
        Api.Api_SendMsg(CurrentQQ, {
            toUser = data.FromGroupId,
            sendToType = 2,
            sendMsgType = "PicMsg",
            groupid = 0,
            content = "",
            picUrl = "http://www.dmoe.cc/random.php",
            picBase64Buf = "",
            fileMd5 = "",
            atUser = 0
        })
    end
    return 1
end
function ReceiveEvents(CurrentQQ, data, extData) return 1 end

