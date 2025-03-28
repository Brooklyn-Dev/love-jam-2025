local Utils = {}

--- Reads a file and returns its contents as a list of lines.
--- Each line from the file is a separate string in the resulting list.
--- @param filename string The name of the file to be read.
--- @return table
function Utils.readFileLines(filename)
    local file = love.filesystem.read(filename)
    local lines = {}
    
    for line in file:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    
    return lines
end

return Utils