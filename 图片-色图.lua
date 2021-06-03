local log = require("log")
local Api = require("coreApi")
local json = require("json")
local http = require("http")
local mysql = require("mysql")

function ReceiveFriendMsg(CurrentQQ, data)
    if data.MsgType ~= "TempSessionMsg" then
        if string.find(data.Content, "来点色图") == 1 then
            local strJson = setu(1, 0)
            local img_url =
                "https://images.weserv.nl/?url=" .. strJson["url"] ..
                    "&output=webp"
            local img_url = strJson["url"]
            log.notice("the img_url is %s", img_url)
            local str = "标题：" .. strJson["title"] ..
                            "\nhttps://www.pixiv.net/artworks/" ..
                            strJson["pid"] .. "\n作者：" .. strJson["author"] ..
                            "\nhttps://www.pixiv.net/users/" .. strJson["uid"] ..
                            "\n原图：" .. strJson["url"]
            Api.Api_SendMsgV2(CurrentQQ, {
                ToUserUid = data.FromUin,
                SendToType = 1,
                SendMsgType = "PicMsg",
                Content = str,
                PicUrl = img_url
            })
        end
        if string.find(data.Content, "来点r18色图") == 1 then
            local strJson = setu(1, 1)
            local img_url =
                "https://images.weserv.nl/?url=" .. strJson["url"] ..
                    "&output=webp"
            local img_url = strJson["url"]
            log.notice("the img_url is %s", img_url)
            local str = "标题：" .. strJson["title"] ..
                            "\nhttps://www.pixiv.net/artworks/" ..
                            strJson["pid"] .. "\n作者：" .. strJson["author"] ..
                            "\nhttps://www.pixiv.net/users/" .. strJson["uid"] ..
                            "\n原图：" .. strJson["url"]
            Api.Api_SendMsgV2(CurrentQQ, {
                ToUserUid = data.FromUin,
                SendToType = 1,
                SendMsgType = "PicMsg",
                Content = str,
                PicUrl = img_url
            })
        end
    end
    if data.MsgType == "TempSessionMsg" and data.ToUin == tonumber(CurrentQQ) then
        if string.find(data.Content, "来点色图") == 13 then
            local strJson = setu(1, 0)
            local img_url =
                "https://images.weserv.nl/?url=" .. strJson["url"] ..
                    "&output=webp"
            local img_url = strJson["url"]
            log.notice("the img_url is %s", img_url)
            local str = "标题：" .. strJson["title"] ..
                            "\nhttps://www.pixiv.net/artworks/" ..
                            strJson["pid"] .. "\n作者：" .. strJson["author"] ..
                            "\nhttps://www.pixiv.net/users/" .. strJson["uid"] ..
                            "\n原图：" .. strJson["url"]
            Api.Api_SendMsgV2(CurrentQQ, {
                ToUserUid = data.FromUin,
                GroupID = data.TempUin,
                SendToType = 3,
                SendMsgType = "PicMsg",
                Content = str,
                PicUrl = img_url
            })
        end
        if string.find(data.Content, "来点r18色图") == 13 then
            local strJson = setu(1, 1)
            local img_url =
                "https://images.weserv.nl/?url=" .. strJson["url"] ..
                    "&output=webp"
            local img_url = strJson["url"]
            log.notice("the img_url is %s", img_url)
            local str = "标题：" .. strJson["title"] ..
                            "\nhttps://www.pixiv.net/artworks/" ..
                            strJson["pid"] .. "\n作者：" .. strJson["author"] ..
                            "\nhttps://www.pixiv.net/users/" .. strJson["uid"] ..
                            "\n原图：" .. strJson["url"]
            Api.Api_SendMsgV2(CurrentQQ, {
                ToUserUid = data.FromUin,
                GroupID = data.TempUin,
                SendToType = 3,
                SendMsgType = "PicMsg",
                Content = str,
                PicUrl = img_url
            })
        end
    end
    return 1
