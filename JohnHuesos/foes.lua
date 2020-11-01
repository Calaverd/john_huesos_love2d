function BaseEnemigo(x,y)
    local self = BaseEntity(x,y)

    self.hp = 1
    
    self.red_flicker = false
    self.fliker_timer = 0
    
    self.entity_id = 0

    self.can_damage_player_on_touch = true
    self.can_get_damaged = true

    self.shoot = false
    
    self.entity_tipe = "foe"
    
    
    function self.takeDamage(damage)
        local d = damage or 1
        self.hp = self.hp-d
        self.red_flicker = true
    end
    
    function self.checkForDamageTiles()
        if getTileCol(math.floor(self.x),math.floor(self.y)) == 7 then
            --underwater
            self.takeDamage()
        end
        if getTileCol(math.floor(self.x),math.floor(self.y)) == 8 then
            --underwater
            self.takeDamage(20)
        end
    end
    
    
    function self.Flick(dt)
        if self.red_flicker and self.fliker_timer < 0.09 then
            self.fliker_timer = self.fliker_timer+dt
            self.color[2] = 0
            self.color[3] = 0
        else
            self.color[2] = 1
            self.color[3] = 1
            self.fliker_timer = 0
            self.red_flicker = false
        end
    end
    
    return self
end


function DancingBloob(x,y)
    local self = BaseEnemigo(x,y)
    
    self.hp = 1
    self.col.x = self.x-0.75
    self.col.y = self.y-3
    self.col.w = 1.25
    self.col.h = 3
    
    self.entity_id = 2
    
    self.score_given = 500
    
    local ima = love.graphics.newImage("rsc/sprites/dancing_bloob.png")
    local framelist = simpleQuadsImagenAnchoAlto(80,58,16,29)
    self.is_dead = false
    self.use_frame = 1
    
    self.walk_anim = Animation({1,2,3,4,5})
    self.walk_anim.periodo = 0.1
    self.dead_anim = Animation({6,7,8,9,10})
    self.dead_anim.periodo = 0.1
    
    function self.update(dt)
        self.applyGravity(15,dt)
        
        if not self.is_dead then
            local move = (5*dt*self.dir)
            if self.canMoveX(move) then
                self.x = self.x+move
            else
                self.dir = self.dir*(-1)
            end
            
            self.col.x = self.x-0.5
            self.col.y = self.y-3
            self.col.w = 1
            self.col.h = 3
            
            self.updateColRect()
            self.checkForDamageTiles()
            
            if self.hp <= 0 then
                self.can_damage_player_on_touch = false
                self.is_dead = true
                self.dead_anim.restart()
            else
                if not self.on_screen then
                    self.freeze()
                end
            end
            self.use_frame = self.walk_anim.getFrameActual()
        else
            
            self.col.x = self.x-0.5
            self.col.y = self.y-0.5
            self.col.w = 1
            self.col.h = 0.5
            self.updateColRect()
            
            self.use_frame = self.dead_anim.getFrameActual()
            if self.dead_anim.is_ended then
                self.use_frame = 10
                self.update = self.disapear
            end
        end
        self.Flick(dt)
    end

    function self.draw()
        --[[
         love.graphics.setColor(1,0,0,0.5)
        if self.on_screen then
            love.graphics.setColor(0,0,0,1)
        end
        love.graphics.rectangle('fill',(self.col.x)*TILE_SIZE,(self.col.y)*TILE_SIZE,(self.col.w)*TILE_SIZE,(self.col.h)*TILE_SIZE)
        --]]
        love.graphics.setColor(self.color)
        --love.graphics.rectangle('fill',self.x*TILE_SIZE,self.y*TILE_SIZE,self.w,self.h)
        love.graphics.draw(ima,
            framelist[self.use_frame],self.x*TILE_SIZE,self.y*TILE_SIZE,0,self.dir,1,8,29)
    end
    
    return self
end

ENTITY_DEF_LIST[2] = DancingBloob


