# Installs latest version of shinysense.
devtools::install_github('nstrayer/shinysense', ref = 'version_2_dev')

# Installs latest version of keras. 
devtools::install_github('rstudio/keras')

# Make sure you have the python versions of keras/tensorflow installed on your machine.
keras::install_keras()