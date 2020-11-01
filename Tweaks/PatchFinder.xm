#import "../Headers/PatchFinder.h"
#import "../Headers/MemHooks.h"
#import "../Headers/AeonLucid.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <mach-o/loader.h>
#include <mach-o/nlist.h>

@interface LSApplicationProxy
+(LSApplicationProxy *)applicationProxyForIdentifier:(NSString *)bundleId;
-(NSURL *)bundleURL;
@end

void (*orig_kabank)(void);
void kabank_ret(void) {}

/* Get the next load command from the current one */
#define NEXTCMD(cmd) ({ \
	__typeof__(cmd) _cmd = (cmd); \
	(struct load_command*)((char*)_cmd + _cmd->cmdsize); \
})

/* Iterate through all load commands */
#define ITERCMDS(i, cmd, cmds, ncmds) \
for(i = 0, cmd = (cmds); i < (ncmds); i++, cmd = NEXTCMD(cmd))


static int print_symbols(void* map, size_t filesize) {
	bool is64bit = false;
	uint32_t i, ncmds;
	struct load_command* cmd, *cmds;
	struct mach_header* mh = (struct mach_header*)map;

	/* Parse mach_header to get the first load command and the number of commands */
	if(mh->magic != MH_MAGIC) {
		if(mh->magic == MH_MAGIC_64) {
			is64bit = true;
			struct mach_header_64* mh64 = (struct mach_header_64*)mh;
			cmds = (struct load_command*)&mh64[1];
			ncmds = mh64->ncmds;
		}
		else {
			fprintf(stderr, "Invalid magic number: %08X\n", mh->magic);
			return -1;
		}
	}
	else {
		cmds = (struct load_command*)&mh[1];
		ncmds = mh->ncmds;
	}

	/* Keep track of the symtab if found. */
	struct symtab_command* symtab_cmd = NULL;

	/* Iterate through the Mach-O's load commands */
	ITERCMDS(i, cmd, cmds, ncmds) {
		/* Make sure we don't loop infinitely */
		if(cmd->cmdsize == 0) {
			fprintf(stderr, "Load command too small!\n");
			return -1;
		}

		/* Make sure the load command is completely contained in the file */
		if((uintptr_t)cmd + cmd->cmdsize - (uintptr_t)mh > filesize) {
			fprintf(stderr, "Load command truncated!\n");
			return -1;
		}

		/* Process the load command */
		if(cmd->cmd == LC_SYMTAB) {
			symtab_cmd = (struct symtab_command*)cmd;
			break;
		}
	}

	const char* strtab = (const char*)map + symtab_cmd->stroff;
	if(is64bit) {
		struct nlist_64* symtab = (struct nlist_64*)((char*)map + symtab_cmd->symoff);

		/* Print all symbols */
		for(i = 0; i < symtab_cmd->nsyms; i++) {
			struct nlist_64* nl = &symtab[i];

			/* Skip debug symbols */
			if(nl->n_type & N_STAB) {
				continue;
			}

			/* Get name of symbol type */
			const char* type = NULL;
			switch(nl->n_type & N_TYPE) {
				case N_UNDF: type = "N_UNDF"; break;
				case N_ABS:  type = "N_ABS"; break;
				case N_SECT: type = "N_SECT"; break;
				case N_PBUD: type = "N_PBUD"; break;
				case N_INDR: type = "N_INDR"; break;

				default:
					fprintf(stderr, "Invalid symbol type: 0x%x\n", nl->n_type & N_TYPE);
					return -1;
			}

			const char* symname = &strtab[nl->n_un.n_strx];
      NSString *symname2 = [NSString stringWithUTF8String:symname];
      if(strcmp(type, "N_SECT") == 0
			&& ![symname2 hasPrefix:@"_OBJC"]
			&& ![symname2 hasPrefix:@"_symbolic"]
			&& ![symname2 hasPrefix:@"_AFQueryString"]
			&& ![symname2 hasPrefix:@"_kabang"]
			&& ![symname2 hasPrefix:@"__"]
			&& [symname2 hasPrefix:@"_"]
			&& [symname2 length] == 34)
      {
        NSLog(@"[FlyJB] Symbol \"%s\" type: %s value: 0x%llx\n", symname, type, nl->n_value);
        MSHookFunction(MSFindSymbol(NULL, symname), (void *)kabank_ret, (void **)&orig_kabank);
      }
		}
	}
	else {
		struct nlist* symtab = (struct nlist*)((char*)map + symtab_cmd->symoff);

		/* Print all symbols */
		for(i = 0; i < symtab_cmd->nsyms; i++) {
			struct nlist* nl = &symtab[i];

			/* Skip debug symbols */
			if(nl->n_type & N_STAB) {
				continue;
			}

			/* Thumb functions start at addr + 1 (kind of) */
			uint32_t value = nl->n_value;
			if((nl->n_type & N_TYPE) == N_SECT && nl->n_desc == N_ARM_THUMB_DEF) {
				value |= 1;
			}

			/* Get name of symbol type */
			const char* type = NULL;
			switch(nl->n_type & N_TYPE) {
				case N_UNDF: type = "N_UNDF"; break;
				case N_ABS:  type = "N_ABS"; break;
				case N_SECT: type = "N_SECT"; break;
				case N_PBUD: type = "N_PBUD"; break;
				case N_INDR: type = "N_INDR"; break;

				default:
					fprintf(stderr, "Invalid symbol type: 0x%x\n", nl->n_type & N_TYPE);
					return -1;
			}

      const char* symname = &strtab[nl->n_un.n_strx];
      NSString *symname2 = [NSString stringWithUTF8String:symname];
			if(strcmp(type, "N_SECT") == 0
			&& ![symname2 hasPrefix:@"_OBJC"]
			&& ![symname2 hasPrefix:@"_symbolic"]
			&& ![symname2 hasPrefix:@"_AFQueryString"]
			&& ![symname2 hasPrefix:@"_kabang"]
			&& ![symname2 hasPrefix:@"__"]
			&& [symname2 hasPrefix:@"_"]
			&& [symname2 length] == 34)
			{
        NSLog(@"[FlyJB] Symbol \"%s\" type: %s value: 0x%x\n", symname, type, nl->n_value);
        MSHookFunction(MSFindSymbol(NULL, symname), (void *)kabank_ret, (void **)&orig_kabank);
      }
		}
	}

	return 0;
}


