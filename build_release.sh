#!/bin/bash

BUILD_DIR=$(dirname "$0")/build
mkdir -p $BUILD_DIR
#cd $BUILD_DIR

sum="sha1sum"

export GO111MODULE=on
echo "Setting GO111MODULE to" $GO111MODULE

if ! hash sha1sum 2>/dev/null; then
	if ! hash shasum 2>/dev/null; then
		echo "I can't see 'sha1sum' or 'shasum'"
		echo "Please install one of them!"
		exit
	fi
	sum="shasum"
fi

UPX=false
if hash upx 2>/dev/null; then
	UPX=true
fi

VERSION=`date -u +%Y%m%d`
LDFLAGS="-X main.VERSION=$VERSION -s -w"
GCFLAGS=""

# AMD64 
#OSES=(linux darwin windows freebsd)
OSES=(linux darwin windows)
for os in ${OSES[@]}; do
	suffix=""
	if [ "$os" == "windows" ]
	then
		suffix=".exe"
	fi
	env CGO_ENABLED=0 GOOS=$os GOARCH=amd64 go build -mod=vendor -ldflags "$LDFLAGS" -gcflags "$GCFLAGS" -o $BUILD_DIR/supervisord_${os}_amd64${suffix} 
	if $UPX; then upx -9 $BUILD_DIR/supervisord_${os}_amd64${suffix} ;fi
	tar -zcf $BUILD_DIR/supervisord-${os}-amd64-$VERSION.tar.gz $BUILD_DIR/supervisord_${os}_amd64${suffix} 
	$sum $BUILD_DIR/supervisord-${os}-amd64-$VERSION.tar.gz
done

# 386
OSES=(linux windows)
for os in ${OSES[@]}; do
	suffix=""
	if [ "$os" == "windows" ]
	then
		suffix=".exe"
	fi
	env CGO_ENABLED=0 GOOS=$os GOARCH=386 go build -mod=vendor -ldflags "$LDFLAGS" -gcflags "$GCFLAGS" -o $BUILD_DIR/supervisord_${os}_386${suffix}
	if $UPX; then upx -9 $BUILD_DIR/supervisord_${os}_386${suffix} ;fi
	tar -zcf $BUILD_DIR/supervisord-${os}-386-$VERSION.tar.gz $BUILD_DIR/supervisord_${os}_386${suffix} 
	$sum $BUILD_DIR/supervisord-${os}-386-$VERSION.tar.gz
done

# ARM
ARMS=(5 6 7)
for v in ${ARMS[@]}; do
	env CGO_ENABLED=0 GOOS=linux GOARCH=arm GOARM=$v go build -mod=vendor -ldflags "$LDFLAGS" -gcflags "$GCFLAGS" -o $BUILD_DIR/supervisord_linux_arm$v 
if $UPX; then upx -9 $BUILD_DIR/supervisord_linux_arm$v ;fi
tar -zcf $BUILD_DIR/supervisord-linux-arm$v-$VERSION.tar.gz $BUILD_DIR/supervisord_linux_arm$v 
$sum $BUILD_DIR/supervisord-linux-arm$v-$VERSION.tar.gz
done

# ARM64
OSES=(linux darwin windows)
for os in ${OSES[@]}; do
	suffix=""
	if [ "$os" == "windows" ]
	then
		suffix=".exe"
	fi
	env CGO_ENABLED=0 GOOS=$os GOARCH=arm64 go build -mod=vendor -ldflags "$LDFLAGS" -gcflags "$GCFLAGS" -o $BUILD_DIR/supervisord_${os}_arm64${suffix} 
	if $UPX; then upx -9 $BUILD_DIR/supervisord_${os}_arm64${suffix} ;fi
	tar -zcf $BUILD_DIR/supervisord-${os}-arm64-$VERSION.tar.gz $BUILD_DIR/supervisord_${os}_arm64${suffix} 
	$sum $BUILD_DIR/supervisord-${os}-arm64-$VERSION.tar.gz
done

#MIPS32LE
#env CGO_ENABLED=0 GOOS=linux GOARCH=mipsle GOMIPS=softfloat go build -mod=vendor -ldflags "$LDFLAGS" -gcflags "$GCFLAGS" -o $BUILD_DIR/supervisord_linux_mipsle 
#env CGO_ENABLED=0 GOOS=linux GOARCH=mips GOMIPS=softfloat go build -mod=vendor -ldflags "$LDFLAGS" -gcflags "$GCFLAGS" -o $BUILD_DIR/supervisord_linux_mips 

#if $UPX; then upx -9 $BUILD_DIR/supervisord_linux_mips* ;fi
#tar -zcf $BUILD_DIR/supervisord-linux-mipsle-$VERSION.tar.gz $BUILD_DIR/supervisord_linux_mipsle 
#tar -zcf $BUILD_DIR/supervisord-linux-mips-$VERSION.tar.gz $BUILD_DIR/supervisord_linux_mips 
#$sum $BUILD_DIR/supervisord-linux-mipsle-$VERSION.tar.gz
#$sum $BUILD_DIR/supervisord-linux-mips-$VERSION.tar.gz
