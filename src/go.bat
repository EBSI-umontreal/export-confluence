IF "%PROCESSOR_ARCHITEW6432%"=="" GOTO native
%SystemRoot%\Sysnative\cmd.exe /c %0 %*
exit
:native

set JAVA_HOME=%~dp0vendor\jdk-25.0.3+9
SET PATH=%PATH%;%~dp0;%~dp0vendor\phantomjs-2.1.1-windows\bin;%~dp0vendor\casperjs-1.1.4-1\bin;%~dp0vendor\apache-ant-1.10.17\bin;%~dp0vendor\ansicon189\x64;%~dp0vendor\calibre-portable-8.00\Calibre;
ansicon -p
SET CLASSPATH=%CLASSPATH%;.;%~dp0vendor\SaxonHE9-8-0-12J\saxon9he.jar;

ant
pause
