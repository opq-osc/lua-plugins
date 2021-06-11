local Api = require("coreApi")
local http = require("http")
local json = require("json")
local log = require("log")

function ReceiveFriendMsg(CurrentQQ, data) return 1 end

function ReceiveGroupMsg(CurrentQQ, data)
    if data.FromUserId == tonumber(CurrentQQ) then return 1 end
    local admin_data = Read("./Plugins/data/管理员列表/" ..
                                data.FromGroupId .. ".txt")
    if string.find(admin_data, CurrentQQ) then
        local is_admin = 0
        local admins = json.decode(admin_data)
        for _, admin in ipairs(admins) do
            if admin == data.FromUserId then
                log.info("%s", "匹配到管理员")
                is_admin = 1
            end
        end
        if data.MsgType == "TextMsg" then
            if is_admin == 0 then
                if data.Content:find("禅定模式") == 1 then
                    num = math.floor(time_cal(data.Content))
                    if num > 0 and num < 43200 then
                        shut_user(CurrentQQ, data.FromGroupId, data.FromUserId,
                                  num)
                        send_text_to_group(CurrentQQ, data,
                                           "恭喜您荣获 " .. num ..
                                               "分钟 禁言，特此表彰")
                    end

                    return 1
                end
                result = swear(data.Content)
                if result == "pass" then
                    return 1
                else
                    log.info("黑名单关键词匹配成功==============>%s",
                             result)
                    math.randomseed(os.time())
                    luck = math.random(1, 100)
                    if (luck == 25) then
                        shut_time = 30
                    else
                        math.randomseed(os.time() * os.time())
                        shut_time = math.ceil(math.random(60, 600) / 60)
                    end
                    shut_user(CurrentQQ, data.FromGroupId, data.FromUserId,
                              shut_time)
                    os.execute('sleep 1')
                    strArray = {
                        data.FromNickName ..
                            "，恭喜你喜提禁言套餐一份，约" ..
                            shut_time .. "分钟后解除禁言", "啊这",
                        "sm?", "哦？", "刺激嗷", "你好怪哦",
                        "找禁？勉强满足你吧",
                        "别水群了，做点其他事吧"
                    }
                    math.randomseed(os.time() + os.time())
                    str = strArray[math.random(1, #strArray)]
                    send_at_to_group(CurrentQQ, data, str)
                end
            end
        end
        if data.MsgType == "AtMsg" and is_admin == 1 then
            jData = json.decode(data.Content)
            if jData.Content:find("禁言") or jData.Content:find("cj") or
                jData.Content:find("惩戒") then
                num = time_cal(jData.Content)
                if num == 0 then num = 1 end
                for _, uid in ipairs(jData.UserID) do
                    shut_user(CurrentQQ, data.FromGroupId, uid, num)
                end
            end
            if jData.Content:find("解禁") or jData.Content:find("jj") then
                for _, uid in ipairs(jData.UserID) do
                    shut_user(CurrentQQ, data.FromGroupId, uid, 0)
                end
            end
        end
    end
    return 1

end

function ReceiveEvents(CurrentQQ, data, extData)
    if data.MsgType == "ON_EVENT_GROUP_ADMIN" then
        os.execute("mkdir -p Plugins/data/管理员列表/")
        local admin_file =
            "./Plugins/data/管理员列表/" .. extData.GroupID .. ".txt"
        local admin_data = Read(admin_file)
        if admin_data == nil then Wirte(admin_file, "[]") end

        local admins = json.decode(admin_data)
        if extData.Flag == 0 then
            for i = 1, #admins, 1 do
                if admins[i] == extData.UserID then
                    table.remove(admins, i)
                    Wirte(admin_file, json.encode(admins))
                end
            end
        end
        if extData.Flag == 1 then
            table.insert(admins, extData.UserID)
            Wirte(admin_file, json.encode(admins))
        end

        str = string.format("群管变更事件 GroupID %d UserID %d  Flag %d",
                            extData.GroupID, extData.UserID, extData.Flag)
        -- Flag 1升管理0将管理
        log.notice("%s", str)
    end
    return 1
end

function time_cal(content)
    local num = 0
    if content:find("%d*%.?%d+") then
        num = 1
        days = content:match("(%d*%.?%d+)天")
        hours = content:match("(%d*%.?%d+)小时")
        minutes = content:match("(%d*%.?%d+)分钟")
        seconds = content:match("(%d*%.?%d+)秒")
        if tonumber(days) then num = num + tonumber(days) * 60 * 24 end
        if tonumber(hours) then num = num + tonumber(hours) * 60 end
        if tonumber(minutes) then num = num + tonumber(minutes) end
        if tonumber(seconds) then num = num + tonumber(seconds) / 60 end
        if num > 1 then num = num - 1 end
    end
    return num
end

function shut_user(CurrentQQ, gid, uid, shut_time)
    Api.Api_CallFunc(CurrentQQ, "OidbSvc.0x570_8",
                     {GroupID = gid, ShutUpUserID = uid, ShutTime = shut_time})
end
function send_at_to_group(CurrentQQ, data, content)
    if (data.MsgType == "AtMsg") then
        raw = json.decode(data.Content).Content
    else
        raw = data.Content
    end
    Api.Api_SendMsgV2(CurrentQQ, {
        ToUserUid = data.FromGroupId,
        SendToType = 2,
        SendMsgType = "ReplayMsg",
        Content = content,
        ReplayInfo = {
            MsgSeq = data.MsgSeq,
            MsgTime = data.MsgTime,
            UserID = data.FromUserId,
            RawContent = raw
        }
    })
end

function send_text_to_group(CurrentQQ, data, content)
    Api.Api_SendMsgV2(CurrentQQ, {
        ToUserUid = data.FromGroupId,
        SendToType = 2,
        SendMsgType = "TextMsg",
        Content = content
    })
end

function swear(content)
    black_list = {
        "来.*禁言套餐", "有种禁言我", "求禁言", "狗管理",
        "狗群主"
    }
    for i = 1, #black_list, 1 do
        if string.find(content, black_list[i]) then return black_list[i] end
    end
    return "pass"
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
