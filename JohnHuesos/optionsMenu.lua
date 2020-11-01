local MENUOPTIONS_OPTIONS = {}

MENUOPTIONS_OPTIONS["EN"] = { "Shader","Full screen","Language","Return"}
MENUOPTIONS_OPTIONS["ES"] = { "Shader","Pantalla Completa","Idioma","Regresar" }

function MainTile()
    local self = Escena()
    local menuengine = require "menuengine"
    local optionsmenu = nil
    
    function self.setEnglish()
        LANG = 'EN'
    end
    
    function self.setSpanish()
        LANG = 'ES'
    end
    
    function self.shader()
        USE_SHADERS  = not USE_SHADERS
    end
    
    function self.fullScreen()
        FULL_SCREEN  = not FULL_SCREEN
        love.window.setFullscreen( FULL_SCREEN  )
    end
    
    function self.loadCortinilla()
        local init_scene =  love.filesystem.load("cortinilla.lua")()
        ESCENA_MANAGER.push(init_scene)
    end
    
    function self.changeLang()
        if LANG == 'ES' then
            LANG = 'EN'
        else
            LANG = 'ES'
        end
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
        
        
        optionsmenu = menuengine.new(512-300,350,600)
        optionsmenu:addEntry('',self.shader)
        optionsmenu:addEntry('',self.fullScreen)
        optionsmenu:addEntry('',self.changeLang)
        optionsmenu:addEntry('',self.loadMenu)
        
        --optionsmenu:addEntry("Quit Game", quit_game)

    end
    
    function self.update(dt)
        optionsmenu:update()
        
        if USE_SHADERS then
            if LANG == 'ES' then
                optionsmenu.entries[1].text = MENUOPTIONS_OPTIONS[LANG][1] .. '-> Encendido'
            end
            if LANG == 'EN' then
                optionsmenu.entries[1].text = MENUOPTIONS_OPTIONS[LANG][1] .. ' -> On'
            end
        else
            if LANG == 'ES' then
                optionsmenu.entries[1].text = MENUOPTIONS_OPTIONS[LANG][1] .. '-> Apagado'
            end
            if LANG == 'EN' then
                optionsmenu.entries[1].text = MENUOPTIONS_OPTIONS[LANG][1] .. ' -> Off'
            end
        end
        optionsmenu.entries[1].font = FONT
        
        if FULL_SCREEN then
            if LANG == 'ES' then
                optionsmenu.entries[2].text = MENUOPTIONS_OPTIONS[LANG][2] .. '-> Sí'
            end
            if LANG == 'EN' then
                optionsmenu.entries[2].text = MENUOPTIONS_OPTIONS[LANG][2] .. ' -> Yes'
            end
        else
            if LANG == 'ES' then
                optionsmenu.entries[2].text = MENUOPTIONS_OPTIONS[LANG][2] .. '-> No'
            end
            if LANG == 'EN' then
                optionsmenu.entries[2].text = MENUOPTIONS_OPTIONS[LANG][2] .. ' -> Not'
            end
        end
        optionsmenu.entries[2].font = FONT
        
        if LANG == 'ES' then
            optionsmenu.entries[3].text = MENUOPTIONS_OPTIONS[LANG][3] .. '-> Español'
        end
        if LANG == 'EN' then
            optionsmenu.entries[3].text = MENUOPTIONS_OPTIONS[LANG][3] .. ' -> English'
        end
        optionsmenu.entries[3].font = FONT
        
        optionsmenu.entries[4].text = MENUOPTIONS_OPTIONS[LANG][4] 
        
        optionsmenu.entries[optionsmenu.cursor].font = FONT_BOLD
    
    end

    
    function self.draw()
        love.graphics.clear(0.2,0.2,0.2)
        love.graphics.setFont(FONT)
        
        optionsmenu:draw()
    end
    
    function self.loadMenu()
        writeUserSettings()
        ESCENA_MANAGER.pop()
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

return MainTile()