function MadEye(x,y)
    local self = BaseEnemigo(x,y)
    
    self.entity_id = 3
    
    local ima = love.graphics.newImage("rsc/sprites/eye.png")
    local framelist = simpleQuadsImagenAnchoAlto(64,48,16,16)
    self.use_frame = 1
    
    self.fly_anim = Animation({1,2,3,4,5,1,5,2,3,4,5,})
    self.fly_anim.periodo = 0.1
    self.dead_anim = Animation({6,7,8,9,10})
    self.dead_anim.periodo = 0.1
    self.hp = 1
    
    self.score_given = 750
    
    function self.estado(dt)
    end
    
    function self.goToPlayer(dt)
        local cx = self.player_pos.x-self.x
        local cy = self.player_pos.y-self.y-1
        local v = Vector2D(cx,cy)
        local v_normal = v.normalizar()
        if v_normal.x < 0 then
            self.dir = 1
        else
            self.dir = -1
        end
        local move_x = (dt*5*v_normal.x)
        local move_y = (dt*5*v_normal.y)
        if v.magnitud() > 0.5 then 
            self.x = self.x+move_x
            self.y = self.y+move_y
        else
            self.estado = self.runFromPlayer
        end
    end
    
    function self.runFromPlayer(dt)
        local cx = self.player_pos.x-self.x
        local cy = self.player_pos.y-self.y+1
        local v = Vector2D(cx,cy)
        local v_normal = v.normalizar()
        if v_normal.x < 0 then
            self.dir = -1
        else
            self.dir = 1
        end
        local move_x = (dt*5*v_normal.x)
        local move_y = (dt*5*v_normal.y)
        if v.magnitud() < 15  then 
            self.x = self.x-move_x
            self.y = self.y-move_y*2
        else
            self.estado = self.goToPlayer
        end
    end
    
    self.estado = self.goToPlayer
    
    function self.update(dt)
        if not self.is_dead then
            
            self.estado(dt)
            
            self.col.x = self.x-0.7
            self.col.y = self.y-0.7
            self.col.w = 1.4
            self.col.h = 1.4
            self.updateColRect()
            
            if self.hp <= 0 then
                self.can_damage_player_on_touch = false
                self.is_dead = true
                self.dead_anim.restart()
            else
                if not self.on_screen then
                    self.freeze()
                end
            end
            self.use_frame = self.fly_anim.getFrameActual()
        else
            self.col.x = self.x-0.5
            self.col.y = self.y-0.5
            self.col.w = 1
            self.col.h = 1
            self.updateColRect()
            self.applyGravity(15,dt)
            -- [[
            self.use_frame = self.dead_anim.getFrameActual()
            if self.dead_anim.is_ended then
                self.use_frame = 10
                self.color[4] = self.color[4]-dt
                if self.color[4] <= 0 then
                    self.to_remove = true
                end
                if not self.on_screen then
                    self.to_remove = true
                end
            end
        end
        
        self.Flick(dt)
    end
    
    function self.draw()
        
        --]]
        love.graphics.setColor(self.color)
        --love.graphics.rectangle('fill',self.x*TILE_SIZE,self.y*TILE_SIZE,self.w,self.h)
        love.graphics.draw(ima,
            framelist[self.use_frame],self.x*TILE_SIZE,self.y*TILE_SIZE,0,self.dir,1,7,8)
        
    end
    
    return self
end

ENTITY_DEF_LIST[3] = MadEye



