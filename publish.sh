#!/usr/bin/env bash

[ -f .env ] && [ -z $AUTOENV ] && source .env

GH_USER=${GH_USER:-`whoami`}
GH_SECRET=${GH_SECRET:-`cat ~/.ghtoken`}
GH_REPO=${GH_REPO:-`basename $(pwd)`}
GH_TARGET=${GH_TARGET:-"master"}
GH_HOST=${GH_HOST:-"uploads.github.com"}
GH_ENDPOINT="repos/${GH_USER}/${GH_REPO}/releases"
USE_TLS=${USE_TLS:-`true`}
VERSION=$(date "+%s")
ASSETS_PATH=./build
ASSETS_EXT=tgz
ASSETS_RELEASE=${GH_REPO}.${VERSION}.${ASSETS_EXT}

[ -d $ASSETS_PATH ] || mkdir $ASSETS_PATH

docker save alpine:latest | gzip > $ASSETS_PATH/${ASSETS_RELEASE}

git add -u
git commit -m "(feat) Nightly release - $VERSION"
git push

DATA="{ \
  \"tag_name\": \"v$VERSION\", \
  \"target_commitish\": \"$GH_TARGET\", \
  \"name\": \"v$VERSION\", \
  \"body\": \"new nightly version $VERSION\", \
  \"draft\": false, \
  \"prerelease\": false }"

res=`curl -X POST \
	--user "$GH_USER:$GH_SECRET" \
	-d "${DATA}" \
	https://api.github.com/${GH_ENDPOINT}`

echo "Create release result: ${res}"
rel_id=`echo ${res} | jq -r '.id'`

curl -X POST \
	--user "$GH_USER:$GH_SECRET" \
 	--header 'Content-Type: text/javascript ' \
	--upload-file "${ASSETS_PATH}/${ASSETS_RELEASE}" \
	https://${GH_HOST}/${GH_ENDPOINT}/${rel_id}/assets?name=${ASSETS_RELEASE}
