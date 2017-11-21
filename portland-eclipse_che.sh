# https://hub.docker.com/r/eclipse/che/
# https://www.eclipse.org/che/docs/setup/getting-started-multi-user/index.html

# Run Container
docker run -it \
  --name=eclipse \
  --restart="unless-stopped" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /vpool/eclipse-che:/data \
  -e CHE_MULTIUSER=true \
  eclipse/che start