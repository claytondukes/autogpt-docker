ARG GOTTY_VERSION=v1.5.0

FROM alpine:3.15 AS builder

ARG GOTTY_VERSION

WORKDIR /build

ADD https://github.com/sorenisanerd/gotty/releases/download/${GOTTY_VERSION}/gotty_${GOTTY_VERSION}_linux_arm64.tar.gz gotty-aarch64.tar.gz
ADD https://github.com/sorenisanerd/gotty/releases/download/${GOTTY_VERSION}/gotty_${GOTTY_VERSION}_linux_amd64.tar.gz gotty-x86_64.tar.gz

RUN tar -xzvf "gotty-$(uname -m).tar.gz"
RUN apk update
RUN apk add --no-cache git
RUN git clone -b stable https://github.com/Significant-Gravitas/Auto-GPT.git

##############################

FROM amd64/python:3.11-alpine
#FROM python:3.10-alpine

COPY --chmod=+x --from=builder /build/gotty /bin/gotty

WORKDIR /app

COPY --from=builder /build/Auto-GPT/ /app

RUN apk update && apk add --no-cache git vim curl pkgconfig \
cairo-dev g++ gcc libffi-dev libjpeg-turbo-dev libxml2-dev libxslt-dev \
gstreamer gst-plugins-base gst-plugins-good \
girara-dev gobject-introspection-dev sudo wget curl \
&& addgroup -g 1000 -S auto-gpt && adduser -u 1000 -S -G auto-gpt auto-gpt \
&& pip install --upgrade pip \
&& pip install pycairo PyGObject \
&& python3 -m pip install --no-cache-dir --user -r requirements.txt \
&& chown -R 1000:1000 /app

USER 1000

ENV PINECONE_API_KEY=${PINECONE_API_KEY} \
    PINECONE_ENV=${PINECONE_ENV} \
    OPENAI_API_KEY=${OPENAI_API_KEY} \
    ELEVENLABS_API_KEY=${ELEVENLABS_API_KEY} \
    ELEVENLABS_VOICE_1_ID=${ELEVENLABS_VOICE_1_ID} \
    ELEVENLABS_VOICE_2_ID=${ELEVENLABS_VOICE_2_ID} \
    SMART_LLM_MODEL=${SMART_LLM_MODEL} \
    FAST_LLM_MODEL=${FAST_LLM_MODEL} \
    GOOGLE_API_KEY=${GOOGLE_API_KEY} \
    CUSTOM_SEARCH_ENGINE_ID=${CUSTOM_SEARCH_ENGINE_ID} \
    USE_AZURE=${USE_AZURE} \
    OPENAI_AZURE_API_BASE=${OPENAI_AZURE_API_BASE} \
    OPENAI_AZURE_API_VERSION=${OPENAI_AZURE_API_VERSION} \
    OPENAI_AZURE_DEPLOYMENT_ID=${OPENAI_AZURE_DEPLOYMENT_ID} \
    IMAGE_PROVIDER=${IMAGE_PROVIDER} \
    HUGGINGFACE_API_TOKEN=${HUGGINGFACE_API_TOKEN} \
    USE_MAC_OS_TTS=${USE_MAC_OS_TTS} \
    MEMORY_BACKEND=${MEMORY_BACKEND} \
    REDIS_HOST=${REDIS_HOST} \
    REDIS_PORT=${REDIS_PORT} \
    REDIS_PASSWORD=${REDIS_PASSWORD} \
    WIPE_REDIS_ON_START=${WIPE_REDIS_ON_START} \
    EXECUTE_LOCAL_COMMANDS=${EXECUTE_LOCAL_COMMANDS} \
    COMMAND_LINE_PARAMS=${COMMAND_LINE_PARAMS}

EXPOSE 8080

WORKDIR /app
