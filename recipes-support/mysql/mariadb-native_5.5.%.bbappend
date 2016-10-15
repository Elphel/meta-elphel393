SRC_URI = "http://downloads.mariadb.com/MariaDB/mariadb-${PV}/source/mariadb-${PV}.tar.gz \
           file://fix-cmake-module-path.patch \
           file://remove-bad-path.patch \
           file://fix-mysqlclient-r-version.patch \
           file://my.cnf \
           file://mysqld.service \
           file://install_db.service \
           file://install_db \
           file://mysql-systemd-start \
           file://configure.cmake-fix-valgrind.patch \
           file://fix-a-building-failure.patch \
          "
          