FROM python:3.8-slim as image-compile

LABEL maintainer="John Westbrook <jdwestbrook@gmail.com>"
#
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
# Build-time metadata as defined at http://label-schema.org
LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="mytemplate" \
    org.label-schema.description="Example template for RCSB web service" \
    org.label-schema.url="https://github.com/rcsb/py-rcsb_app_template.git" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/rcsb/py-rcsb_app_template.git" \
    org.label-schema.vendor="RCSB" \
    org.label-schema.version=$VERSION \
    org.label-schema.schema-version="1.0"

WORKDIR /app/

# copy requirements file (should include selected versions of uvicorn gunicorn)
COPY ./requirements.txt /app/requirements.txt

# install dependencies
RUN set -eux \
    && apt-get update && apt-get install -y --no-install-recommends build-essential \
    cmake \
    flex \
    bison \
    && pip install  --no-cache-dir --upgrade pip setuptools wheel \
    && pip install  --no-cache-dir -r /app/requirements.txt \
    && rm -rf /root/.cache/pip \
    && apt-get remove --auto-remove -y build-essential cmake && apt-get -y autoremove

COPY ./rcsb /app/rcsb
COPY ./deploy/gunicorn_conf.py /app/gunicorn_conf.py
#
# COPY ./tox.ini /app/tox.ini
# COPY ./setup.py /app/setup.py
# COPY ./setup.cfg /app/setup.cfg
# COPY ./pylintrc /app/pylintrc

COPY ./deploy/launch.sh /app/launch.sh
RUN chmod +x /app/launch.sh
COPY ./entryPoint.sh /app/entryPoint.sh
RUN chmod +x entryPoint.sh

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
EXPOSE 80

# Launch the service
ENTRYPOINT ["/entryPoint.sh"]
CMD ["/app/launch.sh"]