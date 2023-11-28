FROM node:21
COPY ./ /todo-list
WORKDIR /todo-list
RUN npm install && npm run build

FROM nginx
RUN mkdir /todo-list
COPY --from=0 /todo-list/dist /todo-list
COPY nginx.conf /etc/nginx/nginx.conf