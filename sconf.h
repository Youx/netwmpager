/* 
 * Copyright 2004-2005 Timo Hirvonen
 */

#ifndef _SCONF_H
#define _SCONF_H

void sconf_load(void);
void sconf_free(void);

/* these return 1 on success, 0 on error (not found, type mismatch) */
int sconf_get_str_option(const char *name, char **value);
int sconf_get_int_option(const char *name, int *value);
int sconf_get_flt_option(const char *name, double *value);
int sconf_get_bool_option(const char *name, int *value);

#endif
