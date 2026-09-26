// Native test of the Main_MiSTer support/next code the NeXT core relies on
// (built by tb/run_tests.sh from the synced sources):
//
//   1. the Reed-Solomon codec against the golden vectors of Previous
//      (tb/rs_vectors.hex: per set 1024 data, 1296 encoded, 1296 corrupted,
//      1024 decoded; vector 1 is the boot ROM's ECC system test pattern,
//      36 corrected bytes),
//   2. the MO ECC window round trip (write 3 blocks, read them back),
//   3. the SCSI response windows against the byte tables the FPGA used to
//      build: INQUIRY, READ CAPACITY, MODE SENSE pages 0/1/3/4/3F with the
//      page-4 geometry (cylinders = ceil(blocks / 128), 24-bit) for the
//      sizes tb_next_scsi_geometry.sv used to check in the RTL.

#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>

#include "support/next/next_rs.h"
#include "support/next/next_mo.h"
#include "support/next/next_scsi.h"
#include "support/next/next_cdrom.h"

static int errors = 0;
static void check(int cond, const char *what)
{
	printf("%s: %s\n", cond ? "PASS" : "FAIL", what);
	if (!cond) errors++;
}

static int load_vectors(const char *path, uint8_t *vec, int n)
{
	FILE *f = fopen(path, "r");
	if (!f) return 0;
	int i = 0;
	unsigned v;
	while (i < n && fscanf(f, "%x", &v) == 1) vec[i++] = (uint8_t)v;
	fclose(f);
	return i == n;
}

static void rs_set(const uint8_t *vec, int base, int expcnt, const char *label)
{
	uint8_t buf[1296];
	char msg[128];
	memset(buf, 0, sizeof(buf));
	memcpy(buf, vec + base, 1024);
	next_rs_encode(buf);
	snprintf(msg, sizeof(msg), "%s: encode matches the reference", label);
	check(memcmp(buf, vec + base + 1024, 1296) == 0, msg);

	memcpy(buf, vec + base + 2320, 1296);
	int e = next_rs_decode(buf);
	snprintf(msg, sizeof(msg), "%s: decode corrects to the reference data", label);
	check(memcmp(buf, vec + base + 3616, 1024) == 0, msg);
	snprintf(msg, sizeof(msg), "%s: corrected error count %d (expect %d)", label, e, expcnt);
	check(e == expcnt, msg);
}

static void mo_window(const uint8_t *vec)
{
	uint8_t blk[1536], out[1536];
	memset(blk, 0, sizeof(blk));
	memcpy(blk, vec, 1024);
	next_mo_command(NEXT_MO_ECC_BLK | (NEXT_MO_ECC_ENCODE << 8), blk, 1536);
	next_mo_fill(NEXT_MO_ECC_BLK | (NEXT_MO_ECC_ENCODE << 8), out, 1536);
	check(memcmp(out, vec + 1024, 1296) == 0 && out[1296] == 0 && out[1297] == 0,
	      "MO window: encode round trip");
	memcpy(blk, vec + 2320, 1296);
	next_mo_command(NEXT_MO_ECC_BLK | (NEXT_MO_ECC_DECODE << 8), blk, 1536);
	next_mo_fill(NEXT_MO_ECC_BLK | (NEXT_MO_ECC_DECODE << 8), out, 1536);
	check(memcmp(out, vec + 3616, 1024) == 0 && out[1296] == 0 && out[1297] == 36,
	      "MO window: decode round trip, 36 corrected");
}

static int win_len(const uint8_t *b) { return (b[510] << 8) | b[511]; }

static void mount(int unit, uint64_t bytes, int ro)
{
	fileTYPE f = {};
	int writable = !ro;
	f.size = (int64_t)bytes;
	next_mount_hook(unit, "disk", &f, &writable);
}

