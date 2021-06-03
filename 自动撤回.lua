local Api = require('coreApi')

function ReceiveGroupMsg(CurrentQQ, data)
    if data.FromUserId == tonumber(CurrentQQ) then
        if data.Content:find('s后销毁') then
            local num = data.Content:match("(%d+)s后销毁.*")
            if tonumber(num) then delay = tonumber(num) end
            revoke_msg(CurrentQQ, data, delay)
        end
        if data.Content:find('窥屏检测') then
            revoke_msg(CurrentQQ, data, 40)
        end
        if data.Content:find('处理出错') then
            revoke_msg(CurrentQQ, data, 1)
        end
        return 2
    end

    if data.Content:find('秒撤回') then
        local num = data.Content:match("(%d+)秒撤回.*")
        if tonumber(num) then delay = tonumber(num) end
        revoke_msg(CurrentQQ, data, delay)
    end
end

function ReceiveFriendMsg(CurrentQQ, data) return 1 end

function ReceiveEvents(CurrentQQ, data, extData) return 1 end

function revoke_msg(CurrentQQ, data, delay)
    -- os.execute('sleep ' .. delay)
    -- Api.Api_CallFunc(CurrentQQ, 'PbMessageSvc.PbMsgWithDraw', {
    --     GroupID = data.FromGroupId,
    --     MsgSeq = data.MsgSeq,
    --     MsgRandom = data.MsgRandom
    -- })
    revoke_cmd =
        "/usr/bin/curl -H \"Content-Type: application/json\" -X POST --data '{\"GroupID\":" ..
            data.FromGroupId .. ",\"MsgSeq\":" .. data.MsgSeq ..
            ",\"MsgRandom\":" .. data.MsgRandom ..
            "}' 'http://127.0.0.1:9720/v1/LuaApiCaller?qq=" .. CurrentQQ ..
            "&funcname=PbMessageSvc.PbMsgWithDraw&timeout=5'"
    cmd = "sleep " .. delay .. " && " .. revoke_cmd .. " &"
    os.execute(cmd)
end
