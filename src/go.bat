IF "%PROCESSOR_ARCHITEW6432%"=="" GOTO native
%SystemRoot%\Sysnative\cmd.exe /c %0 %*
exit
:native
SET PATH=%PATH%;%~dp0;%~dp0phantomjs-2.1.1-windows\bin;%~dp0n1k0-casperjs-54a7a05\bin;%~dp0apache-ant-1.9.6\bin;%~dp0ansicon\x64;
ansicon -p
