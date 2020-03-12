From i02sopop/trello-github-action-base:latest

RUN (cd perl-trello-module; \
	git pull; \
	cd ..)

COPY trello.pl /

RUN (find / -name perl)

CMD [ "perl", "/trello.pl" ]
