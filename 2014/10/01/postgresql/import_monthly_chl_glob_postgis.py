from subprocess import call
from os.path import join
import os

dataRoot = "/Users/denis/Dropbox/data/chl_seawifs_8days_9km"
lfiles = listdir(dataRoot)



for year in 2000:2014
	dataDir = join(dataRoot, str(year), 'MONTHLY')
	lfiles = os.listdir(dataDir)
	for f in lfiles:
		if '.gz' in f:
			filename = join(dataDir, f)
			call(['gzip', '-d', filename])

	call('raster2pgsql -I -C -a -F -s 4326 -b 1 *.nc chl.GLOB_25_MO | psql -d dd -U postgres', shell=True)
	lfiles = os.listdir(dataDir)
	for f in lfiles:
		if '.nc' in f:
			filename = join(dataDir, f)
			call(['raster2pgsql', '-I', '-C', '-a', '-F', '-s 4326' '-b 1', filename, 'chl.GLOB_25_MO |',  'psql -d dd -U postgres'], shell=True)

