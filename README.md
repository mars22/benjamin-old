# Benjamin

*** Beware of little expenses. A small leak will sink a great ship. ***

`Benjamin Franklin`

# AWS
You can redirect the incoming traffic on port 80 to port 4000 with iptables:
iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 4000


# logi
journalctl -xe

#deploy
MIX_ENV=prod mix deps.get
cd assets
  brunch build --production
MIX_ENV=prod mix phx.digest
MIX_ENV=prod mix compile

sudo MIX_ENV=prod PORT=80 elixir --detached -S mix phx.server
