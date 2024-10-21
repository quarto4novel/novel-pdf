install:
	sudo dnf install texlive-novel texlive-libertinus-fonts

install-texlive2024: install
	# See: https://www.tug.org/texlive/quickinstall.html
	pushd /tmp
	wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
	zcat < install-tl-unx.tar.gz | tar xf -
	cd $(find ./install-tl-* -maxdepth 0 -type d)
	sudo perl ./install-tl
	popd
	echo "Ajouter le chemin /usr/local/texlive/2024/bin/x86_64-linux à votre path si ce n'est pas déjà fait"

clean:
	rm -rf out

book: clean
	mkdir -p out
	lualatex --output-directory=out quarto-novel.tex
