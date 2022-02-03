# SPDX-License-Identifier: AGPL-3.0-or-later
# Copyright (C) Enrico Weigelt, metux IT consult <info@metux.net>

. /opt/zimbra/libexec/zm-util-base.sh

[ "$ZM_LDAP_DATADIR"        ] || ZM_LDAP_DATADIR="$ZIMBRA_ROOT/data/ldap"
[ "$ZM_LDAP_CONFIG_DB"      ] || ZM_LDAP_CONFIG_DB="$ZM_LDAP_DATADIR/config"
[ "$ZM_LDAP_USER"           ] || ZM_LDAP_USER="zimbra"
[ "$ZM_LDAP_GROUP"          ] || ZM_LDAP_GROUP="zimbra"
[ "$ZM_LDAP_BIND"           ] || ZM_LDAP_BIND="ldapi:/// ldap://:389/"
[ "$ZM_LDAP_LDIF_DIR"       ] || ZM_LDAP_LDIF_DIR="$ZIMBRA_ROOT/common/etc/openldap"
[ "$ZM_LDAP_SCHEMA_DIR"     ] || ZM_LDAP_SCHEMA_DIR="$ZM_LDAP_CONFIG_DB/cn=config/cn=schema"
[ "$ZM_LDAP_LOGLEVEL"       ] || ZM_LDAP_LOGLEVEL="0"
[ "$ZM_LDAP_REPLICATION_DN" ] || ZM_LDAP_REPLICATION_DN="uid=zmreplica,cn=admins,cn=zimbra"
[ "$ZM_LDAP_ZIMBRA_DN"      ] || ZM_LDAP_ZIMBRA_DN="uid=zimbra,cn=admins,cn=zimbra"
[ "$ZM_LDAP_CERT"           ] || ZM_LDAP_CERT="$ZM_CONFDIR/slapd.crt"
[ "$ZM_LDAP_KEY"            ] || ZM_LDAP_KEY="$ZM_CONFDIR/slapd.key"

ZM_LDAP_EXTRA_SCHEMA="cosine zimbra amavisd core inetorgperson dyngroup opendkim"

zm_start_slapd() {
    $ZM_LDAP_LIBEXECDIR/slapd \
        -l LOCAL0 \
        -u "$ZM_LDAP_USER" \
        -h "$ZM_LDAP_BIND" \
        -F "$ZM_LDAP_CONFIG_DB" \
        -d $ZM_LDAP_LOGLEVEL &
}

zm_ldapadd() {
    $ZM_LDAP_BINDIR/ldapadd -Q -H ldapi:/// -Y EXTERNAL "$@"
    return $?
}

zm_ldapsearch() {
    $ZM_LDAP_BINDIR/ldapsearch -Q -H ldapi:/// -Y EXTERNAL "$@"
    return $?
}

zm_ldapmodify() {
    $ZM_LDAP_BINDIR/ldapmodify -Q -H ldapi:/// -Y EXTERNAL "$@"
    return $?
}

zm_check_slapd() {
    if zm_ldapsearch -b 'cn=config' '(objectclass=olcGlobal)' olcConfigDir 2>/dev/null | \
        grep "olcConfigDir: $ZM_LDAP_CONFIG_DB" >/dev/null; then
        return 0
    else
        return 1
    fi
}

zm_wait_for_slapd() {
    for i in 1 2 3 4 5 ; do
        if zm_check_slapd ; then
            return 0
        else
            sleep 1
        fi
    done
    zm_log_err "cant reach slapd"
    return 1
}

zm_ldap_start_wait() {
    if ! zm_start_slapd ; then
        zm_log_err "failed starting slapd"
        return 1
    fi

    if ! zm_wait_for_slapd ; then
        zm_log_err "failed reaching slapd"
        return 2
    fi

    return 0
}

