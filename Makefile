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
	git commit -m "Updating site"
	rsync -avhW ./_site/* ../marczuo.github.io
	cd ../marczuo.github.io
	git add -A
	git commit -m "Updating site"

push: deploy
	@echo "Pushing to Github server....."
	git push origin master
	cd ../marczuo.github.io
	git push origin master

preview: build
	@echo "Copying site to http server directory..."
	rsync -ahW ./_site/* /srv/http
