File map for the TDaemon demos - what is what?
==============================================
Using the Lazarus IDE GUI to Initialize the TDaemon and TDaemonMapper
---------------------------------------------------------------------
TestDaemon.*				Project Source files for the Daemon
DaemonUnit1.*				The main unit containing the TThread descendant controlling the daemon
DaemonMapperUnit1.*			The TDaemonMapper descendant holding all the daemon settings

Using pure Pascal code to initialize the TDaemon and TDaemonMapper
------------------------------------------------------------------
TestDaemonCodeOnly.*		Project Source files for the Daemon

Used by both projects
---------------------
FileLoggerUnit				A thread safe log to file unit
DaemonWorkerThread			A TThread implementation providing the actual "worker" code of the daemon
DaemonSystemdInstallerUnit		Code providing -install and -uninstall support for Linux. Not required for Windows.
