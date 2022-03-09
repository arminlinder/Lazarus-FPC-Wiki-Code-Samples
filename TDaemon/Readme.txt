These is the source code for the "Daemons and Services" tutorials located at https://wiki.lazarus.freepascal.org/Daemons_and_Services

Common: files used by all projects
----------------------------------
FileLoggerUnit				A thread safe log to file unit
DaemonWorkerThread			A TThread implementation providing the actual "worker" code of the daemon
DaemonSystemdInstallerUnit		Code providing -install and -uninstall support for Linux. Not required for Windows.

Project: TestDaemon
Using the Lazarus IDE GUI to Initialize the TDaemon and TDaemonMapper
-------------------------------------------------------------------------------------------
TestDaemon.*				Project Source files for the Daemon
DaemonUnit1.*				The main unit containing the TThread descendant controlling the daemon
DaemonMapperUnit1.*			The TDaemonMapper descendant holding all the daemon settings

Project: TestDaemonCodeOnly
Using pure Pascal code to initialize the TDaemon and TDaemonMapper
------------------------------------------------------------------
TestDaemonCodeOnly.*		Project Source files for the Daemon