zm_ldap_init() {
    mkdir -p $ZM_LDAP_DATADIR/state/run \
             $ZM_LDAP_DATADIR/mdb/db \
             $ZM_LDAP_DATADIR/accesslog/db \
             $ZM_LDAP_DATADIR/config

    if [ ! -f $ZM_LDAP_CONFIG_DB/cn=config.ldif ]; then
        zm_log_info "echo need to create ldap config dir"
        cp -R $ZIMBRA_ROOT/common/etc/openldap/config/* $ZM_LDAP_CONFIG_DB
        mkdir -p "$ZM_LDAP_SCHEMA_DIR"

        for i in $ZM_LDAP_EXTRA_SCHEMA ; do
            zm_log_info "installing schema: $i"
            cat $ZIMBRA_ROOT/common/etc/openldap/schema/$i.ldif \
                | sed -E 's~^(dn: cn=.*),cn=schema,cn=config$~\1~' \
                > "$ZM_LDAP_SCHEMA_DIR/cn=$i.ldif"
        done
    fi

    zm_chown "$ZM_LDAP_DATADIR"
}

zm_ldap_load_ldif() {
    if zm_ldapadd < $1 ; then
        zm_log_info "$0: loaded ldif: $1"
        return 0
    else
        zm_log_err "failed loading ldif: $1"
        return 1
    fi
}

zm_ldap_check_obj_oc() {
    local basedn="$1"
    local oc="$2"

    zm_ldapsearch -b "$basedn" "(objectclass=$oc)" dn 2>/dev/null | \
        grep "dn: $basedn" >/dev/null
    return $?
}

zm_ldap_load_objdata() {
    local name="$1"
    local basedn="$2"
    local oc="$3"
    local fn="$4"

    if zm_ldap_check_obj_oc "$basedn" "$oc" >/dev/null; then
        zm_log_info "$name object already loaded"
        return 0
    fi

    zm_log_info "loading $name object"
    zm_ldap_load_ldif "$ZM_LDAP_LDIF_DIR/$fn.ldif"
    return $?
}

zm_ldap_load_initdata() {
    local replpass="$1"
    local servername="$2"
    zm_ldap_load_objdata 'root'                'cn=zimbra'                           'organizationalRole' zimbra
    zm_ldap_load_objdata 'default cos'         'cn=default,cn=cos,cn=zimbra'         'zimbraCOS'          zimbra_defaultcos
    zm_ldap_load_objdata 'default externalcos' 'cn=defaultExternal,cn=cos,cn=zimbra' 'zimbraCOS'          zimbra_defaultexternalcos
    zm_log_info "now setting replication password $ZM_LDAP_REPLICATION_DN $replpass"
    zm_ldap_setpass "$ZM_LDAP_REPLICATION_DN" "$replpass"
}

zm_ldap_setpass() {
    local user="$1"
    local pass="$2"
    local hashed=`$ZIMBRA_ROOT/common/sbin/slappasswd -s $pass`

    if [ ! "$user" ]; then
        zm_log_err "$0: missing username"
        return 1
    fi

    if [ ! "$pass" ]; then
        zm_log_info "$0: no password given for $user - skipping"
    fi

    (
        echo "dn: $user"
        echo "changetype: modify"
        echo "replace: userPassword"
        echo "userPassword: $hashed"
    ) | zm_ldapmodify
    return $?
}

zm_ldap_set_globalconf() {
    local attr="$1"
    local val="$2"

    if [ ! "$val" ]; then
        zm_log_info "removing global config: $attr"
        (
            echo "dn: cn=config,cn=zimbra"
            echo "changetype: modify"
            echo "delete: $attr"
        ) | zm_ldapmodify
    else
        zm_log_info "setting global config: $attr = $val"
        (
            echo "dn: cn=config,cn=zimbra"
            echo "changetype: modify"
            echo "replace: $attr"
            echo "$attr: $val"
        ) | zm_ldapmodify
    fi
}

zm_ldap_set_serverid() {
    local server_id="$1"

    if [ ! "$server_id" ]; then
        zm_log_info "no server id given"
        return 0
    fi
    zm_log_info "serverId: $server_id"
    (
        echo "dn: cn=config"
        echo "changetype: modify"
        echo "replace: olcServerID"
        echo "olcServerID: $server_id"
    ) | zm_ldapmodify
    return $?
}

zm_ldap_find_dn() {
    zm_ldapsearch -LLL "$@" dn | sed -e 's~^dn: ~~; /^[[:space:]]*$/d'
    return $?
}

zm_ldap_accesslog_dn() {
    zm_ldap_find_dn -b "cn=config" "(olcSuffix=cn=accesslog)"
    return $?
}

zm_ldap_maindb_dn() {
    zm_ldap_find_dn -b "cn=config" "(olcSuffix=)"
    return $?
}

zm_configure_mmr() {
    local rid=1
    local base=`zm_ldap_maindb_dn`
    local myself="$1"
    local bindpw="$2"

    shift
    shift
    zm_ldap_setpass "$ZM_LDAP_REPLICATION_DN" "$bindpw"

    # fixme: only enable mmr when more than one node
    if [ ! "$2" ]; then
        zm_log_info "only one node. mmr disabled"
        return 0
    fi

    (
        echo "dn: $base"
        echo "changetype: modify"
        echo "replace: olcSyncrepl"
        while [ "$1" ]; do
            hn="$1"
            shift
            zm_log_info "master: $hn"
            local mmrURI="ldap://$hn:389"
            if [ "$hn" != "$myself" ]; then
                echo "olcSyncrepl: rid=$rid provider=\"$mmrURI\" bindmethod=simple timeout=0 network-timeout=0 binddn=\"$ZM_LDAP_REPLICATION_DN\" credentials=\"$bindpw\" $tlsforce filter=\"(objectclass=*)\" searchbase=\"\" logfilter=\"(&(objectClass=auditWriteObject)(reqResult=0))\" logbase=cn=accesslog scope=sub schemachecking=off type=refreshAndPersist retry=\"60 +\" syncdata=accesslog tls_cacertdir=$ZM_CA_DIR keepalive=240:10:30"
                rid=$((rid+1))
            fi
        done
        echo ""
        # note: this has to be done *after* the syncrepl records are written
        echo "dn: $base"
        echo "changetype: modify"
        echo "replace: olcMirrorMode"
        echo "olcMirrorMode: TRUE"
    ) | zm_ldapmodify
}

zm_ldap_install_ca() {
    mkdir -p "$ZM_CA_DIR"
    cp "$@" "$ZM_CA_DIR"
    zm_chown "$ZM_CA_DIR"
}

zm_ldap_install_keys() {
    local cert="$1"
    local key="$2"

    mkdir -p "$ZM_CONFDIR"
    cp "$cert" "$ZM_LDAP_CERT"
    cp "$key"  "$ZM_LDAP_KEY"
    zm_chown "$ZM_LDAP_CERT" "$ZM_LDAP_KEY"
}

zm_ldap_createserver() {
    local nodename="$1"
    local uuid=`uuid`

    # FIXME: should we read out globalconfig's zimbraServerExtraObjectClass ?
    zm_log_info "creating server entry"
    (
        echo "dn: cn=$nodename,cn=servers,cn=zimbra"
        echo "changetype: add"
        echo "objectClass: zimbraServer"
        echo "cn: $nodename"
        echo "zimbraId: $uuid"
    ) | zm_ldapmodify

    zm_log_info "updating server entry"
    (
        echo "dn: cn=$nodename,cn=servers,cn=zimbra"
        echo "changetype: modify"
        echo "add: zimbraServiceInstalled"
        echo "zimbraServiceInstalled: ldap"
        echo "-"
        echo "add: zimbraServiceEnabled"
        echo "zimbraServiceEnabled: ldap"
    ) | zm_ldapmodify
}
