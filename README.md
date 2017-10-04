# Benjamin

*** Beware of little expenses. A small leak will sink a great ship. ***

`Benjamin Franklin`

# HEROKU DEPLOY
git push heroku master

# RUN ANY TASK
heroku run "POOL_SIZE=2 mix hello.task"
# HEROKU MIGRATION
heroku run "POOL_SIZE=2 mix ecto.migrate"

heroku logs # use --tail if you want to tail them
heroku run "POOL_SIZE=2 iex -S mix"
