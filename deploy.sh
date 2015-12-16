#!/bin/bash
echo "Deploying site....."
rsync -avhW $HOME/Development/Hakyll/disputationes/_site/* $HOME/Development/Hakyll/marczuo.github.io
cd $HOME/Development/Hakyll/marczuo.github.io
git add -A
git commit -m "Updating site"
git push origin master
echo "All done!"
