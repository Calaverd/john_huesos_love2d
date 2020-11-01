--[[
CORE - Colección de funciones utiles para manejar juegos.

Cambios:BXOR a cambiado a una version más rapida

--]]

---binary xor logical door by Arno Wagner 
function bxor(x, y)
   local z = 0
   for i = 0, 31 do
      if (x % 2 == 0) then                      -- x had a '0' in bit i
         if ( y % 2 == 1) then                  -- y had a '1' in bit i
            y = y - 1 
            z = z + 2 ^ i                       -- set bit i of z to '1' 
         end
      else                                      -- x had a '1' in bit i
         x = x - 1
         if (y % 2 == 0) then                  -- y had a '0' in bit i
            z = z + 2 ^ i                       -- set bit i of z to '1' 
         else
            y = y - 1 
         end
      end
      y = y / 2
      x = x / 2
   end
   return z
end


--oveloaded functions
function Overloaded()
    local fns = {}
    local mt = {}
    
    local function oerror()
        return error("Invalid argument types to overloaded function")
    end
    
    function mt:__call(...)
        local arg = {...}
        local default = self.default
        
        local signature = {}
        for i,arg in ipairs {...} do
            signature[i] = type(arg)
        end
        
        signature = table.concat(signature, ",")
        
        return (fns[signature] or self.default)(...)
    end
    
    function mt:__index(key)
        local signature = {}
        local function __newindex(self, key, value)
            print(key, type(key), value, type(value))
            signature[#signature+1] = key
            fns[table.concat(signature, ",")] = value
            print("bind", table.concat(signature, ", "))
        end
        local function __index(self, key)
            print("I", key, type(key))
            signature[#signature+1] = key
            return setmetatable({}, { __index = __index, __newindex = __newindex })
        end
        return __index(self, key)
    end
    
    function mt:__newindex(key, value)
        fns[key] = value
    end
    
    return setmetatable({ default = oerror }, mt)
end




---
function testbflag(set, flag)
  return set % (2*flag) >= flag
end

function setbflag(set, flag)
  if set % (2*flag) >= flag then
    return set
  end
  return set + flag
end

function clrbflag(set, flag) -- clear flag
  if set % (2*flag) >= flag then
    return set - flag
  end
  return set
end



--interolación lineal.
function lerp(a,b,t) return (1-t)*a + t*b end

--[[
Clase vector2D
]]
function Vector2D(x,y)
    local self = {x = x or 0,y= y or 0}
    
    function self.magnitud()
      return math.sqrt(self.x*self.x+self.y*self.y) or 0
    end
    
    function self.magnitudCuadrada()
      return self.x*self.x+self.y*self.y or 0
    end
    
    function self.productoPunto(vec)
      --print(self.x,self.y)
      --print(vec.x,vec.y)
      return self.x*vec.x + self.y*vec.y
    end
    
    function self.productoCruz(vec)
      --print(self.x,self.y)
      --print(vec.x,vec.y)
      return self.x*vec.y - self.y*vec.x
    end
    
    function self.lerpVector(vec,t)
        local t = t or 0.5
        self.x = lerp(vec.x,self.x,t)
        self.y = lerp(vec.y,self.y,t)
    end
    
    function self.normalizar(min)
      local min = min or 0
      local mag = self.magnitud()
      if mag > min  then
        return self/mag
      end
      return Vector2D(0,0)
    end
    --sobrecarga de operadores...
    local mt = {
    __add = function (lhs, rhs) 
        x = lhs.x + rhs.x
        y = lhs.y + rhs.y
        return Vector2D(x,y) 
        end,
    __sub = function (lhs, rhs) 
        x = lhs.x - rhs.x
        y = lhs.y - rhs.y
        return Vector2D(x,y) 
        end,
    __div = function (lhs, rhs) 
         if type(rhs) == 'number' then 
            x = lhs.x/rhs
            y = lhs.y/rhs
            return Vector2D(x,y)
          end    
        x = lhs.x/rhs.x
        y = lhs.y/rhs.y
        return Vector2D(x,y) 
        end,
    __mul = function (lhs,rhs)
        if type(rhs) == 'number' then 
            x = lhs.x*rhs
            y = lhs.y*rhs
            return Vector2D(x,y)
          end
        x = lhs.x*rhs.x
        y = lhs.y*rhs.y
        return Vector2D(x,y) 
        end,
    __call = function(a, op)
        if op == '.' then 
            return function(b) return self.productoPunto(b) end
        elseif op == 'x' then
            return function(b) return self.productoCruz(b) end
            end
        
        end
        
    }
    
    setmetatable(self, mt) -- use "mt" as the metatable
    
    self.type = 'Vector2D'
    
    return self
end


function Sprite(source,x,y)
    local self = {
        image = love.graphics.newImage(source),
        pos= Vector2D(),
        col= Vector2D(),
        angulo = 0,
        escala = Vector2D(),
        pivote = Vector2D(),
        velocidad = Vector2D(),
        ancho,
        alto
        }
        
    self.pos.x = x or 0
    self.pos.y = y or 0 
    
    
    self.escala.x = 1
    self.escala.y = 1
    self.pivote.x = 0.5
    self.pivote.y = 0.5
    self.image_width, self.image_height = self.image:getDimensions( )
    
    self.ancho = self.image_width
    self.alto = self.image_height
    
    self.col.x = self.pos.x-(self.ancho*self.pivote.x)
    self.col.y = self.pos.y-(self.ancho*self.pivote.x)
    self.col.w = self.ancho
    self.col.h = self.alto
    
    self.quad = love.graphics.newQuad(0,0,self.image_width,self.image_height,self.image_width,self.image_height)
    function self.draw()
        love.graphics.draw(self.image,
                           self.quad,
                           self.pos.x,self.pos.y,
                           self.angulo,
                           self.escala.x,self.escala.y,
                           self.image_width*self.pivote.x, self.image_height*self.pivote.y)
    end
    
    
    function self.update()
    end
    
    function self.fromColToPos(offset_x,offset_y)
       local offset_x = offset_x or 0
       local offset_y = offset_y or 0
       self.pos.x = self.col.x+offset_x+self.ancho*self.pivote.x
       self.pos.y = self.col.y+offset_y+self.alto*self.pivote.y
    end
    
    return self
end


function Cronometro()
    local self = {}
    local start_time = 0 
    local pause_time = 0
    local iniciado = false
    local pausado = false
    local detenido = false
    
    function self.estaDetenido()
        return detenido
    end
    
    function self.estaPausado()
        return pausado
    end
    
    function self.estaIniciado()
        return iniciado
    end
    
    function self.iniciar()
        iniciado = true
        pausado = false
        detenido = false
        start_time = love.timer.getTime()
        pause_time = 0
    end
    
    function self.getTicks()
        if iniciado then
            if pausado then
                return pause_time
            else
                local a = (love.timer.getTime()-start_time)
                return a
            end
        end
        return 0
    end
    
    function self.hanPasado(segundos)
       if self.getTicks() >=  segundos then
            self.iniciar()
            return true
       end
       return false
    end
    
    function self.pausar()
        if iniciado and (not pausado) then
            pausado = true
            pause_time = love.timer.getTime()-start_time
        end
    end
    
    function self.despausar()
        if iniciado and pausado then
            pausado = false
            start_time = love.timer.getTime()-pause_time
            pause_time = 0
        end
    end
    
    function self.detener()
       detenido = true
       iniciado = false
       pausado = false
    end
    
    return self
end



function Animation(lista_frames)
    local self = {}
    self.reloj = Cronometro()
    self.reloj.iniciar()
    self.frames = lista_frames
    self.frame_actual = 1
    self.periodo = 0.2
    self.is_ended = false
    function self.getFrameActual()
        if self.reloj.hanPasado(self.periodo) then
            if self.frames[self.frame_actual+1] then
                self.frame_actual = self.frame_actual+1
            else
                self.frame_actual = 1
                self.is_ended = true
            end
        end
        return self.frames[self.frame_actual]
    end
    
    function self.checkEnded()
       return self.is_ended
    end
    
    function self.restart()
       self.reloj.iniciar()
       self.frame_actual = 1
       self.is_ended = false
    end
    
    return self
end


function simpleQuadsImagenAnchoAlto(ancho_ima,alto_ima,ancho_r,alto_r)
    local lista = {}
    local filas = math.floor(alto_ima/alto_r)
    local columnas = math.floor(ancho_ima/ancho_r)
    
    offset_x = offset_x or 0
    offset_y = offset_y or 0

    --print(filas,columnas)
    local count = 1
    local i = 0
    while i < filas do
        local j = 0
        while j < columnas do
            local x = (ancho_r*j)+offset_x
            local y = (alto_r*i)+offset_y
            lista[count] = love.graphics.newQuad(x,y,ancho_r,alto_r,ancho_ima, alto_ima)
            count = count+1
            --io.write('*')
            j = j+1
        end
        i=i+1
        --io.write('\n')
    end
    return lista
end


function quadsImagenAnchoAlto(ancho_ima,alto_ima,ancho_r,alto_r,offset_x,offset_y)
    local lista = {}
    local filas = math.floor(alto_ima/alto_r)
    local columnas = math.floor(ancho_ima/ancho_r)
    
    offset_x = offset_x or 0
    offset_y = offset_y or 0

    --print(filas,columnas)
    local count = 1
    local i = 0
    while i < filas do
        local j = 0
        while j < columnas do
            local x = (ancho_r*j)+offset_x
            local y = (alto_r*i)+offset_y
            lista[count] = love.graphics.newQuad(x,y,ancho_r-offset_x-1,alto_r-offset_y-1,
    ancho_ima, alto_ima)
            count = count+1
            --io.write('*')
            j = j+1
        end
        i=i+1
        --io.write('\n')
    end
    return lista
end


RATIO = Vector2D()
OFFSET_X = -00
OFFSET_Y = -00
ZOOM = 01


function Camara(blanco,max_x,max_y,min_x,min_y)
    local self = {apuntar_a=blanco,
        pos = Vector2D(),
        --el limite maximo de la camara, el maximo signed int positivo
        limite_max_x = max_x or 2147483647,
        limite_max_y = max_y or 2147483647,
        limite_min_x = min_x or -2147483647,
        limite_min_y = min_y or -2147483647,
        ancho,
        alto,
        zoom,
        }
        
        
    self.pos = self.apuntar_a.pos
    
    self.ancho = love.graphics.getWidth()/RATIO.x
    self.alto = love.graphics.getHeight()/RATIO.y
    self.zoom = 1
    self.min_zoom = 0.2
    self.max_zoom = 1.5
    self.zooming = 0
    self.name = 'camara'
    
    self.custom_ancho = nil
    self.custom_alto = nil
    self.custom = false
    self.smooth_movement = true
    --fija el mundo fisico para la camara
    --y agrega la camara al mundo fisico
    --(el mundo es de bump.lua)
    
    function self.setMinZoom(zoom) 
        self.min_zoom = zoom or 0.2
    end
    
    function self.setMaxZoom(zoom) 
        self.max_zoom = zoom or 1.5
    end
    
    local mid_ancho = self.ancho/2
    local mid_alto = self.alto/2
    
    function self.setCustomSize(ancho, alto)
       self.custom_ancho = ancho
       self.custom_alto = alto
       self.customsize = true
    end
    
    function self.setSmoothMov(flag)
       self.smooth_movement = flag
    end

    function self.update()
        if not self.customsize then
           self.ancho = (love.graphics.getWidth()/RATIO.x)*self.zoom
           self.alto = (love.graphics.getHeight()/RATIO.y)*self.zoom
        else
           self.ancho = (self.custom_ancho*RATIO.x)/self.zoom
           self.alto = (self.custom_alto*RATIO.y)/self.zoom
        end
        
        local mid_ancho = (self.ancho/2)
        local mid_alto = (self.alto/2)
        
        if self.smooth_movement then
           self.pos.lerpVector(self.apuntar_a.pos,0.75) --how fast the camer flows he objetive
        else
           self.pos = self.apuntar_a.pos
        end
        
        if (self.pos.x-mid_ancho > self.limite_min_x) and ((self.pos.x+self.ancho) < self.limite_max_x+mid_ancho) then
            self.pos.x = tonumber(self.pos.x)
        else 
            self.pos.x = mid_ancho--mid_ancho
        end
        
        
        if (self.pos.y-mid_alto > self.limite_min_y) and ((self.pos.y+self.alto) < self.limite_max_y+mid_alto) then
            self.pos.y = tonumber(self.pos.y)
        else
            self.pos.y = mid_alto--mid_alto
        end
        
        OFFSET_X = -(self.pos.x-mid_ancho)
        OFFSET_Y = -(self.pos.y-mid_alto)
        
        if self.zooming < 0 then
            self.zoom = lerp(self.zoom,self.zoom-0.25,0.05)
            if self.zoom < self.min_zoom then
                self.zoom = self.min_zoom
                self.zooming = 0
            end
        elseif self.zooming > 0 then
            self.zoom = lerp(self.zoom,self.zoom+0.25,0.05)
            if self.zoom > self.max_zoom then
                self.zoom = self.max_zoom
                self.zooming = 0
            end
        end
        
        if self.zoom < self.min_zoom then self.zoom = self.min_zoom end
        if self.zoom > self.max_zoom then self.zoom = self.max_zoom end
        ZOOM = self.zoom

        love.graphics.setScissor( 0, 0,love.graphics.getWidth(),love.graphics.getHeight())
    end
    
    function self.draw()
       --love.graphics.setLineWidth(20)
       love.graphics.rectangle("line",-OFFSET_X,-OFFSET_Y,self.ancho,self.alto)
       love.graphics.setLineWidth(1)
    end
    
    
    function self.getZoom()
        return self.zoom
    end
    
    return self
end




function screenPosToWorldPos(x,y)
   local x2 = ((love.mouse.getX( )/RATIO.x)*ZOOM)-(OFFSET_X)
   local y2 = ((love.mouse.getY( )/RATIO.y)*ZOOM)-(OFFSET_Y)
   return Vector2D(math.floor(x2),math.floor(y2))
end


function getCustomSeed(string_base)
    local i = 1
    local lens = string_base:len()+1
    if lens <= 1 then
        return os.time()
    end
    local string_number = '0'
    while i < lens do
        local char = string_base:sub(i,i)
        local char_byte = string.byte(char)
        if char_byte >= 48 and char_byte <= 57 then
           string_number = string_number..char
        else
           string_number = tostring(tonumber(string_number)+char_byte)
        end
        i = i+1
        
    end
    return tonumber(string_number)
end


function setCustomSeed(string_base)
   local seed = getCustomSeed(string_base)
   love.math.setRandomSeed( seed )
   math.randomseed(seed)
end

-- by Michal Kottman
function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end


function initMatrix(x,y,val)
    local temp_row = {}
    local matrix = {}
    local v;
    if val == nil then 
      v = 0
    else
      v = val
    end
    
    local i = 0
    while i < y do
        temp_row = {}
        local j = 0
        while j < x do 
            local val = 0
            table.insert(temp_row,0)
            --if val == 1 then --io.write(' #') else --io.write('  ') end
            j=j+1
        end
        table.insert(matrix,temp_row)
        i=i+1
        ----print(' ')
    end
    
    return matrix
end


function hsvToRgb(h, s, v)
  local r, g, b

  local i = math.floor(h * 6);
  local f = h * 6 - i;
  local p = v * (1 - s);
  local q = v * (1 - f * s);
  local t = v * (1 - (1 - f) * s);

  i = i % 6

  if i == 0 then r, g, b = v, t, p
  elseif i == 1 then r, g, b = q, v, p
  elseif i == 2 then r, g, b = p, v, t
  elseif i == 3 then r, g, b = p, q, v
  elseif i == 4 then r, g, b = t, p, v
  elseif i == 5 then r, g, b = v, p, q
  end

  return r * 255, g * 255, b * 255
end


function tablefind(tab,el)
    for index, value in pairs(tab) do
        if value == el then
            return index
        end
    end
end

function isValInTable(tab,val)
    for index, value in pairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end
