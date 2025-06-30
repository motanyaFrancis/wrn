###########
# BUILDER #
###########

# pull official base image
FROM python:3.13.3-alpine AS builder

# set work directory
WORKDIR /var/www/wrn

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install dependencies for building
RUN apk update \
    && apk add postgresql-dev gcc python3-dev musl-dev

# RUN apk add pkgconfig
# RUN apk add --no-cache gcc musl-dev mariadb-connector-c-dev
# RUN apk add mariadb-dev mariadb-client  

# lint
RUN pip install --upgrade pip
RUN pip install flake8==3.9.2
COPY . .
# RUN flake8 --ignore=E501,F401 .

# install dependencies
COPY ./requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /var/www/wrn/wheels -r requirements.txt

#########
# FINAL #
#########

# pull official base image
FROM python:3.13.3-alpine
# ARG user
# create directory for the wrnadmin user
RUN mkdir -p /usr/src/wrn/

# create the wrnadmin user
# RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN addgroup -S wrnadmin && adduser -S wrnadmin -G wrnadmin

# create the appropriate directories
ENV APP_HOME=/usr/src/wrn
# RUN mkdir $APP_HOME/wrn
# ENV HOME=$APP_HOME/wrn
# RUN mkdir $APP_HOME
RUN mkdir $APP_HOME/staticfiles
RUN mkdir $APP_HOME/mediafiles

WORKDIR $APP_HOME

# install dependencies
RUN apk update && apk add libpq
COPY --from=builder /var/www/wrn/wheels /wheels
COPY --from=builder /var/www/wrn/requirements.txt .
RUN pip install --no-cache /wheels/*

# copy entrypoint.prod.sh
COPY ./entrypoint.sh .
RUN sed -i 's/\r$//g'  $APP_HOME/entrypoint.sh
RUN chmod +x  $APP_HOME/entrypoint.sh

# copy project
COPY . $APP_HOME

# chown all the files to the app user
RUN chown -R wrnadmin:wrnadmin $APP_HOME

RUN chmod 755 /usr/src/wrn/entrypoint.sh
RUN ["chmod", "+x", "/usr/src/wrn/entrypoint.sh"]
# change to the wrnadmin user
USER wrnadmin
# RUN chmod +x  $APP_HOME/entrypoint.sh
# run entrypoint.prod.sh
ENTRYPOINT ["/usr/src/wrn/entrypoint.sh"]