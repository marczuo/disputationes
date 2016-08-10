all: preview

clean: site
	@echo "Cleaning site....."
	./site clean

build: site
	@echo "Building site....."
	./site build

site: site.hs
	ghc --make -threaded site.hs

deploy: clean build
	@echo "Deploying site....."
	git add -A
	git commit -m "Updating site"
	rsync -avhW ./_site/* ../marczuo.github.io
	cd ../marczuo.github.io
	git add -A
	git commit -m "Updating site"

push: deploy
	@echo "Pushing to Github server....."

preview: clean build
	@echo "Copying site to http server directory..."
	rsync -ahW ./_site/* /srv/http
