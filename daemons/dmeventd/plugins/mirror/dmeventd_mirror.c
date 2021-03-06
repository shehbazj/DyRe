/*
 * Copyright (C) 2005-2015 Red Hat, Inc. All rights reserved.
 *
 * This file is part of LVM2.
 *
 * This copyrighted material is made available to anyone wishing to use,
 * modify, copy, or redistribute it subject to the terms and conditions
 * of the GNU Lesser General Public License v.2.1.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include "lib.h"
#include "libdevmapper-event.h"
#include "dmeventd_lvm.h"
#include "defaults.h"

/* FIXME Reformat to 80 char lines. */

#define ME_IGNORE    0
#define ME_INSYNC    1
#define ME_FAILURE   2

struct dso_state {
	struct dm_pool *mem;
	char cmd_lvscan[512];
	char cmd_lvconvert[512];
};

DM_EVENT_LOG_FN("mirr")

static int _process_status_code(const char status_code, const char *dev_name,
				const char *dev_type, int r)
{
	/*
	 *    A => Alive - No failures
	 *    D => Dead - A write failure occurred leaving mirror out-of-sync
	 *    F => Flush failed.
	 *    S => Sync - A sychronization failure occurred, mirror out-of-sync
	 *    R => Read - A read failure occurred, mirror data unaffected
	 *    U => Unclassified failure (bug)
	 */ 
	if (status_code == 'F') {
		log_error("%s device %s flush failed.", dev_type, dev_name);
		r = ME_FAILURE;
	} else if (status_code == 'S')
		log_error("%s device %s sync failed.", dev_type, dev_name);
	else if (status_code == 'R')
		log_error("%s device %s read failed.", dev_type, dev_name);
	else if (status_code != 'A') {
		log_error("%s device %s has failed (%c).",
			  dev_type, dev_name, status_code);
		r = ME_FAILURE;
	}

	return r;
}

static int _get_mirror_event(char *params)
{
	int i, r = ME_INSYNC;
	char **args = NULL;
	char *dev_status_str;
	char *log_status_str;
	char *sync_str;
	char *p = NULL;
	int log_argc, num_devs;

	/*
	 * dm core parms:	     0 409600 mirror
	 * Mirror core parms:	     2 253:4 253:5 400/400
	 * New-style failure params: 1 AA
	 * New-style log params:     3 cluster 253:3 A
	 *			 or  3 disk 253:3 A
	 *			 or  1 core
	 */

	/* number of devices */
	if (!dm_split_words(params, 1, 0, &p))
		goto out_parse;

	if (!(num_devs = atoi(p)) ||
	    (num_devs > DEFAULT_MIRROR_MAX_IMAGES) || (num_devs < 0))
		goto out_parse;
	p += strlen(p) + 1;

	/* devices names + "400/400" + "1 AA" + 1 or 3 log parms + NULL */
	args = dm_malloc((num_devs + 7) * sizeof(char *));
	if (!args || dm_split_words(p, num_devs + 7, 0, args) < num_devs + 5)
		goto out_parse;

	/* FIXME: Code differs from lib/mirror/mirrored.c */
	dev_status_str = args[2 + num_devs];
	log_argc = atoi(args[3 + num_devs]);
	log_status_str = args[3 + num_devs + log_argc];
	sync_str = args[num_devs];

	/* Check for bad mirror devices */
	for (i = 0; i < num_devs; i++)
		r = _process_status_code(dev_status_str[i], args[i],
			i ? "Secondary mirror" : "Primary mirror", r);

	/* Check for bad disk log device */
	if (log_argc > 1)
		r = _process_status_code(log_status_str[0],
					 args[2 + num_devs + log_argc],
					 "Log", r);

	if (r == ME_FAILURE)
		goto out;

	p = strstr(sync_str, "/");
	if (p) {
		p[0] = '\0';
		if (strcmp(sync_str, p+1))
			r = ME_IGNORE;
		p[0] = '/';
	} else
		goto out_parse;

out:
	dm_free(args);
	return r;

out_parse:
	dm_free(args);
	log_error("Unable to parse mirror status string.");

	return ME_IGNORE;
}

static int _remove_failed_devices(const char *cmd_lvscan, const char *cmd_lvconvert)
{
	int r;

	if (!dmeventd_lvm2_run_with_lock(cmd_lvscan))
		log_info("Re-scan of mirrored device failed.");

	/* if repair goes OK, report success even if lvscan has failed */
	r = dmeventd_lvm2_run_with_lock(cmd_lvconvert);

	log_info("Repair of mirrored device %s.",
		 (r) ? "finished successfully" : "failed");

	return r;
}

void process_event(struct dm_task *dmt,
		   enum dm_event_mask event __attribute__((unused)),
		   void **user)
{
	struct dso_state *state = *user;
	void *next = NULL;
	uint64_t start, length;
	char *target_type = NULL;
	char *params;
	const char *device = dm_task_get_name(dmt);

	do {
		next = dm_get_next_target(dmt, next, &start, &length,
					  &target_type, &params);

		if (!target_type) {
			log_info("%s mapping lost.", device);
			continue;
		}

		if (strcmp(target_type, "mirror")) {
			log_info("%s has unmirrored portion.", device);
			continue;
		}

		switch(_get_mirror_event(params)) {
		case ME_INSYNC:
			/* FIXME: all we really know is that this
			   _part_ of the device is in sync
			   Also, this is not an error
			*/
			log_notice("%s is now in-sync.", device);
			break;
		case ME_FAILURE:
			log_error("Device failure in %s.", device);
			if (!_remove_failed_devices(state->cmd_lvscan,
						    state->cmd_lvconvert))
				/* FIXME Why are all the error return codes unused? Get rid of them? */
				log_error("Failed to remove faulty devices in %s.",
					  device);
			/* Should check before warning user that device is now linear
			else
				log_notice("%s is now a linear device.",
					   device);
			*/
			break;
		case ME_IGNORE:
			break;
		default:
			/* FIXME Provide value then! */
			log_info("Unknown event received.");
		}
	} while (next);
}

int register_device(const char *device,
		    const char *uuid __attribute__((unused)),
		    int major __attribute__((unused)),
		    int minor __attribute__((unused)),
		    void **user)
{
	struct dso_state *state;

	if (!dmeventd_lvm2_init_with_pool("mirror_state", state))
		goto_bad;

	if (!dmeventd_lvm2_command(state->mem, state->cmd_lvscan, sizeof(state->cmd_lvscan),
				   "lvscan --cache", device)) {
		dmeventd_lvm2_exit_with_pool(state);
		goto_bad;
	}

	if (!dmeventd_lvm2_command(state->mem, state->cmd_lvconvert, sizeof(state->cmd_lvconvert),
				   "lvconvert --repair --use-policies", device)) {
		dmeventd_lvm2_exit_with_pool(state);
		goto_bad;
	}

	*user = state;

	log_info("Monitoring mirror device %s for events.", device);

	return 1;
bad:
	log_error("Failed to monitor mirror %s.", device);

	return 0;
}

int unregister_device(const char *device,
		      const char *uuid __attribute__((unused)),
		      int major __attribute__((unused)),
		      int minor __attribute__((unused)),
		      void **user)
{
	struct dso_state *state = *user;

	dmeventd_lvm2_exit_with_pool(state);
	log_info("No longer monitoring mirror device %s for events.",
		 device);

	return 1;
}
