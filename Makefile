##### Makefile for building ffmpeg
FFSRC=$(shell pwd)/sources/
FFBUILD=$(shell pwd)/builds/
FFBIN=$(shell pwd)/bin/
FFVERSION=4.1

FFMPEG_OPTIONS:=--prefix="$(FFBUILD)" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$(FFBUILD)/include" \
  --extra-ldflags="-L$(FFBUILD)/lib" \
  --extra-libs=-lpthread \
  --extra-libs=-lm \
  --bindir="$(FFBIN)"

FFMPEG_OPTIONS += --enable-gpl
FFMPEG_OPTIONS += --enable-libfreetype
FFMPEG_OPTIONS += --enable-libfontconfig
FFMPEG_OPTIONS += --enable-libmp3lame 
FFMPEG_OPTIONS += --enable-libopus 
FFMPEG_OPTIONS += --enable-libvorbis 
FFMPEG_OPTIONS += --enable-libvpx 
FFMPEG_OPTIONS += --enable-libx264 
FFMPEG_OPTIONS += --enable-libx265 
FFMPEG_OPTIONS += --enable-libfdk-aac
FFMPEG_OPTIONS += --enable-cuda 
FFMPEG_OPTIONS += --enable-cuvid 
FFMPEG_OPTIONS += --enable-nvenc 
FFMPEG_OPTIONS += --enable-libnpp
FFMPEG_OPTIONS += --enable-static
FFMPEG_OPTIONS += --disable-shared
FFMPEG_OPTIONS += --enable-nonfree
FFMPEG_OPTIONS += --extra-cflags=-I/usr/local/cuda/include --extra-ldflags=-L/usr/local/cuda/lib64
#FFMPEG_OPTIONS += --enable-libmfx 
CROSS_HOST = --host=aarch64-linux-gnu
export PATH:=$(FFBIN):$(PATH)

help:
	@echo "make prepare"
	@echo "make build"
initialize:
	@mkdir -p $(FFSRC) $(FFBIN) $(FFBUILD)
prepare: initialize nasm yasm libx264 libx265 libfdk_aac libmp3lame libopus libogg libvorbis libvpx nv-codec-headers


$(FFSRC)/nasm-2.13.03.tar.gz:
	@wget https://www.nasm.us/pub/nasm/releasebuilds/2.13.03/nasm-2.13.03.tar.gz -O $@
$(FFSRC)/nasm-2.13.03: $(FFSRC)/nasm-2.13.03.tar.gz
	@tar zxf  $< -C $(FFSRC)
nasm: $(FFSRC)/nasm-2.13.03
	@echo "Building $@ ..."
	@cd $< && ./autogen.sh && ./configure --prefix="$(FFBUILD)" --bindir="$(FFBIN)" && make && make install

$(FFSRC)/yasm-1.3.0.tar.gz:
	@wget http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz -O $@
$(FFSRC)/yasm-1.3.0: $(FFSRC)/yasm-1.3.0.tar.gz
	@tar zxf  $< -C $(FFSRC)
yasm: $(FFSRC)/yasm-1.3.0 
	@echo "Building $@ ..."
	
	@cd $< && ./configure --prefix="$(FFBUILD)" --bindir="$(FFBIN)" && make && make install

$(FFSRC)/libx264:
	@git clone --depth 1 http://git.videolan.org/git/x264 $(FFSRC)/libx264
libx264: $(FFSRC)/libx264
	@echo "Building $@ ..."
	@cd $(FFSRC)/libx264 && PKG_CONFIG_PATH="$(FFBUILD)/lib/pkgconfig" ./configure $(CROSS_HOST) --disable-asm --prefix="$(FFBUILD)" --bindir="$(FFBIN)" --enable-pic --enable-static && make && make install

$(FFSRC)/x265_2.8.tar.gz:
	@wget https://bitbucket.org/multicoreware/x265/downloads/x265_2.8.tar.gz -O $(FFSRC)/x265_2.8.tar.gz
$(FFSRC)/x265_2.8/build/linux: $(FFSRC)/x265_2.8.tar.gz
	@tar zxf $< -C $(FFSRC)
libx265: $(FFSRC)/x265_2.8/build/linux 
	@echo "Building $@ ..."
	@cd $< && cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$(FFBUILD)" -DENABLE_SHARED:bool=off ../../source && make && make install

