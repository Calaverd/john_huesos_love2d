Cervantes = {}

Cervantes.FormatList = {}

function Cervantes.addFormat(font_format,name_format)
    Cervantes.FormatList[name_format] = font_format
end

--initialize the cervantes lib
function Cervantes.init()
    Cervantes.addFormat(Cervantes.Format(),'default')
    Cervantes.addFormat(Cervantes.Format(love.graphics.newFont(14),'*'),'bold')
    --Cervantes.FormatList['default bold'].set
end

function Cervantes.Word(text,format_name)
    local self = {}
    self.render_text = ''
    self.complete_text = text
    self.completed = false
    self.is_started = false
    self.index = 0
    self.len_text = #self.complete_text
    
    self.add_letter_tween = nil
    
    local word_format = Cervantes.FormatList[format_name]
    
    
    local wordWidth = word_format.getTextWidth(self.complete_text)
    local wordHeight = word_format.getTextHeight()
    self.x = 0
    self.y = 0
    function self.setPos(x,y)
        self.x = x
        self.y = y
    end
    
    
    function self.start()
        self.is_started = true
        self.add_letter_tween = 0
    end
    
    function self.update(dt)
        if self.is_started and not self.completed then
            self.add_letter_tween = self.add_letter_tween+dt
           
            local completed_action = (self.add_letter_tween >= word_format.getSpeed())
            if completed_action then
                if self.index <= self.len_text then
                    local next_char = self.complete_text:utf8sub(math.floor(self.index),math.floor(self.index))
                    self.render_text = self.render_text..next_char
                    --print()
                     self.index = self.index+1
                    self.add_letter_tween = 0
                    if  word_format.sound and next_char ~= ' ' then
                        word_format.sound:play()
                    end
                end
                if #self.complete_text == #self.render_text then
                    self.completed = true
                end
            end
        end
    end
    
    function self.draw(offset_x,offset_y)
        love.graphics.setColor(word_format.getColor())
        love.graphics.setFont(word_format.getFont())
        
        love.graphics.print(self.render_text,self.x+offset_x,self.y+offset_y)
        --love.graphics.rectangle('line',self.x,self.y,wordWidth,word_format.getTextHeight())
    end
    
    function self.getWordWidth()
        return wordWidth
    end
    
    function self.getWordHeight()
        return wordHeight
    end
    
    return self
end

function Cervantes.Format(Font,Markup_char)
    local self = {}
    self.color = {1,1,1}
    self.sonido = nil
    self.speed_text = 0.1 --the speed to add a word
    self.markup_char = Markup_char
    if Font == nil then
        Font = love.graphics.getFont()
    end
    self.font_to_use = Font
    
    function self.getMarkupChar()
        return self.markup_char
    end
    
    function self.getFont()
        return self.font_to_use
    end
    
    function self.getTextHeight()
        return self.font_to_use:getHeight()
    end

    function self.getTextWidth(text)
        return self.font_to_use:getWidth(text)
    end
    
    function self.getSpeed()
        return self.speed_text
    end
    
    function self.getColor()
        return self.color
    end

    return self
end

function Cervantes.parseText(text)
    local words = {}
    local use_format = 'default'
    local formats_used_in_text = {}
    for word in text:gmatch("%S+") do
        local first_char = word:utf8sub(1,1)
        local last_char = word:utf8sub(word:utf8len(),word:utf8len())
        local tem_format = use_format
        for format_name, formats in pairs(Cervantes.FormatList) do
            if formats.getMarkupChar() == first_char then
                use_format = format_name
                word = word:utf8sub(2,word:utf8len())
            end
        end
        
        tem_format = use_format
        
        for format_name, formats in pairs(Cervantes.FormatList) do
            if formats.getMarkupChar() == last_char and use_format == format_name then
                use_format = 'default'
                word = word:utf8sub(1,word:utf8len()-1)
            end
        end
        
        table.insert(words, Cervantes.Word(word..' ',tem_format))
        
        if formats_used_in_text[tem_format] then
            formats_used_in_text[tem_format] = formats_used_in_text[tem_format]+1
        else 
            formats_used_in_text[tem_format] = 1
        end
    end
    
    local max = 0
    local averange_format = nil
    for format_name, num in pairs(formats_used_in_text) do
        if num > max then
            max = num
            averange_format = format_name 
        end
    end
    
    
    return words, averange_format
end



function Cervantes.textBox(x,y,w,h)
    local self = {}
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    
    self.word_list = nil
    self.averange_text_format = nil
    self.show_from = 1
    self.show_to = 1
    self.current_word = 1
    
    self.completed = false
    
    
    function self.setWordList(list,averange_text_format)
        self.word_list = list
        self.averange_text_format = averange_text_format
        self.showWordsListFrom(self.show_from)
        self.compled = false
    end
    
    function self.showWordsListFrom(last)
        local i = last
        local ix = 1
        local iy = 1
        local wh = Cervantes.FormatList[self.averange_text_format].getTextHeight()
        while self.word_list[i] do
            local y_off = 0
            if self.word_list[i].getWordHeight() > wh then
                y_off = self.word_list[i].getWordHeight() - wh
            end
            if ix+self.word_list[i].getWordWidth() < self.w then
                self.word_list[i].setPos(ix,iy-y_off)
                ix=ix+self.word_list[i].getWordWidth()
            else
                ix = 0
                if (iy + wh*2) > self.h then
                    break
                else                    
                    iy = iy+wh
                    self.word_list[i].setPos(ix,iy-y_off)
                    ix=ix+self.word_list[i].getWordWidth()
                end
            end
            i=i+1
        end
        self.show_to = i
    end
    
    function self.continueText()
        self.show_from = self.show_to
        self.showWordsListFrom(self.show_to)
        self.stoped = false
    end
    
    function self.update(dt)
        if not self.word_list[self.current_word].is_started then
            if self.current_word  <= self.show_to then
                self.word_list[self.current_word].start()
                if (#self.word_list) == self.current_word then
                    self.compled = true
                    print('Adios')
                end
            else
                self.stoped = true
            end
        else
            if self.word_list[self.current_word].completed then
                if self.current_word +1 <= #self.word_list then
                    self.current_word = self.current_word +1
                end
            else
                self.word_list[self.current_word].update(dt)
            end
        end
        
        --[[
        if self.stoped and love.keyboard.isDown('space') then
            if not self.completed then 
                print('Deberiamos continuar...')
                self.continueText()
            end
        end--]]
        if self.stoped then
            if not self.completed then 
                print('Deberiamos continuar...')
                self.continueText()
            end
        end
        
    end
    
    function self.draw()
        --love.graphics.setColor(1,1,1)
        --love.graphics.rectangle('fill',self.x,self.y,self.w,self.h)
        local i = self.show_from
        while i < self.show_to do
            self.word_list[i].draw(self.x,self.y)
            i=i+1
        end
    end
    
    return self
end


return Cervantes