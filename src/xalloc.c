/*
 * Copyright (C) 2007  Moritz Grimm <mgrimm@mrsserver.net>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

#include "compat.h"

#include <stdlib.h>
#include <string.h>

#include "log.h"
#include "xalloc.h"

void *
xmalloc_c(size_t size, const char *file, unsigned int line)
{
	void	*ret = malloc(size);

	if (NULL == ret) {
		log_alert("%s[%u]: cannot allocate %zu bytes",
		    file, line, size);
		exit(1);
	}

	return (ret);
}

void *
xcalloc_c(size_t nmemb, size_t size, const char *file, unsigned int line)
{
	void	*ret = calloc(nmemb, size);

	if (NULL == ret) {
		log_alert("%s[%u]: cannot allocate %zu * %zu bytes",
		    file, line, nmemb, size);
		exit(1);
	}

	return (ret);
}

void *
xreallocarray_c(void *ptr, size_t nmemb, size_t size, const char *file,
    unsigned int line)
{
	void	*ret = reallocarray(ptr, nmemb, size);

	if (NULL == ret) {
		log_alert("%s[%u]: cannot allocate %zu * %zu bytes",
		    file, line, nmemb, size);
		exit(1);
	}

	return (ret);
}

char *
xstrdup_c(const char *str, const char *file, unsigned int line)
{
	char	*ret = strdup(str);

	if (NULL == ret) {
		log_alert("%s[%u]: cannot allocate %zu bytes",
		    file, line, strlen(str) + 1);
		exit(1);
	}

	return (ret);
}

void
xfree_c(void *ptr, const char *file, unsigned int line)
{
	(void)file;
	(void)line;
	free(ptr);
}
