RegisterCommand('report', function()
    ESX.TriggerServerCallback('myreport:getPlayerReport', function(report)
        if report then

            lib.registerContext({
                id = 'existing_report',
                title = 'Aktivní report',
                options = {
                    {
                        title = report.title,
                        description = report.description,
                        disabled = true
                    },
                    {
                        title = 'Zavřít report',
                        onSelect = function()
                            TriggerServerEvent('myreport:closeOwnReport')
                        end
                    },
                    {
                        title = 'Zavřít menu',
                        onSelect = function()
                            lib.hideContext()
                        end
                    }
                }
            })
            lib.showContext('existing_report')
        else
        
            local input = lib.inputDialog('Nový report', {
                {type = 'input', label = 'Název problému 🚨', required = true},
                {type = 'textarea', label = 'Popis problému 📋', required = true}
            })

            if input then
                TriggerServerEvent('myreport:sendReport', input[1], input[2])
                TriggerEvent('okokNotify:Alert', "Report", "Report byl odeslán.", 5000, 'success')
            end
        end
    end)
end)

local expandedReport = nil

RegisterCommand('reporty', function()
    ESX.TriggerServerCallback('myreport:getReports', function(reports)
        if not reports then
            TriggerEvent('okokNotify:Alert', "Reporty", "Nemáš oprávnění vidět reporty.", 5000, 'error')
            return
        end

        if #reports == 0 then
            TriggerEvent('okokNotify:Alert', "Reporty", "Žádné aktivní reporty.", 5000, 'info')
            return
        end

        ShowReportMenu(reports)
    end)
end)

function ShowReportMenu(reports)
    local options = {}

    for _, rep in ipairs(reports) do
        table.insert(options, {
            title = rep.title .. " | " .. rep.playerName .. " (#" .. rep.playerId .. ")",
            description = rep.description,
            onSelect = function()
                if expandedReport == rep.id then
                    expandedReport = nil
                else
                    expandedReport = rep.id
                end
                ShowReportMenu(reports)
            end
        })

        if expandedReport == rep.id then
            table.insert(options, {
                title = '→ Teleportovat k hráči',
                onSelect = function()
                    TriggerServerEvent('myreport:tpToPlayer', rep.playerId)
                    lib.hideContext()
                    expandedReport = nil
                end
            })
            table.insert(options, {
                title = '→ Uzavřít report',
                onSelect = function()
                    TriggerServerEvent('myreport:closeReport', rep.id, rep.playerId)
                    lib.hideContext()
                    expandedReport = nil
                end
            })
            table.insert(options, {
                title = '→ Odejít',
                onSelect = function()
                    expandedReport = nil
                    lib.hideContext()
                end
            })
        end
    end

    lib.registerContext({
        id = 'report_menu',
        title = 'Seznam reportů 📋',
        options = options
    })
    lib.showContext('report_menu')
end

RegisterNetEvent('myreport:teleport', function(targetId)
    local ped = PlayerPedId()
    local targetPed = GetPlayerPed(GetPlayerFromServerId(targetId))
    if targetPed and targetPed ~= 0 then
        local coords = GetEntityCoords(targetPed)
        SetEntityCoords(ped, coords.x, coords.y, coords.z)
    else
        TriggerEvent('okokNotify:Alert', "Report", "Hráč není online nebo nelze najít jeho pozici.", 5000, 'error')
    end
end)

RegisterNetEvent('myreport:showExistingReport', function(report)
    lib.registerContext({
        id = 'existing_report_notify',
        title = 'Už máš aktivní report',
        options = {
            {
                title = report.title,
                description = report.description,
                disabled = true
            },
            {
                title = 'Zavřít report',
                onSelect = function()
                    TriggerServerEvent('myreport:closeOwnReport')
                end
            },
            {
                title = 'Zavřít menu',
                onSelect = function()
                    lib.hideContext()
                end
            }
        }
    })
    lib.showContext('existing_report_notify')
end)
