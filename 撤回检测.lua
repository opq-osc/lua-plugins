local log = require("log")
local Api = require("coreApi")
local json = require("json")
local http = require("http")
local mysql = require("mysql")

local admin_qq = xxxxxxx -- 换为自己的QQ号

-- 数据库配置
mysqlhost = "localhost" -- 默认不动
mysqldb = "opqbot" -- 数据库名
mysqluser = "opqbot" -- 数据库用户名
mysqlpass = "xxx" -- 数据库密码

function ReceiveFriendMsg(CurrentQQ, data) return 1 end

function ReceiveGroupMsg(CurrentQQ, data)
    if data.Content == "开启撤回检测" then
        os.execute("mkdir -p Plugins/data/撤回检测/")
        Wirte("Plugins/data/撤回检测/" .. data.FromGroupId .. ".txt",
              "开启")
        send_text_to_group(CurrentQQ, data.FromGroupId, "已开启")
    end
    if data.Content == "关闭撤回检测" then
        os.execute("mkdir -p Plugins/data/撤回检测/")
        Wirte("Plugins/data/撤回检测/" .. data.FromGroupId .. ".txt",
              "关闭")
        send_text_to_group(CurrentQQ, data.FromGroupId, "已关闭")
    end
    return 1
end

function ReceiveEvents(CurrentQQ, data, extData)
    if data.MsgType == "ON_EVENT_GROUP_REVOKE" then -- 监听 群撤回事件
        -- 撤回事件处理
        str = Read("Plugins/data/撤回检测/" .. extData.GroupID .. ".txt")
        -- if (str == nil) then
        --     log.info("Str ====> %s", str)
        --     return 1
        -- end
        if str ~= nil and string.find(str, "关闭") then return 1 end

        if (extData.UserID == tonumber(CurrentQQ) or extData.UserID == admin_qq) then
            return 1
        end
        CheHui(CurrentQQ, data, extData)
        -- xxxxxxxxxxxxxxx
        return 1
    end
end

