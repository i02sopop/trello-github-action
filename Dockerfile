From i02sopop/trello-github-action-base:latest

RUN apt-get update && apt-get install -y git
RUN (cd perl-trello-module;
	git pull;
	cd ..)

COPY trello.pl /

CMD [ "perl", "/trello.pl" ]
