-- deferHdl
local M = {_TYPE='module', _NAME='deferHdl', _VERSION='0.1'}

function M.nilHandleF()
	dPprint("nil handler")
end
	
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
	dPrint("Queue Add "..Handler.name)
	Hdl.queue[Handler.name] = Handler
end

function M.remove(Hdl, Handler)
	dPrint("Queue Remove "..Handler.name)
	Hdl.queue[Handler.name] = nil
end

function dPrint(str)
	print(str)
end

function M.handle(Hdl, EventT)
	dPrint("deferHandler running on Event..."..EventT.name)
	local HandleComplete = false
		
	newevent = EventT.name

	for HdlKey, Handler in pairs(Hdl.queue) do
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
							return
						end
					end
				else
					dPrint("Matched event: "..event.." for handler: "..Handler.name)
					Handler.handlerF(Hdl, Handler, EventT)
					return
				end
			end
		end
	end
end

function M.clearevent(EventT)
	EventT.active = false
end

return M


