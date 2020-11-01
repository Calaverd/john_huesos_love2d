love.filesystem.load("utf8.lua")()
cervantes = love.filesystem.load("cervantes.lua")()


INTRO_TEXT = {}
INTRO_TEXT['EN'] = {
    [[The #ALIENS# run away towards the stars once they see themselves defeated by %JOHN HUESOS.%]],
    [[The %WITCH CARMELA% Thanks him for saving the earth.]],
    [[Him go back to their tomb, knowing that everything will be alright...]],
    [[Because if the world needs him once more, *they know where to dig.* ]]
}
INTRO_TEXT['ES'] = {
    [[Los #ALIENÍGENAS# huyen hacia las estrellas una vez que se ven derrotados por %JOHN HUESOS.%]],
    [[La %BRUJA CARMELA% le agradece por salvar la tierra.]],
    [[Él regresa a su tumba, sabiendo que todo estará bien...]],
    [[Porque si el mundo lo necesita una vez más, *ellos saben dónde cavar.* ]]
    }
SKIP_TEXT = {}
SKIP_TEXT['ES'] = 'Presiona "espacio" para omitir.'
SKIP_TEXT['EN'] = 'Press "space" to skip.'

function IntroScene()
    local self = Escena()
    local map = nil
    local intro_ima = nil
    local intro_frames = nil
    
    local list_words = nil
    local box = Cervantes.textBox(20*4,130*4,226*4,48*4)
    
    local current_slide = 1
    local next_pause_counter = 0
    
    local bg_music = nil
    local bg_ima = nil
    local can_go = false
    
    function self.load()
        bg_ima =  love.graphics.newImage("rsc/ending_town.png")
        intro_ima = love.graphics.newImage("rsc/ending_titles.png")
        intro_frames = simpleQuadsImagenAnchoAlto(256,192,128,96)
        
        cervantes.init()
        --override the default font
        Cervantes.addFormat(Cervantes.Format(FONT),'default')
        Cervantes.addFormat(Cervantes.Format(FONT_BOLD,'*'),'bold')
        Cervantes.addFormat(Cervantes.Format(FONT_BOLD,'#'),'bad')
        Cervantes.addFormat(Cervantes.Format(FONT_BOLD,'%'),'good')
        
        Cervantes.FormatList['default'].color = {0.8,0.8,0.8}
        Cervantes.FormatList['default'].sound = TEXT_SOUND
        Cervantes.FormatList['default'].speed_text = 0.08
        Cervantes.FormatList['bold'].color = {1,1,1}
        Cervantes.FormatList['bold'].speed_text = 0.08
        Cervantes.FormatList['bold'].sound = TEXT_SOUND
        Cervantes.FormatList['bad'].color = {1,0.2,0.2}
        Cervantes.FormatList['bad'].speed_text = 0.08
        Cervantes.FormatList['bad'].sound = TEXT_SOUND
        Cervantes.FormatList['good'].color = {0.1,0.1,0.8}
        Cervantes.FormatList['good'].speed_text = 0.08
        Cervantes.FormatList['good'].sound = TEXT_SOUND
        print(TEST)
        
        list_words, averange_format  = cervantes.parseText(INTRO_TEXT[LANG][current_slide])
        print('the averange format is:' ,averange_format)
        box.setWordList(list_words,averange_format)
        
        bg_music = love.audio.newSource("rsc/music/year2014.xm",'stream')
        bg_music:setLooping(true)
        bg_music:play()
    end
    
    function self.update(dt)
        box.update(dt)
        if box.compled then
            next_pause_counter = next_pause_counter +dt
            if next_pause_counter >= 2 then
                if INTRO_TEXT[LANG][current_slide+1] then
                    current_slide = current_slide+1
                    box = nil
                    box = Cervantes.textBox(20*4,130*4,226*4,48*4)
                    list_words, averange_format  = cervantes.parseText(INTRO_TEXT[LANG][current_slide])
                    box.setWordList(list_words,averange_format)
                    next_pause_counter = 0
                else
                    print('Go to main menu')
                    can_go = true
                end
            end
        end
    end
    
    function self.draw()
        love.graphics.clear(0,0,0)
         
        love.graphics.push()
        --
        love.graphics.scale(4,4)
        
        love.graphics.setColor(1,1,1)
        love.graphics.draw(intro_ima, intro_frames[current_slide] ,128,64,0,1,1,64,48)
        
        
        love.graphics.pop()
        
        box.draw()
        
        if can_go then
            love.graphics.draw(bg_ima,0,0,0,4,4)
            love.graphics.setColor(0,0,0)
            love.graphics.setFont(FONT_SMALL)
            love.graphics.print(SKIP_TEXT[LANG],0,0)
            
            love.graphics.setFont(FONT_BOLD)
            love.graphics.printf("FIN",512-200,256,200,"center")
        end
        
    end
    
    function self.loadMainMenu()
        bg_music:stop()
        local new_scene = love.filesystem.load("mainMenu.lua")()
        ESCENA_MANAGER.replace(new_scene)
    end
    

    function self.keyreleased( key, scancode )
    end
    
    function self.keypressed(key,scancode)
        if key == "space" and can_go then
            self.loadMainMenu()
        end
    end
    
    return self
end

return IntroScene()