-- 撤回检测
function CheHui(CurrentQQ, data, extData)

    -- err = json.encode(extData)
    -- log.info("撤回事件========>%v", extData)

    c = mysql.new()
    -- 初始化mysql对象
    if (mysqlpass == "") then return 1 end

    str = string.format("群 %d  成员 UserID %s 撤回了消息Seq %s \n",
                        extData.GroupID, extData.UserID, extData.MsgSeq)
    log.info("%s", str)
    ok, err = c:connect({
        host = mysqlhost,
        port = 3306,
        database = mysqldb,
        user = mysqluser,
        password = mysqlpass
    })
    -- 建立连接
    log.info("sql %v", err)
    if ok then
        sqlstr = string.format(
                     "select * from msgcache where `GroupID`= %d and `MsgSeq` = %d",
                     extData.GroupID, extData.MsgSeq)
        res, err = c:query(sqlstr) -- 跟群群id和消息SEQ查询出撤回的消息内容
        if err == nil then
            c.close(c)
            GroupID = extData.GroupID
            MsgType = res[1]["MsgType"]
            Data = res[1]["Data"]

            if MsgType == "TextMsg" then
                content = "@[GETUSERNICK(" .. extData.UserID ..
                              ")] 刚刚想撤回这条消息：\n═══════════════\n" ..
                              Data ..
                              "\n═══════════════"
                send_text_to_group(CurrentQQ, GroupID, content)
            end

            if MsgType == "BigFaceMsg" then
                -- Data {"Content":"[表情101]","Hex":"FKY=","Index":101,"tips":"[大表情]"}
                content = "@[GETUSERNICK(" .. extData.UserID ..
                              ")] 刚刚想撤回一个表情包，正在解码..."
                send_text_to_group(CurrentQQ, GroupID, content)
                os.execute('sleep 1')
                jData = json.decode(Data)
                Api.Api_SendMsg(CurrentQQ, {
                    toUser = GroupID,
                    sendToType = 2,
                    sendMsgType = "ForwordMsg",
                    content = "",
                    GETUSERNICK = 0,
                    groupid = 0,
                    voiceUrl = "",
                    voiceBase64Buf = "",
                    picUrl = "",
                    picBase64Buf = "",
                    forwordBuf = jData.ForwordBuf, -- 欲转发的base64buf 图片消息 视频消息 会给出此参数
                    forwordField = jData.ForwordField -- 欲写入协议的字段ID 图片消息 视频消息 会给出此参数
                })

            end
            if MsgType == "PicMsg" then
                jData = json.decode(Data)
                if (jData.Tips == "[群消息-QQ闪照]") then
                    content = "@[GETUSERNICK(" .. extData.UserID ..
                                  ")] 刚刚想撤回一张闪照，正在解码..."
                    send_text_to_group(CurrentQQ, GroupID, content)
                    os.execute('sleep 1')
                    Api.Api_SendMsgV2(CurrentQQ, {
                        ToUserUid = GroupID,
                        SendToType = 2,
                        SendMsgType = "ForwordMsg",
                        ForwordBuf = jData.ForwordBuf, -- 欲转发的base64buf 图片消息 视频消息 会给出此参数
                        ForwordField = jData.ForwordField -- 欲写入协议的字段ID 图片消息 视频消息 会给出此参数
                    })
                    return 1
                end
                content = "@[GETUSERNICK(" .. extData.UserID ..
                              ")] 刚刚想撤回一张图片，正在解码..."
                send_text_to_group(CurrentQQ, GroupID, content)
                os.execute('sleep 1')
                md5s = {};
                Api.Api_SendMsgV2(CurrentQQ, {
                    ToUserUid = GroupID,
                    SendToType = 2,
                    SendMsgType = "ForwordMsg",
                    ForwordBuf = jData.GroupPic[1].ForwordBuf, -- 欲转发的base64buf 图片消息 视频消息 会给出此参数
                    ForwordField = jData.GroupPic[1].ForwordField -- 欲写入协议的字段ID 图片消息 视频消息 会给出此参数
                })
                -- Api.Api_SendMsgV2(CurrentQQ, {
                --     ToUserUid = GroupID,
                --     SendToType = 2,
                --     SendMsgType = "PicMsg",
                --     Content = "图片",
                --     PicUrl = jData.GroupPic[1].Url
                -- })
            end
            if MsgType == "AtMsg" then
                jData = json.decode(Data)
                if (jData.Tips == "[回复]") then
                    content = "@[GETUSERNICK(" .. extData.UserID ..
                                  ")] 刚刚回复 @" ..
                                  jData.UserExt[1]['QQNick'] ..
                                  " 说：\n═══════════\n" ..
                                  jData.Content ..
                                  "\n═══════════"
                    send_text_to_group(CurrentQQ, GroupID, content)
                    return 1
                end
                content =
                    "@[GETUSERNICK(" .. extData.UserID .. ")] 刚刚对 " ..
                        jData.UserExt[1]['QQNick'] ..
                        " 说：\n═══════════\n" ..
                        jData.Content .. "\n═══════════"
                send_text_to_group(CurrentQQ, GroupID, content)
            end
            if MsgType == "VoiceMsg" then
                content = "@[GETUSERNICK(" .. extData.UserID ..
                              ")] 刚刚想撤回一段语音，正在解码..."
                send_text_to_group(CurrentQQ, GroupID, content)
                os.execute('sleep 1')
                Api.Api_SendMsgV2(CurrentQQ, {
                    ToUserUid = GroupID,
                    SendToType = 2,
                    SendMsgType = "VoiceMsg",
                    VoiceUrl = json.decode(Data).Url
                })
            end
            if MsgType == "VideoMsg" then
                content = "@[GETUSERNICK(" .. extData.UserID ..
                              ")] 刚刚想撤回一段视频，正在解码..."
                send_text_to_group(CurrentQQ, GroupID, content)
                os.execute('sleep 1')
                Api.Api_SendMsgV2(CurrentQQ, {
                    ToUserUid = GroupID,
                    SendToType = 2,
                    SendMsgType = "ForwordMsg",
                    ForwordBuf = json.decode(Data).ForwordBuf, -- 欲转发的base64buf 图片消息 视频消息 会给出此参数
                    ForwordField = json.decode(Data).ForwordField -- 欲写入协议的字段ID 图片消息 视频消息 会给出此参数
                })
            end
            if MsgType == "XmlMsg" then
                -- Data {"MsgSeq":3536,"ReplayContent":"11 @Mac","SrcContent":"...","UserID":123123,"tips":"[回复]"}
                -- log.info("sql %s", json.decode(Data).url)
                Api.Api_SendMsg(CurrentQQ, {
                    toUser = GroupID,
                    sendToType = 2,
                    sendMsgType = "XmlMsg",
                    groupid = 0,
                    content = string.format("%s", Data),
                    GETUSERNICK = 0
                })
            end
            if MsgType == "JsonMsg" then
                -- Data {"MsgSeq":3536,"ReplayContent":"11 @Mac","SrcContent":"...","UserID":123123,"tips":"[回复]"}
                -- log.info("sql %s", json.decode(Data).url)
                Api.Api_SendMsg(CurrentQQ, {
                    toUser = GroupID,
                    sendToType = 2,
                    sendMsgType = "JsonMsg",
                    groupid = 0,
                    content = string.format("%s", Data),
                    GETUSERNICK = 0
                })
            end
        end
    end
    return 1
end

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
