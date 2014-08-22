require 'net/https'
require 'json'
require 'time'

http = Net::HTTP.new("api.digitalocean.com", 443)
http.use_ssl = true

res = http.start do
  http.get("/v2/droplets", "Authorization" => "Bearer #{ENV['DIGITALOCEAN_TOKEN']}")
end

droplets = JSON.parse(res.body)['droplets']
droplets.each do |droplet|
  next unless /^itamae-/ =~ droplet['name']
  if Time.now - Time.parse(droplet['created_at']) >= 60 * 60
    puts "destroying #{droplet}..."
    res = http.start do
      http.delete("/v2/droplets/#{droplet['id']}", "Authorization" => "Bearer #{ENV['DIGITALOCEAN_TOKEN']}")
    end
  end
end

