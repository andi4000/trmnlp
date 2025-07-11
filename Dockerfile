ARG RUBY_VERSION=3.4.1
FROM ruby:${RUBY_VERSION} AS runner

RUN apt-get update && apt-get install -y --no-install-recommends \
    imagemagick \
    firefox-esr

WORKDIR /app

RUN mkdir -p ./lib/trmnlp/

COPY Gemfile \
    Gemfile.lock \
    trmnl_preview.gemspec \
    ./

COPY lib/trmnlp/version.rb /app/lib/trmnlp/

ENV BUNDLE_PATH=/cache/bundle
RUN --mount=type=cache,id=cached-bundle,target=/cache/bundle <<EOF
set -x
bundle env | head -n 40

du -shc /cache/bundle

bundle install
bundle clean --dry-run

cp -ar /cache/bundle /opt/
ls -lha /opt/bundle
ls -lha /opt/bundle/ruby/3*
EOF

ENV BUNDLE_PATH=/opt/bundle

COPY lib/ /app/lib/
COPY web/ /app/web/
COPY bin/ /app/bin/
COPY templates/ /app/templates/

EXPOSE 4567

ENV BUNDLE_GEMFILE=/app/Gemfile
WORKDIR /plugin
ENTRYPOINT [ "bundle", "exec", "/app/bin/trmnlp" ]
