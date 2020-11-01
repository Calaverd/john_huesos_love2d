love.filesystem.load("core.lua")()
love.filesystem.load("escena.lua")()


io.stdout:setvbuf("no")

local major, minor, revision, codename = love.getVersion( )
local LEFT_M_BUTTON = 'l'
if major >= 0 then
   if minor > 9 then 
       LEFT_M_BUTTON = 1
   end
end


SIZE_WIN_W = 512*2
SIZE_WIN_H = 384*2
function love.resize(w, h)
  print(("Window resized to width: %d and height: %d."):format(w, h))
  SIZE_WIN_H = h
  SIZE_WIN_W = w
end


love.window.setTitle("John Huesos")
love.window.setMode(512*2,384*2,{resizable=true})
love.graphics.setDefaultFilter( 'nearest', 'nearest', 1 )

support =  love.graphics.getSupported()
print(support.glsl3)


GAME_OVER_SONG = nil
LEVEL_COMPLETE_SONG = nil
LEVEL_BG_SONG = nil
LEVEL_BOSS_SONG = nil

TEXT_SOUND = nil  
FONT_BOLD = nil
FONT = nil
FONT_SMALL = nil

INITIAL_SCORE = 0
SCORE = 0


LANG = 'EN'
USE_SHADERS = true
FULL_SCREEN = false
FPS = 60
EXIST_USER_SETTINGS = false


MIN_DT = 1/FPS
NEXT_TIME = 0

function writeUserSettings()
    local dir = love.filesystem.getSaveDirectory( )
    
    local data = '\r\n'
    data = data..'LANG = "'..tostring(LANG)..'"\r\n'
    data = data..'USE_SHADERS = '..tostring(USE_SHADERS)..'\r\n'
    data = data..'FULL_SCREEN = '..tostring(FULL_SCREEN)..'\r\n'
    
    success, message = love.filesystem.write("user_settings.lua",data, size )
end


CANVAS = nil
SHADER = nil

ESCENA_MANAGER = EscenaManager()
DRAW_TIMER = nil
--local init_scene =  love.filesystem.load("Overworld.lua")()
--local init_scene =  love.filesystem.load("cortinilla.lua")()
--ESCENA_MANAGER.push(init_scene)

function LevelData(map_file_name,backgrond_ima,normal_music,boss_music)
    local self = {}
    self.map_file_name =map_file_name
    self.background_file_ima = backgrond_ima
    self.normal_music = normal_music
    self.boss_music = boss_music
    return self
end

--LEVEL_1_DATA = LevelData()

CURRENT_LEVEL = 1
LEVEL_LIST = { 
    {'rsc/maps/level1.spk',
        levelname = {
            ES = '-Invasión de Calacatecuaro-',
            EN = '-Invasion of Calacatecuaro-',
            },
        bossname = {
            ES = 'U N I P O D E\nLos trípodes salian muy caros',
            EN = 'U N I P O D\nThe tripods were very expensive',
            },
        },
    {'rsc/maps/level2.spk',
        levelname = {
            ES = '-Luces sobre el cerro pelado-',
            EN = '-Lights over the bald hill-',
            },
        bossname = {
            ES = 'L. O. V. N. I.\nLetal Objeto Volador No Identificado',
            EN = 'D. U. F. O.\nDeathly Unidentified Flying Object',
            },
        },
    {'rsc/maps/level3.spk',
        levelname = {
            ES = '-Batalla al filo del amanecer-',
            EN = '-Battle on the edge of the sunrise-',
            },
        bossname = {
            ES = 'F E M U R T\nLider en jefe de la invasión',
            EN = 'F E M U R T\nLeader in chief of the invasion',
            },
        },
    }

