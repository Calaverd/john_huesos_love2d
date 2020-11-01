local CHOSE = {}
CHOSE["EN"] = {"Please, choose a language\nYou can change this later on Options"}
CHOSE["ES"] = { "Por favor, escoje un idioma\nPuedes cambiarlo después en Opciones" }


function AskIdiom()
    local self = Escena()
    local menuengine = require "menuengine"
    local asklangmenu = nil
    
    function self.loadCortinilla()
        writeUserSettings()
        
        --local new_scene = love.filesystem.load("intro.lua")()
        --ESCENA_MANAGER.replace(new_scene)
        local new_scene = love.filesystem.load("mainMenu.lua")()
        ESCENA_MANAGER.replace(new_scene)
        --write user setings
        
    end
    
    
    function self.load()
        love.graphics.setFont(FONT)
        
        menuengine.settings.symbolSelectedBegin = ''
        menuengine.settings.symbolSelectedEnd = ''
        menuengine.settings.normalSelectedBegin = '' 
        menuengine.settings.normalSelectedBegin = '' 
        menuengine.settings.colorSelected  = {0.1,0.1,0.8}
        menuengine.settings.colorNormal  = {0,0,0}
        menuengine.settings.sndMove = love.audio.newSource("rsc/sounds/pick.wav", "static")
        menuengine.settings.sndSuccess = love.audio.newSource("rsc/sounds/accept.wav", "static")
        
        
        asklangmenu = menuengine.new(512-100,350,200)
        asklangmenu:addEntry("English",self.loadCortinilla)
        asklangmenu:addEntry("Español",self.loadCortinilla)
        
        --asklangmenu:addEntry("Quit Game", quit_game)

    end
    
    function self.update(dt)
        asklangmenu:update()
        asklangmenu.entries[1].font = FONT
        asklangmenu.entries[2].font = FONT
        
        if asklangmenu.cursor == 1 then
            LANG = 'EN'
            asklangmenu.entries[1].font = FONT_BOLD
        end
    
        if asklangmenu.cursor == 2 then
            LANG = 'ES'
            asklangmenu.entries[2].font = FONT_BOLD
        end
    end
    
    function self.draw()
        love.graphics.clear(0.2,0.2,0.2)
        love.graphics.setFont(FONT)
        love.graphics.printf(CHOSE[LANG],512-250, 100, 500,"center")
        
        asklangmenu:draw()
    end

    function self.keyreleased( key, scancode )
    end
    
    function self.keypressed(key,scancode)
        menuengine.keypressed(scancode)
    end
    
    function self.mousemoved(x, y, dx, dy, istouch)
        
    end
        
    
    return self
end




return AskIdiom()