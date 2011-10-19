/*
 * serial_demux.h
 * Copyright 2008-2010, Eric B. Decker
 * Mam-Mark Project
 */

#ifndef __SERIAL_DEMUX_H__
#define __SERIAL_DEMUX_H__


#define SERIAL_DEMUX_RESOURCE "Serial_Demux_Resource"

enum {
  SERIAL_OWNER_NULL		=      unique(SERIAL_DEMUX_RESOURCE),
  SERIAL_OWNER_SERIAL		=      unique(SERIAL_DEMUX_RESOURCE),
  SERIAL_OWNER_GPS		=      unique(SERIAL_DEMUX_RESOURCE),
  SERIAL_OWNER_NUM_CLIENTS	= uniqueCount(SERIAL_DEMUX_RESOURCE),
};

#endif  /* __SERIAL_DEMUX_H__ */
