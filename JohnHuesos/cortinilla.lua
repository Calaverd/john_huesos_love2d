function Cortinilla()
    local self = Escena()
    local cortinilla = nil
    local x_ratio = 0
    local y_ratio = 0
    
    local half_w = 0
    local half_h = 0
    
    local color = {0.878,0.192,0.235}
    local show_cortinilla = true
    local lerp_val = 0
    
    self.useShaders = false
    
    function self.load()
        cortinilla = love.graphics.newVideo('rsc/Cortinilla.ogg')
        width, height = cortinilla:getDimensions( )
        x_ratio = (512*2)-(width/2)
        y_ratio = (384*2)-(height/2)
        half_h = (height/2)
        half_w = (width/2)
        
    end
    
    function self.update(dt)
        cortinilla:play()
        if cortinilla:tell( ) >= 12 then
            show_cortinilla = false
            lerp_val = lerp_val+dt*0.5
            
        end
        color[1] = lerp(color[1],0,lerp_val)
        color[2] = lerp(color[2],0,lerp_val)
        color[3] = lerp(color[3],0,lerp_val)
        if lerp_val >= 1 then
            if EXIST_USER_SETTINGS then
                --local new_scene = love.filesystem.load("intro.lua")()
                --ESCENA_MANAGER.replace(new_scene)
                local new_scene = love.filesystem.load("mainMenu.lua")()
                ESCENA_MANAGER.replace(new_scene)
            else
                local init_scene =  love.filesystem.load("ask_idiom.lua")()
                ESCENA_MANAGER.push(init_scene)
            end
            cortinilla:release( )
        end
    end
    
    function self.draw()
        love.graphics.clear(color)
         
        love.graphics.push()
        love.graphics.scale(1,1)
        --love.graphics.scale(x_ratio ,y_ratio)
        if show_cortinilla then
            love.graphics.draw(cortinilla,512,384,0,1,1,half_w,half_h)
        end
        
        
        love.graphics.pop()
    end

    

    function self.keyreleased( key, scancode )
    end
    
    function self.keypressed(key,scancode)
    end
    
    return self
end

return Cortinilla()