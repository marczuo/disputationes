hakyll_home_dir = `cd ..; pwd`

all: preview

clean: site
	@echo "Cleaning site....."
	./site clean

build: site
	@echo "Building site....."
	./site build

site: site.hs
	ghc --make -threaded site.hs

deploy: build
	@echo "Deploying site....."
	git add -A
	git diff-index --quiet HEAD || git commit -m "Updating site"
	rsync -avhW --delete $(hakyll_home_dir)/disputationes/_site/* $(hakyll_home_dir)/marczuo.github.io
	cd $(hakyll_home_dir)/marczuo.github.io
	git add -A
	git diff-index --quiet HEAD || git commit -m "Updating site"

push: deploy
	@echo "Pushing to Github server....."
	git push origin master
	cd $(hakyll_home_dir)/marczuo.github.io
	git push origin master

preview: build
	@echo "Copying site to http server directory..."
	rsync -ahW --delete $(hakyll_home_dir)/disputationes/_site/* /srv/http
