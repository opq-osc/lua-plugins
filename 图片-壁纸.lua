local log = require("log")
local Api = require("coreApi")
local json = require("json")
local http = require("http")

function ReceiveFriendMsg(CurrentQQ, data)

    if data.MsgType ~= "TempSessionMsg" then
        if string.find(data.Content, "壁纸") == 1 then
            img_url = wallpaper()
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
    end
    if data.MsgType == "TempSessionMsg" and data.ToUin == tonumber(CurrentQQ) then
        if string.find(data.Content, "壁纸") == 13 then
            img_url = wallpaper()
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
    end
    return 1
end
function ReceiveGroupMsg(CurrentQQ, data)
    if string.find(data.Content, "壁纸") == 1 then
        img_url = wallpaper()
        Api.Api_SendMsg(CurrentQQ, {
            toUser = data.FromGroupId,
            sendToType = 2,
            sendMsgType = "PicMsg",
            groupid = 0,
            content = "",
            picUrl = img_url,
            picBase64Buf = "",
            fileMd5 = "",
            atUser = 0
        })
    end
    return 1
end
function ReceiveEvents(CurrentQQ, data, extData) return 1 end

function wallpaper()
    math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 6)))
    local randomPage = math.random(0, 100)
    local randomNum = math.random(1, 14)
    response, error_message = http.request("GET",
                                           "http://wallpaper.apc.360.cn/index.php",
                                           {
        query = "c=WallPaper&a=getAppsByOrder&order=create_time&start=" ..
            randomPage .. "&count=15&from=360chrome",
        headers = {
            ["Accept"] = "*/*",
            ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36"
        }
    })
    local html = response.body
    local strJson = json.decode(html)
    local img_url = strJson["data"][randomNum]["url"]
    log.notice("the img_url is %s", img_url)
    return img_url
end