$(FFSRC)/libfdk_aac:
	@git clone  --depth 1 https://github.com/mstorsjo/fdk-aac $(FFSRC)/libfdk_aac
libfdk_aac: $(FFSRC)/libfdk_aac
	@echo "Building $@ ..."
	@cd $(FFSRC)/libfdk_aac && autoreconf -fiv && ./configure $(CROSS_HOST) --prefix="$(FFBUILD)" --disable-shared && make && make install

$(FFSRC)/lame-3.100.tar.gz:
	@wget http://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz -O $@
$(FFSRC)/lame-3.100: $(FFSRC)/lame-3.100.tar.gz
	@tar zxf $< -C $(FFSRC)
libmp3lame: $(FFSRC)/lame-3.100
	@echo "Building $@ ..."
	@cd $< && ./configure $(CROSS_HOST) --prefix="$(FFBUILD)" --bindir="$(FFBIN)" --disable-shared --enable-nasm && make && make install

$(FFSRC)/opus-1.2.1.tar.gz:
	@wget https://archive.mozilla.org/pub/opus/opus-1.2.1.tar.gz -O $@
$(FFSRC)/opus-1.2.1: $(FFSRC)/opus-1.2.1.tar.gz
	@tar zxf $< -C $(FFSRC)
libopus: $(FFSRC)/opus-1.2.1 
	@echo "Building $@ ..."
	@cd $< && ./configure $(CROSS_HOST) --prefix="$(FFBUILD)" --disable-shared && make && make install

$(FFSRC)/libogg-1.3.3.tar.gz:
	@wget http://downloads.xiph.org/releases/ogg/libogg-1.3.3.tar.gz -O $@
$(FFSRC)/libogg-1.3.3: $(FFSRC)/libogg-1.3.3.tar.gz
	@tar zxf $< -C $(FFSRC)
libogg: $(FFSRC)/libogg-1.3.3
	@echo "Building $@ ..."
	@cd $< && ./configure $(CROSS_HOST) --prefix="$(FFBUILD)" --disable-shared && make && make install

$(FFSRC)/libvorbis-1.3.5.tar.gz:
	@wget http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.5.tar.gz -O $@
$(FFSRC)/libvorbis-1.3.5: $(FFSRC)/libvorbis-1.3.5.tar.gz
	@tar zxf $< -C $(FFSRC)
libvorbis: $(FFSRC)/libvorbis-1.3.5
	@echo "Building $@ ..."
	@cd $< && ./configure $(CROSS_HOST) --prefix="$(FFBUILD)" --with-ogg="$(FFBUILD)" --disable-shared && make && make install

$(FFSRC)/libvpx:
	@git clone --depth 1 https://github.com/webmproject/libvpx.git $@
libvpx: $(FFSRC)/libvpx
	@echo "Building $@ ..."
	@cd $< && ./configure $(CROSS_HOST) --prefix="$(FFBUILD)" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm && make && make install

$(FFSRC)/nv-codec-headers:
	@git clone --depth 1 https://git.videolan.org/git/ffmpeg/nv-codec-headers.git $@
nv-codec-headers: $(FFSRC)/nv-codec-headers
	@cd $< && make install PREFIX="$(FFBUILD)"

$(FFSRC)/ffmpeg-$(FFVERSION).tar.bz2:
	@wget https://ffmpeg.org/releases/ffmpeg-$(FFVERSION).tar.bz2 -O $@

$(FFSRC)/ffmpeg-$(FFVERSION): $(FFSRC)/ffmpeg-$(FFVERSION).tar.bz2
	@tar jxf $< -C $(FFSRC)

ffmpeg: $(FFSRC)/ffmpeg-$(FFVERSION)
	@echo "Building $@ ..."
	@cd $< && PKG_CONFIG_PATH="$(FFBUILD)/lib/pkgconfig" ./configure  $(CROSS_HOST) $(FFMPEG_OPTIONS) && make && make install && hash -r

ffmpeg-clean:
	-@make -C $(FFSRC)/ffmpeg-$(FFVERSION) clean

clean: ffmpeg-clean

dist-clean: 
	-@rm -rf $(FFBUILD) $(FFBIN)
	
