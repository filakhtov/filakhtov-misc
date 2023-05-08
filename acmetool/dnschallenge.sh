#!/bin/bash

MYSQL_HOSTNAME="localhost"
MYSQL_DATABASE="pdns"
MYSQL_USERNAME="pdns"
MYSQL_PASSWORD="pdns"

CERT_FILE_USER="root"
CERT_FILE_GROUP="root"

function _log {
	echo >&2 "$(date) ${@}"
}

function _parse_basedomain {
	local DOMAIN="${1}"
	local BASEDOMAIN=$(echo -n "${DOMAIN}" | awk -F'.' '{print $(NF-1) "." $NF}')

	echo -n "${BASEDOMAIN}"
}

function _fetch_domain_id {
	local BASEDOMAIN="${1}"

	local STATEMENT="SELECT id FROM domains WHERE name='${BASEDOMAIN}'"
	local DOMAINID=$(mysql "${MYSQL_DATABASE}" -h "${MYSQL_HOSTNAME}" -u "${MYSQL_USERNAME}" -p"${MYSQL_PASSWORD}" -ss -e "${STATEMENT}")

	if [ -z "${DOMAINID}" ]; then
		_log "Could not get domain ID from PowerDNS database, invalid base domain!"
		exit 1
	fi

	_log "Found domain in database with ID: ${DOMAINID}"

	echo -n "${DOMAINID}"
}

function deploy_challenge {
	local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"

	# Check arguments
	[ ! -z "${DOMAIN}" ] || { _log 'Missing parameter: DOMAIN ($1)'; exit 1; }
	[ ! -z "${TOKEN_VALUE}" ] || { _log 'Missing parameter: TOKEN_VALUE ($3)'; exit 1; }

	# Get domain ID from database
	local BASEDOMAIN=$(_parse_basedomain "${DOMAIN}")
	local DOMAINID=$(_fetch_domain_id "${BASEDOMAIN}")

	# Output some debug information about the task
	_log "Parsed command line arguments:"
	_log "> Task: Deploying ACME challenge record"
	_log "> Domain: ${DOMAIN}"
	_log "> Base Domain: ${BASEDOMAIN}"
	_log "> Token Code: ${TOKEN_VALUE}"

	# Create new _acme-challenge.<DOMAIN> record
	local STATEMENT="INSERT INTO records (domain_id, name, type, content, ttl) VALUES (${DOMAINID}, '_acme-challenge.${DOMAIN}', 'TXT', '\"${TOKEN_VALUE}\"', 60)"
	mysql "${MYSQL_DATABASE}" -h "${MYSQL_HOSTNAME}" -u "${MYSQL_USERNAME}" -p"${MYSQL_PASSWORD}" -ss -e "${STATEMENT}"
	if [ $? -ne 0 ]; then
		_log "Could not insert new ACME challenge record into PowerDNS database!"
		exit 2
	fi
	_log "Inserted ACME challenge record into PowerDNS database."
}

function clean_challenge {
	local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"

	# Check arguments
	[ ! -z "${DOMAIN}" ] || { _log 'Missing parameter: DOMAIN ($1)'; exit 1; }
	[ ! -z "${TOKEN_VALUE}" ] || { _log 'Missing parameter: TOKEN_VALUE ($3)'; exit 1; }

	# Output some debug information about the task
	_log "Parsed command line arguments:"
	_log "> Task: Cleanup ACME challenge record(s)"
	_log "> Domain: ${DOMAIN}"

	# Delete all old _acme-challenge.<DOMAIN> records
	local STATEMENT="DELETE FROM records WHERE name='_acme-challenge.${DOMAIN}' AND content='\"${TOKEN_VALUE}\"'"
	mysql "${MYSQL_DATABASE}" -h "${MYSQL_HOSTNAME}" -u "${MYSQL_USERNAME}" -p"${MYSQL_PASSWORD}" -ss -e "${STATEMENT}"
	if [ $? -ne 0 ]; then
		_log "Could not delete old ACME challenge records from PowerDNS database!"
		exit 2
	fi
	_log "Deleted all old ACME challenge records from PowerDNS database."
}


if [ $(id -u) -ne 0 ]; then
	_log "This application can only be run as root, exiting..."
	exit 3
fi

EVENT_NAME="$1"
shift

case "$EVENT_NAME" in
  challenge-dns-start)
    deploy_challenge $@
    ;;

  challenge-dns-stop)
    clean_challenge $@
    ;;

  *)
    exit 42
    ;;
esac
