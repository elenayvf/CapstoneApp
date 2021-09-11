# syntax=docker/dockerfile:1

# Install the base requirements for the app.
# This stage is to support development.
FROM python:alpine AS base
WORKDIR /
COPY requirements.txt .
RUN pip install -r requirements.txt

# Clear out the node_modules and create the zip
FROM app-base AS app-zip-creator
RUN rm -rf node_modules && \
    apk add zip && \
    zip -r /app.zip /

# build
FROM node:12-alpine
RUN apk add --no-cache python g++ make
WORKDIR /
COPY . .
RUN yarn install --production
CMD ["node", "src/index.js"]

# Run tests to validate app
FROM node:12-alpine AS app-base
RUN apk add --no-cache python g++ make
WORKDIR /
COPY package.json yarn.lock ./
RUN yarn install
COPY spec ./spec
COPY src ./src
RUN yarn test


