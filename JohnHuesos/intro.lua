love.filesystem.load("utf8.lua")()
cervantes = love.filesystem.load("cervantes.lua")()


INTRO_TEXT = {}
INTRO_TEXT['EN'] = {
    [[Some time ago in *1935* near a village in *MICHOHACAN MEXICO* from the sky fallen an #ALIEN SHIP.#  ]],
    [[The #ALIENS# following the orders of #COLONEL FEMURT# started a conquest offensive to take over the earth. ]],
    [[The %WITCH CARMELA% seeing the #ALIENS# power, soon knew no living human could stop them. So decided to bring a hero from the dead... ]],
    [[*Fight once more for all of us, for every one of us!* %JOHN HUESOS!!!%  ]]
}
INTRO_TEXT['ES'] = {
    [[Hace algún tiempo en *1935* cerca de un pueblito en %MÉXICO MICHOACAN% desde el cielo cayó una #NAVE ALIENÍGENA.# ]], 
    [[Los #ALIENÍGENAS# siguiendo las órdenes del #CORONEL FEMURT# dieron comienzo a una ofensiva para conquistar la tierra. ]], 
    [[La %BRUJA CARMELA% al ver el poderío #ALIENÍGENA# se dio cuenta de que ningún ser viviente podría detenerles. Por lo cual, decidió traer a un héroe de entre los muertos...]],
    [[*¡Lucha una vez más por nosotros! ¡Sálvanos a todos!* %¡¡¡JOHN HUESOS!!!%]]
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
    
    function self.load()
        intro_ima = love.graphics.newImage("rsc/intro_titles.png")
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
        
        bg_music = love.audio.newSource("rsc/music/terror song video game.ogg",'stream')
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
                    self.loadMainMenu()
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
        love.graphics.setFont(FONT_SMALL)
        love.graphics.print(SKIP_TEXT[LANG],0,0)
        box.draw()
    end
    
    function self.loadMainMenu()
        bg_music:stop()
        --local new_scene = love.filesystem.load("mainMenu.lua")()
        --ESCENA_MANAGER.replace(new_scene)
        
        local init_scene =  love.filesystem.load("level.lua")()
        ESCENA_MANAGER.replace(init_scene,LEVEL_LIST[CURRENT_LEVEL])

    end
    

    function self.keyreleased( key, scancode )
    end
    
    function self.keypressed(key,scancode)
        if key == "space" then
          self.loadMainMenu()
        end
    end
    
    return self
end

return IntroScene()