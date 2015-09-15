hooksecurefunc(StaticPopupDialogs["DEATH"],"OnShow",function(self)
	if InActiveBattlefield() and not IsActiveBattlefieldArena() then
		self.button1:Click()
	end
end)