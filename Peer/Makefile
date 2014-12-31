COMPONENT=PeerAppC

# uncomment this for network programming support
# BOOTLOADER=tosboot

#CFLAGS += -DCC2420_DEF_CHANNEL=21
#CFLAGS += -DRF230_DEF_CHANNEL=16
#CFLAGS += -DCC2420_DEF_RFPOWER=4

#DEFAULT_LOCAL_GROUP = 0x1A

# Enable Low Power Listening
#CFLAGS += -DLOW_POWER_LISTENING
#CFLAGS += -DLPL_SLEEP_INTERVAL=512

# disables support for the AM stack, which somewhat reduces code size
# and compresses packet formats.  If you want to use other tinyos
# protocols which are AM-based, you should not include this.
CFLAGS += -DIEEE154FRAMES_ENABLED

# lib6lowpan contains inet_ntop6 and inet_pton6 to process ascii
# representations of IPv6 addresses.  You can remove them to save some
# code if you don't use them
# CFLAGS += -DNO_LIB6LOWPAN_ASCII

################################################################################
### Configure RPL
################################################################################
# you can compile with or without a routing protocol... of course,
# without it, you will only be able to use link-local communication.
PFLAGS += -DRPL_ROUTING -DRPL_STORING_MODE -I$(TINYOS_OS_DIR)/lib/net/rpl
#PFLAGS += -DRPL_OF_MRHOF -DRPL_ROOT_ADDR=1
PFLAGS += -DRPL_OF_0=1
PFLAGS += -DRPL_OF_MRHOF=0


# Set this when you want to use statically assigned addresses. The stack will
# not use DHCP in that case.
PFLAGS += -DIN6_PREFIX=\"fec0::\"

################ CoAP Server ###############################
CFLAGS += -DCOAP_SERVER_ENABLED
# port where server is listening
#CFLAGS += -DCOAP_SERVER_PORT=5683L
#set max uri length
CFLAGS += -DMAX_URI_LENGTH=14

# set PDU size
# default: 127
# XML: >165
# Link resource: 1024
CFLAGS += -DCOAP_MAX_PDU_SIZE=127

# set supported content types
# CFLAGS += -DCOAP_CONTENT_TYPE_PLAIN
#CFLAGS += -DCOAP_CONTENT_TYPE_XML
CFLAGS += -DCOAP_CONTENT_TYPE_BINARY
#CFLAGS += -DCOAP_CONTENT_TYPE_JSON

# disables observe
CFLAGS += -DWITHOUT_OBSERVE

# disables block-wise transfer
CFLAGS += -DWITHOUT_BLOCK

# disables .well-known/core resource
CFLAGS += -DWITHOUT_WELLKNOWN

# don't include textual representation of error code in payload
CFLAGS += -DSHORT_ERROR_RESPONSE

# timeout in milliseconds for sending PreACK
CFLAGS += -DCOAP_PREACK_TIMEOUT=1000

CFLAGS += -I.
CFLAGS += -I..
TINYOS_ROOT_DIR?=/opt/tinyos-main
include $(TINYOS_ROOT_DIR)/Makefile.include
