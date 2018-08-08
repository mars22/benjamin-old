import contextlib

from fabric import api
from fabric.contrib.files import exists

api.env.use_ssh_config = True
api.env.roledefs = {
    'PROD': ['aws'],
}

api.env.project_src = '/home/ubuntu/app/benjamin/'
api.env.git_url = 'git@bitbucket.org:mslowinski/benjamin.git'
api.env.prompts = {
    'Are you sure you want to do this?': 'yes',
}


@api.roles('PROD')
def update():
    with contextlib.nested(
        api.cd('%(project_src)s' % api.env),
    ):
        api.run('git pull')
        api.run('MIX_ENV=prod mix deps.get')
        with contextlib.nested(
            api.cd('%(project_src)s/assets' % api.env),
        ):
          api.run('brunch build --production')

        api.run('MIX_ENV=prod mix compile --force')
        api.run('MIX_ENV=prod mix phx.digest')
        api.sudo('systemctl restart benjamin.service')


@api.roles('PROD')
def migrate():
    with contextlib.nested(
        api.cd('%(project_src)s' % api.env),
    ):
        api.run('MIX_ENV=prod mix ecto.migrate')


@api.roles('PROD')
def rollback():
    with contextlib.nested(
        api.cd('%(project_src)s' % api.env),
    ):
        api.run('MIX_ENV=prod mix ecto.rollback')
