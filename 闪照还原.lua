local log = require("log")
local Api = require("coreApi")
local json = require("json")
local http = require("http")

local admin_qq = xxxxxxx -- 换为自己的QQ号

function ReceiveFriendMsg(CurrentQQ, data) return 1 end
function ReceiveGroupMsg(CurrentQQ, data)
    flash_file = "Plugins/data/闪照还原/" .. data.FromGroupId .. ".txt"
    if data.Content == "开启闪照还原" then
        os.execute("mkdir -p Plugins/data/闪照还原/")
        Wirte(flash_file, "开启")
        send_text_to_group(CurrentQQ, data.FromGroupId, "已开启")
        return 1
    end
    if data.Content == "关闭闪照还原" then
        os.execute("mkdir -p Plugins/data/闪照还原/")
        Wirte(flash_file, "关闭")
        send_text_to_group(CurrentQQ, data.FromGroupId, "已关闭")
        return 1
    end
    str = Read(flash_file)
    if str ~= nil and string.find(str, "关闭") then return 1 end

    if (data.FromUserId == tonumber(CurrentQQ) or data.FromUserId == admin_qq) then return 1 end

    if string.find(data.Content, "请使用新版手机QQ查看闪照。") then
        local image = data.Content:match("[a-zA-z]+://[^\s]*")
        ApiRet = Api.Api_SendMsg(CurrentQQ, {
            toUser = data.FromGroupId,
            sendToType = 2,
            sendMsgType = "PicMsg",
            content = "偷偷发闪照？",
            atUser = 0,
            voiceUrl = "",
            voiceBase64Buf = "",
            picUrl = "" .. image .. "",
            picBase64Buf = "",
            fileMd5 = ""
        })
    end
    return 1
end
function ReceiveEvents(CurrentQQ, data, extData) return 1 end
function send_text_to_group(CurrentQQ, toUid, str)
    Api.Api_SendMsgV2(CurrentQQ, {
        ToUserUid = toUid,
        SendToType = 2,
        SendMsgType = "TextMsg",
        Content = str
    })
end

function Read(url)
    file = io.open(url, "r")
    if (file == nil) then
        return nil
    else
        file:seek("set")
        str = file:read("*a")
        file:close()
        return str
    end
end

function Wirte(url, msg)
    file = io.open(url, "w+")
    file:write(msg)
    file:close()
    return "ok"
end
