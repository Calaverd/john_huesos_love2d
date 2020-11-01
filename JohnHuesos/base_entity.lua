function BaseEntity(x,y)
    local self = {}
    self.x = x
    self.y = y
    self.vel_y = 0
    self.dir = -1
    
    self.to_remove = false
    self.score_given = 10
    
    self.col = {}
    self.col.x = 0
    self.col.y = 0
    self.col.w = 1
    self.col.h = 1
    
    BWORLD:add(self,self.col.x,self.col.y,self.col.w,self.col.h)
    
    self.on_screen = true
    
    self.color = {}
    self.color[1] = 1
    self.color[2] = 1
    self.color[3] = 1
    self.color[4] = 1
    
    self.player_pos = {}
    self.player_pos.x = 0
    self.player_pos.y = 0
    
    self.entity_tipe = "base"
    self.entity_id = -1
    
    function self.getPlayerPos(x,y)
        self.player_pos.x = x
        self.player_pos.y = y
    end
    
    function self.update(dt)
    
    end

    function self.draw()
        love.graphics.setColor(1,0,0)
        love.graphics.rectangle('line',self.x*8,self.y*8,2,2)
    end
    
    function self.canGoDown(dy)
        local can = isValInTable(TILES_CAN_STOP_FALL, getTileCol(math.floor(self.x),math.floor(self.y+dy)))
        return  can
    end
    
    function self.canMoveX(dx)
        local can = isValInTable(TILES_CAN_PASS, getTileCol(math.floor(self.x+dx),math.floor(self.y-1)))
        return  can
    end
    
    function self.pointCol(x,y)
        local items, len = BWORLD:queryPoint(x,y)
        local i = 1
        while items[i] do
            if self == items[i] then
                return true
            end
            i=i+1
        end
        return false
    end
    
    
    function self.updateColRect()
        BWORLD:update(self,self.col.x,self.col.y,self.col.w,self.col.h)
    end
    
    function self.collisionRect(x,y,w,h)
        local items, len = BWORLD:queryRect(x,y,w,h)
        local i = 1
        while items[i] do
            if self == items[i] then
                return true
            end
            i=i+1
        end
        return false
    end
    
    function self.isOnScreen(x,y,w,h)
        self.on_screen = false
        local items, len = BWORLD:queryRect(x,y,w,h)
        local i = 1
        while items[i] do
            if self == items[i] then
                self.on_screen = true
            end
            i=i+1
        end
        return self.on_screen
    end
    
    function self.applyGravity(gravedad,dt)
        
        self.vel_y = self.vel_y + (gravedad*dt)
        if self.vel_y >= gravedad then 
            self.vel_y = gravedad
        end
        
        if not self.canGoDown(self.vel_y*dt) then
            self.y = self.y+(self.vel_y*dt)
        else
            self.y = math.floor(self.y+(self.vel_y*dt))
            self.vel_y = 0
        end
    end
    
    function self.disapear(dt)
        self.color[4] = self.color[4]-dt
        if self.color[4] <= 0 then
            self.to_remove = true
        end
        if not self.on_screen then
            self.to_remove = true
        end
    end
    
    function self.freeze()
        self.to_remove = true
        setTileControl(math.floor(self.x),math.floor(self.y-1),self.entity_id)
    end
    return self
end
