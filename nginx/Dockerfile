FROM nginx:1.28-alpine

RUN rm /etc/nginx/conf.d/default.conf
# RUN rm /etc/nginx/conf.d/api.mosongo.co.ke.conf
COPY nginx.conf /etc/nginx/conf.d
# RUN mkdir -p /usr/share/nginx/html/backendAPI
# COPY ./dist /usr/share/nginx/html/backendAPI