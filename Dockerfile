# Adapted from monokrome/wine
FROM ubuntu:14.04.3

MAINTAINER identakid.net <ccssdev@identakid.net>

RUN dpkg --add-architecture i386 && \
    apt-get update -y && \
    apt-get install -y software-properties-common && add-apt-repository -y ppa:ubuntu-wine/ppa && \
    apt-get update -y && \
    apt-get install -y wine1.7 winetricks xvfb && \
    apt-get purge -y software-properties-common && \
    apt-get autoclean -y

# Wget is needed by winetricks
RUN apt-get update && \
    apt-get install wget

# Wine doesn't run well as root, set up a non-root user
RUN useradd -d /home/wix -m -s /bin/bash wix
ENV HOME /home/wix
RUN chown wix:wix /home/wix
ENV WINEPREFIX /home/wix/.wine
ENV WINEARCH win32
USER wix

# Install .NET Framework 4.0
RUN wine wineboot && xvfb-run winetricks --unattended dotnet40 corefonts

# Install WiX
WORKDIR /home/wix
RUN wget -O wix310-binaries.zip 'http://download-codeplex.sec.s-msft.com/Download/Release?ProjectName=wix&DownloadId=1587180&FileTime=131118854877130000&Build=21031' && \
    unzip wix310-binaries.zip && \
    rm -rf wix310-binaries.zip doc sdk

# Allow this container to be run as an executable
# that wraps the Wine envinronment
ENV WINEDEBUG -all
ENV PATH="${PATH}:${HOME}"
CMD ["/bin/bash"]