function AlienEliteSoilder(x,y)
    local self = BaseEnemigo(x,y)
    
    self.entity_id = 4
    
    self.score_given = 2000
    
    local ima = love.graphics.newImage("rsc/sprites/alien_soilder_1.png")
    local framelist = simpleQuadsImagenAnchoAlto(96,96,32,32)
    self.use_frame = 1
    
    
    self.walk_anim = Animation({3,2,1})
    self.walk_anim.periodo = 0.1
    self.dead_anim = Animation({4,5,6,9,6,9,6,9,6,9,6})
    self.dead_anim.periodo = 0.15
    self.shoot_anim = Animation({2,7,8})
    self.shoot_cool_down = 0
    self.shoot = false
    self.hp = 5
    self.can_spin = true
    
    function self.getBullet()
        return self.x+1.3*self.dir,self.y-2.5,self.dir,'guided' --'standar'
    end
    
    function self.update(dt)
        self.applyGravity(15,dt)
        if not self.is_dead then
            local cx = self.player_pos.x-self.x
            local v = Vector2D(cx,cy)
            local v_normal = v.normalizar()
            if self.can_spin then
                if v_normal.x < 0 then
                    self.dir = -1
                    self.col.x = self.x-0.7
                    self.col.y = self.y-4
                    self.col.w = 1.8
                    self.col.h = 4
                else
                    self.dir = 1
                    self.col.x = self.x-1.2
                    self.col.y = self.y-4
                    self.col.w = 1.8
                    self.col.h = 4
                end
            end
            
            
            
            if v.magnitud() < 16 then
                self.shoot_cool_down = self.shoot_cool_down+dt
                if self.shoot_cool_down > 0.75 then
                    self.can_spin = false
                    self.use_frame = self.shoot_anim.getFrameActual()
                    if self.use_frame == 8 then
                        self.shoot_cool_down = 0
                        self.shoot = true
                    end
                else
                    
                    self.use_frame = 2
                    self.shoot_anim.restart()
                    self.can_spin = true
                    self.shoot = false
                end
                --SHOOT
                
            else
                self.shoot = false
                self.can_spin = true
                local move = (dt*7.5*v_normal.x)
                if self.canMoveX(move) then
                    self.x = self.x+move
                    self.use_frame = self.walk_anim.getFrameActual()
                else
                    self.use_frame = 2
                   
                    --SHOOT
                end
            end
            
            self.updateColRect()
            self.checkForDamageTiles()
            
            if self.hp <= 0 then
                self.can_damage_player_on_touch = false
                self.is_dead = true
                self.dead_anim.restart()
            else
                if not self.on_screen then
                    self.freeze()
                end
            end
            
        else
            self.col.x = self.x-1
            self.col.y = self.y-1
            self.col.w = 1
            self.col.h = 1
            self.updateColRect()
            
            -- [[
            self.use_frame = self.dead_anim.getFrameActual()
            self.color[4] = self.color[4]-(0.5*dt)
            if self.color[4] <= 0 then
                self.to_remove = true
            end
            if not self.on_screen then
                self.to_remove = true
            end
            if self.dead_anim.is_ended then
                self.use_frame = 6
            end
        end
        
        self.Flick(dt)
    end
    
    function self.draw()
        -- [[
        --love.graphics.setColor(1,0,0)
        --love.graphics.rectangle('fill',(self.col.x)*TILE_SIZE,(self.col.y)*TILE_SIZE,(self.col.w)*TILE_SIZE,(self.col.h)*TILE_SIZE)
        
        love.graphics.setColor(self.color)
        --love.graphics.rectangle('fill',self.x*TILE_SIZE,self.y*TILE_SIZE,self.w,self.h)
        love.graphics.draw(ima,
            framelist[self.use_frame],self.x*TILE_SIZE,self.y*TILE_SIZE,0,self.dir,1,16,32)
        
    end
    
    return self
end

ENTITY_DEF_LIST[4] = AlienEliteSoilder

function Teke(x,y)
    local self = BaseEnemigo(x,y)
    
    self.entity_id = 5
    
    self.score_given = 600
    
    local ima = love.graphics.newImage("rsc/sprites/teke.png")
    local framelist = simpleQuadsImagenAnchoAlto(48,32,16,16)
    self.use_frame = 1
    
    self.jump_anim = Animation({1,2,1,2})
    self.jump_anim.periodo = 0.1
    self.dead_anim = Animation({4,5,4,5})
    self.dead_anim.periodo = 0.1
    self.jump_cons_anim = Animation({1,2,1,2,1,2,1,2})
    --self.jump_cons_anim.periodo = 0.1
    self.hp = 1
    self.on_floor = true
    self.to_jump_counter = 0 
    
    function self.applyGravity(gravedad,dt)
        
        self.vel_y = self.vel_y + (gravedad*dt)
        if self.vel_y >= gravedad then 
            self.vel_y = gravedad
        end
        
        if not self.canGoDown(self.vel_y*dt) then
            self.y = self.y+(self.vel_y*dt)
            self.on_floor = false
        else
            self.y = math.floor(self.y+(self.vel_y*dt))
            self.vel_y = 0
            self.on_floor = true
        end
    end
    
    function self.estado(dt)
    end
    
    function self.on_air(dt)
        
        local move_x = (dt*8*-self.dir)
        if self.canMoveX(move_x) then
             self.x = self.x+move_x
        end
        
        self.applyGravity(12,dt)
        if self.on_floor then
            self.jump_cons_anim.restart()
            self.estado = self.to_jump
        end
        
        

    end
    
    function self.to_jump(dt)
        
        self.use_frame = self.jump_cons_anim.getFrameActual()
        if self.use_frame == 1 then
            self.dir = 1
        else
            self.dir = -1
        end
        self.to_jump_counter =  self.to_jump_counter+dt
        
        
        local cx = self.player_pos.x-self.x
        local cy = self.player_pos.y-self.y-1
        local v = Vector2D(cx,cy)
        
        if self.to_jump_counter > 1 and (v.magnitud() < 8) then
            if self.player_pos.x < self.x then
                self.dir = 1
            else
                self.dir = -1
            end
            self.estado = self.jump
            self.vel_y = -8
            self.to_jump_counter = 0
            self.jump_anim.restart()
        end
    end
    
    function self.jump(dt)
        self.use_frame = self.jump_anim.getFrameActual()
        if self.jump_anim.is_ended then
            self.use_frame = 3
            self.estado = self.on_air
        end
        
    end
    
    self.estado = self.to_jump
    
    function self.update(dt)
        self.col.x = self.x-0.5
        if self.dir == -1 then
            self.col.x = self.x-1
        end
        self.col.y = self.y-1.25
        self.col.w = 1.5
        self.col.h = 1.25
        if not self.is_dead then
            
            self.estado(dt)
            
            
            self.updateColRect()
            
            if self.hp <= 0 then
                self.can_damage_player_on_touch = false
                self.is_dead = true
                self.dead_anim.restart()
            else
                if not self.on_screen then
                    self.freeze()
                end
            end
            self.checkForDamageTiles()
           
        else
            
            self.updateColRect()
            self.applyGravity(15,dt)
            -- [[
            self.use_frame = self.dead_anim.getFrameActual()
            if self.dead_anim.is_ended then
                self.use_frame = 6
                self.color[4] = self.color[4]-dt
                if self.color[4] <= 0 then
                    self.to_remove = true
                end
                if not self.on_screen then
                    self.to_remove = true
                end
            end
        end
        
        self.Flick(dt)
    end
    
    function self.draw()
        
        --]]
        love.graphics.setColor(self.color)
        love.graphics.draw(ima,
            framelist[self.use_frame],self.x*TILE_SIZE,self.y*TILE_SIZE,0,self.dir,1,7,16)
        
        --love.graphics.setColor(1,0,0)
        --love.graphics.rectangle('fill',(self.col.x)*TILE_SIZE,(self.col.y)*TILE_SIZE,(self.col.w)*TILE_SIZE,(self.col.h)*TILE_SIZE)
        
    end
    
    return self
end

ENTITY_DEF_LIST[5] = Teke



function AlienSoilder(x,y)
    local self = BaseEnemigo(x,y)
    
    self.entity_id = 6
    
    local ima = love.graphics.newImage("rsc/sprites/granadero.png")
    local framelist = simpleQuadsImagenAnchoAlto(96,72,24,24)
    self.use_frame = 1
    
    self.score_given = 1000
    
    self.walk_anim = Animation({2,3,4})
    self.walk_anim.periodo = 0.1
    self.dead_anim = Animation({10,11,12,11,12,11,12,11,12})
    self.dead_anim.periodo = 0.15
    self.shoot_anim = Animation({5,6,7,8,9})
    self.shoot_anim.periodo = 0.1
    self.shoot_cool_down = 0
    self.shoot = false
    self.hp = 3
    self.can_spin = true
    
    function self.getBullet()
        return self.x+1.3*-self.dir,self.y-2.5,-self.dir,'bloop' --'standar'
    end
    
    function self.update(dt)
        self.applyGravity(15,dt)
        if not self.is_dead then
            local cx = self.player_pos.x-self.x
            local v = Vector2D(cx,cy)
            local v_normal = v.normalizar()
            if self.can_spin then
                if v_normal.x < 0 then
                    self.dir = 1
                    self.col.x = self.x-1
                    self.col.y = self.y-3
                    self.col.w = 1
                    self.col.h = 3
                else
                    self.dir = -1
                    self.col.x = self.x
                    self.col.y = self.y-3
                    self.col.w = 1
                    self.col.h = 3
                end
            end
            
            
            
            if v.magnitud() < 14 then
                self.shoot_cool_down = self.shoot_cool_down+dt
                if self.shoot_cool_down > 0.75 then
                    self.can_spin = false
                    self.use_frame = self.shoot_anim.getFrameActual()
                    if self.use_frame == 9 then
                        self.shoot_cool_down = 0
                        self.shoot = true
                    end
                else
                    
                    self.use_frame = 1
                    self.shoot_anim.restart()
                    self.can_spin = true
                    self.shoot = false
                end
                --SHOOT
                
            else
                self.shoot = false
                self.can_spin = true
                local move = (dt*8*v_normal.x)
                if self.canMoveX(move) and self.canMoveX(move+(self.dir*-1.5)) then
                    self.x = self.x+move
                    self.use_frame = self.walk_anim.getFrameActual()
                else
                    self.use_frame = 1
                   
                    --SHOOT
                end
            end
            
            self.updateColRect()
            self.checkForDamageTiles()
            
            if self.hp <= 0 then
                self.can_damage_player_on_touch = false
                self.is_dead = true
                self.dead_anim.restart()
            else
                if not self.on_screen then
                    self.freeze()
                end
            end
            
        else
            self.col.x = self.x-1
            self.col.y = self.y-1
            self.col.w = 1
            self.col.h = 1
            self.updateColRect()
            
            -- [[
            self.use_frame = self.dead_anim.getFrameActual()
            self.color[4] = self.color[4]-(0.5*dt)
            if self.color[4] <= 0 then
                self.to_remove = true
            end
            if not self.on_screen then
                self.to_remove = true
            end
            if self.dead_anim.is_ended then
                self.use_frame =11
            end
        end
        
        self.Flick(dt)
    end
    
    function self.draw()
        --[[
        love.graphics.setColor(1,0,0)
        love.graphics.rectangle('fill',(self.col.x)*TILE_SIZE,(self.col.y)*TILE_SIZE,(self.col.w)*TILE_SIZE,(self.col.h)*TILE_SIZE)
        --]]
        love.graphics.setColor(self.color)
        --love.graphics.rectangle('fill',self.x*TILE_SIZE,self.y*TILE_SIZE,self.w,self.h)
        love.graphics.draw(ima,
            framelist[self.use_frame],self.x*TILE_SIZE,self.y*TILE_SIZE,0,self.dir,1,16,24)
        
    end
    
    return self
end

ENTITY_DEF_LIST[6] = AlienSoilder



function TorretaR(x,y)
    local self = BaseEnemigo(x,y)
    
    self.entity_id = 7
    self.score_given = 1750
    
    local ima = love.graphics.newImage("rsc/sprites/torreta.png")
    local framelist = simpleQuadsImagenAnchoAlto(112,64,28,32)
    self.use_frame = 1
    
    
    self.walk_anim = Animation({1,2})
    self.walk_anim.periodo = 0.1
    self.dead_anim = Animation({7,8,7,8,7,8,7,8,7,8})
    self.dead_anim.periodo = 0.15
    self.shoot_anim = Animation({3,4,5,6})
    self.shoot_anim.periodo = 0.2
    self.shoot_cool_down = 0
    self.shoot = false
    self.hp = 3
    self.can_spin = true
    self.dir = 1
    
    function self.getBullet()
        return self.x+1.4*-self.dir,self.y-2.2,-self.dir,'standar' --'standar'
    end
    
    function self.update(dt)
        self.applyGravity(15,dt)
        if not self.is_dead then
            local cx = self.player_pos.x-self.x
            local v = Vector2D(cx,cy)
            local v_normal = v.normalizar()
            
            if self.dir == 1 then
                self.col.x = self.x-1
                self.col.y = self.y-3.5
                self.col.w = 1
                self.col.h = 3.5
                if v_normal.x < 0 then
                    self.can_get_damaged = false
                else
                    self.can_get_damaged = true
                end
            else
                self.col.x = self.x
                self.col.y = self.y-3.5
                self.col.w = 1
                self.col.h = 3.5
                if v_normal.x > 0 then
                    self.can_get_damaged = false
                else
                    self.can_get_damaged = true
                end
            end
            
            
            
            if v.magnitud() < 10 and not self.can_get_damaged then
                self.shoot_cool_down = self.shoot_cool_down+dt
                if self.shoot_cool_down > 0.75 then
                    self.use_frame = self.shoot_anim.getFrameActual()
                    if self.use_frame == 5 then
                        self.shoot_cool_down = 0
                        self.shoot = true
                    end
                else
                    
                    self.use_frame = 1
                    self.shoot_anim.restart()
                    self.shoot = false
                end
                --SHOOT
                
            else
                self.shoot = false
                local vel = 8.5
                if self.can_get_damaged then
                    vel = 4
                end
                local move = (dt*vel*v_normal.x)
                if self.canMoveX(move) then
                    self.x = self.x+move
                    self.use_frame = self.walk_anim.getFrameActual()
                else
                    self.use_frame = 1
                   
                    --SHOOT
                end
            end
            
            self.updateColRect()
            self.checkForDamageTiles()
            
            if self.hp <= 0 then
                self.can_damage_player_on_touch = false
                self.is_dead = true
                self.dead_anim.restart()
            else
                if not self.on_screen then
                    self.freeze()
                end
            end
            
        else
            self.col.x = self.x-1
            self.col.y = self.y-1
            self.col.w = 1
            self.col.h = 1
            self.updateColRect()
            
            -- [[
            self.use_frame = self.dead_anim.getFrameActual()
            self.color[4] = self.color[4]-(0.5*dt)
            if self.color[4] <= 0 then
                self.to_remove = true
            end
            if not self.on_screen then
                self.to_remove = true
            end
            if self.dead_anim.is_ended then
                self.use_frame =8
            end
        end
        
        self.Flick(dt)
    end
    
    function self.draw()
        -- [[
        
        
        love.graphics.setColor(self.color)
        --love.graphics.rectangle('fill',self.x*TILE_SIZE,self.y*TILE_SIZE,self.w,self.h)
        love.graphics.draw(ima,
            framelist[self.use_frame],self.x*TILE_SIZE,self.y*TILE_SIZE,0,self.dir,1,16,32)
        
        --love.graphics.setColor(1,0,0)
        --love.graphics.rectangle('fill',(self.col.x)*TILE_SIZE,(self.col.y)*TILE_SIZE,(self.col.w)*TILE_SIZE,(self.col.h)*TILE_SIZE)
        
    end
    
    return self
end

ENTITY_DEF_LIST[7] = TorretaR

function TorretaL(x,y)
    local self = TorretaR(x,y)
    self.dir = -1
    self.entity_id = 8
    return self
end

ENTITY_DEF_LIST[8] = TorretaL




function BossAlienShip(x,y)
    local self = BaseEnemigo(x,y)
    
    self.entity_id = 9
    SHOW_BOSS_HP = true
    
    self.score_given = 50000
    
    local ima = love.graphics.newImage("rsc/sprites/boss_1.png")
    local framelist = simpleQuadsImagenAnchoAlto(192,114,48,38)
    
    local x1_border = self.x - 28
    local x2_border = self.x + 5
    setBossBorders(x-28,x+5)
    
    self.use_frame = 1
    
    self.fly_anim = Animation({1})
    self.fly_anim.periodo = 0.1
    self.dead_anim = Animation({1,2,7,3,4,7,5,6,7,8,7,8,9,8,9,8,9,8,9,8,9,10,11,12,11,12,11,12})
    self.dead_anim.periodo = 0.1
    self.normal_shoot_anim = Animation({1,1,1,6,7})
    self.normal_shoot_anim.periodo = 0.1
    
    self.bloop_shoot_anim = Animation({1,1,2,3})
    self.bloop_shoot_anim.periodo = 0.1
    
    self.guided_shoot_anim = Animation({1,1,4,5})
    self.guided_shoot_anim.periodo = 0.2
    
    self.hp = 100
    
    self.shoot_counter = 0
    self.normal_counter = 0
    self.shoot_tipe = 'standar'
    
    function self.estado(dt)
    end

    function self.getBullet()
        if self.shoot_tipe == 'standar' then
            return self.x+2.5*self.dir,self.y-2.3,self.dir,'standar' --'standar'
        elseif self.shoot_tipe == 'bloop' then
             return self.x-2.4*self.dir,self.y-1.3,self.dir,'bloop' --'standar'
        elseif self.shoot_tipe == 'guided' then
             return self.x,self.y-1,self.dir,'guided' --'standar'
        end
    end
    
    function self.normalShot(dt)
        self.use_frame = 1
        local move_x = (dt*8*self.dir)
        if self.canMoveX(move_x+(self.dir*1.5)) then
            self.x = self.x+move_x
        else
            self.dir = self.dir*(-1)
            self.normal_counter = self.normal_counter +1
        end
        self.use_frame = 1
        self.shoot_counter = self.shoot_counter+dt
        if self.shoot_counter > 0.75 then
            self.shoot = false
            self.use_frame = self.normal_shoot_anim.getFrameActual()
            if self.use_frame == 7 then
                self.shoot = true
                self.normal_shoot_anim.restart()
                self.shoot_counter = 0
            end
        end
        
        if self.normal_counter > 3 then
            self.normal_counter = 0
            self.estado = self.upShoot
            self.shoot_tipe = 'bloop'
        end
        
    end
    
    function self.upShoot(dt)
        self.use_frame = 1
        local move_y = (dt*5)  
        if self.y > 9 then
            self.y = self.y-move_y
        else
            local move_x = (dt*8*self.dir)
            if self.canMoveX(move_x+(self.dir*1.5)) then
                self.x = self.x+move_x
            else
                self.dir = self.dir*(-1)
                self.normal_counter = self.normal_counter +1
            end
            
            self.use_frame = 1
            self.shoot_counter = self.shoot_counter+dt
            if self.shoot_counter > 0.4 then
                self.shoot = false
                self.use_frame = self.bloop_shoot_anim.getFrameActual()
                if self.use_frame == 3 then
                    self.shoot = true
                    self.bloop_shoot_anim.restart()
                    self.shoot_counter = 0
                end
            end
            
            if self.normal_counter > 4 then
                if math.floor(self.x) == x1_border+17 then
                    self.normal_counter = 0
                    self.estado = self.toCenter
                    self.shoot_tipe = 'guided'
                end
                --self.x = x2_border-5
            end
            
        end
        
    end
    
    function self.toCenter(dt)
        self.use_frame = 1
        local move_y = (dt*-5)  
        if math.floor(self.y)<14 then
            self.y = self.y-move_y
        else
            self.use_frame = 1
            self.shoot_counter = self.shoot_counter+dt
            if self.shoot_counter > 0.4 then
                self.shoot = false
                self.use_frame = self.guided_shoot_anim.getFrameActual()
                if self.use_frame == 5 then
                    self.shoot = true
                    self.guided_shoot_anim.restart()
                    self.shoot_counter = 0
                    self.normal_counter = self.normal_counter+1
                end
            end
            
            if self.normal_counter > 10 then
                self.normal_counter = 0
                    self.estado = self.intro
                    self.shoot_tipe = 'standar'
                --self.x = x2_border-5
            end
            
        end
    end
    
    function self.intro(dt)
        local move_y = (dt*-5)  
        if not self.canGoDown(move_y) then
            self.y = self.y-move_y
        else
            if self.hp > 0 then
                self.estado = self.normalShot
            end
        end
        self.use_frame = self.fly_anim.getFrameActual()
    end
    
    
    --self.shoot_tipe = 'guided'
    self.estado = self.intro
    
    function self.update(dt)
        if not self.is_dead then
            
            self.estado(dt)
            
            self.col.x = self.x-2.5
            self.col.y = self.y-3.8
            self.col.w = 5
            self.col.h = 2.5
            self.updateColRect()
            
            if self.hp <= 0 then
                self.can_damage_player_on_touch = false
                self.is_dead = true
                self.dead_anim.restart()
                SHOW_BOSS_HP = false
            else
                if self.hp < 50 then
                    self.color[2] = 1
                end
                if not self.on_screen then
                    self.freeze()
                end
            end
            
        else
            self.col.x = self.x-2.5
            self.col.y = self.y-4
            self.col.w = 5
            self.col.h = 1
            self.updateColRect()
            self.applyGravity(15,dt)
            -- [[
            self.use_frame = self.dead_anim.getFrameActual()
            if self.dead_anim.is_ended then
                LEVEL_COMPLETE = true
                self.use_frame = 12
                self.color[4] = self.color[4]-dt
                if self.color[4] <= 0 then
                    self.to_remove = true
                end
                if not self.on_screen then
                    self.to_remove = true
                end
            end
        end
        
        self.Flick(dt)
        BOSSHP = self.hp 
    end
    
    function self.draw()
        --love.graphics.setColor(1,0,0)
        --love.graphics.rectangle('fill',(self.col.x)*TILE_SIZE,(self.col.y)*TILE_SIZE,(self.col.w)*TILE_SIZE,(self.col.h)*TILE_SIZE)
        --]]
        love.graphics.setColor(self.color)
        --love.graphics.rectangle('fill',self.x*TILE_SIZE,self.y*TILE_SIZE,self.w,self.h)
        love.graphics.draw(ima,
            framelist[self.use_frame],self.x*TILE_SIZE,self.y*TILE_SIZE,0,-self.dir,1,24,38)
        
        
    end
    
    return self
end

ENTITY_DEF_LIST[9] = BossAlienShip


function BossUnipodo(x,y)
    local self = BaseEnemigo(x,y)
    
    self.entity_id = 10
    SHOW_BOSS_HP = true
    self.score_given = 25000
    
    local ima = love.graphics.newImage("rsc/sprites/boss_0.png")
    local framelist = simpleQuadsImagenAnchoAlto(224,96,32,48)
    
    local x1_border = self.x - 28
    local x2_border = self.x + 5
    setBossBorders(x-28,x+5)
    
    self.jump_anim = Animation({9})
    self.jump_anim.periodo = 0.1
    self.dead_anim = Animation({8,9,8,9,10,11,10,11,10,11,10,11,10,11,10,11,12,13,14,13,14,13,14,13,14})
    self.dead_anim.periodo = 0.1
    self.start_jump_anim = Animation({9,4,9,4})
    self.jump_cons_anim = Animation({1,2,3,1,2,3})
    --self.jump_cons_anim.periodo = 0.1
    self.sumon_anim = Animation({1,2,3,4,5,6,7,8,9})
    self.sumon_anim.periodo = 0.15
    self.sumon_counter = 0
    
    self.hp = 100
    self.on_floor = true
    self.to_jump_counter = 0 
    
    
    function self.applyGravity(gravedad,dt)
        
        self.vel_y = self.vel_y + (gravedad*dt)
        if self.vel_y >= gravedad then 
            self.vel_y = gravedad
        end
        
        if not self.canGoDown(self.vel_y*dt) then
            self.y = self.y+(self.vel_y*dt)
            self.on_floor = false
        else
            self.y = math.floor(self.y+(self.vel_y*dt))
            self.vel_y = 0
            self.on_floor = true
        end
    end
    
    function self.estado(dt)
    end
    
    function self.on_air(dt)
        
        local move_x = (dt*12*-self.dir)
        if self.canMoveX(move_x) then
             self.x = self.x+move_x
        end
        
        self.applyGravity(12,dt)
        if self.on_floor then
            self.jump_cons_anim.restart()
            self.estado = self.to_jump
        end
    end
    
    function self.sumon(dt)
        self.can_get_damaged = false
        self.use_frame = self.sumon_anim.getFrameActual()
        if self.use_frame == 9 then
            if self.dir == 1 then
                setTileControl(math.floor(self.x),math.floor(self.y-1),11)
            else
                setTileControl(math.floor(self.x+1),math.floor(self.y-1),12)
            end
            self.sumon_counter = self.sumon_counter +1
            self.sumon_anim.restart()
            if self.sumon_counter >= 3 then
                self.estado = self.start_jump
                self.start_jump_anim.restart()
                self.sumon_counter = 0
                self.can_get_damaged = true
            end
        end
        
    end
    
    
    function self.start_jump(dt)
        self.use_frame = self.start_jump_anim.getFrameActual()
        if self.start_jump_anim.is_ended then
            self.estado = self.jump
            self.vel_y = -math.sqrt(math.abs(self.player_pos.x-self.x-1)*15)
            self.to_jump_counter = 0
            self.jump_anim.restart()
        end
    end
    
    
    function self.to_jump(dt)
        
        self.use_frame = self.jump_cons_anim.getFrameActual()
        
        self.to_jump_counter =  self.to_jump_counter+dt
        
        
        local cx = self.player_pos.x-self.x
        local cy = self.player_pos.y-self.y-1
        local v = Vector2D(cx,cy)
        
        if self.to_jump_counter > 1.5 and (v.magnitud() < 28) then
            if self.player_pos.x < self.x then
                self.dir = 1
            else
                self.dir = -1
            end
            if math.random(0,100) > 35 then
                self.start_jump_anim.restart()
                self.estado = self.start_jump
            else
                self.estado = self.sumon
                self.sumon_anim.restart()
            end
        end
    end
    
    function self.jump(dt)
        self.use_frame = self.jump_anim.getFrameActual()
        if self.jump_anim.is_ended then
            self.use_frame = 9
            self.estado = self.on_air
        end
        
    end
    
    self.estado = self.to_jump
    
    function self.update(dt)
        self.col.x = self.x-0.3
        if self.dir == -1 then
            self.col.x = self.x-1.2
        end
        self.col.y = self.y-5.5
        self.col.w = 1.5
        self.col.h = 5
        if not self.is_dead then
            
            self.estado(dt)
            self.applyGravity(15,dt)
            
            self.updateColRect()
            
            if self.hp <= 0 then
                self.can_damage_player_on_touch = false
                self.is_dead = true
                self.dead_anim.restart()
            else
                if not self.on_screen then
                    self.freeze()
                end
            end
            self.checkForDamageTiles()
           
        else
            
            self.updateColRect()
            self.applyGravity(15,dt)
            -- [[
            self.use_frame = self.dead_anim.getFrameActual()
            if self.dead_anim.is_ended then
                LEVEL_COMPLETE = true
                self.use_frame = 14
                self.color[4] = self.color[4]-dt
                if self.color[4] <= 0 then
                    self.to_remove = true
                end
                if not self.on_screen then
                    self.to_remove = true
                end
            end
        end
        
        self.Flick(dt)
        BOSSHP = self.hp 
    end
    
    function self.draw()
        
        --]]
        if self.can_get_damaged then
            love.graphics.setColor(self.color)
        else
            love.graphics.setColor(1,0,1)
        end
        
        local quad = framelist[self.use_frame]
        if quad == nil then
            quad = framelist[1]
        end
        
        love.graphics.draw(ima,quad,self.x*TILE_SIZE,self.y*TILE_SIZE,0,self.dir,1,16,48)
        
        --love.graphics.setColor(1,0,0,0.5)
        --love.graphics.rectangle('fill',(self.col.x)*TILE_SIZE,(self.col.y)*TILE_SIZE,(self.col.w)*TILE_SIZE,(self.col.h)*TILE_SIZE)
        
    end
    
    return self
end

function SuperDancingBloopR(x,y)
    local self = DancingBloob(x,y)
    self.score_given = 650
    self.hp = 2
    return self
end

function SuperDancingBloopL(x,y)
    local self = SuperDancingBloopR(x,y)
    self.dir = self.dir*(-1)
    return self
end


ENTITY_DEF_LIST[10] = BossUnipodo
ENTITY_DEF_LIST[11] = SuperDancingBloopR
ENTITY_DEF_LIST[12] = SuperDancingBloopL



function BossTank(x,y)
    local self = BaseEnemigo(x,y)
    
    self.entity_id = 13
    self.score_given = 100000
    
    local ima = love.graphics.newImage("rsc/sprites/boos_2.png")
    local framelist = simpleQuadsImagenAnchoAlto(128,192,32,32)
    self.use_frame = 1
    
    local x1_border = self.x - 23
    local x2_border = self.x + 17
    setBossBorders(x-23,x+17)
    SHOW_BOSS_HP = true
    
    
    self.walk_anim = Animation({1,2,3})
    self.walk_anim.periodo = 0.1
    self.dead_anim = Animation({16,17,16,17,16,17,18,19,19,20,20,19,19,20,20,19,19,20,20,21,22,21,22,21,22,21,22,21,19,19,20,20})
    self.dead_anim.periodo = 0.1
    self.shoot_anim = Animation({4,5,6,7,12,5,8,9,12,5,10,11,12,5,6,7,12,5,8,9,12,5,10,11,12,5,6,7,12,5,8,9,12,5,10,11,12,5,6,7,12,5,8,9,12,5,10,11,12,5,6,7,12,5,8,9,12,5,10,11,12,5})
    self.shoot_anim.periodo = 0.1
    self.shoot_main_cannon_anim = Animation({13,14,14,15})
    self.shoot_main_cannon_anim.periodo = 0.1
    self.shoot_cool_down = 0
    self.shoot = false
    self.hp = 50
    self.can_spin = true
    self.dir = 1
    self.use_bullet = 0
    self.shoot_counter = 0
    self.sumon_cooldown = 0
    self.sumon_anim = Animation({23,24})
    
    function self.getBullet()
        if self.use_bullet == 0 then
            return self.x+0.5*-self.dir,self.y-0.5,-self.dir,'standar' --'standar'
        end
        if self.use_bullet == 1 then
            return self.x+0.5*-self.dir,self.y-1.5,-self.dir,'standar' --'standar'
        end
        if self.use_bullet == 2 then
            return self.x+0.5*-self.dir,self.y-2.5,-self.dir,'standar' --'standar'
        end
        if self.use_bullet == 3 then
            return self.x+1.5*-self.dir,self.y-1.5,-self.dir,'guided' --'standar'
        end
    end
    
    function self.state(dt)
    end

    function self.sumon(dt)
        self.use_frame = self.sumon_anim.getFrameActual()
        self.sumon_cooldown = self.sumon_cooldown+dt 
        if self.sumon_cooldown > 3 then
            setTileControl(math.floor(x1_border+17),math.floor(self.y-16),6)
            self.sumon_cooldown= 0
            self.state = self.shoot_main_cannon
            self.shoot_counter = 3
        end
    end
    
    function self.shoot_to_player(dt)
        self.shoot_cool_down = self.shoot_cool_down+dt
        self.use_frame = self.shoot_anim.getFrameActual()
        if self.shoot_cool_down > 0.4 then
            if self.use_frame == 7 then
                self.shoot = true
                self.use_bullet = 0
                self.shoot_cool_down = 0
            end
            if self.use_frame == 9 then
                self.shoot = true
                self.use_bullet = 1
                self.shoot_cool_down = 0
            end
            if self.use_frame == 11 then
                self.shoot = true
                self.use_bullet = 2
                self.shoot_cool_down = 0
            end
        else
            
            --self.use_frame = 1
            --self.shoot_anim.restart()
            self.shoot = false
        end
        if self.shoot_anim.is_ended then
            self.state = self.shoot_main_cannon
        end
    end
    
     function self.shoot_main_cannon(dt)
        local cx = self.player_pos.x-self.x
        local v = Vector2D(cx,cy)
        local v_normal = v.normalizar()
        self.dir = -v_normal.x
        
        self.shoot_cool_down = self.shoot_cool_down+dt
        self.use_frame = self.shoot_main_cannon_anim.getFrameActual()
        if self.shoot_cool_down > 0.75 then
            if self.use_frame == 15 then
                self.shoot = true
                self.use_bullet = 3
                self.shoot_cool_down = 0
                self.shoot_counter = self.shoot_counter+1
            end
        else
            self.use_frame = 1
            self.shoot_anim.restart()
            self.shoot = false
        end
        
        if self.shoot_counter >= 5 then
            self.state = self.realocate
            self.shoot_counter = 0
        end
    end
    
    function self.realocate(dt)
        local cx = self.player_pos.x-self.x
        local v = Vector2D(cx,cy)
        local v_normal = v.normalizar()
        self.dir = -v_normal.x
        
        
        
        local pdist = v.magnitud()
        self.use_frame = 1
        if  pdist > 8 then
            self.shoot = false
            local move = (dt*8*-self.dir)
            if self.canMoveX(move) then
                self.x = self.x+move
                self.use_frame = self.walk_anim.getFrameActual()
            else
                self.use_frame = 1
            end
        end
        -- [[
        if math.abs(self.player_pos.y-self.y) < 3 and not self.can_get_damaged then
            self.state = self.shoot_to_player
            self.shoot_cool_down = 0
            self.shoot_anim.restart()
        end
        --]]--
        
        if  pdist < 6 then
            self.state = self.sumon
            --self.shoot_cool_down = 0
            --self.shoot_main_cannon_anim.restart()
        end
        
    end
    
    self.state = self.realocate
    
    
    function self.update(dt)
        self.applyGravity(15,dt)
        if not self.is_dead then
           
            
           self.state(dt)
            
            
            if self.dir == 1 then
                self.col.x = self.x-1
                self.col.y = self.y-3.5
                self.col.w = 1
                self.col.h = 3.5
                if self.player_pos.x < self.x then
                    self.can_get_damaged = false
                else
                    self.can_get_damaged = true
                end
            else
                self.col.x = self.x
                self.col.y = self.y-3.5
                self.col.w = 1
                self.col.h = 3.5
                if self.player_pos.x > self.x then
                    self.can_get_damaged = false
                else
                    self.can_get_damaged = true
                end
            end
            
            self.updateColRect()
            self.checkForDamageTiles()
            
            if self.hp <= 0 then
                self.can_damage_player_on_touch = false
                self.is_dead = true
                self.dead_anim.restart()
            else
                if not self.on_screen then
                    self.freeze()
                end
            end
            
        else
            self.col.x = self.x-1
            self.col.y = self.y-1
            self.col.w = 1
            self.col.h = 1
            self.updateColRect()
            
            -- [[
            self.use_frame = self.dead_anim.getFrameActual()
            if self.color[4] > 0 then
                self.color[4] = self.color[4]-dt*0.2
            end
            if self.dead_anim.is_ended then
                LEVEL_COMPLETE = true
                self.use_frame = 14
                
                if not self.on_screen then
                    self.to_remove = true
                end
            end
        end
        
        self.Flick(dt)
        BOSSHP = self.hp*2
   end
    
    function self.draw()
        -- [[
        
        
        love.graphics.setColor(self.color)
        --love.graphics.rectangle('fill',self.x*TILE_SIZE,self.y*TILE_SIZE,self.w,self.h)
        love.graphics.draw(ima,
            framelist[self.use_frame],self.x*TILE_SIZE,self.y*TILE_SIZE,0,self.dir,1,16,32)
        
        --love.graphics.setColor(1,0,0)
        --love.graphics.rectangle('fill',(self.col.x)*TILE_SIZE,(self.col.y)*TILE_SIZE,(self.col.w)*TILE_SIZE,(self.col.h)*TILE_SIZE)
        
    end
    
    return self
end

ENTITY_DEF_LIST[13] = BossTank
