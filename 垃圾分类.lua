local log = require("log")
local Api = require("coreApi")
local json = require("json")
local http = require("http")

function ReceiveFriendMsg(CurrentQQ, data)
    return 1
end
function ReceiveGroupMsg(CurrentQQ, data)
if (string.find(data.Content, "垃圾分类") == 1) then
	local keyWord = data.Content:gsub("垃圾分类 ", "")
	local keyWord = keyWord:gsub("垃圾分类", "")
	if keyWord == nil then
		return 1
	end
	response, error_message =
		    http.request(
		    "GET",
		    "https://api.vvhan.com/api/la.ji?",
		    {
		        query = "lj="..url_encode(keyWord),
		        headers = {
		            ["Accept"] = "*/*",
								["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36"
		        }
		    }
		)
		local html = response.body
        local status = html
		local a = json.decode(status)
		log.notice("垃圾分类--->%s", html)
		
        Api.Api_SendMsgV2(CurrentQQ, {
            ToUserUid = data.FromGroupId,
            SendToType = 2,
            SendMsgType = "TextMsg",
            Content = "『" ..a.name.. "』" ..a.sort
        })
	end
    return 1
end
function ReceiveEvents(CurrentQQ, data, extData)
    return 1
end

function url_encode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w ])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str	
end

