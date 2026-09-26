// Implementations behind the shim headers: stdio-backed file access,
// no-op SPI, the NeXT core name, no CHD.

#include <string.h>
#include "file_io.h"
#include "user_io.h"
#include "spi.h"
#include "hardware.h"
#include "support/chd/mister_chd.h"

int FileOpen(fileTYPE *f, const char *name, int)
{
	f->fp = fopen(name, "rb");
	if (!f->fp) { f->size = 0; return 0; }
	fseeko(f->fp, 0, SEEK_END);
	f->size = (int64_t)ftello(f->fp);
	fseeko(f->fp, 0, SEEK_SET);
	strncpy(f->name, name, sizeof(f->name) - 1);
	f->name[sizeof(f->name) - 1] = 0;
	return 1;
}

int FileSeek(fileTYPE *f, int64_t offset, int origin)
{
	if (!f->fp) return 0;
	return fseeko(f->fp, (off_t)offset, origin) == 0;
}

int FileReadAdv(fileTYPE *f, void *buf, int length, int failres)
{
	if (!f->fp) return failres;
	size_t n = fread(buf, 1, (size_t)length, f->fp);
	return (int)n;
}

void FileClose(fileTYPE *f)
{
	if (f->fp) fclose(f->fp);
	f->fp = nullptr;
	f->size = 0;
}

char is_next() { return 1; }
int  user_io_get_width() { return 0; }

void     EnableIO() {}
void     DisableIO() {}
uint16_t spi_w(uint16_t) { return 0; }
void     spi_block_read(uint8_t *, int, int) {}
void     spi_block_write(const uint8_t *, int, int) {}

void diskled_on() {}

chd_error mister_chd_read_sector(chd_file *, int, uint32_t, uint32_t, int, uint8_t *, uint8_t *, int *) { return 1; }
chd_error mister_load_chd(const char *, toc_t *) { return 1; }
void      chd_close(chd_file *) {}
