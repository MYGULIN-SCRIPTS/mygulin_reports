local reports = {}

local function isAllowedGroup(xPlayer)
    local group = xPlayer.getGroup()
    for _, g in ipairs(Config.AllowedGroups) do
        if g == group then
            return true
        end
    end
    return false
end

RegisterNetEvent('myreport:sendReport', function(title, description)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local playerName = GetPlayerName(src)
    local playerId = src

    for _, rep in ipairs(reports) do
        if rep.playerId == playerId then

            TriggerClientEvent('myreport:showExistingReport', playerId, rep)
            return
        end
    end

    local report = {
        id = #reports + 1,
        title = title,
        description = description,
        playerName = playerName,
        playerId = playerId
    }

    table.insert(reports, report)

    for _, pid in ipairs(ESX.GetPlayers()) do
        local targetXPlayer = ESX.GetPlayerFromId(pid)
        if isAllowedGroup(targetXPlayer) then
            TriggerClientEvent('okokNotify:Alert', pid, "Nový report", playerName .. " (#" .. src .. ") poslal report: " .. title, 5000, 'info')
        end
    end
end)

ESX.RegisterServerCallback('myreport:getReports', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if isAllowedGroup(xPlayer) then
        cb(reports)
    else
        cb(nil)
    end
end)

ESX.RegisterServerCallback('myreport:getPlayerReport', function(source, cb)
    local src = source
    for _, rep in ipairs(reports) do
        if rep.playerId == src then
            cb(rep)
            return
        end
    end
    cb(nil)
end)

RegisterNetEvent('myreport:closeReport', function(reportId, targetId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not isAllowedGroup(xPlayer) then return end

    for i, rep in ipairs(reports) do
        if rep.id == reportId then
            TriggerClientEvent('okokNotify:Alert', targetId, "Report", "Tvůj report byl uzavřen adminem.", 5000, 'success')
            table.remove(reports, i)
            break
        end
    end
end)

RegisterNetEvent('myreport:closeOwnReport', function()
    local src = source
    for i, rep in ipairs(reports) do
        if rep.playerId == src then
            table.remove(reports, i)
            TriggerClientEvent('okokNotify:Alert', src, "Report", "Tvůj report byl uzavřen.", 5000, 'success')
            return
        end
    end
end)

RegisterNetEvent('myreport:tpToPlayer', function(targetId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not isAllowedGroup(xPlayer) then return end

    TriggerClientEvent('myreport:teleport', src, targetId)
    TriggerClientEvent('okokNotify:Alert', targetId, "Report", "Admin tě právě řeší.", 5000, 'info')
end)
