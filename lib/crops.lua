control = {
    v = 0,
    p = { 0, 0 },
    b = { 0, 16 },
    enable = function(self) end,
    event = function(self) end,
    output = function(self, v) return v end,
    get = function(self) return self.v end,
    set = function(self, input)
        self.v = input
        self:event(self.v)
    end,
    draw = function(self, g) end,
    look = function() end
}

function control:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    
    return o
end

toggle = control:new()

function toggle:draw(g)
    if self.enable() then
        g:led(self.p[1], self.p[2], self.b[self.v])
    end
end

function toggle:look(x, y, z)
    if self.enable() then
        if x == self.p[1] and y == self.p[2] then
            if z == 0 then
                local last = self.v
                self.v = Math.abs(self.v - 1)
                self:event(self.v, last)
                
                return true
            end
        end
    end
end

function toggle:set(input)
    self.v = input
    self:event(self.v)
end

momentary = toggle:new()

function momentary:look(x, y, z)
    if self.enable() then
        if x == self.p[1] and y == self.p[2] then
            local v = z
            self:event(v)
            self.v = v
            
            return true
        end
    end
end

value = control:new()

function value:draw(g)
    if self.enable() then
        if type(self.p[1]) == "table" then
            for i = self.p[1][1], self.p[1][2] do
                g:led(i, self.p[2], (i - self.p[1][1] == v) and self.b[2] or self.b[1])
            end
        elseif type(self.p[2]) == "table" then
            for i = self.p[2][1], self.p[2][2] do
                g:led(self.p[1], i, (i - self.p[1][1] == v) and self.b[2] or self.b[1])
            end
        end
    end
end

function value:look(x, y, z)
    if self.enable() then
        
        local is_x = (type(self.p[1]) == "table")
        local l_p = is_x and self.p[1] or self.p[2]
        local s_p = is_x and self.p[2] or self.p[1]
        local l_dim = is_x and x or y
        local s_dim = is_x and y or x
        
        if s_dim == s_p then
            for i = l_p[1], l_p[2] do
                if i == l_dim and z == 1 then
                    local last = self.v
                    local v = i - l_p[1]
                    self:event(v, last)
                    self.v = v

                    return true
                end
            end
        end
    end
end

toggles = control:new()

function toggles:draw(g)
    if self.enable() then
        
        local is_x = (type(self.p[1]) == "table")
        local l_p = is_x and self.p[1] or self.p[2]
        local s_p = is_x and self.p[2] or self.p[1]
        local l_dim = is_x and x or y
        local s_dim = is_x and y or x
        
        local mtrx = {}
        for i = 1, p[2] - p[1] do
            mtrx[i] = false
        end
        for i,v in ipairs(self.v) do
            mtrx[v] = true
        end
        
        for i = l_p[1], l_p[2] do
            if is_x then
                g:led(i, s_p, mtrx[i] and self.b[2] or self.b[1])
            else
                g:led(s_p, i, mtrx[i] and self.b[2] or self.b[1])
            end
        end
    end
end

function toggles:look(x, y, z)
     if self.enable() then
        
        local is_x = (type(self.p[1]) == "table")
        local l_p = is_x and self.p[1] or self.p[2]
        local s_p = is_x and self.p[2] or self.p[1]
        local l_dim = is_x and x or y
        local s_dim = is_x and y or x
        
        if s_dim == s_p then
            for i = l_p[1], l_p[2] do
                if i == l_dim and z == 1 then
                    local last = {}
                    local thing = -1
                    for j,v in ipairs(self.v) do 
                        last[j] = v 
                        if v == i then thing = j end --?
                    end
                    local added = -1
                    local removed = -1
                    
                    if thing == -1 then
                        table.insert(self.v, i)
                        added = i
                    else
                        table.remove(self.v, thing)
                        removed = i
                    end
                    
                    self:event(v, last, added, removed)

                    return true
                end
            end
        end
    end
end

momentaires = toggles:new()
    
function momentaries:look(x, y, z)
    if self.enable() then
        
        local is_x = (type(self.p[1]) == "table")
        local l_p = is_x and self.p[1] or self.p[2]
        local s_p = is_x and self.p[2] or self.p[1]
        local l_dim = is_x and x or y
        local s_dim = is_x and y or x
        
        if s_dim == s_p then
            for i = l_p[1], l_p[2] do
                if i == l_dim then
                    local last = {}
                    local thing = -1
                    for j,v in ipairs(self.v) do 
                        last[j] = v 
                        if v == i then thing = j end --?
                    end
                    local added = -1
                    local removed = -1
                    
                    if thing == -1 and z == 1 then
                        table.insert(self.v, i)
                        added = i
                    else
                        table.remove(self.v, thing)
                        removed = i
                    end
                    
                    self:event(v, last, added, removed)

                    return true
                end
            end
        end
    end
end