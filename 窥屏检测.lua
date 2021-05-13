local log = require("log")
local Api = require("coreApi")
local json = require("json")
local http = require("http")

function ReceiveFriendMsg(CurrentQQ, data) return 1 end
function ReceiveGroupMsg(CurrentQQ, data)
    if string.find(data.Content, "窥屏检测") == 1 then
        threshold = kp_threshold(data)
        if threshold == "ok" then
            local content = {
                "小👶你是否有很多❓",
                "小🐈🐈能有什么坏♥️👀",
                "大🐔大🍐今晚吃🐥", "🅾️🍐给！",
                "🃏竟是我自己🌝",
                "🌶👇💩💉💦🐮🍺"
            }
            math.randomseed(os.time())
            Api.Api_SendMsgV2(CurrentQQ, {
                ToUserUid = data.FromGroupId,
                SendToType = 2,
                SendMsgType = "XmlMsg",
                Content = string.format(
                    "<?xml version='1.0' encoding='UTF-8' standalone='yes' ?><msg serviceID='1' templateID='1' action='' brief='&#91;窥屏检测&#93;' sourceMsgId='0' url=\"https://www.baidu.com\" flag='2' adverSign='0' multiMsgFlag='0'><item layout='2'><title size='38' color='#9900CC' style='1'>%s</title><summary color='#FF0033'>\n👀试图寻找窥屏的群友👀</summary><picture cover=\"服务器API地址/kp.php?g=%s-t=%s\" /></item></msg>",
                    content[math.random(1, #content)], data.FromGroupId,
                    math.random())
            })

            os.execute('sleep 20')
            response, error_message = http.request("GET",
                                                   "服务器API地址/kp_info.php",
                                                   {
                query = "g=" .. data.FromGroupId
            })
            local html = response.body
            log.info("检测结果 ====> %s", html)
            local j = json.decode(html)
            local str = ""
            local len = #j
            if len > 0 then
                for i = 1, len, 1 do
                    local jdata = j[i]
                    local ip = jdata.ip
                    local adr = jdata.addr
                    local ua = jdata.ua
                    local ti = jdata.time
                    str = str .. "\n\n" .. "IP:" .. ip .. "\n地址:" .. adr ..
                              "\n设备:" .. ua .. "\n时间:" .. ti
                end
                send_to_group(CurrentQQ, data.FromGroupId,
                              "检测结果如下：" .. str)
            else
                send_to_group(CurrentQQ, data.FromGroupId,
                              "暂无群友窥屏")
            end
        else
            send_to_group(CurrentQQ, data.FromGroupId,
                          "此功能5分钟内只允许使用一次！")
            os.execute('flock -xn /tmp/' .. data.FromGroupId .. '-kp.lock -c "sleep 300 && echo 0 >| '..'./Plugins/cache/窥屏限制/' .. data.FromGroupId .. '.txt" &')
        end
    end
    return 1
end
function ReceiveEvents(CurrentQQ, data, extData) return 1 end

function kp_threshold(data)
    kp_file = "./Plugins/cache/窥屏限制/" .. data.FromGroupId .. ".txt"
    msg = Read(kp_file)
    if (msg ~= nil) then
        if msg == "1" then
            return "locked"
        else
            Wirte(kp_file, "1")
            os.execute('flock -xn /tmp/' .. data.FromGroupId .. '-kp.lock -c "sleep 300 && echo 0 >| '.. kp_file .. '" &')
        end
    else
        Wirte(kp_file, "1")
        os.execute('flock -xn /tmp/' .. data.FromGroupId .. '-kp.lock -c "sleep 300 && echo 0 >| '.. kp_file .. '" &')
    end
    return "ok"
end

function send_to_group(CurrentQQ, toUid, content)
    Api.Api_SendMsgV2(CurrentQQ, {
        ToUserUid = toUid,
        SendToType = 2,
        SendMsgType = "TextMsg",
        Content = content
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
