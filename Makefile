default: preview

clean: site
	@echo "Cleaning site....."
	./site clean

clean-all: clean
	@echo "Purging binary files..."
	rm -f site site.o site.hi

build: site
	@echo "Building site....."
	./site build

site: site.hs
	stack ghc -- --make -threaded site.hs

deploy: build
	@echo "Deploying site....."
	rsync -ahW --delete ./_site/* ../marczuo.github.io
	git -C ../marczuo.github.io add -A
	git -C ../marczuo.github.io diff-index --quiet HEAD ||\
		git -C ../marczuo.github.io commit -m "Updating site"

commit:
	git add -A
	git diff-index --quiet HEAD || git commit -m "Updating site"

push: deploy commit
	@echo "Pushing to Github server....."
	git push origin master
	git -C ../marczuo.github.io push origin master

preview: build
	@echo "Copying site to http server directory..."
	rsync -ahW --delete ./_site/* /srv/http
