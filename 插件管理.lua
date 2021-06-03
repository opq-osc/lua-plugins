local log = require("log")
local Api = require("coreApi")
local json = require("json")
local http = require("http")

local admin_qq = xxxxxxx -- 换为自己的QQ号

function ReceiveFriendMsg(CurrentQQ, data)
    log.notice("From stop.lua  ReceiveFriendMsg %s", CurrentQQ)
    return 1
end
function ReceiveGroupMsg(CurrentQQ, data)
    if data.FromUserId == admin_qq then
        if data.FromUserId == tonumber(CurrentQQ) then return 1 end
        if string.find(data.Content, "停用") then -- 指令
            file = data.Content:gsub("停用 ", "")
            file = file:gsub("停用", "")
            log.info("停用插件===========>%s", file)
            filePath = string.format("./Plugins/%s.lua", file)
            newPath = string.format("./Plugins/%s.lua.bak", file)
            if os.rename(filePath, newPath) then
                Api.Api_SendMsg(CurrentQQ, {
                    toUser = data.FromGroupId,
                    sendToType = 2,
                    sendMsgType = "TextMsg",
                    groupid = 0,
                    content = "插件「" .. file .. "」停用成功",
                    atUser = 0
                })
            end
        end
        if string.find(data.Content, "启用") then -- 指令
            file = data.Content:gsub("启用 ", "")
            file = file:gsub("启用", "")
            log.info("启用插件===========>%s", file)
            filePath = string.format("./Plugins/%s.lua.bak", file)
            newPath = string.format("./Plugins/%s.lua", file)
            if os.rename(filePath, newPath) then
                Api.Api_SendMsg(CurrentQQ, {
                    toUser = data.FromGroupId,
                    sendToType = 2,
                    sendMsgType = "TextMsg",
                    groupid = 0,
                    content = "插件「" .. file .. "」启用成功",
                    atUser = 0
                })
            end
        end
    end
    if data.Content == '插件列表' then
        if data.FromUserId == admin_qq then -- 换为自己的QQ号
            if data.FromUserId == tonumber(CurrentQQ) then return 1 end
            local ts = io.popen("ls ./Plugins/*lua*")
            local ls = ts:read("*all")
            ls = ls:gsub(".lua", "")
            ls = ls:gsub("./Plugins/", "")
            log.info("插件=====%s", ls)
            Api.Api_SendMsg(CurrentQQ, {
                toUser = data.FromGroupId,
                sendToType = 2,
                sendMsgType = "TextMsg",
                groupid = 0,
                content = "目前所有插件：\n" .. ls ..
                    "15s后销毁该条消息",
                atUser = 0
            })
        end
    end
    return 1
end
function ReceiveEvents(CurrentQQ, data, extData) return 1 end
