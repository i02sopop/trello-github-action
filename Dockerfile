From perl:latest

RUN apt-get update && apt-get install -y jq
RUN cpan -i JSON Data::Dumper JSON WWW::Trello::Lite

COPY trello.pl /

CMD [ "perl", "/trello.pl" ]
