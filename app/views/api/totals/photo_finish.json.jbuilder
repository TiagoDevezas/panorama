json.array! @articles do |article|
  json.source article[0]
  json.count article[1]
  json.first_date article[2]
  json.first_id article[3]
  json.url article[4]
  json.title article[5]
  json.twitter_shares article[6]
  json.facebook_shares article[7]
end