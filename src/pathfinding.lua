--- @class AStar
--- @field heuristic function The heuristic function used to estimate the distance to the goal.
--- @field findPath function The method that finds the shortest path on the grid.

local AStar = {}
AStar.__index = AStar

--- Heuristic function that calculates the Manhattan distance between two points (x1, y1) and (x2, y2).
--- @param x1 number The x-coordinate of the first point.
--- @param y1 number The y-coordinate of the first point.
--- @param x2 number The x-coordinate of the second point.
--- @param y2 number The y-coordinate of the second point.
--- @return number
function AStar:heuristic(x1, y1, x2, y2)
    return math.abs(x1 - x2) + math.abs(y1 - y2)
end

--- Finds the shortest path from the start position to the end position on a grid.
--- @param startX number The x-coordinate of the start position.
--- @param startY number The y-coordinate of the start position.
--- @param endX number The x-coordinate of the end position.
--- @param endY number The y-coordinate of the end position.
--- @param tiles table A 2D grid representing the map, where each tile is either 'empty' or 'wall'.
--- @param diagonals boolean Whether diagonal movement is allowed.
--- @return table | nil
function AStar:findPath(startX, startY, endX, endY, tiles, diagonals)
    local openList = {}  -- Nodes to be evaluated
    local closedList = {}  -- Nodes already evaluated

    -- Node structure: Contains the coordinates, g (cost from start), h (heuristic to goal), f (total cost), and parent node
    local function createNode(x, y)
        return { x = x, y = y, g = math.huge, h = math.huge, f = math.huge, parent = nil }
    end

    -- Initialise the start node
    local startNode = createNode(startX, startY)
    startNode.g = 0
    startNode.h = self:heuristic(startX, startY, endX, endY)
    startNode.f = startNode.g + startNode.h
    table.insert(openList, startNode)

    -- Main loop
    while #openList > 0 do
        -- Sort openList by f-value (lowest to highest)
        table.sort(openList, function(a, b) return a.f < b.f end)

        -- Pop the node with the lowest f value
        local currentNode = table.remove(openList, 1)

        -- If the current node is the destination, backtrack to find the path
        if currentNode.x == endX and currentNode.y == endY then
            local path = {}
            local node = currentNode

            while node do
                table.insert(path, 1, {x = node.x, y = node.y})
                node = node.parent
            end

            return path
        end

        -- Add current node to closedList to prevent revisiting
        table.insert(closedList, currentNode)

        -- List of potential neighbouring tiles (adjacent cells)
        local neighbours = {
            { x = currentNode.x, y = currentNode.y - 1 },  -- Top
            { x = currentNode.x + 1, y = currentNode.y },  -- Right
            { x = currentNode.x, y = currentNode.y + 1 },  -- Bottom
            { x = currentNode.x - 1, y = currentNode.y },  -- Left
        }

        -- Add diagonal neighbours if allowed
        if diagonals then
            table.insert(neighbours, { x = currentNode.x - 1, y = currentNode.y - 1 })  -- Top-left
            table.insert(neighbours, { x = currentNode.x + 1, y = currentNode.y - 1 })  -- Top-right
            table.insert(neighbours, { x = currentNode.x - 1, y = currentNode.y + 1 })  -- Bottom-left
            table.insert(neighbours, { x = currentNode.x + 1, y = currentNode.y + 1 })  -- Bottom-right
        end

        -- Evaluate each neighbouring tile
        for _, neighbour in ipairs(neighbours) do
            -- Skip invalid tiles (out of bounds or walls)
            if
                neighbour.x < 1 or neighbour.x > #tiles[1] or neighbour.y < 1 or neighbour.y > #tiles
                or tiles[neighbour.y][neighbour.x] == 'wall'
            then
                goto continue
            end

            -- Skip if the neighbor is already in the closed list
            local inClosed = false
            for _, closedNode in ipairs(closedList) do
                if closedNode.x == neighbour.x and closedNode.y == neighbour.y then
                    inClosed = true
                    break
                end
            end

            if inClosed then goto continue end

            -- Calculate g, h, and f values for the neighbour
            local g = currentNode.g + 1  -- Assume all moves cost 1
            local h = self:heuristic(neighbour.x, neighbour.y, endX, endY)
            local f = g + h

            -- Check if the neighbor is already in the open list and has a lower f value
            local inOpen = false
            for _, openNode in ipairs(openList) do
                if openNode.x == neighbour.x and openNode.y == neighbour.y then
                    inOpen = true
                    if f < openNode.f then
                        openNode.g = g
                        openNode.f = f
                        openNode.parent = currentNode
                    end
                    break
                end
            end

            -- If the neighbor is not in openList, add it
            if not inOpen then
                local newNode = createNode(neighbour.x, neighbour.y)
                newNode.g = g
                newNode.h = h
                newNode.f = f
                newNode.parent = currentNode
                table.insert(openList, newNode)
            end

            ::continue::
        end
    end

    -- Return nil if no path was found
    return nil
end

return AStar