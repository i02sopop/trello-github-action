From docker.pkg.github.com/i02sopop/trello-github-action/base:latest

COPY trello.pl /

CMD [ "perl", "/trello.pl" ]
