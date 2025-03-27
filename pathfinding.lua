local AStar = {}
AStar.__index = AStar

-- Manhattan distance 
function AStar:heuristic(x1, y1, x2, y2)
    return math.abs(x1 - x2) + math.abs(y1 - y2)
end

function AStar:findPath(startX, startY, endX, endY, tiles, diagonals)
    local openList = {}
    local closedList = {}
    
    -- Node structure
    local function createNode(x, y)
        return {x = x, y = y, g = math.huge, h = math.huge, f = math.huge, parent = nil}
    end
    
    -- Init start node
    local startNode = createNode(startX, startY)
    startNode.g = 0
    startNode.h = self:heuristic(startX, startY, endX, endY)
    startNode.f = startNode.g + startNode.h
    
    table.insert(openList, startNode)

    -- Find the shortest path
    while #openList > 0 do
        -- Sort openList by ascending f-values
        table.sort(openList, function(a, b) return a.f < b.f end)
        
        -- Pop node with the lowest f value from open list
        local currentNode = table.remove(openList, 1)
        
        -- Backtrack
        if currentNode.x == endX and currentNode.y == endY then
            local path = {}
            local node = currentNode
            while node do
                table.insert(path, 1, {x = node.x, y = node.y})
                node = node.parent
            end
            return path
        end

        -- Add current node to closedList
        table.insert(closedList, currentNode)
        
        -- Check adjacent tiles
        local neighbours = {
            {x = currentNode.x, y = currentNode.y - 1},  -- top
            {x = currentNode.x + 1, y = currentNode.y},  -- right
            {x = currentNode.x, y = currentNode.y + 1},  -- bottom
            {x = currentNode.x - 1, y = currentNode.y},  -- left
        }

        if diagonals then
            table.insert(neighbours, {x = currentNode.x - 1, y = currentNode.y - 1})  -- top-left
            table.insert(neighbours, {x = currentNode.x + 1, y = currentNode.y - 1})  -- top-right
            table.insert(neighbours, {x = currentNode.x - 1, y = currentNode.y + 1})  -- bottom-left
            table.insert(neighbours, {x = currentNode.x + 1, y = currentNode.y + 1})  -- bottom-right
        end

        for _, neighbour in ipairs(neighbours) do
            -- Skip out of bounds or wall tiles or doors
            if
                neighbour.x < 1 or neighbour.x > #tiles[1] or neighbour.y < 1 or neighbour.y > #tiles
                or tiles[neighbour.y][neighbour.x] == 'wall'
            then
                goto continue
            end

            -- If the neighbour is in closedList, skip it
            local inClosed = false
            for _, closedNode in ipairs(closedList) do
                if closedNode.x == neighbour.x and closedNode.y == neighbour.y then
                    inClosed = true
                    break
                end
            end
            if inClosed then goto continue end

            -- Calculate the g, h, and f values
            local g = currentNode.g + 1
            local h = self:heuristic(neighbour.x, neighbour.y, endX, endY)
            local f = g + h

            -- Check if the neighbour is in openList and has a lower f value
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

            -- If the neighbour is not in openList, add it
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

    return nil  -- No path found
end

return AStar