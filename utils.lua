local Utils = {}

function Utils.readFileLines(filename)
    local file = love.filesystem.read(filename)
    local lines = {}
    for line in file:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    
    return lines
end

return Utils