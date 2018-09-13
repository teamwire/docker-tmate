#!/bin/sh

KEYDIR=/etc/tmate-keys

if [ -n "${HOST}" ]; then
  hostopt="-h ${HOST}"
fi

if [ ! -f "${KEYDIR}/ssh_host_rsa_key" ] || [ ! -f "${KEYDIR}/ssh_host_ecdsa_key" ] ; then
	/create_keys.sh
	mv keys/* "$KEYDIR"
	rmdir keys
fi

/message.sh

exec /bin/tmate-slave $hostopt -p ${PORT:-2222} -k "$KEYDIR" 2>&1
