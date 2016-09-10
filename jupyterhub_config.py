# jupyterhub_config.py
c = get_config()

import os
pjoin = os.path.join

runtime_dir = os.path.join('/srv/jupyterhub')
#ssl_dir = pjoin(runtime_dir, 'ssl')
#if not os.path.exists(ssl_dir):
#    os.makedirs(ssl_dir)

# https on :8443
c.JupyterHub.port = 80 
c.JupyterHub.allow_origin='*'
#c.JupyterHub.ip='*' 
# c.JupyterHub.ssl_key = pjoin(ssl_dir, 'privkey.pem')
# c.JupyterHub.ssl_cert = pjoin(ssl_dir, 'fullchain.pem')
#c.JupyterHub.ssl_key = '/etc/letsencrypt/live/<host.domain.name>/privkey.pem'
#c.JupyterHub.ssl_cert = '/etc/letsencrypt/live/<host.domain.name>/fullchain.pem'

# put the JupyterHub cookie secret and state db
# in /var/run/jupyterhub
c.JupyterHub.cookie_secret_file = pjoin('/srv/jupyterhub', 'cookie_secret')
c.JupyterHub.db_url = pjoin('/srv/jupyterhub', 'jupyterhub.sqlite')
# or `--db=/path/to/jupyterhub.sqlite` on the command-line

# put the log file in /var/log
c.JupyterHub.log_file = '/var/log/jupyterhub.log'

# use GitHub OAuthenticator for local users

#c.JupyterHub.authenticator_class = 'oauthenticator.LocalGitHubOAuthenticator'
#c.GitHubOAuthenticator.oauth_callback_url = os.environ['OAUTH_CALLBACK_URL']
# create system users that don't exist yet
#c.LocalAuthenticator.create_system_users = True

# specify users and admin
#c.Authenticator.whitelist = {'anna','cs','johnny','irene'}#, 'myself', 'I'}
c.Authenticator.admin_users = {'anna','cs','johnny','irene','jin','anshul'}#)#, 'myself'}

# start single-user notebook servers in ~/assignments,
# with ~/assignments/Welcome.ipynb as the default landing page
# this config could also be put in
# /etc/ipython/ipython_notebook_config.py
c.Spawner.notebook_dir = '~'
#c.Spawner.args = ['--NotebookApp.default_url=/notebooks/Welcome.ipynb']
c.Spawner.args=['--NotebookApp.allow_origin=*']
