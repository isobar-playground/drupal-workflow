# Do the magic with permissions one more time.
sudo setfacl -dR -m u:$(whoami):rwX -m u:1000:rwX .
sudo setfacl -R -m u:$(whoami):rwX -m u:1000:rwX  .

# Recreate the docker environment.
make up

# Clear cache for new environment.
make drush cr

# Get a one-time login URL.
make drush uli

# This is the last time, I prommise ✨
sudo setfacl -dR -m u:$(whoami):rwX -m u:1000:rwX .
sudo setfacl -R -m u:$(whoami):rwX -m u:1000:rwX  .