int kakaoBankPatch() {
	/* Get an open file descriptor for mmap */
  const char* kabankLibPath = [[[[[LSApplicationProxy applicationProxyForIdentifier:@"com.kakaobank.channel"] bundleURL] path] stringByAppendingPathComponent:@"Frameworks/kakaobank_library.framework/kakaobank_library"] UTF8String];

	int fd = open(kabankLibPath, O_RDONLY);
	if(fd == -1) {
		perror(kabankLibPath);
		return -1;
	}

	/* Get filesize for mmap */
	size_t filesize = lseek(fd, 0, SEEK_END);
	lseek(fd, 0, SEEK_SET);

	/* Map the file */
	void* map = mmap(NULL, filesize, PROT_READ, MAP_PRIVATE, fd, 0);
	if(map == MAP_FAILED) {
		perror("mmap");
		close(fd);
		return -1;
	}

	/* Attempt to print the names of all symbols */
	int ret = print_symbols(map, filesize);

	/* Clean up */
	munmap(map, filesize);
	close(fd);
	return ret;
}

void loadlxShieldMemHooks() {
#if defined __arm64__ || defined __arm64e__
	const uint8_t target[] = {
		0xFD, 0x83, 0x01, 0x91,
		0xFF, 0x03, 0x15, 0xD1,
		0xA8, 0x43, 0x08, 0xD1
	};
	scan_executable_memory(target, sizeof(target), &startHookTarget_lxShield);
#endif
}

void loadAhnLabMemHooks() {
#if defined __arm64__ || defined __arm64e__
	const uint8_t target[] = {
		0x1F, 0x20, 0x03, 0xD5,
		0x68, 0x8F, 0xFA, 0x18,
		0x09, 0x0A, 0x80, 0x52
	};
	scan_executable_memory(target, sizeof(target), &startHookTarget_AhnLab);

	const uint8_t target2[] = {
		0x1F, 0x20, 0x03, 0xD5,
		0x4A, 0x15, 0x00, 0x18,
		0x5F, 0x01, 0x09, 0x6B
	};
	scan_executable_memory(target2, sizeof(target2), &startHookTarget_AhnLab2);

	const uint8_t target3[] = {
		0xFD, 0x43, 0x00, 0x91,
		0x13, 0x0A, 0x80, 0x52,
		0x13, 0x00, 0xAB, 0x72
	};
	scan_executable_memory(target3, sizeof(target3), &startHookTarget_AhnLab3);

	const uint8_t target4[] = {
		0xFD, 0xC3, 0x00, 0x91,
		0xF3, 0x03, 0x02, 0xAA,
		0xF4, 0x03, 0x01, 0xAA,
		0x1F, 0x20, 0x03, 0xD5
	};
	scan_executable_memory(target4, sizeof(target4), &startHookTarget_AhnLab4);
#endif
}
