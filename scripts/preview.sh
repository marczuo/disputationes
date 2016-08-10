#!/bin/sh
echo "Copying site to http server directory..."
rsync -ahW $HOME/Development/Hakyll/disputationes/_site/* /srv/http
