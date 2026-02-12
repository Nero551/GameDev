local remotes = game:GetService("ReplicatedStorage").Remotes

-- wait until UI + scripts are ready
task.wait(0.5)

remotes.ClientReady:FireServer()
