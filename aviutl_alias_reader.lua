local P = {}
P.name = [=[AliasTxtReader]=]
P.priority = 0

function P.ondragenter(files, state)
    for i, v in ipairs(files) do
        if (v.filepath:match("[^.]+$"):lower() == "txt") then
            return true
        end
    end
    return false
end

function P.ondragover(files, state)
    return true
end

function P.ondragleave()
end

function P.ondrop(files, state)
    for i, v in ipairs(files) do
        local file = io.open(v.filepath, "r")
        if file then
            local content = file:read("*all")
            file:close()
            local prefix = content:match("^%[(.-)%]")
            if prefix == "exedit" then
                filename = GCMZDrops.createtempfile('temp', '.exo')
                local outFile = io.open(filename, "w")
                outFile:write(content)
                outFile:close()
                v.filepath = filename
                return files, state
            elseif prefix == "v" or prefix == "vo" or prefix == "a" or prefix == "ao" or prefix == "v.0" or prefix ==
                "vo.0" or prefix == "a.0" or prefix == "ao.0" then
                filename = GCMZDrops.createtempfile('temp', '.exa')
                local outFile = io.open(filename, "w")
                outFile:write(content)
                outFile:close()
                v.filepath = filename
                return files, state
            end
        end
    end
    return false
end
return P
