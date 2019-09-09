# jupyterhub_config.py                                                                                                                                                
c = get_config()
import os
pjoin = os.path.join
runtime_dir = os.path.join('/srv/jupyterhub')
c.JupyterHub.port = 8443
c.JupyterHub.cookie_secret_file = pjoin('/srv/jupyterhub', 'cookie_secret')
c.JupyterHub.db_url = pjoin('/srv/jupyterhub', 'jupyterhub.sqlite')
c.Spawner.notebook_dir = '~'
c.Spawner.args=['--NotebookApp.allow_origin=*','--NotebookApp.allow_remote_access=True']
