FROM jekyll/jekyll:latest as docs

WORKDIR /g
# Copy all docs files to /g.
ADD README.md /g/index.markdown
# Copy Jekyll files to /g.
ADD Gemfile /g/Gemfile
ADD Gemfile.lock /g/Gemfile.lock
ADD _config.yml /g/_config.yml

RUN gem install jekyll bundler

# To use if in RUN, see https://github.com/moby/moby/issues/7281#issuecomment-389440503
# Note that only exists issue like "/bin/sh: 1: [[: not found" for Ubuntu20, no such problem in CentOS7.
SHELL ["/bin/bash", "-c"]

# Setup GEM mirror.
RUN if [[ $GEM_MIRROR != 'no' ]]; then \
      gem sources --add https://mirrors.tuna.tsinghua.edu.cn/rubygems/ \
          --remove https://rubygems.org/; \
      bundle config mirror.https://rubygems.org \
          https://mirrors.tuna.tsinghua.edu.cn/rubygems; \
    fi

RUN gem sources -l && bundle install

# Build md to html by jekyll, remove the first title line to avoid duplicate title.
RUN mkdir _site && chmod 777 _site && \
    bundle exec jekyll build

FROM ubuntu:focal as stable

RUN apt-get update -y && apt-get install -y pandoc

ADD stable /g/stable
ADD srs-server /g/srs-server
WORKDIR /g/stable
RUN pandoc README.md -s -o index.html --metadata title='SRS-HELM'

# Remove all md because it's not needed.
RUN find . -name "*.md" -type f -delete

FROM nginx:stable as dist

COPY --from=docs    /g/_site      /usr/share/nginx/html
COPY --from=stable  /g/stable     /usr/share/nginx/html/stable
COPY --from=stable  /g/stable     /usr/share/nginx/html/srs-server
ADD conf /etc/nginx
