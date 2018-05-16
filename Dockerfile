FROM nginx
LABEL maintainer infrastructure@dallasmakerspace.org
COPY src /usr/share/nginx/html
ENV VIRTUAL_HOST demo.communitygrid.dallasmakerspace.org
ENV VIRTUAL_PORT 80
