IF "%PROCESSOR_ARCHITEW6432%"=="" GOTO native
%SystemRoot%\Sysnative\cmd.exe /c %0 %*
exit
:native

set JAVA_HOME=%~dp0jdk1.8.0_172_x64
SET PATH=%PATH%;%~dp0;%~dp0phantomjs-2.1.1-windows\bin;%~dp0casperjs-1.1.4-1\bin;%~dp0apache-ant-1.10.4\bin;%~dp0ansicon184\x64;%~dp0calibre-portable_3.46\Calibre;
ansicon -p
SET CLASSPATH=%CLASSPATH%;.;%~dp0SaxonHE9-8-0-12J\saxon9he.jar;

ant
pause
