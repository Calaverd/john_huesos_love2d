function Centavo(x,y)
    local self = BaseEntity(x,y-1)
    self.col.x = self.x
    self.col.y = self.y
    self.col.w = 1
    self.col.h = 1
    
    self.dir = 1
    self.entity_id = 14
    
    self.entity_tipe = 'coin'
    
    
    self.score_given = 100
    
    local ima = love.graphics.newImage("rsc/sprites/centavo.png")
    local framelist = simpleQuadsImagenAnchoAlto(32,8,8,8)
    self.use_frame = 1
    self.taken = false
    self.move = 1
    self.move_counter = 0 
    self.spin_anim = Animation({1,2,3,4})
    self.spin_anim.periodo = 0.2
    
    function self.update(dt)
        self.use_frame = self.spin_anim.getFrameActual() 
        if not self.taken then
--            self.use_frame = self.spin_anim.getFrameActual() 
            self.updateColRect()

            if not self.on_screen then
                self.y = self.y+1
                self.freeze()
            end
           
        else
            self.spin_anim.periodo = 0.05
            self.disapear(dt)
            self.y = self.y-dt*1.5
        end
    end
    
    function self.draw()
        love.graphics.setColor(self.color)
        love.graphics.draw(ima,
            framelist[self.use_frame],self.x*TILE_SIZE,self.y*TILE_SIZE,0,self.dir,1)
        
        --love.graphics.setColor(1,0,0)
        --love.graphics.rectangle('fill',(self.col.x)*TILE_SIZE,(self.col.y)*TILE_SIZE,(self.col.w)*TILE_SIZE,(self.col.h)*TILE_SIZE)
    end

    return self
end

function FCentavos(x,y)
    local self = BaseEntity(x,y-1)
    self.col.x = self.x
    self.col.y = self.y
    self.col.w = 1.2
    self.col.h = 1.2
    
    self.dir = 1
    self.entity_id = 15
    
    self.entity_tipe = 'coin'
    
    self.score_given = 5000
    
    local ima = love.graphics.newImage("rsc/sprites/50centavos.png")
    local framelist = simpleQuadsImagenAnchoAlto(50,10,10,10)
    self.use_frame = 1
    self.taken = false
    self.move = 1
    self.move_counter = 0 
    self.spin_anim = Animation({1,2,3,4,5,2,3,4})
    self.spin_anim.periodo = 0.2
    
    function self.update(dt)
        self.use_frame = self.spin_anim.getFrameActual() 
        if not self.taken then
--            self.use_frame = self.spin_anim.getFrameActual() 
            self.updateColRect()

            if not self.on_screen then
                self.y = self.y+1
                self.freeze()
            end
           
        else
            self.spin_anim.periodo = 0.05
            self.disapear(dt)
            self.y = self.y-dt*3
        end
    end
    
    function self.draw()
        love.graphics.setColor(self.color)
        love.graphics.draw(ima,
            framelist[self.use_frame],self.x*TILE_SIZE,self.y*TILE_SIZE,0,self.dir,1)
        
        --love.graphics.setColor(1,0,0)
        --love.graphics.rectangle('fill',(self.col.x)*TILE_SIZE,(self.col.y)*TILE_SIZE,(self.col.w)*TILE_SIZE,(self.col.h)*TILE_SIZE)
    end

    return self
end


function Peso(x,y)
    local self = BaseEntity(x,y-1)
    self.col.x = self.x
    self.col.y = self.y
    self.col.w = 1.2
    self.col.h = 1.2
    
    self.dir = 1
    self.entity_id = 16
    
    self.entity_tipe = 'coin'
    self.score_given = 10000
    
    local ima = love.graphics.newImage("rsc/sprites/peso.png")
    local framelist = simpleQuadsImagenAnchoAlto(60,12,12,12)
    self.use_frame = 1
    self.taken = false
    self.move = 1
    self.move_counter = 0 
    self.spin_anim = Animation({1,2,3,4,5,2,3,4})
    self.spin_anim.periodo = 0.2
    
    function self.update(dt)
        self.use_frame = self.spin_anim.getFrameActual() 
        if not self.taken then
--            self.use_frame = self.spin_anim.getFrameActual() 
            self.updateColRect()

            if not self.on_screen then
                self.y = self.y+1
                self.freeze()
            end
           
        else
            self.spin_anim.periodo = 0.05
            self.disapear(dt)
            self.y = self.y-dt*3
        end
    end
    
    function self.draw()
        love.graphics.setColor(self.color)
        love.graphics.draw(ima,
            framelist[self.use_frame],self.x*TILE_SIZE,self.y*TILE_SIZE,0,self.dir,1)
        
        --love.graphics.setColor(1,0,0)
        --love.graphics.rectangle('fill',(self.col.x)*TILE_SIZE,(self.col.y)*TILE_SIZE,(self.col.w)*TILE_SIZE,(self.col.h)*TILE_SIZE)
    end

    return self
end

function Toston(x,y)
    local self = BaseEntity(x,y-1)
    self.col.x = self.x
    self.col.y = self.y
    self.col.w = 1.2
    self.col.h = 1.2
    
    self.dir = 1
    self.entity_id = 17
    
    self.entity_tipe = 'coin'
    self.score_given = 500000
    
    local ima = love.graphics.newImage("rsc/sprites/10pesos.png")
    local framelist = simpleQuadsImagenAnchoAlto(70,14,14,14)
    self.use_frame = 1
    self.taken = false
    self.move = 1
    self.move_counter = 0 
    self.spin_anim = Animation({1,2,3,4,5,2,3,4})
    self.spin_anim.periodo = 0.2
    
    function self.update(dt)
        self.use_frame = self.spin_anim.getFrameActual() 
        if not self.taken then
--            self.use_frame = self.spin_anim.getFrameActual() 
            self.updateColRect()

            if not self.on_screen then
                self.y = self.y+1
                self.freeze()
            end
           
        else
            self.spin_anim.periodo = 0.05
            self.disapear(dt)
            self.y = self.y-dt*3
        end
    end
    
    function self.draw()
        love.graphics.setColor(self.color)
        love.graphics.draw(ima,
            framelist[self.use_frame],self.x*TILE_SIZE,self.y*TILE_SIZE,0,self.dir,1)
        
        --love.graphics.setColor(1,0,0)
        --love.graphics.rectangle('fill',(self.col.x)*TILE_SIZE,(self.col.y)*TILE_SIZE,(self.col.w)*TILE_SIZE,(self.col.h)*TILE_SIZE)
    end

    return self
end

ENTITY_DEF_LIST[14] = Centavo
ENTITY_DEF_LIST[15] = FCentavos
ENTITY_DEF_LIST[16] = Peso
ENTITY_DEF_LIST[17] = Toston
-----