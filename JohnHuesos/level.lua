local bump = require 'bump/bump'

local lg = love.graphics
local lf = love.filesystem

GUI_TEXT = {}
GUI_TEXT['ES'] = {'TIEMPO','PUNTAJE','NIVEL'}
GUI_TEXT['EN'] = {'TIME','SCORE','LEVEL'}

PAUSE_MENU_TEXT = {}
PAUSE_MENU_TEXT['ES'] = {'- P - A - U - S - A -','Continuar','Reiniciar', 'Opciones','Salir'}
PAUSE_MENU_TEXT['EN'] = {'- P - A - U - S - E -','Resume','Restart','Options','Leave'}

GAMEOVER_MENU_TEXT = {}
GAMEOVER_MENU_TEXT['ES'] = {'FIN DEL\nJUEGO','SE ACABO\nTU TIEMPO','Reiniciar', 'Opciones','Salir'}
GAMEOVER_MENU_TEXT['EN'] = {'GAME\nOVER','SORRY\nTIME OVER','Restart','Options','Leave'}

LEVEL_COMPLETE_MENU_TEXT = {}
LEVEL_COMPLETE_MENU_TEXT['ES'] = {'NIVEL COMPLETO','Presiona "espacio" para continuar'}
LEVEL_COMPLETE_MENU_TEXT['EN'] = {'LEVEL COMPLETE','Push "space" to continue'}


LEVEL_COMPLETE = false
PAUSE = false
GAMEOVER = false
BOSSHP = 0
SHOW_BOSS_HP = false


TILE_SIZE = 8
MAP = nil
MAP_OFFSET_MIN_X = 0
MAP_OFFSET_MIN_Y = 0

MAP_OFFSET_MAX_X = 0
MAP_OFFSET_MAX_Y = 0
FIX_OFFSET_X = false

MAP_DEFAULT_OFFSET_MIN_X = 0
MAP_DEFAULT_OFFSET_MAX_X = 0
MAP_DEFAULT_OFFSET_MIN_Y = 0
MAP_DEFAULT_OFFSET_MAX_Y = 0

TILES_CAN_PASS = {1,2,3,4,8,7}
TILES_CAN_PASS_BULLET = {1,2,3,4,6,8}
TILES_CAN_STOP_FALL = {4,5}
TILES_CAN_DO_DAMAGE = {7,8}


BWORLD = bump.newWorld(32)

ENTITY_DEF_LIST = {}

function getTileFromSet(x,y)
    if MAP.tiles[y] then
        if MAP.tiles[y][x] then
            return MAP.tiles[y][x]
        end
    end
    return 0
end

function getTileCol(x,y)
    if MAP.collision[y] then
        if MAP.collision[y][x] then
            return MAP.collision[y][x]
        end
    end
    return 0
end

function setTileCol(x,y,val)
    if MAP.collision[y] then
        if MAP.collision[y][x] then
            MAP.collision[y][x] = val
        end
    end
end


function setBossBorders(x1,x2)
    local i = 1
    while MAP.collision[i] do
        if MAP.collision[i][x1] == 1 then
            MAP.collision[i][x1] = 6
        end
        if MAP.collision[i][x1-1] == 1 then
            MAP.collision[i][x1] = 6
        end
        if MAP.collision[i][x2] == 1 then
            MAP.collision[i][x2] = 6
        end
        if MAP.collision[i][x2+1] == 1 then
            MAP.collision[i][x2] = 6
        end
        i=i+1
    end
    MAP_OFFSET_MIN_X = x1+1
    FIX_OFFSET_X = true
end

function clearBossBorders(x1,x2)
    local i = 1
    while MAP.collision[i] do
        if MAP.collision[i][x1] == 6 then
            MAP.collision[i][x1] = 1
        end
        if MAP.collision[i][x2] == 6 then
            MAP.collision[i][x2] = 1
        end
        i=i+1
    end
    MAP_OFFSET_MIN_X = 0
    FIX_OFFSET_X = false
end

function getTileControl(x,y)
    if MAP.control[y] then
        if MAP.control[y][x] then
            return MAP.control[y][x]
        end
    end
    return 0
end 

function setTileControl(x,y,val)
    if MAP.control[y] then
        if MAP.control[y][x] then
            MAP.control[y][x] = val
        end
    end
end 

