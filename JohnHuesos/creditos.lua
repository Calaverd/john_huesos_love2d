love.filesystem.load("utf8.lua")()
cervantes = love.filesystem.load("cervantes.lua")()


CREDITOS = {}
CREDITOS['EN'] = 
    [[
Programing
Osvaldo Guadalupe Barajas Fierros
Enrique García Cota (BUMP Library)
Astorek86 (menuengine)

Music
Nestor ovilla
Oscar Armando Gutiérrez Flores
Francisco Alberto Hernandez Carrasco
Cristian Téllez Vargas
Adan Toledo
Neurosys
JAM

Graphics
Ana María González Soriano / AM4JRK
Osvaldo Guadalupe Barajas Fierros

    ]]
    
CREDITOS['ES'] = 
    [[
Programación
Osvaldo Guadalupe Barajas Fierros
Enrique García Cota (BUMP Library)
Astorek86 (menuengine)

Música
Nestor ovilla
Oscar Armando Gutiérrez Flores
Francisco Alberto Hernandez Carrasco
Cristian Téllez Vargas
Adan Toledo
Neurosys
JAM

Gráficos
Ana María González Soriano / AM4JRK
Osvaldo Guadalupe Barajas Fierros

    ]]
    
SKIP_TEXT = {}
SKIP_TEXT['ES'] = 'Presiona "espacio" para omitir.'
SKIP_TEXT['EN'] = 'Press "space" to skip.'

function IntroScene()
    local self = Escena()
    
    function self.load()
        
    end
    
    function self.update(dt)
        
    end
    
    function self.draw()
        love.graphics.clear(0,0,0)
        
        love.graphics.setColor(1,1,1)
        love.graphics.setFont(FONT)
        love.graphics.printf(CREDITOS[LANG],0,50,512*2,"center")
        
    end
    
    function self.loadMainMenu()
        local new_scene = love.filesystem.load("mainMenu.lua")()
        ESCENA_MANAGER.replace(new_scene)
    end
    

    function self.keyreleased( key, scancode )
    end
    
    function self.keypressed(key,scancode)
        if key == "space" or key == "return" then
            self.loadMainMenu()
        end
    end
    
    return self
end

return IntroScene()