FROM dart:2.18

USER root:root

RUN apt update && apt install -y sudo && \
    echo "flutter ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/flutter && \
    chmod 0440 /etc/sudoers.d/flutter && \
    rm -rf /var/lib/apt/lists/* \

USER flutter:flutter

RUN apt update && apt install -y curl git unzip xz-utils zip libglu1-mesa openjdk-17-jdk wget

RUN groupadd android && useradd -d /opt/android-sdk-linux -g android -u 1000 android
COPY tools /opt/tools
COPY licenses /opt/licenses
WORKDIR /opt/android-sdk-linux
RUN /opt/tools/entrypoint.sh built-in
ENV ANDROID_SDK_HOME /opt/android-sdk-linux
ENV ANDROID_SDK_ROOT /opt/android-sdk-linux
ENV ANDROID_HOME /opt/android-sdk-linux
ENV ANDROID_SDK /opt/android-sdk-linux

WORKDIR /home/flutter

ARG flutterVersion=3.3.0

ADD https://api.github.com/repos/flutter/flutter/compare/${flutterVersion}...${flutterVersion} /dev/null

RUN git clone https://github.com/flutter/flutter.git -b ${flutterVersion} flutter-sdk
#need to checkout specific version of flutter
#RUN mkdir /home/flutter/flutter-sdk/bin/cache/dart-sdk/bin/dart
#RUN cp -r /usr/lib/dart /home/flutter/flutter-sdk/bin/cache/dart-sdk/bin/dart

RUN flutter-sdk/bin/flutter precache

RUN flutter-sdk/bin/flutter config --no-analytics

ENV PATH="$PATH:/home/flutter/flutter-sdk/bin"
#ENV PATH="$PATH:/home/flutter/flutter-sdk/bin/cache/dart-sdk/bin"

#RUN flutter doctor


WORKDIR /Home/app

COPY . .

RUN flutter pub get

#RUN flutter build apk

#CMD ["flutter", "build", "apk"]