lf.load("base_entity.lua")()
lf.load("foes.lua")()
lf.load("coins.lua")()
lf.load("bullet_player.lua")()
lf.load("bullet_alien.lua")()
lf.load("player.lua")()

--------
----

function MainTile()
    local self = Escena()
    local player = nil
    local tileset = nil
    local tileset_list = nil
    local paused = false
    
    local player_bullets = {}
    local player_shoot = false
    local shoot_clook = 0
    
    local foes_list = {} 
    local other_entity_list = {} 
    local alien_bullets = {}
    
    local i = 0
    
    local m_w = 0
    local m_h = 0
    local offset_x = 0
    local offset_y = 0
    local old_offset_x = 0
    self.lerp_val = 0
    
    local xf = 0
    local yi = 0
    local yf = 0
    local xi = 0
    
    local sound_player_shoot = nil
    local sound_player_shoot_hit = nil
    local sound_player_shoot_no_sell = nil
    local sound_player_damage = nil
    local sound_player_jump = nil
    local sound_player_coin = nil
    
    local gui_elements = nil
    local gui_elements_frames = nil
    
    self.time_left = 360
    
    local menuengine = require "menuengine"
    local pausemenu = nil
    local menuengine2 = require "menuengine"
    local gameovermenu = nil
    local menuengine3 = require "menuengine"
    local levelcompletemenu = nil
    local bfg = nil    
    local show_level_name_counter = 0
    local show_boss_name_counter = 0
    
    function self.reset()
        player = nil
        tileset = nil
        tileset_list = nil
        paused = false

        player_bullets = {}
        player_shoot = false
        shoot_clook = 0

        foes_list = {} 
        other_entity_list = {} 
        alien_bullets = {}

        i = 0

        m_w = 0
        m_h = 0
        offset_x = 0
        offset_y = 0
        old_offset_x = 0
        self.lerp_val = 0

        xf = 0
        yi = 0
        yf = 0
        xi = 0

        sound_player_shoot = nil
        sound_player_shoot_hit = nil
        sound_player_shoot_no_sell = nil
        sound_player_damage = nil
        sound_player_jump = nil
        sound_player_coin = nil

        gui_elements = nil
        gui_elements_frames = nil

        self.time_left = 360

        pausemenu = nil
        gameovermenu = nil
        levelcompletemenu = nil
        bfg = nil   
        show_level_name_counter = 0
        show_boss_name_counter = 0
        
        PAUSE = false
        GAMEOVER = false
    end
    
    self.level_base_data = nil
    self.music = nil
    self.figth_boss = false
    
    function self.load(data)
        self.level_base_data = data
        MAP = lf.load(data[1])()
        
        MAP_OFFSET_MIN_X = 1
        MAP_OFFSET_MIN_Y = 1

        MAP_OFFSET_MAX_X = #MAP.collision[1]
        MAP_OFFSET_MAX_Y = #MAP.collision

        MAP_DEFAULT_OFFSET_MIN_X = 1
        MAP_DEFAULT_OFFSET_MAX_X = #MAP.collision[1]
        MAP_DEFAULT_OFFSET_MIN_Y = 1
        MAP_DEFAULT_OFFSET_MAX_Y = #MAP.collision
        
        print(MAP_DEFAULT_OFFSET_MIN_X,MAP_DEFAULT_OFFSET_MIN_Y)
        print(MAP_DEFAULT_OFFSET_MAX_X,MAP_DEFAULT_OFFSET_MAX_Y)
        
        local i = 1
        while MAP.control[i] do
            local j = 1
            while MAP.control[i][j] do
                if MAP.control[i][j] == 1 then
                    player = Player(j,i)
                    setTileControl(j,i,0)
                    break
                end
                j=j+1
            end
            i=i+1
        end
        
        bfg = lg.newImage("rsc/bg1.png")
        
        gui_elements = lg.newImage("rsc/gui_bars.png")
        gui_elements_frames = simpleQuadsImagenAnchoAlto(64,64,8,8)
        
        player.imagen = lg.newImage("rsc/sprites/john_huesos.png")
        player.frame_list = simpleQuadsImagenAnchoAlto(120,128,24,24)
        
        BULLET_PLAYER_IMA = lg.newImage("rsc/sprites/bullet.png")
        BULLET_PLAYER_IMA_FRAME_LIST = simpleQuadsImagenAnchoAlto(56,8,8,8)
        BULLET_ALIEN_IMA = lg.newImage("rsc/sprites/bullet_alien.png")
        BULLET_ALIEN_IMA_FRAME_LIST = simpleQuadsImagenAnchoAlto(56,24,8,8)
        
        if self.level_base_data.use_collision_layer then 
            local ima  = lg.newImage("rsc/tiles/col.png")
            tileset = lg.newSpriteBatch(ima,2000)
            tileset_list = simpleQuadsImagenAnchoAlto(64,64,8,8)
        else
            local ima  = lg.newImage("rsc/tiles/tileset.png")
            tileset = lg.newSpriteBatch(ima,2000)
            tileset_list = simpleQuadsImagenAnchoAlto(96,144,8,8)
        end
        
        sound_player_shoot = love.audio.newSource("rsc/sounds/hero_shoot_hit.wav", "static")
        sound_player_shoot_hit = love.audio.newSource("rsc/sounds/hero_shoot.wav", "static")
        sound_player_shoot_no_sell = love.audio.newSource("rsc/sounds/no_sell.wav", "static")
        sound_player_damage = love.audio.newSource("rsc/sounds/hero_hurt.wav", "static")
        player.sound_player_jump = love.audio.newSource("rsc/sounds/hero_jump.wav", "static")
        sound_player_coin_centavo = love.audio.newSource("rsc/sounds/pick_centavo.wav", "static")
        sound_player_coin_50cents = love.audio.newSource("rsc/sounds/pick_50centavos.wav", "static")
        sound_player_coin_peso = love.audio.newSource("rsc/sounds/pick_peso.wav", "static")
        sound_player_coin_toston = love.audio.newSource("rsc/sounds/pick_toston.wav", "static")
        --player.sound_player_lands = love.audio.newSource("rsc/sounds/hero_shoot_hit.wav", "static")
        
        lg.setFont(FONT)
        
        menuengine.settings.symbolSelectedBegin = ''
        menuengine.settings.symbolSelectedEnd = ''
        menuengine.settings.normalSelectedBegin = '' 
        menuengine.settings.normalSelectedBegin = '' 
        menuengine.settings.colorSelected  = {0.1,0.1,0.8}
        menuengine.settings.colorNormal  = {1,1,1}
        menuengine.settings.sndMove = love.audio.newSource("rsc/sounds/pick.wav", "static")
        menuengine.settings.sndSuccess = love.audio.newSource("rsc/sounds/accept.wav", "static")
        
        
        pausemenu = menuengine.new(512-300,350,600)
        pausemenu:addEntry('',self.unpause)
        pausemenu:addEntry(' ',self.reload)
        pausemenu:addEntry(' ',self.loadOptionsMenu)
        pausemenu:addEntry(' ',self.loadMenu)
        
        gameovermenu = menuengine2.new(512-300,350,600)
        gameovermenu:addEntry(' ',self.reload)
        gameovermenu:addEntry(' ',self.loadOptionsMenu)
        gameovermenu:addEntry(' ',self.loadMenu)
        
        levelcompletemenu = menuengine2.new(512-300,350,600)
        levelcompletemenu:addEntry(' ',self.goToNextLevel)
        
        self.music = LEVEL_BG_SONG
        self.music:play()
        self.music:setLooping(true)
        self.figth_boss = false
        
        SCORE = INITIAL_SCORE
    end
    
    function self.unpause()
        PAUSE = false
    end
    
    function self.loadOptionsMenu()
        local init_scene =  lf.load("optionsMenu.lua")()
        ESCENA_MANAGER.push(init_scene)
    end
    
    function self.loadMenu()
        self.music:stop()
        CURRENT_LEVEL = 1
        local new_scene = lf.load("mainMenu.lua")()
        ESCENA_MANAGER.replace(new_scene)
    end
    
    function self.reload()
        self.music:stop()
        --self.reset()
        local init_scene =  lf.load("level.lua")()
        ESCENA_MANAGER.replace(init_scene,self.level_base_data)
    end
    
    function self.goToNextLevel()
        INITIAL_SCORE = SCORE
        self.music:stop()
        CURRENT_LEVEL = CURRENT_LEVEL+1
        if CURRENT_LEVEL > #LEVEL_LIST then
            local init_scene =  lf.load("ending.lua")()
            ESCENA_MANAGER.push(init_scene)
        else
            local init_scene =  lf.load("level.lua")()
            ESCENA_MANAGER.replace(init_scene,LEVEL_LIST[CURRENT_LEVEL])
            print('NEW LEVEL ->>>>',CURRENT_LEVEL)
        end
    end
    
    function self.update(dt)
        if not PAUSE and not GAMEOVER then
            self.music:setVolume(1)
            if not LEVEL_COMPLETE then
                if player.hp > 0 and self.time_left > 0 then
                    self.gameUpdate(dt)
                    
                    show_level_name_counter = show_level_name_counter+dt 
                    
                    if not self.figth_boss then
                        if SHOW_BOSS_HP then
                            self.music:stop()
                            self.music = LEVEL_BOSS_SONG
                            self.music:play()
                            self.music:setLooping(true)
                            self.figth_boss=true
                        end
                    else
                        show_boss_name_counter = show_boss_name_counter+dt
                        if LEVEL_COMPLETE then
                            player_bullets = {}
                            foes_list = {} 
                            other_entity_list = {} 
                            alien_bullets = {}
                            
                            self.music:stop()
                            self.music = LEVEL_COMPLETE_SONG
                            self.music:play()
                        end
                    end
                else
                    GAMEOVER = true
                    self.music:stop()
                    self.music = GAME_OVER_SONG
                    self.music:play()
                    --player.update(dt)
                end
            else
                --LEVEL COMPLETE
                self.updateTiles(dt)
                levelcompletemenu:update(dt)
                local i = 1
                while  levelcompletemenu.entries[i] do
                    levelcompletemenu.entries[i].text = PAUSE_MENU_TEXT[LANG][i+1]
                    levelcompletemenu.entries[i].font = FONT
                    i=i+1
                end
                levelcompletemenu.entries[levelcompletemenu.cursor].font = FONT_BOLD
                --player.update(dt)
            end
        end
            --player.update(dt)
        if PAUSE then
            self.music:setVolume(0.35)
            self.updateTiles(dt)
            pausemenu:update(dt)
            local i = 1
            while  pausemenu.entries[i] do
                pausemenu.entries[i].text = PAUSE_MENU_TEXT[LANG][i+1]
                pausemenu.entries[i].font = FONT
                i=i+1
            end
            pausemenu.entries[pausemenu.cursor].font = FONT_BOLD
        end

        if GAMEOVER then
            self.updateTiles(dt)
            player.update(dt)
            gameovermenu:update(dt)
            local i = 1
            while  gameovermenu.entries[i] do
                gameovermenu.entries[i].text = GAMEOVER_MENU_TEXT[LANG][i+2]
                gameovermenu.entries[i].font = FONT
                i=i+1
            end
            gameovermenu.entries[gameovermenu.cursor].font = FONT_BOLD
        end
    end
    
    function self.updateTiles(dt)
        m_w = 16
        m_h = 12
        if not FIX_OFFSET_X then
            offset_x = math.max(player.cam_look_x-m_w,1)
            self.lerp_val = 0
            old_offset_x = offset_x
        else
            offset_x = lerp(old_offset_x,MAP_OFFSET_MIN_X,self.lerp_val)
            if self.lerp_val < 1 then
                self.lerp_val = self.lerp_val+dt*2
            else
                self.lerp_val = 1
            end
        end
        offset_y = math.min(math.max(player.cam_look_y-m_h,MAP_OFFSET_MIN_Y),MAP_OFFSET_MAX_Y)
        --AGREGAR LOS TILES PARA DIBUJAR EL FONDO
        --TAMBIEN AGREGAR LOS ENEMIGOS QUE EL MAPA MARCA
        xf = math.min(offset_x+(m_w*2)+1,MAP_OFFSET_MAX_X)
        yi = offset_y-1
        yf = offset_y+(m_h*2)+1
        xi = offset_x -1 
        while yi < yf do
            --lg.print( ('%2.0f,%2.f'):format(xi*TILE_SIZE,yi*TILE_SIZE),xi*TILE_SIZE,yi*TILE_SIZE)
            
            while xi < xf do
                lg.setColor(1,1,1)
                if math.floor(xi) == math.floor(player.fx) then
                    if math.floor(yi) == math.floor(player.fy) then
                        lg.setColor(1,0,1)
                    end
                end
                if self.level_base_data.use_collision_layer then 
                    tile = getTileCol(math.floor(xi),math.floor(yi))
                else
                    tile = getTileFromSet(math.floor(xi),math.floor(yi))
                end
                if tile > 0 then
                    tileset:add( tileset_list[tile], math.floor(xi)*TILE_SIZE,(math.floor(yi))*TILE_SIZE)
                end
                lg.setColor(0,0,0)
                
                local entity_id = getTileControl(math.floor(xi),math.floor(yi))
                if entity_id > 1 then
                    print('Try load entity : ',entity_id)
                    local entity = ENTITY_DEF_LIST[entity_id](math.floor(xi),math.floor(yi+1))
                    if entity.entity_tipe == 'foe' then
                        table.insert(foes_list,entity)
                    else
                        table.insert(other_entity_list,entity)
                    end
                    setTileControl(math.floor(xi),math.floor(yi),0)
                end
                
                xi=xi+1
            end
            xi = offset_x -1 
            yi=yi+1
        end
    end
    
    function self.gameUpdate(dt)
        
        player.update(dt)
        
        self.updateTiles(dt)
        
        shoot_clook = shoot_clook+dt
        if player_shoot and player.hp > 0 and shoot_clook > 0.09 then
            local x,y,dir = player.getBullet()
            table.insert(player_bullets,BulletPlayer(x,y,dir))
            player_shoot = false
            player.pressed_shot = false
            shoot_clook = 0
            sound_player_shoot:play()
        end
        
        local screen_x = math.max(player.fx-26,0)
        local screen_y = math.max(player.cam_look_y-12,0)
        i=1
        while foes_list[i] do
            foes_list[i].update(dt)
            foes_list[i].isOnScreen(screen_x,screen_y,52,26)
            foes_list[i].getPlayerPos(player.fx,player.fy)
            if foes_list[i].can_damage_player_on_touch then
                if foes_list[i].collisionRect(
                    player.col_box.x,player.col_box.y,
                    player.col_box.w,player.col_box.h) then
                    player.takeDamage()
                    sound_player_damage:play()
                end
            end
            
            if foes_list[i].shoot then
                local x,y,dir,tipe = foes_list[i].getBullet()
                table.insert(alien_bullets,BulletAlien(x,y,dir,tipe))
                foes_list[i].shoot =false
            end
            
            
            if foes_list[i].to_remove then
                if foes_list[i].is_dead then
                    SCORE = SCORE + foes_list[i].score_given
                end
                BWORLD:remove(foes_list[i])
                table.remove(foes_list,i)
            end
            i=i+1
        end
        
        i=1
        while other_entity_list[i] do
            other_entity_list[i].update(dt)
            other_entity_list[i].isOnScreen(screen_x,screen_y,52,26)
            other_entity_list[i].getPlayerPos(player.fx,player.fy)
            if other_entity_list[i].entity_tipe == 'coin' then
                if not other_entity_list[i].taken then
                    if other_entity_list[i].collisionRect(
                        player.col_box.x,player.col_box.y,
                        player.col_box.w,player.col_box.h) then
                        --player.takeDamage()
                        other_entity_list[i].taken = true
                        if other_entity_list[i].entity_id == 14 then
                            sound_player_coin_centavo:play()
                        end
                        if other_entity_list[i].entity_id == 15 then
                            sound_player_coin_50cents:play()
                        end
                        if other_entity_list[i].entity_id == 16 then
                            sound_player_coin_peso:play()
                        end
                        if other_entity_list[i].entity_id == 17 then
                            sound_player_coin_toston:play()
                        end
                        SCORE = SCORE + other_entity_list[i].score_given
                    end
                end
            end
            
            if other_entity_list[i].to_remove then
                BWORLD:remove(other_entity_list[i])
                table.remove(other_entity_list,i)
            end
            i=i+1
        end
        
        
        i=1
        while player_bullets[i] do
            player_bullets[i].update(dt)
            
            
            
            player_bullets[i].isOnScreen(xi,xf,yi,yf)
            if not player_bullets[i].is_dead then
                
                if not isValInTable(TILES_CAN_PASS_BULLET,
                    getTileCol(math.floor(player_bullets[i].x),math.floor(player_bullets[i].y)) ) then
                    player_bullets[i].noSell()
                    sound_player_shoot_no_sell:play()
                end
                
                local j=1
                while foes_list[j] do
                    if foes_list[j].pointCol(player_bullets[i].x,player_bullets[i].y) then
                        if  foes_list[j].can_get_damaged then
                            player_bullets[i].confirmedImpact()
                            foes_list[j].takeDamage()
                            sound_player_shoot_hit:play()
                            SCORE = SCORE + 5
                        else
                            player_bullets[i].noSell()
                            sound_player_shoot_no_sell:play()
                        end
                        break
                    end
                    j=j+1
                end
            end
            
            if player_bullets[i].to_remove then
                table.remove(player_bullets,i)
            end
            i=i+1
        end
        
        i=1
        while alien_bullets[i] do
            alien_bullets[i].update(dt)
            alien_bullets[i].isOnScreen(xi,xf,yi,yf)
            if not alien_bullets[i].is_dead then
                alien_bullets[i].getPlayerPos(player.fx,player.fy)
                if player.pointCol(alien_bullets[i].x,alien_bullets[i].y) then
                    if  player.can_take_damage then
                        alien_bullets[i].confirmedImpact()
                        player.takeDamage()
                    else
                        alien_bullets[i].noSell()
                    end
                end
            end
            
            if alien_bullets[i].to_remove then
                table.remove(alien_bullets,i)
            end
            i=i+1
        end
        
        self.time_left = self.time_left-dt
        
    end
    
    function self.gameDraw()
        
        lg.push()
        lg.scale(4,4)
        lg.setColor(1,1,1)
        lg.draw(bfg)
        lg.pop()
        
        
        lg.push()
        
        lg.scale(4,4)
        lg.translate(-offset_x*TILE_SIZE,-offset_y*TILE_SIZE)
       
        
        lg.setColor(1,1,1)
        
        
        
        lg.draw(tileset,0,0)
        tileset:clear( )
        
        if player.hp > 0 then
            player.draw()
        end
        
        i=1
        while foes_list[i] do
            foes_list[i].draw()
            i=i+1
        end
        
        i=1
        while other_entity_list[i] do
            other_entity_list[i].draw()
            i=i+1
        end
        
        i=1
        while alien_bullets[i] do
            alien_bullets[i].draw()
            i=i+1
        end
        
        i=1
        while player_bullets[i] do
            player_bullets[i].draw()
            i=i+1
        end
        
        if player.hp <= 0 then
            player.draw()
        end
        
        --[[
        lg.setColor(1,1,0)
        local screen_x = math.max(player.fx-26,0)
        local screen_y = math.max(player.cam_look_y-12,0)
        lg.rectangle('line',screen_x*TILE_SIZE,screen_y*TILE_SIZE,52*TILE_SIZE,26*TILE_SIZE)
        --]]
        
        lg.pop() 
        
        
        lg.setColor(0.1,0.1,0.1)
        lg.rectangle('fill',0,0,512*2,75)
        lg.setColor(1,1,1)
        
        --gui_elements_frames
        lg.setFont(FONT)
        lg.print('JOHN HUESOS')
        lg.draw(gui_elements,gui_elements_frames[12],0,40,0,4,4)
        local j = 0
        local mod = math.modf(player.hp,2)
        while j < player.hp do
             lg.draw(gui_elements,gui_elements_frames[14],34+(j*19),40,0,4,4)
            j=j+1
        end
        
        if show_level_name_counter < 5 then
            if show_level_name_counter >= 4 then
                lg.setColor(1,1,1,5-show_level_name_counter)
            end
            lg.printf(self.level_base_data.levelname[LANG],0,180,512*2,'center')
        end
        lg.setColor(1,1,1,1)
        
        local s = GUI_TEXT[LANG][1]..'\n%03d'
        s = string.format(s,math.floor(self.time_left))
        lg.printf(s,512*2-150,0,150,'center')
        
        s = GUI_TEXT[LANG][2]..'\n%09d'
        s = string.format(s,math.floor(SCORE))
        lg.printf(s,512-150,0,300,'center')
        
        if SHOW_BOSS_HP and BOSSHP > 0 then
            lg.draw(gui_elements,gui_elements_frames[1],336,100,0,4,4)
            j= 0
            local bhp = math.floor(BOSSHP/10)
            while j < bhp do
                lg.draw(gui_elements,gui_elements_frames[11],368+(j*32),100,0,4,4)
                j=j+1
            end
            local d = BOSSHP%10
            if d > 0 then
                lg.draw(gui_elements,gui_elements_frames[1+d],368+(j*32),100,0,4,4)
            end
            while j < 10 do
                lg.draw(gui_elements,gui_elements_frames[13],368+(j*32),100,0,4,4)
                j=j+1
            end
            
            if show_boss_name_counter < 5 then
                if show_boss_name_counter >= 4 then
                    lg.setColor(1,1,1,5-show_boss_name_counter)
                end
                lg.printf(self.level_base_data.bossname[LANG],0,200,512*2,'center')
            end
            lg.setColor(1,1,1,1)
        end
    end
    
    function self.draw()
        lg.clear(0,0,0)
        
        self.gameDraw()
        if PAUSE then
            lg.setFont(FONT)
            pausemenu:draw()
            lg.setFont(FONT_BOLD)
            lg.printf(PAUSE_MENU_TEXT[LANG][1],512-250, 300, 500,"center")
        end
        if GAMEOVER then
            lg.setFont(FONT)
            gameovermenu:draw()
            lg.setFont(FONT_BOLD)
            lg.printf(GAMEOVER_MENU_TEXT[LANG][1],512-250,250,500,"center")
        end
        if LEVEL_COMPLETE then
            lg.setFont(FONT)
            levelcompletemenu:draw()
            lg.setFont(FONT_BOLD)
            lg.printf(LEVEL_COMPLETE_MENU_TEXT[LANG][1],512-250,250,500,"center")
        end
        
    end

    

    function self.keyreleased( key, scancode )
        if scancode == "d" or scancode == "right" and player.pressed_r then
            --pass
            --MOVE_RIGTH = false
            --table.remove(player.pressed_cola,tablefind(player.pressed_cola, 1) )
            player.pressed_r = false
        end
        if scancode == "a" or scancode == "left" and player.pressed_l then
            --pass
            --MOVE_LEFT = false
            --table.remove(player.pressed_cola,tablefind(player.pressed_cola, 4) )
            player.pressed_l = false
        end
        if scancode == "s" or scancode == "down" and player.pressed_d then
            --pass
            --MOVE_RIGTH = false
            --table.remove(player.pressed_cola,tablefind(player.pressed_cola, 3) )
            player.pressed_d = false
        end
        if scancode == "w" or scancode == "up" and player.pressed_u then
            --pass
            --MOVE_LEFT = false
            --table.remove(player.pressed_cola,tablefind(player.pressed_cola, 2) )
            player.pressed_u = false
        end
        
        if scancode == "z" and player.pressed_shot  then
            --player.pressed_shot = false
        end
        
        if scancode == 'r' then
            --[[
            if GANAR or PERDER then
                restart()
            end
            ]]
        end
    end
    
    function self.keypressedOnGame(key,scancode)
        
        if scancode == "d" or scancode == "right" and not player.pressed_r then
            --pass
            --MOVE_RIGTH = false
            --table.insert(player.pressed_cola,1,1)
            player.pressed_r = true
        end
        if scancode == "a" or scancode == "left"  and not player.pressed_l then
            --pass
            --MOVE_LEFT = false
            --table.insert(player.pressed_cola,1,4)
            player.pressed_l = true
        end
        if scancode == "s" or scancode == "down" and not player.pressed_d then
            --pass
            --MOVE_RIGTH = false
            --table.insert(player.pressed_cola,1,3)
            player.pressed_d = true
        end
        if scancode == "w" or scancode == "up" and not player.pressed_u then
            --pass
            --MOVE_LEFT = false
            --table.insert(player.pressed_cola,1,2)
            player.pressed_u = true
        end
        
        if scancode == "z" or scancode == "space" and not player.kneel then
            player_shoot = true
            player.pressed_shot = true
            shoot_clook = 0
        end
    end
    
    function self.keypressed(key,scancode)
        if key == "escape" then
          --love.event.quit()
        end
        
        if scancode == "p" and not GAMEOVER then
            PAUSE = not PAUSE
        end
        
        if not PAUSE then
            if not LEVEL_COMPLETE then
                if player.hp > 0 then
                    self.keypressedOnGame(key,scancode)
                end
            end
        end
        if GAMEOVER or PAUSE then
            menuengine.keypressed(scancode)
            menuengine2.keypressed(scancode)
        end
        if LEVEL_COMPLETE then
            menuengine3.keypressed(scancode)
        end
        
    end
    
    return self
end

function love.focus(focus)
    if not focus and not GAMEOVER and not LEVEL_COMPLETE then
        PAUSE = true
    end
end


return MainTile()