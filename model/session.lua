Session = mondelefant.new_class()
Session.table = 'session'
Session.primary_key = { 'ident' } 

Session:add_reference{
  mode          = 'm1',
  to            = "Member",
  this_key      = 'member_id',
  that_key      = 'id',
  ref           = 'member',
}

local function random_string()
  return multirand.string(
    32,
    '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
  )
end

function Session:new()
  local session = self.prototype.new(self)  -- super call
  session.ident             = random_string()
  session.additional_secret = random_string()
  session:save() 
  return session
end

function Session:by_ident(ident)
  local selector = self:new_selector()
  selector:add_where{ 'ident = ?', ident }
  selector:optional_object_mode()
  return selector:exec()
end
