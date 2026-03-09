local UIManager = {}

UIManager.Screens = {}

for _,controller in script.Parent.Controllers:GetChildren() do
    if controller:IsA("ModuleScript") then
        UIManager.Screens[controller.Name] = require(controller)
    end
end

function UIManager:Open(name)
    if UIManager.Screens[name] then
    end
end

return UIManager