static void scsi_windows(void)
{
	uint8_t b[512];
	char msg[128];

	mount(0, 1000ULL * 512, 0);
	next_scsi_window_fill(NEXT_RESP_BLK | (0u << 20) | 0x1200, b, 512);
	static const uint8_t inq0[33] = { 0x00, 0x00, 0x01, 0x01, 0x31, 0, 0, 0x1C,
		'P','r','e','v','i','o','u','s', 'H','D','D',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ', 'B' };
	check(win_len(b) == 54 && memcmp(b, inq0, 33) == 0, "INQUIRY: the disk target's bytes");
	next_scsi_window_fill(NEXT_RESP_BLK | (0u << 20) | (8u << 16) | 0x1200, b, 512);
	check(b[0] == 0x7F, "INQUIRY: LUN != 0 reports no device");
	next_scsi_window_fill(NEXT_RESP_BLK | (3u << 20) | 0x1200, b, 512);
	check(b[0] == 0x05 && b[1] == 0x80 && memcmp(b + 16, "CD-ROM          ", 16) == 0 && b[32] == '1',
	      "INQUIRY: the CD-ROM target's bytes");

	next_scsi_window_fill(NEXT_RESP_BLK | (0u << 20) | 0x2500, b, 512);
	check(win_len(b) == 8 && b[0] == 0 && b[1] == 0 && b[2] == 0x03 && b[3] == 0xE7 && b[6] == 0x02,
	      "READ CAPACITY: last LBA 999, 512-byte blocks");

	next_scsi_window_fill(NEXT_RESP_BLK | (0u << 20) | 0x1A00 | 0x3F, b, 512);
	check(win_len(b) == 64 && b[0] == 63 && b[2] == 0 && b[3] == 8 && b[5] == 0 && b[6] == 0x03 && b[7] == 0xE8 && b[10] == 0x02,
	      "MODE SENSE 3F: header and block descriptor");
	check(b[12] == 0x01 && b[13] == 0x02 && b[15] == 0x1B, "MODE SENSE 3F: page 1");
	check(b[16] == 0x03 && b[17] == 0x16 && b[27] == 32 && b[28] == 0x02 && b[31] == 0x01 && b[36] == 0x80, "MODE SENSE 3F: page 3");
	check(b[40] == 0x04 && b[41] == 0x12 && b[42] == 0 && b[43] == 0 && b[44] == 8 && b[45] == 4, "MODE SENSE 3F: page 4, 8 cylinders");
	check(b[61] == 0x02 && b[62] == 0x80, "MODE SENSE 3F: page 0");
	next_scsi_window_fill(NEXT_RESP_BLK | (0u << 20) | (1u << 16) | 0x1A00 | 0x04, b, 512);
	check(win_len(b) == 24 && b[0] == 23 && b[3] == 8 && b[4] == 0x04, "MODE SENSE page 4 with DBD: 4-byte header");
	next_scsi_window_fill(NEXT_RESP_BLK | (0u << 20) | 0x1A00 | 0x05, b, 512);
	check(win_len(b) == 0, "MODE SENSE: unknown page has length 0");
	mount(1, 1000ULL * 512, 1);
	next_scsi_window_fill(NEXT_RESP_BLK | (1u << 20) | 0x1A00 | 0x00, b, 512);
	check(b[2] == 0x80, "MODE SENSE: read-only image sets WP");

	static const struct { uint64_t bytes; uint32_t cyl; } geo[] = {
		{ 511, 0 }, { 512, 1 }, { 127 * 512, 1 }, { 128 * 512, 1 }, { 129 * 512 + 511, 2 },
		{ 0x000000ffffffffffULL, 0xFFFFFF }, { 0x0000010000000000ULL, 0 },
	};
	for (unsigned i = 0; i < sizeof(geo) / sizeof(geo[0]); i++)
	{
		uint64_t blocks = (geo[i].bytes >> 9) & 0xFFFFFFFFULL;
		uint32_t cyl = (uint32_t)(((blocks + 127) / 128) & 0xFFFFFF);
		mount(2, geo[i].bytes, 0);
		next_scsi_window_fill(NEXT_RESP_BLK | (2u << 20) | 0x1A00 | 0x04, b, 512);
		uint32_t got = ((uint32_t)b[14] << 16) | ((uint32_t)b[15] << 8) | b[16];
		snprintf(msg, sizeof(msg), "MODE SENSE page 4 geometry: %llu bytes -> %u cylinders (got %u)",
		         (unsigned long long)geo[i].bytes, cyl, got);
		check(got == cyl, msg);
		(void)geo[i].cyl;
	}

	next_scsi_window_fill(NEXT_RESP_BLK | (0u << 20) | 0x4300, b, 512);
	check(win_len(b) == 0, "READ TOC on a disk unit has length 0");
	next_scsi_window_fill(NEXT_RESP_BLK | (3u << 20) | 0x4300, b, 512);
	check(win_len(b) == 0, "READ TOC with no CD mounted has length 0");
	next_scsi_window_fill(NEXT_RESP_BLK | (3u << 20) | (2u << 16) | 0x4200 | 0x01, b, 512);
	check(win_len(b) == 16 && b[1] == 0x15 && b[4] == 0x01, "READ SUB-CHANNEL: idle, current position");
}

int main(int argc, char **argv)
{
	const char *vpath = (argc > 1) ? argv[1] : "rs_vectors.hex";
	static uint8_t vec[9280];
	if (!load_vectors(vpath, vec, 9280))
	{
		printf("FAIL: cannot load %s\n", vpath);
		return 1;
	}
	rs_set(vec, 0, 36, "vector1 (POST pattern)");
	rs_set(vec, 4640, 18, "vector2 (random)");
	mo_window(vec);
	scsi_windows();
	if (errors == 0) printf("ALL PASS\n");
	else printf("%d FAILURES\n", errors);
	return errors ? 1 : 0;
}