function love.load()
    TEXT_SOUND = love.audio.newSource("rsc/sounds/text.wav", "static")  
    FONT_BOLD = love.graphics.newFont('rsc/fonts/Fredoka_One/FredokaOne-Regular.ttf',35)
    FONT = love.graphics.newFont('rsc/fonts/Lato/Lato-Bold.ttf',32)
    FONT_SMALL = love.graphics.newFont('rsc/fonts/Lato/Lato-Bold.ttf',22)
    DRAW_TIMER = Cronometro()
    DRAW_TIMER.iniciar()
    GAME_OVER_SONG = love.audio.newSource("rsc/music/Slaughter Vals.mp3",'stream')
    LEVEL_COMPLETE_SONG = love.audio.newSource("rsc/music/2sp00ky4me.mp3",'stream')
    LEVEL_BG_SONG = love.audio.newSource("rsc/music/glist_by_neurosys.xm",'stream')
    LEVEL_BOSS_SONG = love.audio.newSource("rsc/music/Chicharron Zombie! - Crab sound.mp3",'stream')
    
    local dir = love.filesystem.getSaveDirectory( ).."/"
    local info = love.filesystem.getInfo("user_settings.lua")
    EXIST_USER_SETTINGS = true
    if not info then
        EXIST_USER_SETTINGS = false
    else
        -- prints 'result: 2'
        love.filesystem.load('user_settings.lua')()
        --love.window.setFullscreen( FULL_SCREEN  )
    end
    -- [[DEFAULT
    local init_scene =  love.filesystem.load("cortinilla.lua")()
    ESCENA_MANAGER.push(init_scene)
    --]]
    
    --[[
    local init_scene =  love.filesystem.load("creditos.lua")()
    ESCENA_MANAGER.push(init_scene)
    --]]
    
    --[[
    local init_scene =  love.filesystem.load("level.lua")()
    ESCENA_MANAGER.push(init_scene,
         {'rsc/maps/test.spk',
        levelname = {
            ES = '-El mapa de testeo-',
            EN = '-The testing map-',
            },
        bossname = {
            ES = 'Quien sabe\nestamos en pruebas',
            EN = 'Who cares\nwe are on tests',
        },
        use_collision_layer = false
        }
        )
    --]]
    SHADER = love.graphics.newShader[[
    extern vec2 distortionFactor;
    extern vec2 scaleFactor;
    extern number feather;
    extern number time;
     
    vec4 effect(vec4 color, Image tex, vec2 uv, vec2 px) {
      // to barrel coordinates
      uv = uv * 2.0 - vec2(1.0);
      // distort
      uv *= scaleFactor;
      uv += (uv.yx*uv.yx) * uv * (distortionFactor - 1.0);
      number mask = (1.0 - smoothstep(1.0-feather,1.0,abs(uv.x)))
                  * (1.0 - smoothstep(1.0-feather,1.0,abs(uv.y)));
      // to cartesian coordinates
      uv = (uv + vec2(1.0)) / 2.0;
      
      // per row offset
    float f  = sin( uv.y * 320.f * 3.14f );
    // scale to per pixel
    float o  = f * (0.35f / 320.f);
    // scale for subtle effect
    float s  = f * .03f + 0.97f;
    // scan line fading
    float l  = sin( time * 32.f )*.03f + 0.97f;
    // sample in 3 colour offset
    float r = Texel( tex, vec2( uv.x+o, uv.y+o ) ).x;
    float g = Texel( tex, vec2( uv.x-o, uv.y+o ) ).y;
    float b = Texel( tex, vec2( uv.x  , uv.y-o ) ).z;
    // combine as 
      return vec4( r*0.9f, g*0.9f, b*0.9f, l ) * s * mask;
    }
  
  ]]
    
    CANVAS = love.graphics.newCanvas(512*2,384*2)
    
    NEXT_TIME = love.timer.getTime()
end

function love.keyreleased( key, scancode )
    ESCENA_MANAGER.keyreleased(key,scancode)
end
    
function love.keypressed(key,scancode)
    if key == "escape" then
        love.event.quit()
    end
    ESCENA_MANAGER.keypressed(key,scancode)
end

function love.mousemoved(x, y, dx, dy, istouch)
    ESCENA_MANAGER.mousemoved(x, y)
end

function love.update(dt)
    --evitar que las cosas se caigan si se mueve la pantalla
    dt = math.min(dt,1/30)
    local accum = dt
	while accum > 0 do		-- accumulator for physics! no more penetration!
		local dt = math.min( 1/200, accum )	-- use whatever max dt value works best for you
		accum = accum - dt
		ESCENA_MANAGER.update(dt)
		-- now, do whatever it is you need to do with dt
	end
    --controlar los fps
    --mando a recoger la basura manualmente...
    collectgarbage()
    
    SHADER:send("time",dt)
    --if love.timer then love.timer.sleep(1.0/30.0) end
end


function love.draw()
    
    if DRAW_TIMER.hanPasado(1/60) then
        
        love.graphics.setCanvas(CANVAS)
        ESCENA_MANAGER.draw()
        love.graphics.setCanvas()
        
    end
        
    love.graphics.setBackgroundColor(0,0,0)
    if USE_SHADERS then
        local distortionFactor = {1.06, 1.065}
        local feather = 0.02
        local scaleFactor = {1,1}
        -- [[
        SHADER:send("distortionFactor",distortionFactor)  
        SHADER:send("feather",feather)  
        SHADER:send("scaleFactor",scaleFactor)  
        love.graphics.setBackgroundColor(0.46,0.24,0.10)
        if ESCENA_MANAGER.getUseShaders() then
            love.graphics.setShader(SHADER)
        end
    end
    
    love.graphics.setColor(1,1,1)
    local factor = SIZE_WIN_H/(384*2)
    local x = (SIZE_WIN_W/2)-(512*factor)
    local y = (SIZE_WIN_H/2) -(384*factor)
    
    love.graphics.draw(CANVAS,x,y,0,factor,factor)
    
    love.graphics.setShader()
    --love.graphics.print(tostring(factor),0,0)
    
end
