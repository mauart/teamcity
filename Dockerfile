# Builds Angular App
FROM node:8 as ngbuild

MAINTAINER Lou Sacco <lsacco@illumina.com>

COPY package*.json ./

## Storing node modules on a separate layer will prevent unnecessary npm installs at each build
RUN npm install --silent && mkdir /ng-app && cp -R ./node_modules ./ng-app

WORKDIR /ng-app
COPY . .

#ARG configuration=prod

## Build the angular app in production mode and store the artifacts in dist folder
RUN $(npm bin)/ng build

# Builds a Docker to deliver dist/
FROM nginx

## Copy our default nginx config
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

## Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

## From ‘ngbuild’ stage copy over the artifacts in dist folder to default nginx public folder
COPY --from=ngbuild /ng-app/dist /usr/share/nginx/html

CMD ["nginx", "-g", "daemon off;"]
