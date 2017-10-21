.DEFAULT_GOAL := build
GHC=stack ghc --


.PHONY: clean cleanall build commit push deploy

clean: site
	@echo "Cleaning site....."
	./site clean

cleanall: clean
	@echo "Purging binary files..."
	rm -f site site.o site.hi

site: site.hs
	$(GHC) --make -threaded site.hs

build: _site 
_site: site css drafts templates posts $(wildcard *.markdown *.md *.html)
	@echo "Building site....."
	./site build
commit:
	git add -A
	git diff-index --quiet HEAD || git commit -m "Updating site"

push: deploy commit
	@echo "Pushing to Github server....."
	git push origin master
	git -C ../marczuo.github.io push origin master

deploy: _site
	@echo "Deploying site....."
	rsync -ahW --delete ./_site/* ../marczuo.github.io
	git -C ../marczuo.github.io add -A
	git -C ../marczuo.github.io diff-index --quiet HEAD ||\
		git -C ../marczuo.github.io commit -m "Updating site"
