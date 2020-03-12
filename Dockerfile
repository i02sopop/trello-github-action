From i02sopop/trello-github-action-base:latest

RUN (cd perl-trello-module; \
	git pull; \
	cd ..)

COPY trello.pl /

ENTRYPOINT [ "/trello.pl" ]
