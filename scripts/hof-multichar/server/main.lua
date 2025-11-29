local config <const> = require 'config.server'


local function fetchPlayerSkin(citizenId)
  return MySQL.single.await('SELECT * FROM playerskins WHERE citizenid = ? AND active = 1', {citizenId})
end

local function getPlayerIdentifiers(src)
  return GetPlayerIdentifierByType(src, 'license2'), GetPlayerIdentifierByType(src, 'license')
end

local function buildCharacterMetadata(job, charinfo, money)
  return {
    { key = 'job', value = ('%s (%s)'):format(job.label, job.grade.name) },
    { key = 'nationality', value = charinfo.nationality },
    { key = 'bank', value = lib.math.groupdigits(money.bank) },
    { key = 'cash', value = lib.math.groupdigits(money.cash) },
    { key = 'birthdate', value = charinfo.birthdate },
    { key = 'gender', value = charinfo.gender == 0 and 'Male' or 'Female' },
  }
end

local function fetchPlayerCharacterData(license2, license)
  local result = MySQL.query.await('SELECT * FROM players WHERE license = ? OR license = ?', {license, license2}) or {}
  local characters = {}

  for i = 1, #result do
    local row = result[i]
    local charinfo = json.decode(row.charinfo)
    local job = json.decode(row.job)
    local money = json.decode(row.money)

    characters[i] = {
      citizenid = row.citizenid,
      name = ('%s %s'):format(charinfo.firstname, charinfo.lastname),
      cid = charinfo.cid,
      metadata = buildCharacterMetadata(job, charinfo, money)
    }
  end

  return characters
end

local function getMaxCharacterCount(license2, license)
  if license2 and config.playersNumberOfCharacters[license2] then
    return config.playersNumberOfCharacters[license2]
  end

  if license and config.playersNumberOfCharacters[license] then
    return config.playersNumberOfCharacters[license]
  end

  return config.defaultNumberOfCharacters
end

local function playerOwnsCharacter(src, citizenId)
  if type(citizenId) ~= 'string' or citizenId == '' then
    return false, 'invalid'
  end

  local license2, license = getPlayerIdentifiers(src)
  if not license2 and not license then
    return false, 'missingIdentifier'
  end

  local character = MySQL.single.await('SELECT license, license2 FROM players WHERE citizenid = ? LIMIT 1', {citizenId})
  if not character then
    return false, 'notFound'
  end

  local owns = false
  if license2 and (character.license2 == license2 or character.license == license2) then owns = true end
  if license and (character.license == license or character.license2 == license) then owns = true end

  if not owns then
    return false, 'notOwner'
  end

  return true
end

local function buildCharacterSlots(characters, allowedAmount)
  local slots = {}
  for i = 1, allowedAmount do
    slots[i] = characters[i]
  end
  return slots
end

lib.callback.register('hof-multichar:server:getCharacters', function(source)
  local license2, license = getPlayerIdentifiers(source)
  local chars = fetchPlayerCharacterData(license2, license)
  local allowedAmount = getMaxCharacterCount(license2, license)

  return buildCharacterSlots(chars, allowedAmount), allowedAmount
end)

lib.callback.register('hof-multichar:server:getPreviewPedData', function(_, citizenId)
  local ped = fetchPlayerSkin(citizenId)
  if not ped then return end

  return ped.skin, ped.model and joaat(ped.model)
end)

lib.callback.register('hof-multichar:server:loadCharacter', function(source, citizenId)
  local success = exports.qbx_core:Login(source, citizenId)
  if not success then return end

  exports.qbx_core:SetPlayerBucket(source, 0)
  lib.print.info(('%s (Citizen ID: %s) has successfully loaded!'):format(GetPlayerName(source), citizenId))
end)

---@param data unknown
---@return table? newData
lib.callback.register('hof-multichar:server:createCharacter', function(source, data)
  local newData = {}
  newData.charinfo = data

  local success = exports.qbx_core:Login(source, nil, newData)
  if not success then return end
  Player(source).state:set('isNewCharacter', true, true)

  exports.qbx_core:SetPlayerBucket(source, 0)

  lib.print.info(('%s has created a character'):format(GetPlayerName(source)))
  return newData
end)

lib.callback.register('hof-multichar:server:setCharBucket', function(source)
  exports.qbx_core:SetPlayerBucket(source, source)
  assert(GetPlayerRoutingBucket(source) == source, 'Multicharacter bucket not set.')
end)

RegisterNetEvent('hof-multichar:server:deleteCharacter', function(citizenId)
  local src = source
  local ownsCharacter, reason = playerOwnsCharacter(src, citizenId)

  if not ownsCharacter then
    if reason == 'invalid' then
      exports.qbx_core:Notify(src, 'Invalid character selected', 'error')
    elseif reason == 'missingIdentifier' then
      lib.print.error(('Player %s (%s) attempted to delete %s without identifiers.'):format(GetPlayerName(src) or 'unknown', src, citizenId or 'N/A'))
      exports.qbx_core:Notify(src, 'Unable to verify your identifiers', 'error')
    elseif reason == 'notFound' then
      exports.qbx_core:Notify(src, 'Character not found', 'error')
    else
      lib.print.warn(('Player %s (%s) attempted to delete character %s they do not own.'):format(GetPlayerName(src) or 'unknown', src, citizenId or 'N/A'))
      exports.qbx_core:Notify(src, 'You cannot delete a character you do not own', 'error')
    end
    return
  end

  local success = exports.qbx_core:DeleteCharacter(citizenId)
  if success == false then
    exports.qbx_core:Notify(src, 'Failed to delete your character, try again later', 'error')
    return
  end

  exports.qbx_core:Notify(src, 'Successfully deleted your character', 'success')
end)
