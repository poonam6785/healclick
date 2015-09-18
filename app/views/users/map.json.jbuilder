json.array! @users do |user|
  json.id user.id
  json.latitude user.latitude
  json.longitude user.longitude
end