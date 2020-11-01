local MENU_OPTIONS = {}

MENU_OPTIONS["EN"] = {"New Game", "Options","Credits","Exit"}
MENU_OPTIONS["ES"] = { "Juego nuevo","Opciones","Creditos","Salir" }


function MainMenu()
    local self = Escena()
    local menuengine = require "menuengine"
    local mainmenu = nil
    local bg_music = nil
    local bg_ima = nil
    
    local john_imagen = nil
    local john_frame_list = nil
    local john_anim = nil
    
    function self.loadCortinilla()
        bg_music:stop()
        local init_scene =  love.filesystem.load("creditos.lua")()
        ESCENA_MANAGER.push(init_scene)
    end
    
    function self.loadLevel()
        bg_music:stop()
        INITIAL_SCORE = 0
        SCORE = 0
        --local init_scene =  love.filesystem.load("level.lua")()
        --ESCENA_MANAGER.replace(init_scene,LEVEL_LIST[CURRENT_LEVEL])
        local new_scene = love.filesystem.load("intro.lua")()
        ESCENA_MANAGER.replace(new_scene)
    end
    
    function self.load()
        love.graphics.setFont(FONT)
        
        menuengine.settings.symbolSelectedBegin = ''
        menuengine.settings.symbolSelectedEnd = ''
        menuengine.settings.normalSelectedBegin = '' 
        menuengine.settings.normalSelectedBegin = '' 
        menuengine.settings.colorSelected  = {0.1,0.1,0.9}
        menuengine.settings.colorNormal  = {1,1,1}
        menuengine.settings.sndMove = love.audio.newSource("rsc/sounds/pick.wav", "static")
        menuengine.settings.sndSuccess = love.audio.newSource("rsc/sounds/accept.wav", "static")
        
        
        mainmenu = menuengine.new(154,250,300)
        mainmenu:addEntry('option1',self.loadLevel)
        mainmenu:addEntry('option3',self.loadOptionsMenu)
        mainmenu:addEntry('option4',self.loadCortinilla)
        mainmenu:addEntry('option5',love.event.quit)
        
        --mainmenu:addEntry("Quit Game", quit_game)
        
        bg_ima = love.graphics.newImage("rsc/menu_bg.png")
        john_imagen = love.graphics.newImage("rsc/sprites/john_huesos.png")
        john_frame_list = simpleQuadsImagenAnchoAlto(120,128,24,24)
        john_anim = Animation({16,16,16,16,17})
        john_anim.periodo = 0.25
        bg_music = love.audio.newSource("rsc/music/greenochrome_by_neurosys.xm",'stream')
        bg_music:setLooping(true)
        bg_music:play()
    end
    
    function self.update(dt)
        mainmenu:update()
        
        local i = 1
        while  mainmenu.entries[i] do
            mainmenu.entries[i].text = MENU_OPTIONS[LANG][i]
            mainmenu.entries[i].font = FONT
            i=i+1
        end
        mainmenu.entries[mainmenu.cursor].font = FONT_BOLD
        --mainmenu.entries[i-1].font = FONT_BOLD
    end
    
    function self.draw()
        
        love.graphics.clear(0.2,0.2,0.2)
        love.graphics.draw(bg_ima,0,0,0,4,4)
        local frame = john_anim.getFrameActual()
        love.graphics.draw(john_imagen,john_frame_list[frame],197*4,228,0,4,4)
        love.graphics.setFont(FONT)
        
        mainmenu:draw()
    end
    
    function self.loadOptionsMenu()
        --bg_music:stop()
        local init_scene =  love.filesystem.load("optionsMenu.lua")()
        ESCENA_MANAGER.push(init_scene)
    end

    function self.keyreleased( key, scancode )
    end
    
    function self.keypressed(key,scancode)
        menuengine.keypressed(scancode)
    end
    
    function self.mousemoved(x, y, dx, dy, istouch)
        menuengine.mousemoved(x, y)
    end
    
    
    return self
end



return MainMenu()