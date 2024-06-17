local P = {}
P.name = [=[AviUtl_Alias_Reader]=]
P.priority = 0

local valid_prefixes = {
    exedit = '.exo',
    v = '.exa',
    vo = '.exa',
    a = '.exa',
    ao = '.exa',
    ["v.0"] = '.exa',
    ["vo.0"] = '.exa',
    ["a.0"] = '.exa',
    ["ao.0"] = '.exa'
}

local dialog_texts =
    {{'プロジェクトファイルとEXOのFPS値が一致しません。\nフレーム数をFPSに合わせて変換しますか？\n\nOK = 各オブジェクトのフレーム位置を合わせて配置する\nキャンセル = そのまま配置する (デフォルトと同じ動作)',
      'The FPS value of the project file does not match the FPS value of the EXO file.\nDo you want to convert the number of frames to match the FPS?\n\nOK = Align the frame positions of each object and place them\nCancel = Place them as is (default behavior)'},

     {'プロジェクトファイルとEXOのFPS値が一致しません。\nフレーム数をFPSに合わせて変換しますか？\n※いくつかのオブジェクトが消える場合があります。\n\nOK = 各オブジェクトのフレーム位置を合わせて配置する\nキャンセル = そのまま配置する (デフォルトと同じ動作)',
      'The FPS value of the project file does not match the FPS value of the EXO file.\nDo you want to convert the number of frames to match the FPS?\n* Some objects may DISAPPER!\n\nOK = Align the frame positions of each object and place them\nCancel = Place them as is (default behavior)'}}

function P.ondragenter(files, state)
    for _, v in ipairs(files) do
        if v.filepath:match("%.txt$") or v.filepath:match("%.exo$") then
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

local function create_temp_file_with_content(content, extension)
    local filename = GCMZDrops.createtempfile('temp', extension)
    local outFile = io.open(filename, "w")
    outFile:write(content)
    outFile:close()
    return filename
end

local function convert_frames(content, fps_rate)
    local exo_ini = GCMZDrops.inistring(content)
    local item_idx = 0
    local prev_end_frame = 0
    local prev_layer = 0
    while true do
        local start_frame = tonumber(exo_ini:get(item_idx, "start", nil))
        local end_frame = tonumber(exo_ini:get(item_idx, "end", nil))
        local layer = exo_ini:get(item_idx, "layer", nil)

        if start_frame and end_frame then
            local start_frame2 = math.max(math.floor(start_frame * fps_rate + 0.5), 1)
            local end_frame2 = math.floor(end_frame * fps_rate + 0.5)

            local is_object_overlap = start_frame2 < prev_end_frame + 1

            if layer == prev_layer and start_frame2 ~= 1 and is_object_overlap then
                start_frame2 = start_frame2 + 1
            elseif start_frame == 1 then
                start_frame2 = 1
            end

            local is_next_to_object = prev_end_frame + 1 == start_frame
            if is_next_to_object then
                exo_ini:set(item_idx - 1, "end", start_frame2 - 1)
            end

            exo_ini:set(item_idx, "start", start_frame2)
            exo_ini:set(item_idx, "end", end_frame2)

            prev_layer = layer
            prev_end_frame = end_frame
            item_idx = item_idx + 1
        else
            break
        end
    end
    return tostring(exo_ini)
end

local function process_exo_file(content, aup_fps)
    local converted_exo = nil
    local exo_rate = tonumber(content:match("rate=(%d+)"))
    local exo_scale = tonumber(content:match("scale=(%d+)"))
    if exo_rate and exo_scale then
        local exo_fps = exo_rate / exo_scale
        if aup_fps ~= exo_fps then
            local fps_rate = aup_fps / exo_fps
            local msg_index = 1
            if fps_rate < 1 then
                msg_index = 2
            end
            local dialog_text = dialog_texts[msg_index][GCMZDrops.getpatchid() + 1] or dialog_texts[msg_index][2]

            local is_convert_fps = GCMZDrops.confirm(dialog_text)

            if is_convert_fps then
                converted_exo = GCMZDrops.createtempfile("converted", ".exo")
                local converted_content = convert_frames(content, fps_rate)
                local f, err = io.open(converted_exo, "wb")
                if f == nil then
                    error(err)
                end
                f:write(converted_content)
                f:close()
            end
        end
    end
    return converted_exo
end

local function process_file(file)
    local content = file:read("*all")
    local prefix = content:match("^%[(.-)%]")
    local extension = valid_prefixes[prefix]
    local is_project_open, aupinfo = pcall(GCMZDrops.getexeditfileinfo)

    if extension == '.exo' and is_project_open then
        local aup_fps = aupinfo['rate'] / aupinfo['scale']
        return process_exo_file(content, aup_fps)
    end
    return create_temp_file_with_content(content, extension)
end

function P.ondrop(files, state)
    for _, v in ipairs(files) do
        local file = io.open(v.filepath, "r")
        if file then
            local converted_exo = process_file(file)
            if converted_exo then
                v.filepath = converted_exo
            end
            file:close()
        end
    end
    return files, state
end

return P

