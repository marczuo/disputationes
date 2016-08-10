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
	rsync -avhW --delete ./_site/* ../marczuo.github.io
	cd ../marczuo.github.io
	git add -A
	git diff-index --quiet HEAD || git commit -m "Updating site"

commit:
	git add -A
	git diff-index --quiet HEAD || git commit -m "Updating site"

push: deploy commit
	@echo "Pushing to Github server....."
	git push origin master
	cd ../marczuo.github.io
	git push origin master

preview: build
	@echo "Copying site to http server directory..."
	rsync -ahW --delete ./_site/* /srv/http
