#!/bin/bash
echo "Deploying site....."
./site clean
./site build
rsync -avhW $HOME/Development/Hakyll/disputationes/_site/* $HOME/Development/Hakyll/marczuo.github.io
cd $HOME/Development/Hakyll/marczuo.github.io
git add -A
git commit -m "Updating site"
echo "All done! Don't forget to run\n\tgit push origin master\nwhen you wish to push to live!"
