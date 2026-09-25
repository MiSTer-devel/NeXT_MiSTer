// The HPS side of the NeXT core's SCSI/MO windows, for the Verilator
// benches: the bench's SD-slot models hand window transactions to the
// same Main_MiSTer sources that ship (support/next, copied by
// host/sync_main.sh), through these DPI-C functions.
//
//   host_fill(slot, lba, sz)   serve a read: fills the byte buffer
//   host_byte(i)               byte i of the buffer
//   host_put(i, b)             stage byte i of a write
//   host_exec(slot, lba, sz)   a write landed: run the command
//   host_mount_cd(path)        mount a CD image on the CD-ROM slot
//   host_cd_active()           1 when the host serves the CD-ROM slot's data

#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>

#include "support/next/next_scsi.h"
#include "support/next/next_cdrom.h"
#include "support/next/next_mo.h"

static uint8_t hbuf[16384];

extern "C" int host_fill(int slot, int lba, int sz)
{
	uint32_t l = (uint32_t)lba;
	if (sz < 0 || sz > (int)sizeof(hbuf)) return 0;
	memset(hbuf, 0, (size_t)sz);
	if (slot == NEXT_CDROM_SLOT)
	{
		if (l >= NEXT_WIN_BASE) next_scsi_window_fill(l, hbuf, sz);
		else if (next_cdrom_active(slot)) next_cdrom_fill(slot, l, hbuf, sz);
		else return 0;
		return 1;
	}
	if (slot == NEXT_MO_SLOT && l >= NEXT_WIN_BASE)
	{
		next_mo_fill(l, hbuf, sz);
		return 1;
	}
	return 0;
}

extern "C" int host_byte(int i)
{
	if (i < 0 || i >= (int)sizeof(hbuf)) return 0;
	return hbuf[i];
}

extern "C" void host_put(int i, int b)
{
	if (i < 0 || i >= (int)sizeof(hbuf)) return;
	hbuf[i] = (uint8_t)b;
}

extern "C" void host_exec(int slot, int lba, int sz)
{
	uint32_t l = (uint32_t)lba;
	if (sz < 0 || sz > (int)sizeof(hbuf)) return;
	if (slot == NEXT_CDROM_SLOT && l >= NEXT_WIN_BASE) next_cdrom_command(l, hbuf, sz);
	else if (slot == NEXT_MO_SLOT && l >= NEXT_WIN_BASE)
	{
		next_mo_command(l, hbuf, sz);
		if (getenv("HOST_TRACE"))
		{
			uint8_t r[1536];
			next_mo_fill(l, r, 1536);
			printf("HOST mo op %u in %02x %02x %02x %02x .. %02x %02x -> out %02x %02x %02x %02x fail %d count %d\n",
			       (l >> 8) & 0xFF, hbuf[0], hbuf[1], hbuf[2], hbuf[3], hbuf[1294], hbuf[1295],
			       r[0], r[1], r[2], r[3], r[1296], r[1297]);
		}
	}
}

extern "C" int host_mount_cd(const char *path)
{
	fileTYPE f = {};
	int writable = 1;
	if (!FileOpen(&f, path)) return 0;
	int r = next_mount_hook(NEXT_CDROM_SLOT, path, &f, &writable);
	FileClose(&f);
	return r;
}

// A mount without an image file: the CD-ROM slot's mount hook opens the
// image (cue/chd/raw probing), so it gets a zero-filled temporary one.
extern "C" int host_mount_disk(int slot, long long bytes)
{
	fileTYPE f = {};
	int writable = 1;
	f.size = bytes;
	if (slot == NEXT_CDROM_SLOT)
	{
		static char path[256];
		snprintf(path, sizeof(path), "build/host/cd_slot_%lld.img", bytes);
		FILE *fp = fopen(path, "wb");
		if (!fp) return 0;
		if (bytes > 0) { fseeko(fp, (off_t)(bytes - 1), SEEK_SET); fputc(0, fp); }
		fclose(fp);
		if (bytes == 0) { next_unmount(slot); return 1; }
		if (!FileOpen(&f, path)) return 0;
		int r = next_mount_hook(slot, path, &f, &writable);
		FileClose(&f);
		return r;
	}
	return next_mount_hook(slot, "disk", &f, &writable);
}

extern "C" int host_cd_active()
{
	return next_cdrom_active(NEXT_CDROM_SLOT);
}
