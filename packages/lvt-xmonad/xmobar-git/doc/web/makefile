index.src = ../../readme.md
index = readme.md
releases = ../../changelog.md
css = xmobar.css
images = ../screenshots/xmobar-bottom.png ../screenshots/xmobar-top.png \
         ../screenshots/xmobar-exwm.png
remote = root@xmobar.org:/var/www/xmobar.org/
htmls = index.html releases.html
title = % xmobar - a minimalistic status bar

default: index.html

$(index): $(index.src)
	@tail -n+3 $(index.src) | sed "1s/^/$(title)\n/" > $(index)

index.html: changelog.html $(index) $(css)
	pandoc -f markdown -t html -c $(css) -N -s \
               $(index) > index.html

changelog.html: $(releases) $(css)
	pandoc -f markdown -t html -c $(css) -s \
               $(releases) > changelog.html

upload-images:
	rsync -zav $(images) $(remote)/doc/screenshots

upload-changes: changelog.html
	scp changelog.html $(remote)

upload-pages: $(htmls)
	scp $(htmls) $(css) $(remote)

upload: upload-images upload-pages

clean:
	rm -f $(htmls) $(index) *.png
