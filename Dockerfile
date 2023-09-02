#Here we will define the steps that docker need in order to build our image
#First step is to define the name of the image, that we are gonna using so that is the BASE IMAGE that will gonna pull from DOCKERHUB, that we gonna build on top of to add the dependencies that we need in our project 
#python is the name of the image, 3.9-alpine3.13 is the tag which we will be using
FROM python:3.9-alpine3.13
LABEL maintainer="piyush"

#Below command tells Python that you don't want to Buffer the output, The OUTPUT from python will be printed directly to the console, which prevents any delay
ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
#workdir is the working dir and its the default directory  from where the commands to be run from when we run commands on our Docker Image
WORKDIR /app
#We want to expose PORT 8000 from our container to our local machine when we run the container, this allows us to access that PORT on the container that's running from our image
EXPOSE 8000

ARG DEV=false
#Below runs a command on the Alpine Image that we are using
#apk add --update --no-cache postgresql-client && \ ---> this is the client package that we going to need to install inside our ALPINE image in order for dhjango db adaptor to connect to postgres
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \       
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

#This will update the environment Variable inside the image, we are updating the path-environment variable
#PATH is the environment variable that is automatically created on linux OS systems
ENV PATH="/py/bin:$PATH"

USER django-user
