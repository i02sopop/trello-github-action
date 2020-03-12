From perl:latest

RUN apt-get update && apt-get install -y jq git
RUN cpan -i JSON Data::Dumper Module::Build
RUN (git clone https://github.com/i02sopop/perl-trello-module.git; \
	cd perl-trello-module; \
	ls -a; \
	perl Build.PL; \
	./Build installdeps; \
	./Build install; \
	cd ..)
