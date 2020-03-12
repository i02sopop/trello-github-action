From i02sopop/trello-github-action-base:latest

RUN (cd perl-trello-module; \
	git pull; \
	perl Build.PL; \
	./Build install; \
	cd ..)

COPY trello.pl /

ENTRYPOINT [ "/trello.pl" ]