end
function ReceiveGroupMsg(CurrentQQ, data)
    if string.find(data.Content, "来.*色图") then
        if data.FromUserId == tonumber(CurrentQQ) then
            threshold = "ok"
        else
            threshold = setu_threshold(data)
        end
        if threshold == "ok" then

            if string.find(data.Content, "来点色图") == 1 or
                string.find(data.Content, "来张色图") == 1 or
                string.find(data.Content, "来份色图") == 1 then

                local strJson = setu(1, 0)
                local img_url = "https://images.weserv.nl/?url=" ..
                                    setu_json["url"] .. "&output=webp"
                send_pic_to_group(CurrentQQ, data.FromGroupId, "", img_url)
            end
            if string.find(data.Content, "来点r18色图") == 1 or
                string.find(data.Content, "来张r18色图") == 1 then
                setu_json = setu(1, 1)
                local img_url = "https://images.weserv.nl/?url=" ..
                                    setu_json["url"] .. "&output=webp"
                local img_url = setu_json["url"]
                local str = "30s后销毁该条消息，请快点冲，谢谢"

                send_pic_to_group(CurrentQQ, data.FromGroupId, str, img_url)
            end

            if string.find(data.Content, "来(%d+)张色图") == 1 then
                num = tonumber(data.Content:match("来(%d+)张色图"))
                if num > 10 and data.FromUserId ~= tonumber(CurrentQQ) then
                    send_to_group(CurrentQQ, data.FromGroupId,
                                  "要这么多色图你怎么不冲死呢?")
                else
                    send_to_group(CurrentQQ, data.FromGroupId,
                                  "正在发送ing[表情178][表情67]")
                    setu_json = setu(num, 0)
                    len = #setu_json
                    i = 1
                    while i <= len do
                        os.execute('sleep 0.8')
                        send_pic_to_group(CurrentQQ, data.FromGroupId, "",
                                          setu_json[i])
                        i = i + 1
                    end
                end
            end
        else
            if threshold == "user_is_locked" then
                send_to_group(CurrentQQ, data.FromGroupId,
                              "要这么多色图你怎么不冲死呢?")
            end
            if threshold == "group_is_locked" then
                send_to_group(CurrentQQ, data.FromGroupId,
                              "淦 你们身体这么好的吗?")
            end
        end
    end
    return 1
end
function ReceiveEvents(CurrentQQ, data, extData) return 1 end

function setu(num, r)
    local f, _ = io.open('./Plugins/data/setu.json', "r")
    if r == 1 then
        f, _ = io.open('./Plugins/data/setu_r18.json', "r")
    end
    local content = f:read("*all")
    f:close()
    local setu_data = json.decode(content)
    if num == 1 then
        math.randomseed(os.time())
        setu_json = setu_data[math.random(1, #setu_data)]
    else
        setu_json = {}
        for i = 1, num, 1 do
            math.randomseed(os.time()*i)
            setu_json[i] = setu_data[math.random(1, #setu_data)]["url"]
        end
    end
    return setu_json
end

function send_to_group(CurrentQQ, toUid, content)
    Api.Api_SendMsgV2(CurrentQQ, {
        ToUserUid = toUid,
        SendToType = 2,
        SendMsgType = "TextMsg",
        Content = content
    })
end

function send_pic_to_group(CurrentQQ, toUid, str, img_url)
    log.notice("the setu_img_url is %s", img_url)
    Api.Api_SendMsgV2(CurrentQQ, {
        ToUserUid = toUid,
        SendToType = 2,
        SendMsgType = "PicMsg",
        Content = str,
        PicUrl = img_url
    })
end

-- 读取数据函数
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

-- 写入数据函数
function Wirte(url, msg)
    file = io.open(url, "w+")
    file:write(msg)
    file:close()
    return "ok"
end

function setu_threshold(data)
    os.execute("mkdir -p ./Plugins/cache/色图限制/" .. data.FromGroupId)
    user_lock_file =
        "./Plugins/cache/色图限制/" .. data.FromGroupId .. "/" ..
            data.FromUserId .. ".txt"
    group_lock_file = "./Plugins/cache/色图限制/" .. data.FromGroupId ..
                          "/1.txt"
    msg = Read(user_lock_file)
    if (msg ~= nil) then
        os.execute('flock -xn /tmp/' .. data.FromGroupId .. '-' ..
                       data.FromGroupId ..
                       '-setu.lock -c "sleep 10 && echo 0 >| ' .. user_lock_file ..
                       '" &')
        os.execute('flock -xn /tmp/' .. data.FromGroupId ..
                       '-setu.lock -c "sleep 10 && echo 0 >| ' ..
                       group_lock_file .. '" &')
        if tonumber(msg) >= 3 then
            os.execute('flock -xn /tmp/' .. data.FromGroupId .. '-' ..
                           data.FromGroupId ..
                           '-setu.lock -c "sleep 10 && echo 0 >| ' ..
                           user_lock_file .. '" &')
            return "user_is_locked"
        end
        Wirte(user_lock_file, tonumber(msg) + 1)
        msg = Read(group_lock_file)
        if (msg ~= nil) then
            if tonumber(msg) >= 5 then
                os.execute('flock -xn /tmp/' .. data.FromGroupId .. '-' ..
                               data.FromGroupId ..
                               '-setu.lock -c "sleep 10 && echo 0 >| ' ..
                               group_lock_file .. '" &')
                return "group_is_locked"
            else
                Wirte(group_lock_file, tonumber(msg) + 1)
            end
        else
            Wirte(group_lock_file, 0)
        end
    else
        Wirte(group_lock_file, 0) -- 群限制
        Wirte(user_lock_file, 0) -- 群成员限制
    end
    return "ok"
end
