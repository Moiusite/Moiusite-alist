appName="alist"
builtAt="$(date +'%F %T %z')"
goVersion=$(go version | sed 's/go version //')
gitAuthor="Xhofe <i@nn.ci>"
gitCommit=$(git log --pretty=format:"%h" -1)
version=$(wget -qO- -t1 -T2 "https://api.github.com/repos/Moiusite/Moiusite-alist/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g')
webVersion=$(wget -qO- -t1 -T2 "https://api.github.com/repos/Moiusite/Moiusite-alist-web/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g')

echo "backend version: $version"
echo "frontend version: $webVersion"

ldflags="\
-w -s \
-X 'github.com/alist-org/alist/v3/internal/conf.BuiltAt=$builtAt' \
-X 'github.com/alist-org/alist/v3/internal/conf.GoVersion=$goVersion' \
-X 'github.com/alist-org/alist/v3/internal/conf.GitAuthor=$gitAuthor' \
-X 'github.com/alist-org/alist/v3/internal/conf.GitCommit=$gitCommit' \
-X 'github.com/alist-org/alist/v3/internal/conf.Version=$version' \
-X 'github.com/alist-org/alist/v3/internal/conf.WebVersion=$webVersion' \
"

FetchWebRelease() {
  curl -L https://github.com/Moiusite/Moiusite-alist-web/releases/latest/download/dist.tar.gz -o dist.tar.gz
  tar -zxvf dist.tar.gz
  rm -rf public/dist
  mv -f dist public
  rm -rf dist.tar.gz
}

PrepareBuildDocker() {
  echo "replace github.com/mattn/go-sqlite3 => github.com/leso-kn/go-sqlite3 v0.0.0-20230710125852-03158dc838ed" >>go.mod
  go get gorm.io/driver/sqlite@v1.4.4
  go mod download
}

BuildDocker() {
  PrepareBuildDocker
  go build -o ./bin/alist -ldflags="$ldflags" -tags=jsoniter .
}

if [ "$1" = "release" ]; then
  FetchWebRelease
  if [ "$2" = "docker" ]; then
    BuildDocker
  else
    echo -e "缺乏参数"
  fi
else
  echo -e "参数错误"
fi
