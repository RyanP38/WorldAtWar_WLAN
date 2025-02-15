--= germany_gui.lua =--
-- This file contains the nation-specific GUI logic for Germany.

local germanyGUI = {}

-- Unit Stats for Germany
function germanyGUI.getUnitStats()
    return {
        { name = "Infantry", cost = 3, attack = 1, defense = 2 },
        { name = "Tank", cost = 6, attack = 3, defense = 3 },
        { name = "Submarine", cost = 6, attack = 2, defense = 1 },
        { name = "Battleship", cost = 20, attack = 4, defense = 4 }
    }
end

-- Technologies Tab for Germany
function germanyGUI.drawTechnologiesTab()
    love.graphics.print("Germany Technologies:", 10, 10)
    love.graphics.print("- Rocket Technology (Develop Turn 3)", 10, 40)
    love.graphics.print("- Advanced Tanks (Develop Turn 5)", 10, 60)
end

return germanyGUI
