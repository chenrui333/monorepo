# Stage 1: build stage
FROM node:14 as build

WORKDIR /app

COPY ./yarn.lock ./
COPY ./package.json ./
COPY ./tsconfig.json ./

ENV NOYARNPOSTINSTALL=1
# ENV YARN_CACHE_FOLDER /cache/yarn3
#  --production --frozen-lockfile

COPY ./packages ./packages

# install root dependencies
RUN yarn install

RUN yarn workspace @outsrc/template install
RUN yarn workspace @outsrc/template build

# Stage 2: run stage
FROM build as runner

WORKDIR /app
ARG web=packages/web
COPY --from=build app/${web}/package.json ./${web}/
COPY --from=build app/${web}/.next ./${web}/.next
COPY --from=build app/${web}/public ./${web}/public
COPY --from=build app/${web}/node_modules ./${web}/node_modules
COPY --from=build app/package.json ./
COPY --from=build app/node_modules ./node_modules

EXPOSE 3000
CMD ["yarn", "workspace" ,"@outsrc/template", "run", "start"]
