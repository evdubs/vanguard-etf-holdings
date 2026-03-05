# vanguard-etf-holdings
These Racket programs will download the Vanguard ETF holdings and insert the data into a PostgreSQL database. 
The intended usage is:

```bash
$ racket extract.rkt
$ racket transform-load.rkt
```

You will need to provide a database password for the `transform-load.rkt` program. The available parameters are:

```bash
$ racket transform-load.rkt -h
racket transform-load.rkt [ <option> ... ]
 where <option> is one of
  -b <folder>, --base-folder <folder> : Vanguard ETF Holdings base folder. Defaults to /var/local/vanguard/etf-holdings
  -d <date>, --folder-date <date> : Vanguard ETF Holdings folder date. Defaults to today
  -n <name>, --db-name <name> : Database name. Defaults to 'local'
  -p <password>, --db-pass <password> : Database password
  -u <user>, --db-user <user> : Database user name. Defaults to 'user'
  --help, -h : Show this help
  -- : Do not treat any remaining argument as a switch (at this level)
 Multiple single-letter switches can be combined after one `-`. For
  example: `-h-` is the same as `-h --`
```

This process assumes you can write to a `/var/local/vanguard` folder. This process also assumes you have loaded your database with NASDAQ symbol
file information. This data is provided by the [nasdaq-symbols](https://github.com/evdubs/nasdaq-symbols) project.

### Dependencies

It is recommended that you start with the standard Racket distribution. With that, you will need to install the following packages:

```bash
$ raco pkg install --skip-installed gregor http-easy tasks threading
```
