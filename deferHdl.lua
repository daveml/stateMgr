-- deferHdl
local M = {_TYPE='module', _NAME='deferHdl', _VERSION='0.1'}

function nilHandleF()
	print("nil handler")
end
	
--deferHandle = {} 

function M.init()
	return {{maskHandling=false,maskHandleF=nilHandleF, maskEventType=nil}, queue={}}
end

function M.setMaskHandler(Hdl, HandleF, EventType)
	Hdl.maskHandling = true
	Hdl.maskHandleF = HandleF
	Hdl.maskEventType = EventType
end

function M.newevent(EvName,EvP1,EvP2,EvP3,EvP4)
	return {name=EvName,active=true,p1=EvP1,p2=EvP2,p3=EvP3,p4=EvP4}
end

function M.add(Hdl, Handler)
	print("Queue Add "..Handler.name)
	table.insert(Hdl.queue, Handler)
	Handler.self = # Hdl.queue
end

function M.remove(Hdl, Handler)
	table.remove(Hdl.queue, Handler.self)
end

function dPrint(str)
	print(str)
end

function M.handle(Hdl, EventT)
	dPrint("deferHandler running on Event..."..EventT.name)
	local HandleComplete = false
		
	newevent = EventT.name

	for HdlIdx, Handler in ipairs(Hdl.queue) do
		if HandleComplete then break end
		dPrint("Checking"..Handler.name)
		for EvIdx, event in pairs(Handler.events) do
			if event == newevent then
				if Hdl.maskHandling and event == Hdl.maskEventType then
					for MaskIdx, mask in ipairs(Handler.masks) do
						if mask.en == false then break end
						local status = Hdl.maskHandleF(mask.param)
						if bit.band(status,mask.mask) ~= 0 then
							dPrint("Matched mask event: "..event.." for handler: "..Handler.name)
							Handler.handlerF(Hdl, Handler, EventT)
							HandleComplete = true
							break
						end
					end
				else
					dPrint("Matched event: "..event.." for handler: "..Handler.name)
					Handler.handlerF(Hdl, Handler, EventT)
					HandleComplete = true
					break
				end
			end
		end
	end
end

function M.clearevent(EventT)
	EventT.active = false
end

return M


