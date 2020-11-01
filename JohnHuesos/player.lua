function Player(x,y)
    local self = {}
    self.fx = x
    self.fy = y+1
    self.vel_y = 0
    self.pressed_l = false
    self.pressed_u = false
    self.pressed_d = false
    self.pressed_r = false
    self.pressed_shot = false
    self.pressed_cola = {}
    
    self.hp = 10
    
    self.color = {}
    self.color[1] = 1
    self.color[2] = 1
    self.color[3] = 1
    self.color[4] = 1
    
    self.can_take_damage = true
    self.red_flicker = false
    self.fliker_timer = 0
    self.invencible_timer = 0
    
    self.cam_look_x = 0
    self.cam_look_y = 0
    self.cam_pan_val = 0
    
    self.col_box = {}
    self.col_box.x = 0
    self.col_box.y = 0
    self.col_box.w = 1.6
    self.col_box.h = 2.9
    
    BWORLD:add(self,self.col_box.x,self.col_box.y,self.col_box.w,self.col_box.h)
    
    self.it_jumped = false
    self.on_floor = true
    self.falling = false
    self.looking_rigth = true
    self.runing = false
    self.kneel = false
    
    self.ignore_col_y = 0
    self.coyote_timer = 0
    self.coyote_time = 0.25
    
    self.image = nil
    self.frame_list = nil
    self.frame = 1
    
    self.running_anim = Animation({6,7,8,7})
    self.idle_anim = Animation({1,1,1,1,1,2,1,1,1,1,1})
    self.edge_anim = Animation({11,12,13})
    self.kneel_anim = Animation({15,14})
    
    self.sound_player_jump = nil
    self.sound_player_lands = nil
    
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
    
    function self.takeDamage(damage)
        local d = damage or 1
        if self.can_take_damage then
            self.hp = self.hp-d
            self.red_flicker = true
            self.can_take_damage = false
        end
    end
    
    function self.damageHandle(dt)
        if not self.can_take_damage then
            if self.invencible_timer < 1 then
                self.invencible_timer = self.invencible_timer+dt
                self.fliker_timer = self.fliker_timer+dt
                if self.red_flicker then
                    if self.fliker_timer < 0.1 then
                        self.color[1] = 0.5
                        self.color[2] = 0.5
                        self.color[3] = 0.5
                        self.color[4] = 0.5
                        --self.frame = 9
                    elseif  self.fliker_timer > 0.1 and self.fliker_timer < 0.15 then
                        self.color[4] = 0
                    else
                        self.color[1] = 1
                        self.color[2] = 0
                        self.color[3] = 0
                        self.color[4] = 1
                        self.fliker_timer = 0
                    end
                end
            else
                self.color[1] = 1
                self.color[2] = 1
                self.color[3] = 1
                 self.color[4] = 1
                self.can_take_damage = true
                self.red_flicker = false
                self.invencible_timer = 0
                print(self.hp)
            end
        end
    end
    
    function self.canGoDown(x,y)    
        local t1 = getTileCol(math.floor(x),math.floor(y))
        local t2 = getTileCol(math.floor(x-0.8),math.floor(y))
        local t3 = getTileCol(math.floor(x+0.8),math.floor(y))
       
        if self.ignore_col_y == math.floor(y) then
            if (isValInTable(TILES_CAN_STOP_FALL, t1) and not isValInTable(TILES_CAN_PASS, t1) ) or
               (isValInTable(TILES_CAN_STOP_FALL, t2) and not isValInTable(TILES_CAN_PASS, t2) ) or
               (isValInTable(TILES_CAN_STOP_FALL, t3) and not isValInTable(TILES_CAN_PASS, t3) )then
                return false
            end
        else
            if isValInTable(TILES_CAN_STOP_FALL, t1) or
               isValInTable(TILES_CAN_STOP_FALL, t2)or
               isValInTable(TILES_CAN_STOP_FALL, t3)then
                return false
            end
        end
        return true
    end
    
    function self.inTheBorder(x,y)
        local stable_pos = isValInTable(TILES_CAN_STOP_FALL, getTileCol(math.floor(x),math.floor(y)) )
        if self.looking_rigth then
            return isValInTable(TILES_CAN_STOP_FALL, getTileCol(math.floor(x-0.9),math.floor(y)) ) and not stable_pos
        else
            return isValInTable(TILES_CAN_STOP_FALL, getTileCol(math.floor(x+0.7),math.floor(y)) ) and not stable_pos
        end
    end
    
    function self.canGoUp(x,y)
        local can_move_hat = false
        if self.looking_rigth then
            can_move_hat = isValInTable(TILES_CAN_PASS,getTileCol(math.floor(x-0.75),math.floor(y-3)) )
        else
            can_move_hat = isValInTable(TILES_CAN_PASS,getTileCol(math.floor(x+0.75),math.floor(y-3)) )
        end
        if isValInTable(TILES_CAN_PASS,getTileCol(math.floor(x),math.floor(y-3)) ) and 
            can_move_hat then
            return true
        end
        return false
    end
    
    function self.canChangePos(x,y) 
         local i = 1
        while TILES_CAN_PASS[i] do
            if getTileCol(math.floor(x),math.floor(y)) == TILES_CAN_PASS[i] then
                return true
            end
            i=i+1
        end
        return false
    end
    
    function self.canMoveLeft(x,y) 
        if  isValInTable(TILES_CAN_PASS,getTileCol(math.floor(x-0.8),math.floor(y-0.5))) and 
            isValInTable(TILES_CAN_PASS,getTileCol(math.floor(x-0.8),math.floor(y-1.5))) --and
            --isValInTable(TILES_CAN_PASS,getTileCol(math.floor(x-1),math.floor(y-2.5)))  
            then
            return true
        end
        return false
    end
    
    function self.canMoveRight(x,y) 
        if  isValInTable(TILES_CAN_PASS,getTileCol(math.floor(x+0.8),math.floor(y-0.5))) and 
            isValInTable(TILES_CAN_PASS,getTileCol(math.floor(x+0.8),math.floor(y-1.5))) --and
            --isValInTable(TILES_CAN_PASS,getTileCol(math.floor(x+1),math.floor(y-2.5)))  
            then
            return true
        end
        return false
    end
    
    function self.checkForDamageTiles()
        if getTileCol(math.floor(self.fx),math.floor(self.fy)) == 7 then
            --underwater
            self.takeDamage()
        end
        if getTileCol(math.floor(self.fx),math.floor(self.fy)) == 8 then
            --underwater
            self.takeDamage(20)
        end
    end
    
    
    function self.aliveUpdate(dt)
        local gravedad = 15
        local vel = (10*dt)
        
        self.runing = false 
        
        --el tile donde estamos
        if getTileCol(math.floor(self.fx),math.floor(self.fy-1.5)) == 2 then
            --underwater
            gravedad = 3
            vel = (5*dt)
        end
        self.checkForDamageTiles()
        
        --ignore ALL INPUT if kneel
        self.kneel = self.pressed_d
        
        if self.kneel then
            self.ignore_col_y = math.floor(self.fy)
            if self.it_jumped or self.falling then
                vel = (4*dt)
                gravedad = 22
            else
                vel = (0.5*dt)
            end
        end
        
        
        if not self.canGoUp(self.fx+vel,self.fy) and (self.vel_y < 0) then
            self.vel_y = 0
        end
        
        self.vel_y = self.vel_y + (gravedad*dt)
        self.fy = self.fy+(self.vel_y*dt)
        if self.vel_y >= gravedad then 
            self.vel_y = gravedad
        end
        
        if self.vel_y >= 0 then
            self.falling = true
            self.coyote_timer = self.coyote_timer + (dt)
        end
        
        if self.falling and not self.canGoDown(self.fx,self.fy+self.vel_y*dt) then
            self.fy = math.floor(self.fy+(self.vel_y*dt))
            self.vel_y = 0
            self.on_floor = true
            self.it_jumped = false
            self.falling = false
            self.coyote_timer = 0
            self.ignore_col_y = 0
        end
        
        self.col_box.x = self.fx-0.6
        self.col_box.y = self.fy-2.8
        self.col_box.w = 1.2
        self.col_box.h = 2.2
        
        
        if self.pressed_l and self.canMoveLeft(self.fx-vel,self.fy-0.1) then
            self.fx = self.fx-vel
            if self.looking_rigth then
                self.cam_pan_val = 0 
            end
            self.looking_rigth = false
            self.runing = true
        end
        
        if self.pressed_r and self.canMoveRight(self.fx+vel,self.fy-0.1) then
            self.fx = self.fx+vel
            if not self.looking_rigth then
                self.cam_pan_val = 0 
            end
            self.looking_rigth = true
            self.runing = true
        end
        
        if self.pressed_u and not self.kneel then
            if self.on_floor and not self.falling then
                self.vel_y = -12
                self.on_floor = false
                self.it_jumped = true
                self.pressed_u = false
                self.sound_player_jump:play()
            end
            if self.coyote_timer <= self.coyote_time and not self.it_jumped then
                self.vel_y = -12
                self.on_floor = false
                self.it_jumped = true
                self.pressed_u = false
                self.coyote_timer = 0
                self.sound_player_jump:play()
            end
        end
        
        if self.kneel then
            self.col_box.x = self.fx-0.6
            self.col_box.y = self.fy-1.1
            self.col_box.w = 1.2
        end
        
        
        if self.cam_pan_val < 1 then
            self.cam_pan_val = self.cam_pan_val+(0.5*dt) 
        end
        
        self.cam_look_y = self.fy-8
        if self.looking_rigth then
            self.cam_look_x = lerp(self.cam_look_x,self.fx+5,self.cam_pan_val) 
        else
            self.cam_look_x = lerp(self.cam_look_x,self.fx-5,self.cam_pan_val) 
        end
        
        --ANIMATIONS
        
        if self.it_jumped or self.falling then
            self.frame = 5 --falling
            --este es un espagueti horrible
            self.col_box.h = 2.4
        else
            if self.runing then
                self.frame = self.running_anim.getFrameActual()
            else
                if self.inTheBorder(self.fx,self.fy+self.vel_y*dt) then
                    self.frame = self.edge_anim.getFrameActual()
                else
                   if self.pressed_shot then
                        self.frame = 4
                    else
                        self.frame = self.idle_anim.getFrameActual() --idle
                    end
                end
            end
        end
        if self.kneel then
            self.frame = self.kneel_anim.getFrameActual() 
            self.col_box.h = 1
        end
        
        BWORLD:update(self,self.col_box.x,self.col_box.y,self.col_box.w,self.col_box.h)
        
        self.damageHandle(dt)
            
    end
    
    function self.update(dt)
        if self.hp > 0 then
            self.aliveUpdate(dt)
        else
            self.frame = 9
            self.damageHandle(dt)
        end
    
    end
    
    function self.getBullet()
        local flip = -1
        if self.looking_rigth then
            flip = 1
        end
        return self.fx+1.3*flip,self.fy-1.5,flip
    end
    
    function self.draw()
        --love.graphics.setColor(1,0,0)
        --love.graphics.rectangle('fill',((self.col_box.x)*TILE_SIZE),((self.col_box.y)*TILE_SIZE),self.col_box.w*TILE_SIZE,self.col_box.h*TILE_SIZE)
        
        

        love.graphics.setColor(self.color)
        local flip = -1
        if self.looking_rigth then
            flip = 1
        end
        love.graphics.draw( self.imagen, self.frame_list[self.frame] ,((self.fx)*TILE_SIZE),((self.fy)*TILE_SIZE),0,flip,1,12,24)
        
        love.graphics.setColor(1,0,0)
    end
    
    return self
end