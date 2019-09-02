#!/bin/bash
workdir=/opt/frp
bindir=$workdir/bin
configdir=$workdir/etc
configfile=$workdir/etc/01_configfile
Cline=`cat -n $configfile |grep Client |awk '{print $1}'`
NP=`cat $configfile | wc -l`
NP=$(( $NP + 1 ))

function write_data() {
    for ((k=$1; k<$2; k++))
    do
	cat $3 | sed -n "${k}p" >> $4
    done
}
function write_boot() {
    [[ $1 == "Server" ]] && echo "nohup $bindir/frps -c $configdir/$name.Server >/dev/null 2>&1 & " >> $bindir/frps_start
    [[ $1 == "Client" ]] && echo "nohup $bindir/frpc -c $configdir/$name.Client >/dev/null 2>&1 & " >> $bindir/frpc_start
}
function write_config() {
    for ((i=1; i<10; i++))
    do
	j=$(( $i + 1 ))
	BG=`cat -n $configdir/$1.config | awk -F "{" '{if($2!="") print $1}' | awk '{print $1}' | sed -n "${i}p"`
	END=`cat -n $configdir/$1.config | awk -F "{" '{if($2!="") print $1}' | awk '{{print $1}}' | sed -n "${j}p"`
	name=`cat -n $configdir/$1.config | awk -F "{" '{if($2!="") print $2}' | awk -F "}" '{print $1}' | sed -n "${i}p"`
	[[ $1 == "Server" ]] && echo "Config_Server :$name " && write_boot $1 $name
	[[ $1 == "Client" ]] && echo "Config_Client :$name " && write_boot $1 $name
	BG=$(( $BG + 1 ))
	echo "[common]" > $configdir/$name.$1
	if [[ $BG != '' && $END == '' ]]; then
	    write_data $BG $2 $configdir/$1.config $configdir/$name.$1
	    break
	    echo i=$i j=$j
	fi
	write_data $BG $END $configdir/$1.config $configdir/$name.$1
    done
}
function generate_finalconfig() {
    echo "#!/bin/sh" > $bindir/*_start
    echo "#!/bin/sh
killall frps " > $bindir/frps_start
    echo "#!/bin/sh
killall frpc " > $bindir/frpc_start
    write_config Server $Cline
    write_config Client $NP
    chmod 755 $bindir/frps_start $bindir/frpc_start
    rm -rf $configdir/*.config
    echo "finaish"
}
function generate_midconfig() {
    rm -rf $configdir/*.Server $configdir/*.Client
    write_data 1 $Cline $configfile $configdir/Server.config
    write_data $Cline $NP $configfile $configdir/Client.config
}
generate_midconfig
generate_finalconfig
/opt/frp/bin/frps_start
