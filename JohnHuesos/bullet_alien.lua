
BULLET_ALIEN_IMA = nil
BULLET_ALIEN_IMA_FRAME_LIST = nil

function BulletAlien(x,y,dir,tipe)
    local self = {}
    self.dir = dir
    self.x = x
    self.y = y
    self.w = 2
    self.h = 2
    
    self.on_screen = true
    
    self.is_dead = false
    self.add_explo = false
    self.ricochet = false
    self.to_remove = false
    
    self.shot_anim = Animation({1,2,3})
    self.shot_explo = Animation({4,5,6,7})
    self.ricochet_anim = Animation({6,7})
    self.shot_explo.periodo = 0.05
    self.tipe = tipe or 'standar'
    self.use_frame = 1
    self.frame_offset = 0
    self.dir_y = math.random(-2,2)
    self.vel_y = 0
    
    self.dir_x = 0
    self.dir_y = 0
    
    self.player_pos = {}
    self.player_pos.x = 0
    self.player_pos.y = 0
    self.counter_guided = 0
    
    self.bloop_jumps = 3
    
    if self.tipe == 'standar' then
        self.frame_offset = 0
    elseif self.tipe == 'bloop' then
        self.frame_offset = 7
        self.shot_anim = Animation({1,2,3,2})
    elseif self.tipe == 'guided' then
        self.frame_offset = 14
        self.shot_anim.periodo = 0.05
    end
    
    function self.getPlayerPos(x,y)
        self.player_pos.x = x
        self.player_pos.y = y
    end
    
    
    function self.applyGravity(gravedad,dt)
        
        self.vel_y = self.vel_y + (gravedad*dt)
        if self.vel_y >= gravedad then 
            self.vel_y = gravedad
        end
        if not isValInTable(TILES_CAN_STOP_FALL,getTileCol(math.floor(self.x),math.floor(self.y+(self.vel_y*dt))) ) then
            --self.confirmedImpact()
            self.y = self.y+(self.vel_y*dt)
            return true
        end
        return false
    end
    
    function self.standar(dt)
        if not self.is_dead then
            self.x = self.x+(12*dt*self.dir)
            self.use_frame = self.shot_anim.getFrameActual()
        else
            if self.add_explo then
                self.use_frame = self.shot_explo.getFrameActual()
                if self.shot_explo.is_ended then
                    self.to_remove = true
                end
            end
            if self.ricochet then
                --self.use_frame = 4
                self.x = self.x-(12*dt*self.dir)
                self.applyGravity(15,dt)
                self.use_frame = self.ricochet_anim.getFrameActual()
                if self.ricochet_anim.is_ended then
                    self.to_remove = true
                end
            end
        end
        
        if not self.on_screen then
            self.to_remove = true
        end
        
        if not isValInTable(TILES_CAN_PASS_BULLET,getTileCol(math.floor(self.x),math.floor(self.y)) ) then
            self.confirmedImpact()
        end
    end
    
    function self.guided(dt)
        if not self.is_dead then
            self.counter_guided = self.counter_guided +dt
            if self.counter_guided < 0.75 then
                local cx = self.player_pos.x-self.x
                local cy = self.player_pos.y-self.y-1
                local v = Vector2D(cx,cy)
                local v_normal = v.normalizar()
                if v_normal.x < 0 then
                    self.dir = 1
                else
                    self.dir = -1
                end
                self.dir_x = (dt*10*v_normal.x)
                self.dir_y = (dt*10*v_normal.y)
                
            end
            self.x = self.x+self.dir_x
            self.y = self.y+self.dir_y
            self.use_frame = self.shot_anim.getFrameActual()
        else
            if self.add_explo then
                self.use_frame = self.shot_explo.getFrameActual()
                if self.shot_explo.is_ended then
                    self.to_remove = true
                end
            end
            if self.ricochet then
                --self.use_frame = 4
                self.x = self.x-(12*dt*self.dir)
                self.applyGravity(15,dt)
                self.use_frame = self.ricochet_anim.getFrameActual()
                if self.ricochet_anim.is_ended then
                    self.to_remove = true
                end
            end
        end
        
        if not self.on_screen then
            self.to_remove = true
        end
    end
    
    function self.bloop(dt)
        if not self.is_dead then
            self.use_frame = self.shot_anim.getFrameActual()
            if isValInTable(TILES_CAN_PASS,getTileCol(math.floor(self.x+5*dt*self.dir),math.floor(self.y)) ) then
                self.x = self.x+5*dt*self.dir
            else
                self.dir = -self.dir
            end
            
            if not self.applyGravity(9,dt) then
                self.vel_y = -12+(self.bloop_jumps)
                 self.use_frame = 4
                 self.bloop_jumps = self.bloop_jumps-1
                if self.bloop_jumps <= 0 then
                    self.confirmedImpact()
                end
            end
            
        else
            if self.add_explo then
                self.use_frame = self.shot_explo.getFrameActual()
                if self.shot_explo.is_ended then
                    self.to_remove = true
                end
            end
            if self.ricochet then
                --self.use_frame = 4
                self.x = self.x-(12*dt*self.dir)
                self.applyGravity(15,dt)
                self.use_frame = self.ricochet_anim.getFrameActual()
                if self.ricochet_anim.is_ended then
                    self.to_remove = true
                end
            end
        end
        
        if not self.on_screen then
            self.to_remove = true
        end
    end
    
    function self.update(dt)
        if self.tipe == 'standar' then
            self.standar(dt)
        elseif self.tipe == 'guided' then
            self.guided(dt)
        elseif self.tipe == 'bloop' then
            self.bloop(dt)
        end
    end
    
    function self.noSell()
        self.ricochet = true
        self.is_dead = true
        self.ricochet_anim.restart()
    end
    
    function self.confirmedImpact()
        self.is_dead = true
        self.add_explo = true
    end
    
    function self.draw()
        --]]
        
        
        love.graphics.setColor(1,1,1)
        --love.graphics.rectangle('fill',self.x*TILE_SIZE,self.y*TILE_SIZE,self.w,self.h)
        love.graphics.draw(BULLET_ALIEN_IMA,
            BULLET_ALIEN_IMA_FRAME_LIST[self.frame_offset+self.use_frame],self.x*TILE_SIZE,self.y*TILE_SIZE,0,self.dir,1,4,4)
    end
    
    function self.isOnScreen(xi,xf,yi,yf)
        self.on_screen = ( (self.x < xf) and (self.x > xi) ) 
    end
    
    return self
end