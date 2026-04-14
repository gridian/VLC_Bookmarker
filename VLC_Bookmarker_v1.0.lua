-- VLC Bookmarker Plugin
-- Author: MadebyMJ / Antigravity
-- Description: Adds bookmarking capability to VLC Media Player

function descriptor()
    return {
        title = "VLC Bookmarker",
        version = "1.0",
        author = "MadebyMJ",
        url = "",
        shortdesc = "비디오 북마크 (Bookmark positions)",
        description = "이 확장은 미디어 파일의 특정 시간 위치를 저장하고 나중에 다시 갈 수 있게 해주는 북마크 기능을 제공합니다.\n\n사용법:\n목록에서 지점 저장 후, '바로가기'를 클릭하여 이동하세요.",
        capabilities = {"input-listener", "playing-listener"}
    }
end

local dlg = nil
local list_wgt = nil
local name_input = nil
local bookmarks = {}
local data_file = ""

function activate()
    -- 로컬 데이터 파일 경로 설정
    local userdatadir = vlc.config.userdatadir()
    if not userdatadir then
        userdatadir = ""
    else
        userdatadir = userdatadir .. "/"
    end
    data_file = userdatadir .. "vlc_bookmarks_data.txt"

    create_dialog()
    load_bookmarks()
    refresh_list()
end

function deactivate()
    if dlg then
        dlg:delete()
        dlg = nil
    end
end

function close()
    vlc.deactivate()
end

function playing_changed()
    load_bookmarks()
    if dlg then
        refresh_list()
    end
end

function input_changed()
    load_bookmarks()
    if dlg then
        refresh_list()
    end
end

function create_dialog()
    dlg = vlc.dialog("VLC Bookmarker")
    
    dlg:add_label("북마크 이름 입력:", 1, 1, 1, 1)
    name_input = dlg:add_text_input("새 북마크", 2, 1, 2, 1)
    dlg:add_button("추가 (Add)", add_bookmark, 4, 1, 1, 1)
    
    list_wgt = dlg:add_list(1, 2, 4, 1)
    
    dlg:add_button("바로가기 (Jump)", jump_bookmark, 1, 3, 1, 1)
    dlg:add_button("이름 덮어쓰기 (Edit)", edit_bookmark, 2, 3, 1, 1)
    dlg:add_button("삭제 (Remove)", remove_bookmark, 3, 3, 1, 1)
    dlg:add_button("새로고침 (Refresh)", function() refresh_list() end, 4, 3, 1, 1)
end

function get_current_uri()
    if not vlc.input or not vlc.input.item then return nil end
    local item = vlc.input.item()
    if not item then return nil end
    return item:uri()
end

function load_bookmarks()
    bookmarks = {}
    local file = io.open(data_file, "r")
    if file then
        for line in file:lines() do
            local string_parts = {}
            for match in (line.."|"):gmatch("(.-)|") do
                table.insert(string_parts, match)
            end
            if #string_parts >= 3 then
                local uri = string_parts[1]
                local time_str = string_parts[2]
                local name = string_parts[3]
                
                if uri and time_str and name then
                    if not bookmarks[uri] then
                        bookmarks[uri] = {}
                    end
                    table.insert(bookmarks[uri], {time = tonumber(time_str), name = name})
                end
            end
        end
        file:close()
    end
end

function save_bookmarks()
    local file = io.open(data_file, "w")
    if not file then
        vlc.msg.err("[Bookmarker] 저장할 파일을 열 수 없습니다: " .. tostring(data_file))
        return
    end
    
    for uri, b_list in pairs(bookmarks) do
        for _, b in ipairs(b_list) do
            local safe_name = b.name:gsub("\n", " ")
            file:write(uri .. "|" .. tostring(b.time) .. "|" .. safe_name .. "\n")
        end
    end
    file:close()
end

function format_time(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    if h > 0 then
        return string.format("%02d:%02d:%02d", h, m, s)
    else
        return string.format("%02d:%02d", m, s)
    end
end

function refresh_list()
    if not list_wgt then return end
    list_wgt:clear()
    
    local uri = get_current_uri()
    if not uri or not bookmarks[uri] then return end
    
    -- 시간을 기준으로 북마크 정렬
    table.sort(bookmarks[uri], function(a, b) return a.time < b.time end)
    
    for idx, b in ipairs(bookmarks[uri]) do
        local display_text = "[" .. format_time(b.time) .. "] " .. b.name
        -- 에러 발생 방지를 위해 pcall로 리스트 추가
        pcall(function() list_wgt:add_value(display_text, idx) end)
    end
end

function add_bookmark()
    local input = vlc.object.input()
    if not input then return end
    local uri = get_current_uri()
    if not uri then return end
    
    -- VLC 3.0 이상에서는 vlc.var.get(input, "time")가 마이크로초를 반환 (초 = 값 / 1000000)
    local time_val = vlc.var.get(input, "time")
    local time_sec = 0
    if time_val then
        time_sec = time_val / 1000000
    end
    
    local name = "새 북마크"
    if name_input then
        name = name_input:get_text()
        if name == "" then name = "새 북마크" end
    end
    
    if not bookmarks[uri] then
        bookmarks[uri] = {}
    end
    
    table.insert(bookmarks[uri], {time = time_sec, name = name})
    save_bookmarks()
    refresh_list()
end

function get_selected_index()
    if not list_wgt then return nil end
    local sel = list_wgt:get_selection()
    if not sel then return nil end
    
    for id, text in pairs(sel) do
        return tonumber(id) -- ID가 문자열일 수 있으므로 숫자로 변환
    end
    return nil
end

function jump_bookmark()
    local idx = get_selected_index()
    if not idx then return end
    local uri = get_current_uri()
    if not uri or not bookmarks[uri] then return end
    
    local b = bookmarks[uri][idx]
    if b then
        local input = vlc.object.input()
        if input then
            -- 초 단위의 저장된 시간을 마이크로초로 변환하여 적용
            vlc.var.set(input, "time", math.floor(b.time * 1000000))
        end
    end
end

function edit_bookmark()
    local idx = get_selected_index()
    if not idx then return end
    local uri = get_current_uri()
    if not uri or not bookmarks[uri] then return end
    
    local name = ""
    if name_input then
        name = name_input:get_text()
        if name == "" then return end
    end
    
    bookmarks[uri][idx].name = name
    save_bookmarks()
    refresh_list()
end

function remove_bookmark()
    local idx = get_selected_index()
    if not idx then return end
    local uri = get_current_uri()
    if not uri or not bookmarks[uri] then return end
    
    table.remove(bookmarks[uri], idx)
    save_bookmarks()
    refresh_list()
end
