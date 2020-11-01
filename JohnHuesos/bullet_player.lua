
BULLET_PLAYER_IMA = nil
BULLET_PLAYER_IMA_FRAME_LIST = nil

function BulletPlayer(x,y,dir)
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
    self.ricochet_anim = Animation({4,5,4,5,4,5,4,5})
    self.ricochet_anim.periodo = 0.05
    self.shot_explo = Animation({4,5,6,7})
    self.shot_explo.periodo = 0.05
    self.use_frame = 1
    self.dir_y = math.random(-2,2)
    self.vel_y = 0
    
    function self.applyGravity(gravedad,dt)
        
        self.vel_y = self.vel_y + (gravedad*dt)
        if self.vel_y >= gravedad then 
            self.vel_y = gravedad
        end
        self.y = self.y+(self.vel_y*dt)
        
    end
    
    function self.update(dt)
        if not self.is_dead then
            self.x = self.x+(20*dt*dir)
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
                self.x = self.x-(12*dt*dir)
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
        
        love.graphics.setColor(1,1,1)
        --love.graphics.rectangle('fill',self.x*TILE_SIZE,self.y*TILE_SIZE,self.w,self.h)
        love.graphics.draw(BULLET_PLAYER_IMA,
            BULLET_PLAYER_IMA_FRAME_LIST[self.use_frame],self.x*TILE_SIZE,self.y*TILE_SIZE,0,self.dir,1,4,4)
    end
    
    function self.isOnScreen(xi,xf,yi,yf)
        self.on_screen = ( (self.x < xf) and (self.x > xi) ) 
    end
    
    return self
end