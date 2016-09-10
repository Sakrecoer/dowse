#!/usr/bin/env zsh

R=`pwd`
R=${R%/*}
[[ -r $R/src ]] || {
    print "error: compile.sh must be run from the source base dir"
    return 1
}

source $R/zuper/zuper
source $R/zuper/zuper.init

PREFIX=${PREFIX:-/usr/local/dowse}
CFLAGS="-Wall -fPIC -fPIE -Os"
LDFLAGS="-fPIC -fPIE -pie"


[[ -x $R/build/bin/$1 ]] && {
	act "$1 found in $R/build/bin/$1"
	act "delete it from build/bin to force recompilation"
	return 0 }

notice "Compiling $1"

case $1 in
    seccrond)
        pushd $R/src/seccrond
        CFLAGS="$CFLAGS" make
		install -s -p seccrond $R/build/bin
        popd
        ;;

    webdis)
        pushd $R/src/webdis
        make
        install -s -p webdis $R/build/bin
        popd
        ;;

	# first kore, then webui (which is built with kore)
    kore)
        [[ -x $R/build/kore ]] || {
            pushd $R/src/kore
            make NOTLS=1 DEBUG=1
            popd
        }
        ;;
    webui)
        pushd $R/src/webui
		notice "Generating WebUI configuration"
		act "chroot: $HOME/.dowse"
		act "uid:    $USER"
		cat <<EOF > conf/webui.conf
chroot    $HOME/.dowse
runas     $USER
EOF
		cat conf/webui.conf.dist >> conf/webui.conf
        $R/src/kore/kore build
		install -s -p webui $R/build/bin
        popd
        ;;

    netdata)
        [[ -x $R/build/netdata ]] || {
            pushd $R/src/netdata
            ./autogen.sh
            CFLAGS="$CFLAGS" \
                  ./configure --prefix=${PREFIX}/netdata \
                  --datarootdir=${PREFIX}/netdata \
                  --with-webdir=${PREFIX}/netdata \
                  --localstatedir=$HOME/.dowse \
                  --sysconfdir=/etc/dowse &&
                make &&
                install -s -p src/netdata $R/build/bin
            popd

        }
        ;;
    netdiscover)
        [[ -x $R/build/netdiscover ]] || {
            pushd $R/src/netdiscover
			autoreconf && \
            CFLAGS="$CFLAGS" ./configure --prefix=${PREFIX} && \
                make && \
                install -s -p src/netdiscover $R/build/bin
            popd
        }
        ;;

    sup)
        pushd $R/src/sup

        # make sure latest config.h is compiled in
        rm -f $R/src/sup/sup.o

        make && install -s -p $R/src/sup/sup $R/build

        popd
        ;;

    dnscrypt-proxy)
        pushd $R/src/dnscrypt-proxy
        ./configure --without-systemd --enable-plugins --prefix=${PREFIX} \
            && \
            make && \
            install -s -p src/proxy/dnscrypt-proxy $R/build/bin
        popd
        ;;

	dnscrypt_dowse.so)
		pushd $R/src/dnscrypt-plugin
		./configure && make && \
			install -s -p .libs/dnscrypt_dowse.so $R/build/bin
		popd
		;;

    pgld)
        pushd $R/src/pgl
        ./configure --without-qt4 --disable-dbus --enable-lowmem \
					--disable-networkmanager \
                    --prefix ${PREFIX}/pgl \
                    --sysconfdir ${HOME}/.dowse/pgl/etc \
                    --with-initddir=${PREFIX}/pgl/init.d \
            && \
            make -C pgld && \
            install -s -p $R/src/pgl/pgld/pgld $R/build/bin
        popd
        ;;

    *)
        act "usage; ./src/compile.sh [ clean ]"
        ;;
esac
