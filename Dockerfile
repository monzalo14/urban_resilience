FROM pytorch/pytorch

MAINTAINER Mónica Zamudio López <monzalo14@gmail.com>

ENV REFRESHED_AT 2022-01-31

RUN apt-get update; \
	apt-get  -y update -yq && \
	apt-get  -y install build-essential wget

ADD requirements.txt /tmp/requirements.txt

RUN pip install -r /tmp/requirements.txt

ADD urban_resilience /urban_resilience

CMD [ "/bin/sh", "-c", "python /urban_resilience/models/modelo_prueba.py"]
