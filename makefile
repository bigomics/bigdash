check: document
	Rscript -e "devtools::check()"

document: packer
	Rscript -e "devtools::document()"

packer: sass
	Rscript -e "packer::bundle_prod()"

sass:
	Rscript dev/sass.R
